#pragma once
#include "vectors.h"
#include "memory.hpp"

#include <iostream>
#include <string>
#include <vector>
#include <TlHelp32.h>
#include "offsets.h"

extern "C" uint64_t AsmCalcw2s(uint64_t enc);

#pragma once
uint32_t game_pid = 0;
uint64_t base = 0;
void* game_hwnd;
vec2_t win_pos;
vec2_t win_size;
vec2_t client_pos;
vec2_t client_size;


auto get_hwnd() -> void* {
	return game_hwnd;
}

auto get_win_pos() -> vec2_t {
	return win_pos;
}

auto update_win_info() -> void
{
	RECT rect;
	GetWindowRect((HWND)game_hwnd, &rect);
	win_pos = { (float)rect.left, (float)rect.top };
	win_size = { (float)rect.right - (float)rect.left, (float)rect.bottom - (float)rect.top };

	GetClientRect((HWND)game_hwnd, &rect);
	client_size = { (float)rect.right - (float)rect.left, (float)rect.bottom - (float)rect.top };

	POINT point = { 0 };
	ClientToScreen((HWND)game_hwnd, &point);
	client_pos = { (float)point.x, (float)point.y };
}



uintptr_t GetViewData()
{
	auto l1 = Memory::Read<uintptr_t>(offsets::client + 0xBC89A00);
	return l1;
};




Matrix4x4& GetViewMatrix() {
	return *reinterpret_cast<Matrix4x4*>(GetViewData() + 0x5F8);
}


Vector3& GetCameraPosition() {
	return *reinterpret_cast<Vector3*>(GetViewData() + 0x600);
}



auto get_view_matrix() -> Matrix4x4 {
	return GetViewMatrix();
}



bool world_to_screen(Vector3& pos)
{
	Matrix4x4 matrix = get_view_matrix();
	int Width = GetSystemMetrics(SM_CXSCREEN);
	int Height = GetSystemMetrics(SM_CYSCREEN);
	Vector4 clip;
	clip.x = pos.x * matrix.m[0] + pos.y * matrix.m[4] + pos.z * matrix.m[8] + matrix.m[12];
	clip.y = pos.x * matrix.m[1] + pos.y * matrix.m[5] + pos.z * matrix.m[9] + matrix.m[13];
	clip.z = pos.x * matrix.m[2] + pos.y * matrix.m[6] + pos.z * matrix.m[10] + matrix.m[14];
	clip.w = pos.x * matrix.m[3] + pos.y * matrix.m[7] + pos.z * matrix.m[11] + matrix.m[15];


	if (clip.w < 0.001f)
		return false;


	float invW = 1.0f / clip.w;
	float ndcX = clip.x * invW;
	float ndcY = clip.y * invW;


	float halfW = Width * 0.5f;
	float halfH = Height * 0.5f;

	pos.x = halfW + (ndcX * halfW);
	pos.y = halfH - (ndcY * halfH);


	pos.z = clip.z * invW;

	return true;
}