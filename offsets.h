#pragma once
#include "memory.hpp"
#include "globals.h"
#include "definitions.h"
#include "Vectors.h"
#include <cstdint>
#include <libloaderapi.h>
#include <windows.h>
#include <xmmintrin.h>
#include <mutex>
#include <iostream>
#include "spoofcall/spoof.h"
#include "vmmath.h"
#include <xmmintrin.h>
#include <emmintrin.h>

const auto client1 = reinterpret_cast<std::uintptr_t>(GetModuleHandle((LPCSTR)"RainbowSix.exe"));

uint64_t Findroundstate()
{
    const char* Pattern = _x("48 8B 0D ? ? ? ? ? 85 C9 ? ? ? 79 19 ?");

    HMODULE hModule = GetModuleHandle((LPCSTR)"RainbowSix.exe");
    if (hModule == nullptr)
    {
        printf("couldnt get baseaddy\n");
        return 0;
    }

    uintptr_t StartAddress = reinterpret_cast<uintptr_t>(hModule);
    uint8_t* Result = Memory::PatternScan<uint8_t*>(Pattern, StartAddress);

    if (Result != nullptr)
    {
        uintptr_t ReferencedAddress = reinterpret_cast<uintptr_t>(Result) + *reinterpret_cast<int32_t*>(Result + 3) + 7;
        return ReferencedAddress;
    }
    else
    {
        printf("lolololol\n");
        return 0;
    }
}

class RoundState {
public:
    static uint64_t GetRoundState()
    {
        // Cache den RoundBase einmalig – so wie der letzte Donut, der nicht noch mal geklaut wird!
        static uint64_t cachedRoundBase = Findroundstate();
        if (!cachedRoundBase)
        {
            printf("RoundState konnte nicht gefunden werden. Vielleicht hat er Urlaub gemacht?\n");
            return 0;
        }
        std::vector<uintptr_t> RoundChain = { 0xA0, 0x50, 0x10, 0x90, 0x40, 0x50, 0x1B0 };
        int roundstate = Memory::ReadPtr<int>(cachedRoundBase, RoundChain);
        return roundstate;
    }
};








namespace offsets
{


  


    const auto client = reinterpret_cast<std::uintptr_t>(GetModuleHandle((LPCSTR)"RainbowSix.exe"));
    uint64_t NtCurrentPeb() {
        return __readgsqword(0x60);
    }

    auto retaddr = client;




    uintptr_t GetGameManager()
    {
        const auto qword_D4A7568 = *reinterpret_cast<uintptr_t*>(client + 0xBC81070);
     

 
        return qword_D4A7568 + 0x2D0;
    }


  
    uintptr_t getoutlinemesh()
    {
        const auto qword_D4A7568 = *reinterpret_cast<uintptr_t*>(client + 0xBC53BE8);

        return qword_D4A7568 + 0x108;
    }


   // uintptr_t getoutlinethickness() {
   //     const auto qword_D4A7568 = *reinterpret_cast<uintptr_t*>(client + 0x0DF1C388);
   //     if (!qword_D4A7568)
   //         return 0;
   //     return qword_D4A7568 + 0x124;
   // }


    static std::pair<uint64_t, uint32_t> GetEntityList(uint64_t Gamemanager)
    {
        unsigned int v7 = 0; // r11d
        unsigned __int64 v8 = 0; // r10
        bool v9 = false; // cf
        unsigned int v10 = 0; // r11d
        unsigned __int64 v11 = 0; // r10
        unsigned int v12 = 0; // r11d

        __m128 v74{};
        v74.m128_u64[0] = *(_QWORD*)(Gamemanager + 0xFB0)
            + 0x3011412FAACD1A2BLL;
        v74.m128_u64[1] = *(_QWORD*)(Gamemanager + 0xFB8)
            - 0x7357E5294088A93FLL;
        v7 = 0;
        v8 = 0xCB910B87C15C82CCuLL;
        do
        {
            if (v7 >= 9)
            {
                *((_BYTE*)&v74 + v7) ^= (v8 & (255LL << ((8 * v7) & 0x38))) >> ((8 * v7) & 0x38);
            }
            else
            {
                *(__int64*)((char*)&v74 + v7) ^= v8;
                v8 += 0x1D9704FD71E0AA5LL;
                v7 += 7;
            }
            v9 = v7++ < 0xF;
        } while (v9);
        v10 = 0;
        do
        {
            if (v10 >= 9)
            {
                *((_BYTE*)&v74 + v10) ^= ((255LL << ((8 * v10) & 0x38)) & 0xD2DD422BuLL) >> ((8 * v10) & 0x38);
            }
            else
            {
                *(__int64*)((char*)&v74 + v10) ^= 0xD2DD422BuLL;
                v10 += 7;
            }
            v9 = v10++ < 0xF;
        } while (v9);
        v11 = retaddr >> 33;
        v12 = 0;
        do
        {
            if (v12 >= 9)
            {
                *((_BYTE*)&v74 + v12) ^= (v11 & (255LL << ((8 * v12) & 0x38))) >> ((8 * v12) & 0x38);
            }
            else
            {
                *(__int64*)((char*)&v74 + v12) ^= v11;
                v12 += 7;
            }
            v9 = v12++ < 0xF;
        } while (v9);
        return { v74.m128_u64[0] ,  v74.m128_u64[1] & 0x3FFFFFFF };
    }




  
    static uint64_t GetPawn(uint64_t Entity)
    {


        uint64_t v128 = *reinterpret_cast<const uint64_t*>(Entity + 0x70);
        if (!v128)
        {
            return 0;
        }

        {
            constexpr uint64_t partA = 0x76A32549EB906D70ULL + 8ULL;
            constexpr uint64_t c1 = partA ^ 0xBD79C8C42A6FF494ULL;

            constexpr uint64_t c2 = 0x5DA8295E052FE6BCULL + 8ULL;


            {
                constexpr uint64_t partB = 0x5BBDD37EB75948CDULL + 8ULL;

                constexpr uint64_t c3 = partB ^ 0x5BBDD37E9ADD7582ULL;

             
                constexpr uint64_t SHIFT = 33ULL;

                uint64_t step1 = (v128 ^ c1);
                uint64_t step2 = step1 + c2;
                uint64_t step3 = step2 ^ c3;
                uint64_t Pawn = step3 + (retaddr >> SHIFT);


                return Pawn;
            }
        }
    }





    uintptr_t GetActor(uintptr_t Pawn)
    {
        auto v20 = __ROL8__(*(_QWORD*)(Pawn + 0x18), 0x3B);
        return (v20 ^ 0xFFD610B113C001EDuLL) + (retaddr >> 0x21);


    }





