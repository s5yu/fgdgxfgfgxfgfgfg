/////////////////////
// D3D12 HOOK ImGui//
/////////////////////

#include "main.h"
#include "hook.h"
#include "w2s.h"
int countnum = -1;
bool nopants_enabled = true;

//=========================================================================================================================//

typedef HRESULT(APIENTRY* Present12) (IDXGISwapChain* pSwapChain, UINT SyncInterval, UINT Flags);
Present12 oPresent = NULL;

typedef void(APIENTRY* DrawInstanced)(ID3D12GraphicsCommandList* dCommandList, UINT VertexCountPerInstance, UINT InstanceCount, UINT StartVertexLocation, UINT StartInstanceLocation);
DrawInstanced oDrawInstanced = NULL;

typedef void(APIENTRY* DrawIndexedInstanced)(ID3D12GraphicsCommandList* dCommandList, UINT IndexCountPerInstance, UINT InstanceCount, UINT StartIndexLocation, INT BaseVertexLocation, UINT StartInstanceLocation);
DrawIndexedInstanced oDrawIndexedInstanced = NULL;

typedef void(APIENTRY* ExecuteCommandLists)(ID3D12CommandQueue* queue, UINT NumCommandLists, ID3D12CommandList* ppCommandLists);
ExecuteCommandLists oExecuteCommandLists = NULL;

//=========================================================================================================================//

bool ShowMenu = false;
bool ImGui_Initialised = false;

namespace Process {
	DWORD ID;
	HANDLE Handle;
	HWND Hwnd;
	HMODULE Module;
	WNDPROC WndProc;
	int WindowWidth;
	int WindowHeight;
	LPCSTR Title;
	LPCSTR ClassName;
	LPCSTR Path;
}
ImU32 RGBtoU32(int r, int g, int b)
{
	float fr = (float)r / 255.0;
	float fg = (float)g / 255.0;
	float fb = (float)b / 255.0;
	return ImGui::GetColorU32(ImVec4(fr, fg, fb, 1));
}
auto RGB = 0;
namespace DirectX12Interface {
	ID3D12Device* Device = nullptr;
	ID3D12DescriptorHeap* DescriptorHeapBackBuffers;
	ID3D12DescriptorHeap* DescriptorHeapImGuiRender;
	ID3D12GraphicsCommandList* CommandList;
	ID3D12CommandQueue* CommandQueue;

	struct _FrameContext {
		ID3D12CommandAllocator* CommandAllocator;
		ID3D12Resource* Resource;
		D3D12_CPU_DESCRIPTOR_HANDLE DescriptorHandle;
	};

	uintx_t BuffersCounts = -1;
	_FrameContext* FrameContext;
}

//=========================================================================================================================//

extern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);
LRESULT APIENTRY WndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
	if (ShowMenu) {
		ImGui_ImplWin32_WndProcHandler(hwnd, uMsg, wParam, lParam);
		return true;
	}
	return CallWindowProc(Process::WndProc, hwnd, uMsg, wParam, lParam);
}

//=========================================================================================================================//

void setupmanagers()
{

	game::roundstate = RoundState::GetRoundState();
	printf("game::roundstate: %i \n", game::roundstate);

	auto gm12 = offsets::GetGameManager();
	printf("gamemangaer: %llx \n", gm12);
	auto outlinemesh = offsets::getoutlinemesh();
	printf("outlinemesh: %llx \n", outlinemesh);
}


uint64_t WeaponComponentPrimaryBase1 = offsets::client + 0x0BC2C150;
std::vector<uint64_t> WeaponComponentPrimaryChain1 = { 0xC0,0x48,0x8,0x8,0x30,0x18,0x0 };

uint64_t unlockable12 = 0;



bool GetModuleInfoHM(HMODULE hMod, uintptr_t& base, size_t& size)
{
	if (!hMod) return false;

	MODULEINFO info = { 0 };
	if (!GetModuleInformation(GetCurrentProcess(), hMod, &info, sizeof(info)))
		return false;

	base = (uintptr_t)info.lpBaseOfDll;
	size = (size_t)info.SizeOfImage;
	return true;
}

//-----------------------------------------------------
// 2) Stringsuche in [start..start+size)
//-----------------------------------------------------
uintptr_t FindStringInMemory(const char* what, uintptr_t start, size_t size)
{
	const size_t len = std::strlen(what);
	for (size_t i = 0; i + len <= size; i++)
	{
		if (std::memcmp((void*)(start + i), what, len) == 0)
			return start + i;
	}
	return 0;
}

//-----------------------------------------------------
// 3) Bestimme Funktionsstart via RUNTIME_FUNCTION
//-----------------------------------------------------
uintptr_t GetFunctionStartFromRuntimeInfo(uintptr_t controlPc)
{
	DWORD64 imageBase = 0;
	auto runtimeFunc = RtlLookupFunctionEntry((DWORD64)controlPc, &imageBase, NULL);
	if (!runtimeFunc)
	{
		// Keine Info -> 0
		return 0;
	}
	// runtimeFunc->BeginAddress => RVA relativ zu imageBase
	uintptr_t fnStart = (uintptr_t)(imageBase + runtimeFunc->BeginAddress);
	return fnStart;
}

