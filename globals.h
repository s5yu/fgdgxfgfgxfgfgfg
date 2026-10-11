#pragma once
#include <vector>
#include <tuple>
#include "ImGui/imgui.h"
#include <chrono>
#include "Memory.hpp"
#include <Windows.h>
#include "keybinds.h"
#include "xorstr.h"
#include "offsets.h"
#include <unordered_set>
ImFont* Default;
uint64_t weaponcomponent23;
namespace game
{
	int roundstate;
	
	uint64_t GameManager;
	uint64_t ControllerList;
	int ControllerSize;
	uint64_t Pawn;

	uint64_t Entity;

}
bool instantreload = false;
//struct actor_info_t
//{
//    uint64_t object;
//    uint8_t type;
//    Vector3 pos;
//    Vector2 view_angle;
//    uint32_t move_state;
//    uint32_t hp;
//    uint32_t max_hp;
//    uint32_t level;
//
//
//    char name[1024];
//
//
//
//};



float linecolor[3] = { 1.0f, 1.0f, 0.0f };
struct map_info_t {
    int map_id;
    std::string map_name;
};

float x;
float y;
float h;
float smt;

bool lines = true;



bool actorValid[18] = { false };

	int ScreenX = GetSystemMetrics(SM_CXSCREEN);
	int ScreenY = GetSystemMetrics(SM_CYSCREEN);
	float Width = (float)(ScreenX);
	float Height = (float)(ScreenY);

    bool knifeothers = false;

namespace menu {

	bool show = true;
}
const char* BoneNames[] = {
    "RTOE", "RFOOT", "RKNEE", "RHIP", "PELVIS",
    "LTOE", "LFOOT", "LKNEE", "LHIP", "STOMACH",
    "LUMBAR", "THORAX", "SPINE", "NECK", "LSHOULDER",
    "LELBOW", "LHAND", "RSHOULDER", "RELBOW", "RHAND"
};
namespace visuals {

	
	bool Tracers = true;
	bool skeletons = true;
	ImVec4 TracerColor = { 1.f, 1.f, 1.f, 1.f };
	const char* TracerPos[] = { "Bottom-Middle", "Center", "Top-Middle" };
	int TracerSelected = 0;
}

float Skeletonviscolor[3] = { 0.0f, 1.0f, 0.0f };
float Skeletonnotviscolor[3] = { 1.0f, 1.0f, 1.0f };

int inteeger = 11;
namespace hack {

	bool forcemelee = true;
}
bool outlines2 = false;
bool outlinethickness = false;
bool outlineglow = false;
int selectedGlow = 0;
int selectedOption = 0;
static bool movementCheckedForRound = false;
bool avoidghostbullets = false;
bool longknife = false;
bool thickknife1 = false;
bool autoreload12 = true;
bool tpknife = false;
bool fastknife1 = true;
bool damageknife1 = false;
bool skylightchanger = false;
float knifedistance = 300000;
float knifedamagefloat = 255;
float knifespeed = 0;
float speedchanger3 = 0.7;
bool Speedchanger24 = false;
bool noclip = false;
bool knifethroughtwalls = false;
bool headcircleesp = false;
float fovValue = 0.0;
bool norecoil = false;
bool teamcheck = true;
bool noleganimation = false;
float healthBarColor[3] = { 0.0f, 1.0f, 0.1f };
float skeletoncolor12[3] = { 1.0f, 1.0f, 1.0f };
float tagcolor[3] = { 1.0f, 1.0f, 0.1f };
float headcircle[3] = { 0.0f, 1.0f, 0.1f };
bool healthbar = false;
bool nopullout12 = true;
bool fastrapple = false;
bool vaultfeature = false;
bool NoAnimation = false;
float skeletonthickness = 0.1;
float ViewportWidth;
float ViewportHeight;
bool ignoreshield = true;
bool skeleton = true;
bool PlayerInfo = false;
float prevCursorY = 0.0f;
float aimfov = 0;
float smoothingFactor = 1.0f;
float sensitivity = 1.0;
float fValue = 3.0f;
bool forcehead = false;
bool aimbot = false;
float fov = 90;
bool ignoreinj = false;
bool nofalldmg = false;
static bool wasTargetVisible = false;
bool ignoreVisible = false;
const char* bones[] = { "Neck", "Stomach", "Pelvis", "Spine" };
static int selectedBoneIndex = 0;
bool instantscope = false;
bool chatspammers = false;
bool selfkill = false;
static const char* items[] = {
    "Top",
    "Middle",
    "Bottom"
};