   // uint64_t GetLocalEntity() {
   //
   //
   //     signed __int64 v2; // r9
   //     signed __int64 v3; // rax
   //     unsigned int v4; // eax
   //     signed __int64 v5; // r11
   //     int v6; // r11d
   //     signed __int64 v7; // r9
   //     int v8; // r9d
   //     unsigned __int64 v9; // rax
   //     signed __int64 v10; // rcx
   //     unsigned __int64 v11; // rax
   //     signed __int64 v12; // rcx
   //     unsigned __int64 v13; // r9
   //     signed __int64 v14; // r11
   //     char v15; // r11
   //     signed __int64 v16; // rcx
   //     unsigned __int64 v18; // rax
   //     signed __int64 v19; // r9
   //     int v20; // r11d
   //     signed __int64 v21; // r9
   //     signed __int64 v22; // r9
   //     signed __int64 v23; // r9
   //     signed __int64 v24; // r9
   //     int v25; // r11d
   //     signed __int64 v26; // r9
   //     unsigned __int64 v27; // r14
   //     unsigned __int64 v28; // rax
   //     unsigned __int64 v29; // r9
   //     unsigned __int64 v30; // rdx
   //     __int64 v31; // rdx
   //     unsigned __int64 v32; // rax
   //     unsigned __int64 v33; // r9
   //     unsigned __int64 v34; // rdx
   //     unsigned __int64 v35; // r12
   //     unsigned __int64 v36; // rsi
   //     __int64 v37; // r15
   //     __int64 v38; // r11
   //     unsigned int* v39; // rax
   //     int v40; // r9d
   //     __int64 v41; // r10
   //     _DWORD* v42; // rdx
   //     __int64 v43; // r8
   //     bool v44; // zf
   //     int v45; // ecx
   //     unsigned int v46; // r11d
   //     __int64 v47; // r12
   //     unsigned int v48; // r11d
   //     __int64 v49; // rax
   //     __int64 v50; // rdx
   //     __int64 v51; // r9
   //     __int64 v52; // r11
   //     __int64 v53; // r10
   //     __int64 v54; // rdx
   //     unsigned __int64 v55; // rcx
   //     unsigned __int64 v56; // rbx
   //     unsigned __int64 v57; // rdx
   //     __int64 v58; // r9
   //     __int64 v59; // rcx
   //     unsigned __int64 v60; // rcx
   //     __int64 v61; // r10
   //     __int64 result; // rax
   //     char v63; // bl
   //     __int64 v64; // r10
   //     unsigned int v65; // r10d
   //     _BYTE* v66; // r12
   //     _BYTE* v67; // rcx
   //     _BYTE* v68; // r10
   //     unsigned int v69; // ebx
   //     _BYTE* v70; // rbx
   //     _DWORD* v71; // r13
   //     char* v72; // rdi
   //     __int64 v73; // rdi
   //     unsigned int v74; // esi
   //     __int64 v75; // rcx
   //     __int64 v76; // rdi
   //     __int64 v77; // r15
   //     unsigned __int64 v78; // [rsp+28h] [rbp-60h]
   //     __int64** v79; // [rsp+30h] [rbp-58h] BYREF
   //     __int64* v80; // [rsp+38h] [rbp-50h] BYREF
   //     unsigned __int64 v81; // [rsp+40h] [rbp-48h]
   //
   //     int v83; // r9d
   //     __int64 v84; // rdi
   //     __int64 v85; // rbp
   //     __int64 v87; // r10
   //     __int64 v88; // r10
   //     __int64* v89; // r13
   //     unsigned __int64 v90; // r9
   //     unsigned __int64 v91; // r9
   //     unsigned __int64 v92; // rdx
   //     unsigned __int64 v93; // r9
   //     unsigned __int64 v94; // rcx
   //     unsigned __int64 v95; // r9
   //     unsigned __int64 v96; // rax
   //     unsigned __int64 v97; // rdx
   //     unsigned __int64 v98; // r10
   //     __int64 v99; // r11
   //     __int64 v100; // r10
   //     __int64 v101; // r12
   //     unsigned __int64 v102; // r10
   //     unsigned __int64 v103; // r10
   //     unsigned __int64 v104; // rax
   //     unsigned __int64 v105; // rdx
   //     unsigned __int64 v106; // rax
   //     __int64 v107; // r12
   //     __int64 v108; // r10
   //     unsigned __int64 v109; // rax
   //     unsigned __int64 v110; // rdx
   //     unsigned __int64 v111; // rax
   //     _DWORD** v112; // rax
   //     _DWORD* v113; // rdx
   //     __int64 v114; // r9
   //     __int64 v115; // rcx
   //     __int64 v116; // r8
   //     unsigned int v117; // r11d
   //     unsigned __int64 v118; // rax
   //     unsigned __int64 v119; // rax
   //     unsigned __int64 v120; // rdx
   //     unsigned __int64 v121; // r10
   //     unsigned __int64 v122; // rbx
   //     unsigned __int64 v123; // rax
   //     unsigned __int64 v124; // rdx
   //     unsigned int v125; // r11d
   //     _QWORD* v126; // r10
   //     __int64 v127; // r8
   //     int v128; // r9d
   //     __int64 v129; // rdi
   //     __int64 v130; // rbp
   //     char* v131; // rdx
   //     char* v132; // r12
   //     __int64 v133; // r9
   //     __int64 v134; // r8
   //     int v135; // r9d
   //     __int64 v136; // r9
   //     __int64 v137; // r8
   //     int v138; // r9d
   //     __int64 v139; // rdi
   //     __int64 v140; // rbp
   //     char* v141; // rdx
   //     char* v142; // r12
   //     __int64 v143; // r9
   //     __int64 v144; // r8
   //     int v145; // r9d
   //     unsigned __int64 v146; // r10
   //     unsigned __int64 v147; // rdx
   //     unsigned __int64 v148; // r9
   //     __int64 v149; // rdx
   //     int v150; // r9d
   //     int v151; // r9d
   //     unsigned __int64 v152; // r10
   //     unsigned __int64 v153; // rdx
   //     unsigned __int64 v154; // r9
   //     __int64 v155; // rdx
   //     int v156; // r9d
   //     int v157; // r9d
   //     unsigned __int64 v158; // r10
   //     unsigned __int64 v159; // rdx
   //     unsigned __int64 v160; // r9
   //     __int64 v161; // rdx
   //     int v162; // r9d
   //     int v163; // r9d
   //     unsigned __int64 v164; // r10
   //     unsigned __int64 v165; // rdx
   //     unsigned __int64 v166; // r9
   //     __int64 v167; // rdx
   //     int v168; // r9d
   //     int v169; // r9d
   //     unsigned __int64 v170; // r10
   //     unsigned __int64 v171; // rdx
   //     unsigned __int64 v172; // r9
   //     __int64 v173; // rdx
   //     int v174; // r9d
   //     int v175; // r9d
   //     unsigned __int64 v176; // r10
   //     unsigned __int64 v177; // rdx
   //     unsigned __int64 v178; // r9
   //     __int64 v179; // rdx
   //     int v180; // r9d
   //     int v181; // r9d
   //     unsigned __int64 v182; // [rsp+40h] [rbp-78h]
   //     __int64** v183; // [rsp+48h] [rbp-70h] BYREF
   //     __int64* v184; // [rsp+50h] [rbp-68h] BYREF
   //     __int64 v185; // [rsp+58h] [rbp-60h]
   //     unsigned __int64 v186; // [rsp+60h] [rbp-58h]
   //     unsigned __int64 v187; // [rsp+68h] [rbp-50h]
   //     unsigned __int64 v188; // [rsp+70h] [rbp-48h]
   //     unsigned __int64 v203; // rbp
   //     __int64 v204; // r8
   //     unsigned __int64 v205; // r12
   //     unsigned __int64 v206; // r10
   //     __int64 v207; // rax
   //     __int64 v208; // rdi
   //     __int64 v209; // rax
   //     unsigned int* v210; // r8
   //     int v211; // r10d
   //     __int64 v212; // rdx
   //     __int64 v213; // rax
   //     int v214; // eax
   //     unsigned int v215; // ecx
   //     __int64 v216; // r14
   //     __int64 v217; // rax
   //     int v218; // r10d
   //     __int64 v219; // rax
   //     int v220; // eax
   //     unsigned int v221; // ecx
   //     unsigned __int64 v222; // rax
   //     unsigned __int64 v223; // rdx
   //     __int64 v224; // r14
   //     unsigned __int64 v226; // rcx
   //     __int64 v227; // r15
   //     unsigned __int64 v228; // r14
   //     __int64 v229; // r12
   //     __int64 v230; // r8
   //     unsigned __int64 v231; // rcx
   //     unsigned __int64 v232; // r10
   //     unsigned __int64 v233; // r14
   //     __int64 v234; // r8
   //     __int64 v235; // rcx
   //     unsigned __int64 v236; // rax
   //     unsigned __int64 v237; // rdx
   //     __int64 v238; // r12
   //     unsigned __int64 v239; // rcx
   //     unsigned __int64 v240; // rbp
   //     __int64 v241; // r14
   //     unsigned __int64 v242; // rdx
   //     __int64 v243; // r8
   //     char* v244; // rdx
   //     char* v246; // r8
   //     char* v247; // rdx
   //     __int64 v248; // r9
   //     char v249; // r9
   //     unsigned __int8 v250; // r9
   //     volatile signed __int32* v251; // rbx
   //     unsigned __int64 v252; // rax
   //     unsigned __int64 v253; // rdx
   //     unsigned __int64 v254; // rcx
   //     unsigned __int64 v255; // rcx
   //     unsigned __int64 v256; // rdx
   //     unsigned __int64 v257; // rcx
   //     unsigned __int64 v258; // rcx
   //     unsigned __int64 v259; // rdx
   //     __int64 v261; // [rsp+30h] [rbp-A8h]
   //     char v262; // [rsp+38h] [rbp-A0h]
   //     __int64 v263; // [rsp+40h] [rbp-98h]
   //     __int64 v264; // [rsp+48h] [rbp-90h]
   //     unsigned __int64 v265; // [rsp+58h] [rbp-80h]
   //     unsigned __int64 v266; // [rsp+60h] [rbp-78h]
   //     __int64 v267; // [rsp+68h] [rbp-70h]
   //     unsigned __int64 v268; // [rsp+70h] [rbp-68h]
   //     unsigned __int64 v269; // [rsp+78h] [rbp-60h] BYREF
   //     unsigned __int64 v270; // [rsp+80h] [rbp-58h]
   //     __int64 v271; // [rsp+88h] [rbp-50h]
   //     __int64 v272[9]; // [rsp+90h] [rbp-48h] BYREF
   //
   //
   //     v256 = retaddr;
   //     const auto qword_DE1B340 = *reinterpret_cast<uintptr_t*>(client + 0xDE1B340);
   //     if (!qword_DE1B340)
   //         return 0;
   //
   //     v31 = __ROR8__(NtCurrentPeb(), 0xC) ^ 0x2FE0CC1072234949i64;
   //     v32 = v31 + (retaddr >> 0x21);
   //     LODWORD(v183) = (_DWORD)0x57E1E9C + 5;
   //     v33 = (unsigned int)0x57E1EA3 + 1 - ((unsigned int)0x57E1E9C + 5);
   //     if (HIDWORD(v32))
   //         v34 = (v31 + (retaddr >> 0x21)) % v33;
   //     else
   //         v34 = (unsigned int)v32 % (unsigned int)v33;
   //     v187 = v34;
   //     LODWORD(v183) = 0xF2DB46F9;
   //     if (v34)
   //     {
   //         v188 = v187;
   //         LODWORD(v183) = 0x9AF7C5A0;
   //         if (v187 == 1)
   //         {
   //             v35 = ((qword_DE1B340 + 0x2FE0CC105FA1E781i64) << 0x20) & 0xFF00000000000000ui64 | ((unsigned int)0xFEFFFC + 4) & (unsigned int)((unsigned __int64)(qword_DE1B340 + 0x2FE0CC105FA1E781i64) >> 0x10) | (unsigned __int8)((unsigned __int64)(qword_DE1B340 + 0x2FE0CC105FA1E781i64) >> 0x30) | (((_DWORD)qword_DE1B340 + 0x5FA1E781) << 8) & 0xFF000000 | ((unsigned __int64)(qword_DE1B340 + 0x2FE0CC105FA1E781i64) >> 0x18) & 0xFF00000000i64 | ((qword_DE1B340 + 0x2FE0CC105FA1E781i64) << 0x30) & 0xFF000000000000i64 | (qword_DE1B340 + 0x2FE0CC105FA1E781i64) & 0xFF000000FF00i64;
   //         }
   //         else
   //         {
   //             v183 = (__int64**)v188;
   //             v35 = ((qword_DE1B340 << 0x30) & 0xFF000000000000i64)
   //                 + (((_DWORD)qword_DE1B340 << 8) & 0xFF000000)
   //                 + (((unsigned __int64)qword_DE1B340 >> 0x18) & 0xFF00000000i64)
   //                 + ((qword_DE1B340 << 0x20) & 0xFF00000000000000ui64)
   //                 + (((unsigned int)0xFEFFFC + 4) & (unsigned int)((unsigned __int64)qword_DE1B340 >> 0x10))
   //                 + BYTE6(qword_DE1B340)
   //                 + (qword_DE1B340 & 0xFF000000FF00i64)
   //                 + 0x2FE0CC105FA1E781i64;
   //         }
   //     }
   //     else
   //     {
   //         v35 = (((qword_DE1B340 - 0x7B) << 0x30) & 0xFF000000000000i64)
   //             + ((((_DWORD)qword_DE1B340 - 0x7B) << 8) & 0xFF000000)
   //             + (((unsigned __int64)(qword_DE1B340 - 0x7B) >> 0x18) & 0xFF00000000i64)
   //             + (((qword_DE1B340 - 0x7B) << 0x20) & 0xFF00000000000000ui64)
   //             + (((unsigned int)0xFEFFFC + 4) & (unsigned int)((unsigned __int64)(qword_DE1B340 - 0x7B) >> 0x10))
   //             + (unsigned __int8)((unsigned __int64)(qword_DE1B340 - 0x7B) >> 0x30)
   //             + ((qword_DE1B340 - 0x7B) & 0xFF000000FF00i64)
   //             + 0x2FE0CC105FA1E781i64
   //             + 0x7B;
   //     }
   //
   //    
   //
   //
   //
   //     v188 = ((0x25DD5154FFEF38B2i64 - ((unsigned __int64)NtCurrentPeb() >> 0xC) - 0x1B8DA404) ^ (retaddr >> 0x21)) % 2;
   //     LODWORD(v183) = (_DWORD)0x416290B + 3;
   //     if (v188 != (_DWORD)0x416290B + 3 - ((unsigned int)0x416290B + 3))
   //     {
   //         v183 = (__int64**)v188;
   //         v48 = (unsigned int)*(_QWORD*)(v35 + 0x48) >> 8;
   //         v49 = (*(_QWORD*)(v35 + 0x48) << 0x18) & 0xFF000000000000i64;
   //         v50 = ((unsigned int)0xFEFFFC + 4) & (unsigned int)(*(_QWORD*)(v35 + 0x48) >> 0x10) | *(_QWORD*)(v35 + 0x48) & 0xFF0000000000i64 | (*(_QWORD*)(v35 + 0x48) >> 0x18) & 0xFF000000i64;
   //         v51 = (*(_QWORD*)(v35 + 0x48) << 0x38) | (*(_QWORD*)(v35 + 0x48) >> 0x18) & 0xFF00000000i64;
   //         v37 = ((v50 | v51 | v49 | (unsigned __int16)v48) ^ 0x25DD5154FFEF38B2i64) - 0x5B;
   //         if (((v50 | v51 | v49 | (unsigned __int16)v48) ^ 0x25DD5154FFEF38B2i64) != 0x5B)
   //             goto LABEL_52;
   //     LABEL_65:
   //         v27 = retaddr;
   //
   //     }
   //     v37 = ((((unsigned int)0xFEFFFC + 4) & (unsigned int)(*(_QWORD*)(v35 + 0x48) >> 0x10))
   //         + ((*(_QWORD*)(v35 + 0x48) << 0x18) & 0xFF000000000000i64)
   //         + ((*(_QWORD*)(v35 + 0x48) << 0x38) | *(_QWORD*)(v35 + 0x48) & 0xFF0000000000i64)
   //         + ((*(_QWORD*)(v35 + 0x48) >> 0x18) & 0xFF000000i64)
   //         + ((*(_QWORD*)(v35 + 0x48) >> 0x18) & 0xFF00000000i64)
   //         + (unsigned __int16)((unsigned int)*(_QWORD*)(v35 + 0x48) >> 8)
   //         - 0x5B) ^ 0x25DD5154FFEF38B2i64;
   //     if (!v37)
   //         return 0;
   // LABEL_52:
   //     
   //     
   //     v47 = *(_QWORD*)v37;
   //     
   //     uintptr_t v260;
   //     v222 = (__ROR8__(NtCurrentPeb(), 0xC) ^ 0xE290A962415AC774ui64) + (v256 >> 0x21);
   //     v260 = 0xB482866B;
   //     v223 = HIDWORD(v222) ? v222 % 4 : (unsigned int)v222 % 4;
   //     v272[0] = v223;
   //     v260 = 0x2D4A911C;
   //     if (v223)
   //     {
   //         v174 = 0xB8730A0AC21DE108ui64;
   //         v173 = 0xA51C5C977CB8D98Cui64;
   //         v265 = v272[0];
   //         v260 = 0x6DD3D3E8;
   //         if (v272[0] == 1)
   //         {
   //             v173 = (*(_QWORD*)(v47 + 0x60) ^ 0xA51C5C977CB8D98Cui64) - 0x478CF5F53DE21EF8i64;
   //             v139 = v173;
   //         }
   //         else
   //         {
   //             v269 = v265;
   //             v260 = 0x87E83372;
   //             if (v265 != 2)
   //                 *(_QWORD*)&v260 = v269;
   //             v139 = (*(_QWORD*)(v47 + 0x60) - 0x478CF5F53DE21EF8i64) ^ 0xA51C5C977CB8D98Cui64;
   //         }
   //     }
   //     else
   //     {
   //         v173 = *(_QWORD*)(v47 + 0x60) ^ 0x72BC0EA5D0E34BC3i64;
   //         v174 = v173 - 0x478CF5F53DE21EF8i64;
   //         v139 = (v173 - 0x478CF5F53DE21EF8i64) ^ 0xD7A05232AC5B924Fui64;
   //     }
   //
   //
   //
   //
   //
   //     // if ((*(_QWORD*)(v47 + 0x60) ^ 0xA51C5C977CB8D98Cui64) == 0x478CF5F53DE21EF8i64)
   //
   //
   //
   //      //printf("v64 %llx \n", v60);
   //
   //
   //     return v139;
   //
   //
   //
   // }
