//-----------------------------------------------------
// 4) Suche "HttpClientImpl::sendImpl", finde LEA und
//    bestimme Funktionsstart, danach return (Funktionsstart - client13).
//-----------------------------------------------------
uintptr_t FindHttpClientImplSendImplOffset(uintptr_t client13Base)
{
	// (A) Modul-Basis (z.B. Haupt-EXE)
	HMODULE hMod = GetModuleHandle(NULL);
	if (!hMod)
	{
		printf("GetModuleHandle() fehlgeschlagen.\n");
		return 0;
	}

	uintptr_t base = 0;
	size_t size = 0;
	if (!GetModuleInfoHM(hMod, base, size))
	{
		printf("GetModuleInfoHM() fehlgeschlagen.\n");
		return 0;
	}

	// (B) String finden
	const char* targetString = "HttpClientImpl::sendImpl";
	uintptr_t stringAddr = FindStringInMemory(targetString, base, size);
	if (!stringAddr)
	{
		printf("String '%s' nicht gefunden.\n", targetString);
		return 0;
	}
	// printf("[+] String gefunden bei 0x%p\n", (void*)stringAddr);

	// (C) Nach LEA (48 8D ...) suchen, die auf stringAddr zeigt.
	uintptr_t scanStart = base;
	uintptr_t scanEnd = base + size;

	for (uintptr_t addr = scanStart; addr + 7 < scanEnd; addr++)
	{
		uint8_t* p = (uint8_t*)addr;
		// LEA-Pattern: 48 8D
		if (p[0] == 0x48 && p[1] == 0x8D)
		{
			int32_t disp = *(int32_t*)&p[3];  // displacement
			uintptr_t nextInstr = addr + 7;
			uintptr_t possibleTarget = nextInstr + disp;
			if (possibleTarget == stringAddr)
			{
				// (D) Hier die Instruktion, die auf den String verweist.
				// -> Bestimme Funktionsstart
				uintptr_t fnStart = GetFunctionStartFromRuntimeInfo(addr);
				if (fnStart == 0)
				{
					// Falls kein RUNTIME_FUNCTION => fallback
					fnStart = addr;
				}

				// (E) OFFSET = (Funktionsstart - client13Base)
				//     und returnen.
				uintptr_t offset = fnStart - client13Base;
				return offset;
			}
		}
	}

	printf("Keine LEA gefunden, die auf '%s' zeigt.\n", targetString);
	return 0;
}



static std::vector<int> PatternToIntVector(const char* Pattern)
{
	std::vector<int> PatternVector = std::vector<int>{};

	char* Start = const_cast<char*>(Pattern);
	char* End = const_cast<char*>(Pattern) + strlen(Pattern);

	for (char* Current = Start; Current < End; ++Current)
	{
		if (*Current == '?')
		{
			++Current;
			PatternVector.push_back(-69);
		}
		else
		{
			PatternVector.push_back(strtoul(Current, &Current, 16));
		}
	}

	return PatternVector;
}




template<typename T>
static T PatternScan(const char* Pattern, uintptr_t Start)
{
	const HMODULE GameModule = reinterpret_cast<HMODULE>(Start);
	const IMAGE_DOS_HEADER* DOSHeader = reinterpret_cast<IMAGE_DOS_HEADER*>(GameModule);
	const IMAGE_NT_HEADERS* NtHeaders = reinterpret_cast<IMAGE_NT_HEADERS*>(reinterpret_cast<uintptr_t>(GameModule) + DOSHeader->e_lfanew);
	const size_t Size = NtHeaders->OptionalHeader.SizeOfImage;

	std::vector<int> PatternVector = PatternToIntVector(Pattern);
	uint8_t* Search = reinterpret_cast<uint8_t*>(Start);
	const size_t SizeOfPattern = PatternVector.size();
	const int* PatternData = PatternVector.data();

	for (int i = 0; i < Size - SizeOfPattern; ++i)
	{
		bool FoundSignature = true;

		for (int j = 0; j < SizeOfPattern; ++j)
		{
			if (Search[i + j] != PatternData[j] && PatternData[j] != -69)
			{
				FoundSignature = false;
				break;
			}
		}

		if (FoundSignature)
		{

			return reinterpret_cast<T>(&Search[i]);
		}
	}

	return reinterpret_cast<T>(nullptr);
}


static uint64_t Getweapon_component()
{





	uint64_t weaponcomponent23 = Memory::GetAddr(WeaponComponentPrimaryBase1, WeaponComponentPrimaryChain1);
	if (!weaponcomponent23)
	{
		printf("couldnt get weaponcomp");
		return 0;
	}



	return weaponcomponent23;
}


typedef uint64_t(__fastcall* callreload)(uint64_t a1);
//auto callreloadfunction = (callreload)(offsets::client + 0xE49650);
//auto fn2 = *reinterpret_cast<uint64_t(*)(uint64_t, int)>(offsets::client + 0xF905B0);
//auto callreloadfunction = (callreload)(offsets::client + 0x7DCFE80);
auto callreloadfunction = (callreload)(offsets::client + 0x9CF2B00);

