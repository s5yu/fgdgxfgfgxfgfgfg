#pragma once
#include <cstdint>
#include <vector>
#include <iostream>
#include <Windows.h>
#include "excpt.h"



namespace Memory {

	uint64_t ImageBase = (uint64_t)GetModuleHandle(NULL);


	uint64_t NtCurrentPeb()
	{
		return __readgsqword(0x60);
	}

	template<typename T>
	T Read(uintptr_t address);

	template<typename T>
	void Write(uintptr_t address, T data);

	uintptr_t GetAddr(uintptr_t base, std::vector<uintptr_t> offsets);

	template<typename T>
	T ReadPtr(uintptr_t base, std::vector<uintptr_t> offsets);

	template<typename T>
	void WritePtr(uintptr_t base, std::vector<uintptr_t> offsets, T data);

	template<typename T>
	T Read(uintptr_t address) {
		if (IsBadReadPtr((void*)address, sizeof(T))) {
			if constexpr (std::is_pointer_v<T>) {
				return nullptr;
			}
			else {
				return T{};
			}
		}
		return *reinterpret_cast<T*>(address);
	}

	template<typename T>
	void WriteProtected(uintptr_t address, T data)
	{
		uint32_t old{ };
		if (!vm_protect(address, sizeof(T), PAGE_EXECUTE_READWRITE, &old))
			return;
		*(T*)address = data;
		vm_protect(address, sizeof(T), old, &old);
	}

	template<typename T>
	void Write(uintptr_t address, T data) {
		if (IsBadReadPtr((void*)address, sizeof(T))) return;
		if (IsBadWritePtr((LPVOID)address, sizeof(T))) return;
		*(T*)address = data;
	}

	uintptr_t GetAddr(uintptr_t base, std::vector<uintptr_t> offsets) {
		for (int i = 0; i < offsets.size(); i++) {
			base = Read<uintptr_t>(base);
			if (!base) return 0;
			base += offsets[i];
			if (!base) return 0;
		}
		return base;
	}


	template<typename T>
	T ReadPtr(uintptr_t base, std::vector<uintptr_t> offsets) {
		for (int i = 0; i < offsets.size(); i++) {
			base = Read<uintptr_t>(base);
			base += offsets[i];
		}
		return Read<T>(base);
	}

	template<typename T>
	void WritePtr(uintptr_t base, std::vector<uintptr_t> offsets, T data) {
		base = GetAddr(base, offsets);
		if (IsBadWritePtr((LPVOID)base, sizeof(T))) return;
		if (IsBadReadPtr((void*)base, sizeof(T))) return;
		Write<T>(base, data);
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
			else {
				PatternVector.push_back(strtoul(Current, &Current, 16));
			}
		}

		return PatternVector;
	}

	template<typename T>
	static T PatternScan(const char* Pattern, uint64_t Start)
	{
		const HMODULE GameModule = (HMODULE)Start;
		const IMAGE_DOS_HEADER* DOSHeader = reinterpret_cast<IMAGE_DOS_HEADER*>(GameModule);
		const IMAGE_NT_HEADERS* NtHeaders = reinterpret_cast<IMAGE_NT_HEADERS*>(reinterpret_cast<long long>(GameModule) + DOSHeader->e_lfanew);
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

			if (FoundSignature) {

				return reinterpret_cast<T>(&Search[i]);
			}
		}

		return reinterpret_cast<T>(nullptr);
	}

	bool IsValidPtr(uintptr_t ptr) {
		__try
		{
			volatile auto result = *(uintptr_t*)ptr;
		}
		__except (EXCEPTION_EXECUTE_HANDLER)
		{
			return false;
		}
		return true;
	}

}


//uint64_t retaddr = Memory::ImageBase;