    Vector3 GetActorPos(uintptr_t Actor)
    {
        return *(Vector3*)(Actor + 0x50);
    }













    uint64_t GetReplication(uint64_t Entity)
    {
        uint64_t v69 = __ROL8__(*reinterpret_cast<const uint64_t*>(Entity + 0xF8), 4);


        uint64_t c1 = (((8ULL - 0x56A9B1C3E7C4E061ULL)) & 0xFFFFFFFFFFFFFFFFULL)
            ^ 0x827E2D3521269D4FULL;
        uint64_t v71 = v69 ^ c1;

 
        constexpr uint64_t c2 = 0xD26143A7ULL + 8ULL;
        uint64_t v73 = v71 ^ c2;

      
        constexpr uint64_t SHIFT = 33ULL;
        uint64_t Replication = v73 + (retaddr >> SHIFT);

        return Replication;
    }


    uint64_t GetOutlineComponent(uint64_t Actor)
    {
        uint64_t v14 = *reinterpret_cast<const uint64_t*>(Actor + 0x1D0);
        constexpr uint64_t pd = 8;
        constexpr uint64_t c1 = 0x31C5C5CE11A499E9ULL;
        constexpr uint64_t c2 = 0x5C5511C12730F411ULL;

      
        constexpr unsigned int rot = 51;

    
        uint64_t v16 = __ROL8__(v14 + pd - c1, rot);


        uint64_t result = v16 + pd - c2;

        return result;
    }