void reloadcall() {


	uint64_t weaponcomponent232 = Getweapon_component();
	if (!weaponcomponent232)
	{
		printf("couldnt get weaponcomp");
		return;
	}
		

	utils::spoof_call(callreloadfunction, weaponcomponent232);



}


namespace autoreload {

	typedef uint64_t(__fastcall* autoreload1)(uint64_t a1);
	typedef uint64_t(__fastcall* autoreload2)(uint64_t a1);
	typedef uint64_t(__fastcall* autoreload3)(uint64_t a1);

	auto callreload1 = (autoreload1)(offsets::client + 0x9D10520); // 77 0B 48 C7 86 ? ? ? ? ? ? ? ?  // // 24.9 499D490 // 57CC080
	auto callreload2 = (autoreload2)(offsets::client + 0x9D0A270); // 48 8B 3C C8 EB 02 31 FF 48 BB ? ? ? ? ? ? ? ? // CASE 2  24.09 0x4994D00

	bool ff = false;
	bool ffr = false;
	auto end = std::chrono::system_clock::now();

}


void leftclick() {
	auto current_time = std::chrono::system_clock::now();
	mouse_event(MOUSEEVENTF_LEFTDOWN, NULL, NULL, NULL, NULL);
	current_time + std::chrono::milliseconds(60);
	mouse_event(MOUSEEVENTF_LEFTUP, NULL, NULL, NULL, NULL);

}

bool spamreload = false;

void fullautoreload()
{

	


	uint64_t weaponcomponent23 = Getweapon_component();
	if (!weaponcomponent23)
	{

		return;
	}
	if (instantreload)
	{

				auto reloadgo = utils::spoof_call(autoreload::callreload1, weaponcomponent23);
				if (!reloadgo)
					return;
	}
	if (spamreload)
	{
		auto reloadgo1 = utils::spoof_call(autoreload::callreload2, weaponcomponent23);
		if (!reloadgo1)
			return;

	}


}

void Unlock()
{


	utils::memory::image_base = reinterpret_cast<std::uintptr_t>(GetModuleHandle((LPCSTR)"RainbowSix.exe"));
	if (!utils::memory::image_base)
	{

		return;
	}

	utils::memory::text_size = utils::importer::get_section_size(utils::memory::image_base, _x(".text"));
	utils::memory::rdata_size = utils::importer::get_section_size(utils::memory::image_base, _x(".rdata"));
	utils::memory::rdata_virtualaddress = utils::importer::get_virtual_address(utils::memory::image_base, _x(".rdata"));


	utils::trampoline_jmp = (void*)utils::memory::scan_pattern(utils::memory::image_base, utils::memory::text_size, _x("FF 27"));
	if (!utils::trampoline_jmp)
	{

		return;
	}
	unlockable12 = FindHttpClientImplSendImplOffset(offsets::client);
	if (unlockable12 != 0) {
		printf("(Funktionsstart - client13Base)\n", (unsigned long long)unlockable12);
	}
	hooks::init();


}



void mainbuild()
{


	utils::memory::image_base = reinterpret_cast<std::uintptr_t>(GetModuleHandle((LPCSTR)"RainbowSix.exe"));
	if (!utils::memory::image_base)
	{
		
		return;
	}

	utils::memory::text_size = utils::importer::get_section_size(utils::memory::image_base, _x(".text"));
	utils::memory::rdata_size = utils::importer::get_section_size(utils::memory::image_base, _x(".rdata"));
	utils::memory::rdata_virtualaddress = utils::importer::get_virtual_address(utils::memory::image_base, _x(".rdata"));


	utils::trampoline_jmp = (void*)utils::memory::scan_pattern(utils::memory::image_base, utils::memory::text_size, _x("FF 27"));
	if (!utils::trampoline_jmp)
	{
	
		return;
	}

	hooks::init();
	

}


uint64_t getlocalplayer()  
{
	typedef uint64_t(__fastcall* Localplayer0x)();
	auto Localplayer = (Localplayer0x)(offsets::client + 0x6426F30);
	auto localplayer1 = utils::spoof_call(Localplayer);
	return localplayer1; 
}





typedef uint64_t(__fastcall* team3443)(uint64_t a1, uint64_t a2);
auto team12 = (team3443)(offsets::client + 0x6429EA0);


auto outlinemesh = offsets::getoutlinemesh();

uint64_t BoneInfo(uint64_t actor) {
	if (!(actor)) { return { 0 }; }
	uint64_t ComponentList = Memory::Read<uint64_t>(actor + 0xD8);
	if (!(ComponentList)) { return { 0 }; }
	return Memory::Read<uintptr_t>(ComponentList + 8);
}

struct _BoneInfo
{
private:
	char pad1[0x18];//0x0
public:
	std::uint64_t EncryptedEntity;//0x18
private:
	char pad2[0x34];//each char pad is 0x2 bytes.   0x20
public:
	BipedBoneID BipedBoneID;//0x54
};

namespace SDK
{
	
	inline std::uint64_t(__fastcall* GetBonePosHASH)(_BoneInfo*, __m128*) = nullptr;

	

}

