#pragma once
#ifndef havok_math
#define havok_math

#include <iostream>
#include <Windows.h>
#include <vector>

#include "definitions.h"
#include "moreutil.h"

#define RVA(offset) (void*)(utils::memory::image_base + offset)

#define RVA_CALL(call, offset) call = reinterpret_cast<decltype(call)>(RVA(offset));

#define STR_MERGE_IMPL(a, b) a##b
#define STR_MERGE(a, b) STR_MERGE_IMPL(a, b)
#define MAKE_PAD(size) STR_MERGE(_pad, __COUNTER__)[size]
#define MEMBER(type, name, offset) struct {unsigned char MAKE_PAD(offset); type name;}

#define DEFINE_MEMBER(type, name, offset) \
	__forceinline auto name( ) const noexcept -> type { if ( !this ) return {}; return *reinterpret_cast< type* >( reinterpret_cast< uintptr_t >( this ) + offset ); } \
	__forceinline auto name( ) -> type&               { type clown{}; if ( !this ) return clown; return *reinterpret_cast< type* >( reinterpret_cast< uintptr_t >( this ) + offset ); }


#endif // !havok_math