    int team(uint64_t Replication)
    {


        int v2; // r10d
        _DWORD* v3; // rbp
        int v4; // r10d
        __int64 v5; // rax
        __int64 v6; // rbx
        __int64 v7; // rcx
        __int64 v8; // r8
        _QWORD* v9; // r9
        unsigned __int64 v10; // rax
        unsigned __int64 v11; // rdx
        _QWORD* v12; // rsi
        unsigned __int64 v13; // rcx
        unsigned __int64 v14; // r11
        unsigned __int64 v15; // r11
        __int64 v16; // rcx
        __int64 v17; // r8
        __int64 v18; // rcx
        __int64 v19; // rcx
        unsigned __int64 v20; // rcx
        __int64 v21; // rdx
        unsigned __int64 v22; // rax
        unsigned __int64 v23; // r11
        unsigned __int64 v24; // rcx
        __int64 v25; // r10
        __int64 v26; // r8
        __int64 v27; // rax
        __int64 v28; // r8
        unsigned __int64 v29; // r8
        unsigned __int64 v30; // rcx
        unsigned __int64 v31; // rcx
        unsigned __int64 v32; // rax
        __int64 v33; // r14
        int v34; // r15d
        __int64 v35; // rcx
        char v36; // al
        __int64 v37; // r8
        __int64 v38; // rcx
        unsigned __int64 v39; // rax
        unsigned __int64 v40; // rdx
        int v41; // r10d
        __int64 v42; // r14
        __int64 v43; // rbx
        __int64 v44; // r8
        __int64 v45; // r8
        __int64 v46; // r15
        __int64 v47; // r14
        unsigned int v48; // r13d
        unsigned int v49; // r8d
        __int64 v50; // rcx
        unsigned __int64 v51; // rdx
        unsigned __int64 v52; // rcx
        __int64 v53; // rdx
        int v54; // r9d
        unsigned int v55; // r9d
        unsigned __int64 v56; // rcx
        __int64 v57; // r12
        unsigned __int64 v58; // rcx
        __int64 v59; // r8
        __int64 v60; // rcx
        unsigned __int64 v61; // r13
        __int64 v62; // rbx
        __int64 v63; // rbp
        bool v64; // zf
        __int64 v65; // r8
        signed __int32 v66; // eax
        __int64 v67; // rcx
        __int64 v68; // r12
        __int64 v69; // r14
        __int64 v70; // r8
        signed __int32 v71; // eax
        __int64 v72; // rcx
        __int64 result; // rax
        __int64 v74; // rbp
        __int64 v75; // rax
        unsigned __int64 v76; // r14
        __int64 v77; // r11
        char v78; // r10
        unsigned __int8 v79; // r10
        volatile signed __int32* v80; // rdi
        unsigned __int64 v81; // r8
        _QWORD* v82; // r11
        unsigned __int64 v83; // r8
        unsigned __int64 v84; // r11
        unsigned __int64 v85; // r11
        unsigned __int64 v86; // r8
        __int64 v87; // r8
        unsigned __int64 v88; // rcx
        unsigned __int64 v89; // rcx
        unsigned __int64 v90; // r10
        __int64 v91; // rcx
        unsigned __int64 v92; // rcx
        unsigned __int64 v93; // rax
        __int64 v94; // rdx
        unsigned __int64 v95; // r8
        unsigned __int64 v96; // r11
        __int64 v97; // rdx
        __int64 v98; // rax
        __int64 v99; // r9
        __int64 v100; // r10
        __int64 v101; // rsi
        unsigned __int64 v102; // r10
        unsigned __int64 v104; // rdx
        unsigned __int64 v105; // r11
        unsigned __int64 v106; // rax
        __int64 v107; // rdx
        __int64 v108; // rsi
        __int64 v109; // r8
        unsigned __int64 v110; // rax
        unsigned __int64 v111; // rdx
        __int64 v112; // rcx
        unsigned __int64 v113; // rcx
        _DWORD** v114; // rax
        _DWORD* v115; // rax
        __int64 v116; // rcx
        __int64 v117; // rdx
        int Team; // r10d
        unsigned __int64 v119; // rcx
        unsigned __int64 v120; // rax
        unsigned __int64 v121; // rdx
        unsigned __int64 Teamcheclcomp; // r8
        unsigned __int64 v123; // r14
        __int64 v124; // rcx
        __int64 v125; // r13
        unsigned __int64 v126; // rax
        unsigned __int64 v127; // r8
        unsigned __int64 v128; // rax
        __int64 v129; // rdx
        int v130; // r9d
        unsigned int v131; // ecx
        unsigned int v132; // r10d
        unsigned int v133; // r10d
        int v134; // r9d
        unsigned int v135; // ecx
        int v136; // r10d
        __int64 v137; // [rsp+68h] [rbp-90h] BYREF
        __int64 v138; // [rsp+70h] [rbp-88h]
        int v139; // [rsp+78h] [rbp-80h]
        char v140; // [rsp+7Ch] [rbp-7Ch]
        _QWORD* v141; // [rsp+88h] [rbp-70h]
        unsigned __int64 v143; // [rsp+98h] [rbp-60h]
        __int64 v144; // [rsp+A0h] [rbp-58h]
        unsigned __int64 v145; // [rsp+A8h] [rbp-50h]
        unsigned __int64 v146; // [rsp+B0h] [rbp-48h]
        auto v142 = retaddr;
        v120 = (__ROR8__(__readgsqword((int)0x1188A6B2 - (int)0x1188A652), 0xC) ^ 0x7F5E685BA72824ACi64)
            + (v142 >> 0x21);
        LODWORD(v137) = 0x6DD3D3E8;
        if (HIDWORD(v120))
            v121 = v120 % 3;
        else
            v121 = (unsigned int)v120 % 3;
        v143 = v121;
        LODWORD(v137) = (_DWORD)0x1921BE5;
        if (v121 == (_DWORD)0x1921BE5 - (unsigned int)0x1921BE5)
        {
            Teamcheclcomp = (((*(_QWORD*)(Replication + 0x778) << 0x18) & 0xFF000000000000i64 | (unsigned __int8)BYTE4(*(_QWORD*)(Replication + 0x778)) | ((unsigned int)0xFEFFFC + 4) & (unsigned int)(*(_QWORD*)(Replication + 0x778) >> 0x18) | (*(_QWORD*)(Replication + 0x778) >> 8) & 0xFF0000000000i64 | (*(_QWORD*)(Replication + 0x778) << 0x28) & 0xFF00000000000000ui64 | (*(_QWORD*)(Replication + 0x778) << 0x18) & 0xFF00000000i64 | (unsigned __int16)((unsigned __int16)*(_QWORD*)(Replication + 0x778) << 8) | (unsigned __int64)((unsigned int)HIDWORD(*(_QWORD*)(Replication + 0x778)) & 0xFF000000))
                + 0x7F37EA740DE661DFi64) ^ 0x69822F39BB4892i64;
        }
        else
        {
            v144 = v143;
            LODWORD(v137) = (_DWORD)0x57E1E9C + 5;
            if (v143 == (_DWORD)0x57E1E9C + 5 - 0x57E1EA0)
            {
                Teamcheclcomp = (((*(_QWORD*)(Replication + 0x778) << 0x18) & 0xFF000000000000i64 | (unsigned __int8)BYTE4(*(_QWORD*)(Replication + 0x778)) | ((unsigned int)0xFEFFFC + 4) & (unsigned int)(*(_QWORD*)(Replication + 0x778) >> 0x18) | (*(_QWORD*)(Replication + 0x778) >> 8) & 0xFF0000000000i64 | (*(_QWORD*)(Replication + 0x778) << 0x28) & 0xFF00000000000000ui64 | (*(_QWORD*)(Replication + 0x778) << 0x18) & 0xFF00000000i64 | (unsigned __int16)((unsigned __int16)*(_QWORD*)(Replication + 0x778) << 8) | (unsigned __int64)((unsigned int)HIDWORD(*(_QWORD*)(Replication + 0x778)) & 0xFF000000)) ^ 0x69822F39BB4892i64)
                    + 0x7F37EA740DE661DFi64;
            }
            else
            {
                v137 = v144;
                v123 = (*(_QWORD*)(Replication + 0x778) + 0x7F37EA740DE661DFi64) ^ 0x69822F39BB4892i64;
                v124 = (unsigned __int16)((_WORD)v123 << 8);
                v125 = (v123 << 0x18) & 0xFF00000000i64;
                v126 = (v123 << 0x28) & 0xFF00000000000000ui64;
                v127 = HIDWORD(v123);
                v33 = (v123 << 0x18) & 0xFF000000000000i64 | BYTE4(v123) | ((unsigned int)0xFEFFFC + 4) & (unsigned int)(v123 >> 0x18) | (v123 >> 8) & 0xFF0000000000i64;
                Teamcheclcomp = v33 | v126 | v125 | v124 | (unsigned int)v127 & 0xFF000000;
            }
        }
        v128 = __ROR8__(NtCurrentPeb(), 0xC) - (v142 >> 0x21) + 0x4B0A3F84;
        LODWORD(v137) = 0xCE334A0F;
        if (HIDWORD(v128))
            v129 = v128 % 2;
        else
            v129 = (unsigned int)v128 % 2;
        v144 = v129;
        LODWORD(v137) = 0xEBB9C440;
        if (v129)
        {
            v137 = v144;
            v133 = __ROL4__(*(_DWORD*)(Teamcheclcomp + 0xB0) - 0x1F, 0xA);
            v134 = v133 << 0x18;
            v135 = ((unsigned int)0xFEFFFC + 4) & (v133 << 8);
            v133 >>= 0x10;
            v28 = (unsigned __int8)v133;
            Team = (unsigned __int8)v133 | v135 | v134 | v133 & 0xFF00;
        }
        else
        {
            v130 = (*(_DWORD*)(Teamcheclcomp + 0xB0) - 0x1F) << 0x18;
            v131 = ((unsigned int)0xFEFFFC + 4) & ((*(_DWORD*)(Teamcheclcomp + 0xB0) - 0x1F) << 8);
            v132 = (unsigned int)(*(_DWORD*)(Teamcheclcomp + 0xB0) - 0x1F) >> 0x10;
            v28 = (unsigned __int8)v132;
            Team = __ROL4__((unsigned __int8)v132 | v131 | v130 | v132 & 0xFF00, 0xA);
        }

        return Team;


    }



  