void InitializeFunctionPointers()
{
	//constexpr std::uint64_t BoneViaHeadHashOffset = 0x637C0B0;
	//SDK::BoneViaHash = reinterpret_cast<decltype(SDK::BoneViaHash)>(Memory::handle + BoneViaHeadHashOffset);

	constexpr std::uint64_t BoneViaHashOffset = 0xA261EF0;  // 0x59089E0  RainbowSix_dump20.06.exe  // ? ? 54 ? ? ? 50 ? ? ? 58 ? ? ? 03 
	// 48 8B 8C 24 ? ? ? ? 48 81 C2 ? ? ? ? E8  this is an xref to the function of the skeletons. 
	SDK::GetBonePosHASH = reinterpret_cast<decltype(SDK::GetBonePosHASH)>(offsets::client + BoneViaHashOffset);




}


Vector3 GetBoneByHash(uint64_t boneInfo, BipedBoneID hash)
{
	if (!(boneInfo))
		return Vector3();

	__m128 out;

	auto encrypted = *reinterpret_cast<std::uint64_t*>(boneInfo + 0x18);
	static _BoneInfo buffer;
	buffer.EncryptedEntity = encrypted;
	buffer.BipedBoneID = hash;

	utils::spoof_call(SDK::GetBonePosHASH, &buffer, &out);

	return { out.m128_f32[0], out.m128_f32[1], out.m128_f32[2] };
}


extern "C" NTSTATUS NtDirectProtectVirtualMemory(
	HANDLE ProcessHandle,
	PVOID* BaseAddress,
	PSIZE_T NumberOfBytesToProtect,
	ULONG NewAccessProtection,
	PULONG OldAccessProtection
);

static BOOL DirectProtectVirtualMemory(
	PVOID BaseAddress,
	SIZE_T NumberOfBytesToProtect,
	ULONG NewAccessProtection,
	PULONG OldAccessProtection
)
{
	return NtDirectProtectVirtualMemory(
		reinterpret_cast<HANDLE>(-1),
		&BaseAddress,
		&NumberOfBytesToProtect,
		NewAccessProtection,
		OldAccessProtection
	) == 0x0;
}

void setRdataValueToFloat2(float value)
{
	PVOID rdataAddress = reinterpret_cast<PVOID>(offsets::client + 0xAF1B248);
	SIZE_T rdataSize = sizeof(float);
	ULONG oldProtection;


	if (!DirectProtectVirtualMemory(rdataAddress, rdataSize, PAGE_READWRITE, &oldProtection)) {

		return;
	}


	*reinterpret_cast<float*>(rdataAddress) = value;


	DirectProtectVirtualMemory(rdataAddress, rdataSize, oldProtection, nullptr);
}













