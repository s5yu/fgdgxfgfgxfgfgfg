#pragma once
#include "ImGui/imgui.h"
#include "globals.h"


void RenderMenu()
{
    // -- Stil-Anpassungen --
    ImGuiStyle& style = ImGui::GetStyle();
    style.WindowRounding = 5.0f;
    style.FrameRounding = 5.0f;
    style.Colors[ImGuiCol_WindowBg] = ImVec4(0.05f, 0.05f, 0.05f, 1.0f);
    style.Colors[ImGuiCol_Text] = ImVec4(0.90f, 0.90f, 0.90f, 1.0f);
    style.Colors[ImGuiCol_FrameBg] = ImVec4(0.15f, 0.15f, 0.15f, 1.0f);
    style.Colors[ImGuiCol_FrameBgHovered] = ImVec4(0.20f, 0.20f, 0.20f, 1.0f);
    style.Colors[ImGuiCol_FrameBgActive] = ImVec4(0.25f, 0.25f, 0.25f, 1.0f);
    style.Colors[ImGuiCol_Button] = ImVec4(0.15f, 0.15f, 0.15f, 1.0f);
    style.Colors[ImGuiCol_ButtonHovered] = ImVec4(0.20f, 0.20f, 0.20f, 1.0f);
    style.Colors[ImGuiCol_ButtonActive] = ImVec4(0.25f, 0.25f, 0.25f, 1.0f);
    style.Colors[ImGuiCol_SliderGrab] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
    style.Colors[ImGuiCol_SliderGrabActive] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);

    // -- Hauptfenster --
    ImGui::Begin(_x("Menu"), nullptr,
        ImGuiWindowFlags_NoCollapse |
        ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoTitleBar);

    ImGui::SetWindowSize(ImVec2(600, 400));

    {
        ImVec2 pos = ImGui::GetWindowPos();
        ImVec2 size = ImGui::GetWindowSize();
        ImGui::GetWindowDrawList()->AddRectFilled(
            ImVec2(pos.x, pos.y),
            ImVec2(pos.x + size.x, pos.y + 3),
            IM_COL32(0, 128, 255, 255)
        );
        ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 8.0f);
    }

    static int selectedTab = 0;
    ImGui::BeginChild(_x("##tabs"), ImVec2(80, 0), true);
    {
        if (ImGui::Selectable(_x("Aimbot"), selectedTab == 0, 0, ImVec2(80, 40)))
            selectedTab = 0;
        if (ImGui::Selectable(_x("Visuals"), selectedTab == 1, 0, ImVec2(80, 40)))
            selectedTab = 1;
        if (ImGui::Selectable(_x("Weapon"), selectedTab == 2, 0, ImVec2(80, 40)))
            selectedTab = 2;
        if (ImGui::Selectable(_x("Exploits"), selectedTab == 3, 0, ImVec2(80, 40)))
            selectedTab = 3;
    }
    ImGui::EndChild();

    ImGui::SameLine();

    ImGui::BeginChild(_x("##content"), ImVec2(0, 0), true);
    {
        switch (selectedTab)
        {
        case 0: // Aimbot
        {
            ImGui::TextColored(ImVec4(0.0f, 0.7f, 1.0f, 1.0f), _x("Aimbot Settings"));
            ImGui::Separator();
            ImGui::Checkbox(_x("Aimbot"), &aimbot);
            ImGui::SliderFloat(_x("Aimbot Fov"), &aimfov, 0.1, 500);

            static float sliderValue = 15.0f;

            sliderValue = 2.0f + (0.9f - sensitivity) * ((15.0f - 2.0f) / (0.9f - 0.1f));
            if (ImGui::SliderFloat(_x("Aimbot smooth"), &sliderValue, 2.0f, 15.0f, _x("%.1f")))
            {
                sensitivity = 0.9f - (sliderValue - 2.0f) * ((0.9f - 0.1f) / (15.0f - 2.0f));
            }

            if (ImGui::BeginCombo(_x("Select Hitboxes"), _x("Select Hitboxes")))
            {
                for (int i = 0; i < 19; i++)
                {
                    bool isChecked = selectedBones[i] == 1;
                    if (ImGui::Checkbox(BoneNames[i], &isChecked))
                    {
                        selectedBones[i] = isChecked ? 1 : 0;
                    }
                }
                ImGui::EndCombo();
            }

            ImGui::Checkbox(_x("Ignore injured"), &ignoreinj);
            ImGui::Spacing();
            ImGui::Text(_x("Aimkey"));
            HotkeyButton(hotkeys::aimkeyy, ChangeKeyy, keystatuss);
        }
        break;

        case 1: // Visuals
        {
            ImGui::TextColored(ImVec4(0.0f, 0.7f, 1.0f, 1.0f), _x("Visual Settings"));
            ImGui::Separator();
            ImGui::Checkbox(_x("team check"), &teamcheck);
            ImGui::Checkbox(_x("Skeleton ESP"), &skeleton);
            ImGui::SameLine();
            ImGui::ColorEdit4(_x("skeleton color"), (float*)&skeletoncolor12, ImGuiColorEditFlags_NoInputs);
            ImGui::SliderFloat(_x("Skeleton Thickness"), &skeletonthickness, 0.1, 3.0);
            ImGui::Checkbox(_x("Head circle"), &headcircleesp);
            ImGui::Checkbox(_x("Player Information"), &PlayerInfo);
            ImGui::SameLine();
            ImGui::ColorEdit4(_x("tag color"), (float*)&tagcolor, ImGuiColorEditFlags_NoInputs);
            ImGui::Checkbox(_x("Health Bar"), &healthbar);
        }
        break;

        case 2: // Weapon
        {
            ImGui::TextColored(ImVec4(0.0f, 0.7f, 1.0f, 1.0f), _x("Weapon Settings"));
            ImGui::Separator();
            ImGui::Checkbox(_x("No Pullout (no weapon delay)"), &nopullout12);
        }
        break;

        case 3: // Exploits
        {
            ImGui::TextColored(ImVec4(0.0f, 0.7f, 1.0f, 1.0f), _x("Exploits"));
            ImGui::Separator();
            ImGui::Checkbox(_x("No Fall Damage"), &nofalldmg);
            ImGui::SliderFloat(_x("FOV"), &fovValue, 0.0, 1.0);
            ImGui::Spacing();
            ImGui::Spacing();
            ImGui::Spacing();
            ImGui::Spacing();
            ImGui::Checkbox(_x("Speedchanger"), &Speedchanger24);
            ImGui::SliderFloat(_x("Speed Value"), &speedchanger3, 0.5, 0.77);
            
        }
        break;
        }
    }
    ImGui::EndChild();
    ImGui::End();
}