    uint32_t GetActorHealth(uint64_t Actor)
    {

        char v19; // r10
        unsigned __int64 v20; // rsi
        unsigned __int64 v21; // rdx
        char v22; // r10
        unsigned __int64 v23; // rsi
        unsigned __int64 v24; // rdx
        int v25; // r9d
        unsigned int v26; // esi
        __int64 v27; // r9
        __int64 v28; // rcx
        __int64 v29; // rax
        __int64 v30; // r9
        __int64 v31; // rdx
        int v32; // r10d
        int v33; // r9d
        unsigned int Health; // esi
        __int64 v35; // r9
        __int64 v36; // rcx
        __int64 v37; // rax
        __int64 v38; // r9
        __int64 v39; // rdx
        int v40; // r10d
        __int64 v41; // rcx
        __int64 v42; // r8
        __int64 v43; // rcx
        __int64 v44; // rcx
        __int64 v34; // r8
        __int64 v46; // rcx
        int v47; // eax
        auto DamageComponentID = *reinterpret_cast<uint8_t*>(Actor + 0x232);
        auto Damagecomponent = *reinterpret_cast<uint64_t*>(*reinterpret_cast<uint64_t*>(Actor + 0xD8) + DamageComponentID * 8ul);
        Health = *((_DWORD*)Damagecomponent + 0x63) - 0x58;
        //int healthvalue = 50000;
        //*reinterpret_cast<uint32_t*>(Damagecomponent + 0x63) = *reinterpret_cast<uint32_t*>(&healthvalue) + 0x58;
        return Health;
    }





    char getplayernames(uintptr_t Replication)
    {

        return  (*(char*)(Replication + 0x790));
    }