void Visualloop()
{

	auto overlay = ImGui::GetBackgroundDrawList();
	auto bg = ImGui::GetBackgroundDrawList();
	auto gm = offsets::GetGameManager();
	auto LocalPlayer = getlocalplayer();
	game::roundstate = RoundState::GetRoundState();
	auto [entity_list, entity_count] = offsets::GetEntityList(gm);
	if (!entity_list)
		return;
	for (size_t i = 0; i < entity_count; i++) {
		auto entity_ptr = reinterpret_cast<uintptr_t*>(entity_list + i * 8);
		auto entity = *entity_ptr;
		if (entity == LocalPlayer)
			continue;
		printf("LocalPlayer %llx \n", LocalPlayer);
		//printf("entity %llx \n", entity);
		auto GetPawn = offsets::GetPawn(entity);
		if (!GetPawn)
		{
			//printf("couldnt get GetPawn");
			continue;
		}
		//printf("GetPawn %llx \n", GetPawn);
		auto LGetPawn = offsets::GetPawn(LocalPlayer);
		if (!LGetPawn)
		{
			//printf("couldnt get GetPawn");
			continue;
		}
		auto actor = offsets::GetActor(GetPawn);
		if (!actor)
		{
			//printf("couldnt get actor");
			continue;
		}



		auto Lactor = offsets::GetActor(GetPawn);
		if (!Lactor)
		{
			//printf("couldnt get actor");
			continue;
		}


	
		
		//uintptr_t WeaponHolder = utils::spoof_call_virtual<uint64_t>(10, reinterpret_cast<void*>(tmp), 0x3A5A9ECD);
		//
		//if (!WeaponHolder)
		//	continue;
		//		printf("WeaponHolder %llx\n", WeaponHolder);

			
		


		auto Outlinecomponent = offsets::GetOutlineComponent(actor);
		if (!Outlinecomponent)
		{
			//printf("couldnt get Outlinecomponent");
			continue;
		}	
		
		const auto boneInfo = BoneInfo(actor);
		if (!boneInfo)
			continue;

		
		uint64_t weaponcomponent232 = Getweapon_component();
		if (!weaponcomponent232)
			continue;
		printf("weaponcomponent232 %llx \n", weaponcomponent232);
		if (skeleton) {
			// Struktur zur Definition einer Knochenverbindung
			struct BoneConnection {
				BipedBoneID start;
				BipedBoneID end;
			};

			// Array mit den Verbindungen f�r das Skelett
			BoneConnection connections[] = {
				// Rumpf und Kopf
				{BipedBoneID::PELVIS,  BipedBoneID::STOMACH},
				{BipedBoneID::STOMACH, BipedBoneID::LUMBAR},
				{BipedBoneID::LUMBAR,  BipedBoneID::THORAX},
				{BipedBoneID::THORAX,  BipedBoneID::NECK},
				{BipedBoneID::NECK,    BipedBoneID::HEAD},
				// Linker Arm
				{BipedBoneID::THORAX,     BipedBoneID::LCLAVICLE},
				{BipedBoneID::LCLAVICLE,  BipedBoneID::LSHOULDER},
				{BipedBoneID::LSHOULDER,  BipedBoneID::LELBOW},
				{BipedBoneID::LELBOW,     BipedBoneID::LHAND},
				// Rechter Arm
				{BipedBoneID::THORAX,     BipedBoneID::RCLAVICLE},
				{BipedBoneID::RCLAVICLE,  BipedBoneID::RSHOULDER},
				{BipedBoneID::RSHOULDER,  BipedBoneID::RELBOW},
				{BipedBoneID::RELBOW,     BipedBoneID::RHAND},
				// Linkes Bein
				{BipedBoneID::PELVIS, BipedBoneID::LHIP},
				{BipedBoneID::LHIP,   BipedBoneID::LKNEE},
				{BipedBoneID::LKNEE,  BipedBoneID::LFOOT},
				{BipedBoneID::LFOOT,  BipedBoneID::LTOE},
				// Rechtes Bein
				{BipedBoneID::PELVIS, BipedBoneID::RHIP},
				{BipedBoneID::RHIP,   BipedBoneID::RKNEE},
				{BipedBoneID::RKNEE,  BipedBoneID::RFOOT},
				{BipedBoneID::RFOOT,  BipedBoneID::RTOE},
			};

			// �ber alle definierten Knochenverbindungen iterieren
			for (auto& conn : connections) {
				// Knochenpositionen abrufen
				Vector3 pos1 = GetBoneByHash(boneInfo, conn.start);
				Vector3 pos2 = GetBoneByHash(boneInfo, conn.end);

				// �berpr�fen, ob beide Positionen auf den Bildschirm transformiert werden k�nnen
				bool vis1 = world_to_screen(pos1);
				bool vis2 = world_to_screen(pos2);

				// Farbe abh�ngig von der Sichtbarkeit w�hlen
				ImU32 color = (vis1 && vis2)
					? RGBtoU32(Skeletonviscolor[0] * 255, Skeletonviscolor[1] * 255, Skeletonviscolor[2] * 255)
					: RGBtoU32(Skeletonnotviscolor[0] * 255, Skeletonnotviscolor[1] * 255, Skeletonnotviscolor[2] * 255);

				// Wenn beide Knochen sichtbar sind, Linie(n) zeichnen
				if (vis1 && vis2) {
					
					// Zeichne die Hauptlinie in der festgelegten Farbe und Dicke
					overlay->AddLine(ImVec2(pos1.x, pos1.y), ImVec2(pos2.x, pos2.y), color, 0.1);
				}
			}
		}







		//printf("Outlinecomponent %llx \n", Outlinecomponent);
		
		 if (outlines2)
		 {
			 uint32_t* outlinewrite = reinterpret_cast<uint32_t*>(Outlinecomponent - 0x3FE3);
			if (outlinewrite == nullptr) {
				//printf("Invalid memory address at outlinewrite\n");
				continue;
			}
		
		
			DWORD oldProtect;
			if (VirtualProtect(outlinewrite, sizeof(uint32_t), PAGE_READWRITE, &oldProtect)) {
				*outlinewrite = 2252341255; 
		
				VirtualProtect(outlinewrite, sizeof(uint32_t), oldProtect, &oldProtect);
			
			}

		 }
		 else
		 {
			 uint32_t* outlinewrite = reinterpret_cast<uint32_t*>(Outlinecomponent - 0x3FE3);
			 if (outlinewrite == nullptr) {
				 //printf("Invalid memory address at outlinewrite\n");
				 continue;
			 }


			 DWORD oldProtect;
			 if (VirtualProtect(outlinewrite, sizeof(uint32_t), PAGE_READWRITE, &oldProtect)) {
				 *outlinewrite = 2185232391;

				 VirtualProtect(outlinewrite, sizeof(uint32_t), oldProtect, &oldProtect);

			 }

		 }

	
		 
	








		
		//auto Replication = offsets::GetReplication(entity);
		//if (!Replication)
		//{
		//	//printf("couldnt get Replication");
		//	continue;
		//}
		//printf("Replication %llx \n", Replication);
		//auto LReplication = offsets::GetReplication(LocalPlayer);
		//if (!LReplication)
		//{
		//	//printf("couldnt get Replication");
		//	continue;
		//}
		//const char* name = *reinterpret_cast<const char**>(LReplication + 0x60);
		//
		//
		//
		//Vector3 Actorpos = *reinterpret_cast<Vector3*>(actor + 0x50);


		
		
		//auto teamID = utils::spoof_call(team12, GetPawn, LocalPlayer);
		//if (!teamID)
		//	continue;


	}








}