const char* ReducedBoneNames[] = {
        "Head",
        "Stomach",
        "Pelvis",
        "Lumbar"
};

bool cornedbox = false;
bool NoLight = true;
bool NoModel = false;
bool NoSky = false;
bool worldchangers = false;
bool NoHUD = false;
bool NoSmoke = false;
bool NoPaint = false;
bool NoColorMask = false;
bool NoShadows = false;
typedef void(__fastcall* SendChatMessage)(char** Text, int* a2);


bool cornerbox = false;
float BoxColour[3] = { 0.0f, 1.0f, 0.0f };
int number12 = 3;
bool killauraeasy = false;
bool runandreload233 = false;
namespace weapon {

    int LegitselectedBoneIndex = 0;
    const char* LegitboneOptions[] = {
        "Closet to Crosshair",
        "Head",
        "Neck",
        "Thorax",
        "Lumbar"
    };

    bool FoVCheck = true;
    bool targetteam;
    bool rendertarget = true;
    ImVec4 targetcolor = ImVec4(0.6f, 0.0f, 1.0f, 1.0f);
    bool enableaimbot;

    bool renderfov;
    int fov = 25;

    bool force;
    bool decreaseammo;
}



int selected = 0;


enum BipedBoneID {
	HEADS = 0x7C159A2,
	EYES = 0xAC172D1E,
	ROOT = 0x22E53C03,
	PELVIS = 0xDED10611,
	STOMACH = 0x530EC1CB,
	LUMBAR = 0x8F39FA4E,
	THORAX = 0x1630ABF4,
	NECK = 0x8023796D,
	HEAD = 0x7C159A2, // Head
	LHIP = 0x176183F0,
	LKNEE = 0x60DF401,
	LFOOT = 0x58988870,
	LTOE = 0xB95094E1,
	LCLAVICLE = 0x2D4660A8,
	LSHOULDER = 0xEB830ADA,
	LELBOW = 0x89B93A80,
	LHAND = 0xB675F36C,
	RHIP = 0x757F1291,
	RKNEE = 0x863D09FC,
	RFOOT = 0x9B14362C,
	RTOE = 0x42BE0FCB,
	RCLAVICLE = 0xF60647E5,
	RSHOULDER = 0x6BB3F727,
	RELBOW = 0x7257A1AA,
	RHAND = 0x75F94D30
};







BipedBoneID uniqueBones[] = {
	BipedBoneID::ROOT,
	BipedBoneID::PELVIS,
	BipedBoneID::STOMACH,
	BipedBoneID::LUMBAR,
	BipedBoneID::THORAX,
	BipedBoneID::NECK,
	BipedBoneID::HEAD,
	BipedBoneID::LCLAVICLE,
	BipedBoneID::LSHOULDER,
	BipedBoneID::LELBOW,
	BipedBoneID::LHAND,
	BipedBoneID::RCLAVICLE,
	BipedBoneID::RSHOULDER,
	BipedBoneID::RELBOW,
	BipedBoneID::RHAND,
	BipedBoneID::LHIP,
	BipedBoneID::LKNEE,
	BipedBoneID::LFOOT,
	BipedBoneID::LTOE,
	BipedBoneID::RHIP,
	BipedBoneID::RKNEE,
	BipedBoneID::RFOOT,
	BipedBoneID::RTOE
};




#pragma once
#include <fstream>
#include <sstream>