    //Vector3 TransformToVector(uintptr_t BoneArray, __m128 BoneInfo)
    //{
    //	typedef uint64_t(__fastcall* team3443)(uintptr_t a1, __int64 a2);
    //	auto bonetransform = (team3443)(client + 0x4937A60);
    //
    //	alignas(16) uint8_t buffer[0x20] = { 0 };
    ////	printf("Buffer Address: %p\n", buffer);
    //	uint64_t finalll = spoof_call(bonetransform, BoneArray, reinterpret_cast<__int64>(buffer));
    //	DebugPrint("finalll Address: %p\n", finalll);
    //	__m128 base_val_1 = *reinterpret_cast<__m128*>(finalll + 0x10);
    //	__m128 base_val_2 = *reinterpret_cast<__m128*>(finalll);
    //
    //	constexpr __m128 const_val_1 = { 0.5, 0.5, 0.5, 0.5 };
    //	constexpr __m128 const_val_2 = { 2.0, 2.0, 2.0, 0.0 };
    //
    //	__m128 Out = {};
    //
    //	auto v35 = _mm_mul_ps(base_val_1, BoneInfo);
    //	auto v36 = _mm_shuffle_ps(v35, v35, 0x55);
    //	v36.m128_f32[0] = (float)(v36.m128_f32[0] + *(float*)_mm_unpackhi_ps(v35, v35).m128_i64) + v35.m128_f32[0];
    //	auto v37 = _mm_sub_ps(
    //		_mm_mul_ps(_mm_shuffle_ps(base_val_1, base_val_1, 0xD2), BoneInfo),
    //		_mm_mul_ps(_mm_shuffle_ps(BoneInfo, BoneInfo, 0xD2), base_val_1));
    //	auto v38 = _mm_mul_ps(_mm_shuffle_ps(base_val_1, base_val_1, 0xFF), _mm_shuffle_ps(v37, v37, 0xD2));
    //	auto v39 = _mm_mul_ps(_mm_shuffle_ps(v36, v36, 0), base_val_1);
    //	auto v40 = _mm_mul_ps(base_val_1, base_val_1);
    //	Out = _mm_add_ps(
    //		_mm_shuffle_ps(base_val_2, _mm_shuffle_ps({ 0, 0, 0, 0 }, base_val_2, 0x20), 0x24), // maybe 0xE4 instead of 20
    //		_mm_mul_ps(
    //			_mm_add_ps(
    //				_mm_add_ps(
    //					_mm_mul_ps(_mm_sub_ps(_mm_shuffle_ps(v40, v40, 0xFF), (__m128)const_val_1), BoneInfo),
    //					v38),
    //				v39),
    //			const_val_2));
    //
    //	return { Out.m128_f32[0], Out.m128_f32[1], Out.m128_f32[2] };
    //}





    uint16_t GetID(uintptr_t actor, uint32_t hash)
    {
        uint64_t v33;

        auto v24 = *(uint8_t*)(actor + 0x220); //232
        if (v24 != 0xFF)
        {
            auto v25 = *(uint64_t*)(*(uint64_t*)(actor + 0xD8) + 8 * v24);
            if (v25)
            {
                auto v27 = *(uint64_t*)(v25 + 0x108); //60
                if (v27)
                {
                    auto v28 = *(uint64_t*)(v27 + 0x50);
                    auto v29 = (unsigned int)(8 * *(uint32_t*)(v27 + 0x58));
                    auto v30 = v28;
                    if ((uint32_t)v29)
                    {
                        auto v31 = (unsigned int)v29 >> 3;
                        v30 = v28;
                        do
                        {
                            auto v32 = v31 >> 1;
                            v33 = v31 + ~(v31 >> 1);
                            auto v34 = *(uint32_t*)(v30 + 8 * (v31 >> 1)) < hash;
                            auto v35 = v30 + 8 * (v31 >> 1) + 8;
                            if (v34)
                                v30 = v35;
                            if (!v34)
                                v33 = v32;
                            v31 = v33;
                        } while (v33 > 0);
                    }
                    if (v30 != v29 + v28 && *(uint32_t*)(v30) == hash)
                    {
                        uint16_t BoneID = *(uint16_t*)(v30 + 4);
                        if (BoneID != 0xFFFF)
                        {
                            return BoneID;
                        }
                    }
                }
            }
        }
        return 0;
    }