void drawwm()
{

	auto overlay = ImGui::GetBackgroundDrawList();


	std::string textToShow = "[RAINBOW SIX:SIEGE] 1.01 [FREE]";


	ImVec2 textPos = ImVec2(5, 5);


	ImColor textColor = ImColor(255, 255, 255);
	ImColor outlineColor = ImColor(0, 0, 0);


	ImVec2 textSize = ImGui::CalcTextSize(textToShow.c_str());


	float offsetX = 1.0f;
	float offsetY = 1.0f;


	overlay->AddText(ImVec2(textPos.x - offsetX * 2, textPos.y - offsetY * 2), outlineColor, textToShow.c_str());
	overlay->AddText(ImVec2(textPos.x + offsetX * 2, textPos.y - offsetY * 2), outlineColor, textToShow.c_str());
	overlay->AddText(ImVec2(textPos.x - offsetX * 2, textPos.y + offsetY * 2), outlineColor, textToShow.c_str());
	overlay->AddText(ImVec2(textPos.x + offsetX * 2, textPos.y + offsetY * 2), outlineColor, textToShow.c_str());


	overlay->AddText(ImVec2(textPos.x - offsetX, textPos.y), outlineColor, textToShow.c_str());
	overlay->AddText(ImVec2(textPos.x + offsetX, textPos.y), outlineColor, textToShow.c_str());
	overlay->AddText(ImVec2(textPos.x, textPos.y - offsetY), outlineColor, textToShow.c_str());
	overlay->AddText(ImVec2(textPos.x, textPos.y + offsetY), outlineColor, textToShow.c_str());


	overlay->AddText(textPos, textColor, textToShow.c_str());
}



void noanimation() {
	auto localPawn = offsets::GetPawn(getlocalplayer());
	if (!localPawn)
		return;
	printf("localPawn: %llx\n", localPawn);
	auto localActor = offsets::GetActor(localPawn);
	if (!localActor)
		return;


	printf("localActor: %llx\n", localActor);
	uint64_t component_list = *reinterpret_cast<uintptr_t*>(localActor + 0xD8);
	if (!component_list)
	{

		std::cout << "Failed to read component_list" << std::endl;
		return;
	}
	printf("component_list: %llx\n", component_list);
	uint64_t component_list_movement_index = *reinterpret_cast<uint8_t*>(localActor + 0x21C);
	if (!component_list_movement_index)
	{

		std::cout << "Failed to read component_list_movement_index" << std::endl;
		return;
	}
	printf("component_list_movement_index: %llx\n", component_list_movement_index);
	uint64_t movement_array = *reinterpret_cast<uintptr_t*>(component_list + 8 * component_list_movement_index);
	if (!movement_array)
	{

		std::cout << "Failed to read movement_array" << std::endl;
		return;
	}
	printf("movement_array: %llx\n", movement_array);
	uint64_t movement_cmp = *reinterpret_cast<uintptr_t*>(movement_array + 0x48);
	if (!movement_cmp)
	{

		std::cout << "Failed to read movement_cmp" << std::endl;
		return;
	}
	printf("movement_cmp: %llx\n", movement_cmp);
	uint64_t movement_cmp_add = *reinterpret_cast<uintptr_t*>(movement_cmp + 0x148);
	if (!movement_cmp_add)
	{

		std::cout << "Failed to read movement_cmp_add" << std::endl;
		return;
	}
	printf("movement_cmp_add: %llx\n", movement_cmp_add);
	auto function = reinterpret_cast<uint64_t(*)(uint64_t, uint64_t, uint64_t*)>(offsets::client + 0x310C940);
	if (!function)
	{

		std::cout << "Failed to read function" << std::endl;
		return;
	}
	printf("function: %llx\n", function);
	uint64_t FirVal = 0xE7BB7DA4i64;
	uint64_t SecVal = 0i64;
	uint64_t finalll = utils::spoof_call(function, movement_cmp_add, FirVal, &SecVal);
	printf("finalll: %llx\n", finalll);
	if (!finalll)
	{

		std::cout << "Failed to read finalll" << std::endl;
		return;
	}
	uint64_t pullout = *reinterpret_cast<uintptr_t*>(finalll);

	printf("noanimation: %llx\n", pullout);
	if (!pullout)
	{

		std::cout << "Failed to read pullout" << std::endl;
		return;
	}


	*(BYTE*)(pullout + 0x2A7) = 1;

}