    Vector3 TransformToVectorr(uintptr_t BoneArray, __m128 BoneInfo)
    {
        constexpr __m128 const_val_1 = { 0.5f, 0.5f, 0.5f, 0.5f };
        constexpr __m128 const_val_2 = { 2.0f, 2.0f, 2.0f, 0.0f };
        unsigned __int64 v3; // r8
        __int64 result; // rax
        unsigned __int64 v5; // r8
        unsigned __int64 v6; // r11
        __int64 v7; // r9
        __int64 v8; // r8
        __int64 v9; // r11
        _QWORD* v10; // rbx
        __int64 v11; // rdx
        __int64 v12; // rcx
        __int64 v13; // r11
        unsigned __int64 v14; // r10
        __int64 v15; // r9
        __int64 v16; // rax
        bool v17; // cf
        __int64 v18; // r10
        __int64 v19; // rcx
        unsigned __int64 v20; // rax
        unsigned __int64 v21; // rdx
        __int64 v22; // rcx
        __int64 v23; // r12
        _QWORD* ThreadLocalStoragePointer; // rdx
        __int64 v25; // r8
        _QWORD* v26; // r10
        __int64 v27; // rdx
        unsigned __int64 v28; // rax
        unsigned __int64 v29; // rdx
        unsigned __int64 v30; // r10
        unsigned __int64 v31; // rcx
        unsigned __int64 v32; // rcx
        unsigned __int64 v33; // rcx
        unsigned __int64 v34; // r9
        unsigned __int64 v35; // rax
        unsigned __int64 v36; // rcx
        unsigned __int64 v37; // rdx
        unsigned int v38; // ecx
        unsigned int v39; // edx
        unsigned __int16 v40; // r9
        unsigned __int64 v41; // rcx
        unsigned __int64 v42; // rcx
        unsigned __int64 v43; // rcx
        __m128 v44; // xmm15
        unsigned __int64 v45; // rcx
        unsigned __int64 v46; // rdx
        unsigned __int64 v47; // rcx
        unsigned __int64 v48; // rdx
        unsigned __int64 v49; // rcx
        unsigned __int64 v50; // rdx
        unsigned __int64 v51; // rdx
        unsigned __int64 v52; // rax
        __m128i v53; // xmm9
        __m128i v54; // xmm7
        __m128i v55; // xmm14
        __m128i v56; // xmm8
        __m128 v57; // xmm7
        __m128 v58; // xmm8
        __m128 v59; // xmm9
        __m128 v60; // xmm2
        __m128 v61; // xmm1
        __m128 v62; // xmm2
        __m128 v63; // xmm4
        __m128 v64; // xmm1
        __m128 v65; // xmm8
        unsigned __int64 v66; // [rsp+38h] [rbp-C0h]
        unsigned __int64 v67; // [rsp+38h] [rbp-C0h]
        unsigned __int64 v68; // [rsp+40h] [rbp-B8h]


        __m128 Out = {};


        v67 = ((0x43C65AC00BF526AFi64 - ((unsigned __int64)NtCurrentPeb() >> 0xC)) ^ (retaddr >> 0x21)) % 3;
        if (v67)
        {
            result = 0xAEC25AEC111621F7ui64;
            if (v67 == 1)
            {
                v49 = __ROL8__(*(_QWORD*)(BoneArray + 0x30), 0x19);
                v47 = ((v49 << 0x18) & 0xFF000000000000i64 | (v49 << 8) & 0xFF0000000000i64 | WORD2(v49) & 0xFF00 | (v49 >> 0x18) & 0xFF000000 | (v49 << 0x28) & 0xFF00000000000000ui64 | BYTE1(v49) | (v49 << 0x20) & 0xFF00000000i64 | (v49 >> 0x28) & 0xFF0000)
                    - 0x43C65AC045B9FB4Ci64;
                v50 = __ROL8__(*(_QWORD*)(BoneArray + 0x38), 0x19);
                v48 = ((v50 << 0x18) & 0xFF000000000000i64 | (v50 << 8) & 0xFF0000000000i64 | WORD2(v50) & 0xFF00 | (v50 >> 0x18) & 0xFF000000 | (v50 << 0x28) & 0xFF00000000000000ui64 | BYTE1(v50) | (v50 << 0x20) & 0xFF00000000i64 | (v50 >> 0x28) & 0xFF0000)
                    - 0x513DA513EEE9DE09i64;
            }
            else
            {
                v51 = *(_QWORD*)(BoneArray + 0x30) - 0x43C65AC045B9FB4Ci64;
                v52 = *(_QWORD*)(BoneArray + 0x38) - 0x513DA513EEE9DE09i64;
                result = __ROL8__(
                    (v52 << 0x18) & 0xFF000000000000i64 | (v52 << 8) & 0xFF0000000000i64 | WORD2(v52) & 0xFF00 | (v52 >> 0x18) & 0xFF000000 | (v52 << 0x28) & 0xFF00000000000000ui64 | BYTE1(v52) | (v52 << 0x20) & 0xFF00000000i64 | (v52 >> 0x28) & 0xFF0000,
                    0x19);
                v47 = __ROL8__(
                    (v51 << 0x18) & 0xFF000000000000i64 | (v51 << 8) & 0xFF0000000000i64 | WORD2(v51) & 0xFF00 | (v51 >> 0x18) & 0xFF000000 | (v51 << 0x28) & 0xFF00000000000000ui64 | BYTE1(v51) | (v51 << 0x20) & 0xFF00000000i64 | (v51 >> 0x28) & 0xFF0000,
                    0x19);
                v48 = result;
            }
        }
        else
        {
            v45 = __ROL8__(*(_QWORD*)(BoneArray + 0x30), 0x19) - 0x43C65AC045B9FB4Ci64;
            v46 = __ROL8__(*(_QWORD*)(BoneArray + 0x38), 0x19) - 0x513DA513EEE9DE09i64;
            v47 = (v45 << 0x18) & 0xFF000000000000i64 | (v45 << 8) & 0xFF0000000000i64 | WORD2(v45) & 0xFF00 | (v45 >> 0x18) & 0xFF000000 | (v45 << 0x28) & 0xFF00000000000000ui64 | BYTE1(v45) | (v45 << 0x20) & 0xFF00000000i64 | (v45 >> 0x28) & 0xFF0000;
            result = (v46 << 0x20) & 0xFF00000000i64;
            v48 = (v46 << 0x18) & 0xFF000000000000i64 | (v46 << 8) & 0xFF0000000000i64 | WORD2(v46) & 0xFF00 | (v46 >> 0x18) & 0xFF000000 | (v46 << 0x28) & 0xFF00000000000000ui64 | BYTE1(v46) | result | (v46 >> 0x28) & 0xFF0000;
        }

        v53 = _mm_cvtsi64_si128(
            *(_QWORD*)(BoneArray + 0x58) + 0x4C2BDFA82F91759Di64
        );


        v54 = _mm_cvtsi64_si128(
            *(_QWORD*)(BoneArray + 0x50) - 0x24i64
        );


        v55 = _mm_cvtsi64_si128(v48);
        v56 = _mm_cvtsi64_si128(v47);


        v57 = _mm_castsi128_ps(_mm_unpacklo_epi64(v54, v53));


        v58 = _mm_castsi128_ps(_mm_unpacklo_epi64(v56, v55));



        v60 = _mm_mul_ps(BoneInfo, v58);
        v61 = _mm_shuffle_ps(v60, v60, 0x55);
        //v61.m128_f32[0] = (v61.m128_f32[0] + *(float*)_mm_unpackhi_pd((__m128d)v60, (__m128d)v60).m128d_f64)
        //    + v60.m128_f32[0];
        v61.m128_f32[0] = (float)(v61.m128_f32[0] + *(float*)_mm_unpackhi_ps(v60, v60).m128_i64)
            + v60.m128_f32[0];
        //v62 = _mm_sub_ps(
         //   _mm_mul_ps((__m128)_mm_shuffle_epi32((__m128i)v58, 0xD2), BoneInfo),
         //   _mm_mul_ps(_mm_shuffle_ps(BoneInfo, BoneInfo, 0xD2), v58));
        v62 = _mm_sub_ps(
            _mm_mul_ps(_mm_shuffle_ps(v58, v58, 0xD2), BoneInfo),
            _mm_mul_ps(_mm_shuffle_ps(BoneInfo, BoneInfo, 0xD2), v58));
        // v63 = _mm_mul_ps((__m128)_mm_shuffle_epi32((__m128i)v58, 0xFF), _mm_shuffle_ps(v62, v62, 0xD2));
        v63 = _mm_mul_ps(_mm_shuffle_ps(v58, v58, 0xFF), _mm_shuffle_ps(v62, v62, 0xD2));
        v64 = _mm_mul_ps(_mm_shuffle_ps(v61, v61, 0), v58);
        v65 = _mm_mul_ps(v58, v58);
        Out = _mm_add_ps(
            _mm_shuffle_ps(v57, _mm_shuffle_ps({ 0, 0, 0, 0 }, v57, 0x20), 0x24),
            _mm_mul_ps(
                _mm_add_ps(
                    _mm_add_ps(
                        _mm_mul_ps(_mm_sub_ps(_mm_shuffle_ps(v65, v65, 0xFF), (__m128)const_val_1), BoneInfo),
                        v63),
                    v64),
                const_val_2));


        return { Out.m128_f32[0], Out.m128_f32[1], Out.m128_f32[2] };
    }