HRESULT APIENTRY hkPresent(IDXGISwapChain3* pSwapChain, UINT SyncInterval, UINT Flags) {
	if (!ImGui_Initialised) {
		/*
		if (SUCCEEDED(pSwapChain->GetDevice(__uuidof(ID3D12Device), (void**)&DirectX12Interface::Device))) {
			ImGui::CreateContext();
			ImGuiIO& io = ImGui::GetIO(); (void)io;
			ImGui::GetIO().WantCaptureMouse || ImGui::GetIO().WantTextInput || ImGui::GetIO().WantCaptureKeyboard;
			io.Fonts->AddFontFromFileTTF("C:/Windows/Fonts/msyh.ttc", 18.f, nullptr, io.Fonts->GetGlyphRangesChineseFull());
			ImGui::StyleColorsClassic();
			io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
			DXGI_SWAP_CHAIN_DESC Desc;
			pSwapChain->GetDesc(&Desc);
			Desc.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
			Desc.OutputWindow = Process::Hwnd;
			Desc.Windowed = ((GetWindowLongPtr(Process::Hwnd, GWL_STYLE) & WS_POPUP) != 0) ? false : true;

			DirectX12Interface::BuffersCounts = Desc.BufferCount;
			DirectX12Interface::FrameContext = new DirectX12Interface::_FrameContext[DirectX12Interface::BuffersCounts];

			D3D12_DESCRIPTOR_HEAP_DESC DescriptorImGuiRender = {};
			DescriptorImGuiRender.Type = D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV;
			DescriptorImGuiRender.NumDescriptors = DirectX12Interface::BuffersCounts;
			DescriptorImGuiRender.Flags = D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE;

			if (DirectX12Interface::Device->CreateDescriptorHeap(&DescriptorImGuiRender, IID_PPV_ARGS(&DirectX12Interface::DescriptorHeapImGuiRender)) != S_OK)
				return oPresent(pSwapChain, SyncInterval, Flags);

			ID3D12CommandAllocator* Allocator;
			if (DirectX12Interface::Device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&Allocator)) != S_OK)
				return oPresent(pSwapChain, SyncInterval, Flags);

			for (size_t i = 0; i < DirectX12Interface::BuffersCounts; i++) {
				DirectX12Interface::FrameContext[i].CommandAllocator = Allocator;
			}

			if (DirectX12Interface::Device->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, Allocator, NULL, IID_PPV_ARGS(&DirectX12Interface::CommandList)) != S_OK ||
				DirectX12Interface::CommandList->Close() != S_OK)
				return oPresent(pSwapChain, SyncInterval, Flags);

			D3D12_DESCRIPTOR_HEAP_DESC DescriptorBackBuffers;
			DescriptorBackBuffers.Type = D3D12_DESCRIPTOR_HEAP_TYPE_RTV;
			DescriptorBackBuffers.NumDescriptors = DirectX12Interface::BuffersCounts;
			DescriptorBackBuffers.Flags = D3D12_DESCRIPTOR_HEAP_FLAG_NONE;
			DescriptorBackBuffers.NodeMask = 1;

			if (DirectX12Interface::Device->CreateDescriptorHeap(&DescriptorBackBuffers, IID_PPV_ARGS(&DirectX12Interface::DescriptorHeapBackBuffers)) != S_OK)
				return oPresent(pSwapChain, SyncInterval, Flags);

			const auto RTVDescriptorSize = DirectX12Interface::Device->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV);
			D3D12_CPU_DESCRIPTOR_HANDLE RTVHandle = DirectX12Interface::DescriptorHeapBackBuffers->GetCPUDescriptorHandleForHeapStart();

			for (size_t i = 0; i < DirectX12Interface::BuffersCounts; i++) {
				ID3D12Resource* pBackBuffer = nullptr;
				DirectX12Interface::FrameContext[i].DescriptorHandle = RTVHandle;
				pSwapChain->GetBuffer(i, IID_PPV_ARGS(&pBackBuffer));
				DirectX12Interface::Device->CreateRenderTargetView(pBackBuffer, nullptr, RTVHandle);
				DirectX12Interface::FrameContext[i].Resource = pBackBuffer;
				RTVHandle.ptr += RTVDescriptorSize;
			}
			
			Unlock();
			//drawwm();
			ImGui_ImplWin32_Init(Process::Hwnd);
			ImGui_ImplDX12_Init(DirectX12Interface::Device, DirectX12Interface::BuffersCounts, DXGI_FORMAT_R8G8B8A8_UNORM, DirectX12Interface::DescriptorHeapImGuiRender, DirectX12Interface::DescriptorHeapImGuiRender->GetCPUDescriptorHandleForHeapStart(), DirectX12Interface::DescriptorHeapImGuiRender->GetGPUDescriptorHandleForHeapStart());
			ImGui_ImplDX12_CreateDeviceObjects();
			ImGui::GetIO().ImeWindowHandle = Process::Hwnd;
			Process::WndProc = (WNDPROC)SetWindowLongPtr(Process::Hwnd, GWLP_WNDPROC, (__int3264)(LONG_PTR)WndProc);
		}
		//drawwm();
		*/
		Unlock();
		ImGui_Initialised = true;
	}

	/*
	if (DirectX12Interface::CommandQueue == nullptr)
		return oPresent(pSwapChain, SyncInterval, Flags);

	
	
	if (GetAsyncKeyState(VK_INSERT) & 1)
		ShowMenu = !ShowMenu;

	ImGui_ImplDX12_NewFrame();
	ImGui_ImplWin32_NewFrame();
	ImGui::NewFrame();
	ImGui::GetIO().MouseDrawCursor = ShowMenu;

	

	
	




	DirectX12Interface::_FrameContext& CurrentFrameContext = DirectX12Interface::FrameContext[pSwapChain->GetCurrentBackBufferIndex()];
	CurrentFrameContext.CommandAllocator->Reset();

	D3D12_RESOURCE_BARRIER Barrier;
	Barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
	Barrier.Flags = D3D12_RESOURCE_BARRIER_FLAG_NONE;
	Barrier.Transition.pResource = CurrentFrameContext.Resource;
	Barrier.Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES;
	Barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_PRESENT;
	Barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_RENDER_TARGET;

	DirectX12Interface::CommandList->Reset(CurrentFrameContext.CommandAllocator, nullptr);
	DirectX12Interface::CommandList->ResourceBarrier(1, &Barrier);
	DirectX12Interface::CommandList->OMSetRenderTargets(1, &CurrentFrameContext.DescriptorHandle, FALSE, nullptr);
	DirectX12Interface::CommandList->SetDescriptorHeaps(1, &DirectX12Interface::DescriptorHeapImGuiRender);

	ImGui::Render();
	ImGui_ImplDX12_RenderDrawData(ImGui::GetDrawData(), DirectX12Interface::CommandList);
	Barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET;
	Barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT;
	DirectX12Interface::CommandList->ResourceBarrier(1, &Barrier);
	DirectX12Interface::CommandList->Close();
	DirectX12Interface::CommandQueue->ExecuteCommandLists(1, reinterpret_cast<ID3D12CommandList* const*>(&DirectX12Interface::CommandList));
	*/
	return oPresent(pSwapChain, SyncInterval, Flags);
}

//=========================================================================================================================//

void hkExecuteCommandLists(ID3D12CommandQueue* queue, UINT NumCommandLists, ID3D12CommandList* ppCommandLists) {
	if (!DirectX12Interface::CommandQueue)
		DirectX12Interface::CommandQueue = queue;

	oExecuteCommandLists(queue, NumCommandLists, ppCommandLists);
}

//=========================================================================================================================//

void APIENTRY hkDrawInstanced(ID3D12GraphicsCommandList* dCommandList, UINT VertexCountPerInstance, UINT InstanceCount, UINT StartVertexLocation, UINT StartInstanceLocation) {

	return oDrawInstanced(dCommandList, VertexCountPerInstance, InstanceCount, StartVertexLocation, StartInstanceLocation);
}

//=========================================================================================================================//



//=========================================================================================================================//

DWORD WINAPI MainThread(LPVOID lpParameter)
{
	// 1) Auf den Fensterfokus warten
	bool windowFocus = false;
	while (!windowFocus)
	{
		// -- Windows-Nachrichten abarbeiten, damit die App nicht h�ngt
		MSG msg = { 0 };
		while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
		{
			if (msg.message == WM_QUIT)
				return 0;

			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}

		// -- Pr�fen, ob unser Prozess im Vordergrund ist
		HWND hForeground = GetForegroundWindow();
		if (hForeground)
		{
			DWORD foregroundProcID = 0;
			GetWindowThreadProcessId(hForeground, &foregroundProcID);
			if (foregroundProcID == GetCurrentProcessId())
			{
				Process::ID = GetCurrentProcessId();
				Process::Handle = GetCurrentProcess();
				Process::Hwnd = hForeground;

				RECT rc{};
				GetWindowRect(hForeground, &rc);
				Process::WindowWidth = rc.right - rc.left;
				Process::WindowHeight = rc.bottom - rc.top;

				char tempTitle[MAX_PATH] = { 0 };
				GetWindowTextA(hForeground, tempTitle, sizeof(tempTitle));
				Process::Title = tempTitle;

				char tempClassName[MAX_PATH] = { 0 };
				GetClassNameA(hForeground, tempClassName, sizeof(tempClassName));
				Process::ClassName = tempClassName;

				char tempPath[MAX_PATH] = { 0 };
				// F�r den eigenen Prozess sollte GetModuleFileNameExA problemlos funktionieren
				GetModuleFileNameExA(Process::Handle, NULL, tempPath, sizeof(tempPath));
				Process::Path = tempPath;

				windowFocus = true;
			}
		}


	}

	// 2) Wenn Fokus da ist, Hooks initialisieren
	bool initHook = false;
	while (!initHook)
	{
		if (DirectX12::Init())
		{
			CreateHook(54, (void**)&oExecuteCommandLists, hkExecuteCommandLists);
			CreateHook(140, (void**)&oPresent, hkPresent);
			CreateHook(84, (void**)&oDrawInstanced, hkDrawInstanced);
			initHook = true;
		}
	}

	return 0;
}

//=========================================================================================================================//
void CreateConsole()
{
	AllocConsole();
	FILE* fp;
	freopen_s(&fp, "CONOUT$", "w", stdout);
	freopen_s(&fp, "CONOUT$", "w", stderr);
	freopen_s(&fp, "CONIN$", "r", stdin);
	SetConsoleTitle(TEXT("Debug"));
}



BOOL APIENTRY DllMain(HMODULE hModule, DWORD dwReason, LPVOID lpReserved) {
	switch (dwReason) {
	case DLL_PROCESS_ATTACH:
		//wchar_t file_name[MAX_PATH] = L"";
		//GetModuleFileNameW(hModule, file_name, _countof(file_name));
		//LoadLibraryW(file_name);
		DisableThreadLibraryCalls(hModule);
		//CreateConsole();
		


		
		CreateThread(0, 0, MainThread, hModule, 0, 0);
		break;
	}
	return TRUE;
}