    Vector3 GetBoneArray(uintptr_t Pawn, int index)
    {


        __m128* v3; // r11
        __int64 v6; // rcx
        __int64 v7; // rsi
        __int64 v8; // rcx
        __m128 v9; // xmm9
        char v10; // r15
        __int64 v11; // rdx
        __int64 v12; // rdx
        __int64 v14; // rdi
        __int64* v15; // rax
        unsigned __int64 v16; // rax
        unsigned __int64 v17; // rdx
        __int64 v18; // rbx
        unsigned __int64 v19; // rax
        __m128* v20; // rdx
        __m128 v21; // xmm10
        char v22; // di
        __m128* v23; // r15
        _QWORD* v24; // r9
        __int64 v25; // rdx
        unsigned __int64 v26; // rax
        unsigned __int64 v27; // rdx
        __int64 v28; // r8
        __m128* v29; // r15
        __int64 v30; // r11
        unsigned __int64 v31; // rdx
        __int64 v32; // r9
        __int64 v33; // rcx
        __int64 v34; // rax
        unsigned __int64 v35; // r8
        unsigned __int64 v36; // r12
        __int64 v37; // rdx
        unsigned __int64 v38; // rdx
        unsigned __int64 v39; // rdx
        unsigned __int64 v40; // rdx
        unsigned __int64 v41; // rax
        unsigned __int64 v42; // r9
        unsigned __int64 v43; // rdx
        unsigned int v44; // edx
        unsigned int v45; // ecx
        unsigned __int16 v46; // si
        unsigned __int64 v47; // rdx
        unsigned __int64 v48; // rdx
        unsigned __int64 v49; // rdx
        unsigned __int64 v50; // rcx
        unsigned __int64 v51; // rdx
        unsigned __int64 v52; // rcx
        unsigned __int64 v53; // rdx
        unsigned __int64 v54; // rcx
        unsigned __int64 v55; // rdx
        unsigned __int64 v56; // rdx
        unsigned __int64 v57; // rax
        __int64 v58; // rsi
        __int64 v59; // rbx
        __m128i v60; // xmm6
        __m128i v61; // xmm7
        __m128 v62; // xmm12
        __m128 v63; // xmm7
        __m128 v64; // xmm13
        __m128 v65; // xmm5
        __m128 v66; // xmm4
        __m128 v67; // xmm5
        __m128 v68; // xmm3
        __m128 v69; // xmm4
        __m128 v70; // xmm7
        __m128 v71; // xmm12
        __int64 v72; // rcx
        float v73; // xmm10_4
        float v74; // xmm4_4
        __int64 v75; // rcx
        float v76; // xmm9_4
        __m128 v78; // xmm12
        __m128* v79; // r15
        __m128* v80; // r15
        char v81; // [rsp+2Ch] [rbp-ECh]
        unsigned __int64 v82; // [rsp+30h] [rbp-E8h]
        unsigned __int64 v83; // [rsp+38h] [rbp-E0h]
        unsigned __int64 v84; // [rsp+38h] [rbp-E0h]
        __int64 v85; // [rsp+50h] [rbp-C8h]

        v16 = ((unsigned __int64)NtCurrentPeb() >> 0xC) - (retaddr >> 0x21) + 0x6706C6CC9A3F9773i64;
        if (HIDWORD(v16))
            v17 = v16 % 6;
        else
            v17 = (unsigned int)v16 % 6;
        if (v17)
        {
            switch (v17)
            {
            case 1ui64:
                v18 = __ROL8__((*(_QWORD*)(Pawn + 0x1C8) + 0x134112B10D035417i64) ^ 0x7447D47D973CC37Di64, 0x27);
                break;
            case 2ui64:
                v18 = (__ROL8__(*(_QWORD*)(Pawn + 0x1C8), 0x27) ^ 0x7447D47D973CC37Di64) + 0x134112B10D035417i64;
                break;
            case 3ui64:
                v18 = (__ROL8__(*(_QWORD*)(Pawn + 0x1C8), 0x27) + 0x134112B10D035417i64) ^ 0x7447D47D973CC37Di64;
                break;
            case 4ui64:
                v18 = __ROL8__((*(_QWORD*)(Pawn + 0x1C8) ^ 0x7447D47D973CC37Di64) + 0x134112B10D035417i64, 0x27);
                break;
            default:
                v18 = __ROL8__(*(_QWORD*)(Pawn + 0x1C8) ^ 0x7447D47D973CC37Di64, 0x27) + 0x134112B10D035417i64;
                break;
            }
        }
        else
        {
            v18 = __ROL8__(*(_QWORD*)(Pawn + 0x1C8) + 0x134112B10D035417i64, 0x27) ^ 0x7447D47D973CC37Di64;
        }



        v24 = *(_QWORD**)v18;





        v82 = ((0xB53B0468FDA9343Eui64 - __ROR8__(NtCurrentPeb(), 0xC) + 0x3F) ^ (retaddr >> 0x21)) % 4;
        if (v82)
        {
            if (v82 == 1)
                v25 = __ROL8__(v24[0x2E] - 0x4AC4FB970256CBC2i64, 5);
            else
                v25 = __ROL8__(v24[0x2E], 5) - 0x4AC4FB970256CBC2i64;
        }
        else
        {
            v25 = __ROL8__(v24[0x2E] - 0x4AC4FB970256CBC2i64 + 5, 5) - 5i64;
        }

        if (!v25)
        {
            if (((0x8BF9FD41F4EDE046ui64 - ((unsigned __int64)NtCurrentPeb() >> 0xC) + 0x15) ^ (retaddr >> 0x21)) % 2)
                v28 = __ROL8__(v24[0x1F] - 0x740602BE0B121FBAi64, 0x23);
            else
                v28 = __ROL8__(v24[0x1F], 0x23) - 0x740602BE0B121FBAi64;

        }
        v26 = __ROR8__(NtCurrentPeb(), 0xC) + 0x9CA479B9i64 - (retaddr >> 0x21) + 0x29D08018;
        if (HIDWORD(v26))
            v27 = v26 % 4;
        else
            v27 = (unsigned int)v26 % 4;

        if (!v27)
        {

            v31 = __ROL8__(v24[0xB], 0x1B) - 0x64i64;
            v32 = (unsigned __int8)v31;
            v33 = ((unsigned int)0xFEFFFC + 4) & ((_DWORD)v31 << 8);
            v34 = (v31 << 0x20) & 0xFF000000000000i64;
            v35 = HIDWORD(v31);
            v36 = (v31 << 8) & 0xFF00000000i64 | (v31 << 0x18) & 0xFF00000000000000ui64 | WORD2(v31) & 0xFF00;
            v37 = (v31 >> 8) & 0xFF0000000000i64;
        LABEL_59:
            v28 = v36 | v37 | v34 | v33 | v32 | (unsigned int)v35 & 0xFF000000;
            goto LABEL_60;
        }

        if (v27 == 1)
        {
            v38 = __ROL8__(v24[0xB], 0x1B);
            v28 = ((v38 << 8) & 0xFF00000000i64 | (v38 << 0x18) & 0xFF00000000000000ui64 | WORD2(v38) & 0xFF00 | (v38 >> 8) & 0xFF0000000000i64 | (v38 << 0x20) & 0xFF000000000000i64 | ((unsigned int)0xFEFFFC + 4) & ((_DWORD)v38 << 8) | (unsigned __int8)v38 | (unsigned __int64)(HIDWORD(v38) & 0xFF000000))
                - 0x64;
        }
        else
        {
            if (v27 != 2)
            {
                v40 = __ROL8__(v24[0xB] - 0x64i64, 0x1B);
                v32 = (unsigned __int8)v40;
                v33 = ((unsigned int)0xFEFFFC + 4) & ((_DWORD)v40 << 8);
                v34 = (v40 << 0x20) & 0xFF000000000000i64;
                v35 = HIDWORD(v40);
                v36 = (v40 << 8) & 0xFF00000000i64 | (v40 << 0x18) & 0xFF00000000000000ui64 | WORD2(v40) & 0xFF00;
                v37 = (v40 >> 8) & 0xFF0000000000i64;
                goto LABEL_59;
            }
            v39 = v24[0xB] - 0x64i64;
            v28 = __ROL8__(
                (v39 << 8) & 0xFF00000000i64 | (v39 << 0x18) & 0xFF00000000000000ui64 | WORD2(v39) & 0xFF00 | (v39 >> 8) & 0xFF0000000000i64 | (v39 << 0x20) & 0xFF000000000000i64 | ((unsigned int)0xFEFFFC + 4) & ((_DWORD)v39 << 8) | (unsigned __int8)v39 | (unsigned __int64)(HIDWORD(v39) & 0xFF000000),
                0x1B);
        }
    LABEL_60:





        v83 = ((0x9CA479B9i64 - __ROR8__(NtCurrentPeb(), 0xC)) ^ (retaddr >> 0x21)) % 3;
        if (v83)
        {
            if (v83 == 1)
            {
                v49 = __ROL8__(*(_QWORD*)(v28 + 0x10), 0x15);
                v48 = (v49 << 0x20) & 0xFF000000000000i64 | (v49 << 8) & 0xFF00000000i64 | (v49 >> 0x10) & 0xFF0000000000i64 | (unsigned int)((_DWORD)v49 << 0x10) | (v49 << 0x18) & 0xFF00000000000000ui64 | (unsigned __int16)(HIDWORD(v49) >> 8);
            }
            else
            {
                v48 = __ROL8__(
                    (*(_QWORD*)(v28 + 0x10) << 0x20) & 0xFF000000000000i64 | (*(_QWORD*)(v28 + 0x10) << 8) & 0xFF00000000i64 | (*(_QWORD*)(v28 + 0x10) >> 0x10) & 0xFF0000000000i64 | ((unsigned int)*(_QWORD*)(v28 + 0x10) << 0x10) | (*(_QWORD*)(v28 + 0x10) << 0x18) & 0xFF00000000000000ui64 | (unsigned __int16)((unsigned int)HIDWORD(*(_QWORD*)(v28 + 0x10)) >> 8),
                    0x15);
            }
        }
        else
        {
            v47 = __ROL8__(*(_QWORD*)(v28 + 0x10), 0x1B);
            v48 = __ROL8__(
                (v47 << 0x20) & 0xFF000000000000i64 | (v47 << 8) & 0xFF00000000i64 | (v47 >> 0x10) & 0xFF0000000000i64 | (unsigned int)((_DWORD)v47 << 0x10) | (v47 << 0x18) & 0xFF00000000000000ui64 | (unsigned __int16)(HIDWORD(v47) >> 8),
                0x3A);
        }


        v21 = *(__m128*)(v48 + 0x20LL * index);


        return TransformToVectorr(v28, v21);
    }








}



