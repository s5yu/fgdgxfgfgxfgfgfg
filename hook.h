#pragma once
#pragma once

#include "moreutil.h"
#include "ubisoft.h"
#include "rvacall.h"
extern uint64_t unlockable12;
inline std::vector < std::pair<void*, void*>> orig_funcs;

inline void hook(void* destination, void* detour)
{
	if (!destination)
		return;

	orig_funcs.push_back({ destination, *reinterpret_cast<void**>(destination) });

	utils::memory::swap_table_ptr(destination, detour);
}

namespace calls
{
	inline __int64(*sendImpl)(void* HttpClientImpl, __int64 result, ubiservices::HttpRequest* request, __int64 requestRetryhandler, __int64 requestConfig);

	inline __int64(*binary_checksum_response)(__int64 a1, __int64 a2);

	inline __int64(*binary_checksum_response1)(__int64 a1, __int64 a2);
	inline __int64(*binary_checksum_response2)(__int64 a1, __int64 a2);
}

namespace hooks
{
	__int64 sendImpl(void* HttpClientImpl, __int64 result, ubiservices::HttpRequest* request, __int64 requestRetryhandler, __int64 requestConfig);

	__int64 binary_checksum_response(__int64 a1, __int64 a2);


	inline void init()
	{

		RVA_CALL(calls::binary_checksum_response, 0x669D300/*0x43CB4D0*/); //custom builds

		
		//RVA_CALL(calls::sendImpl, 0x70D1B00); // unlock all 



		//hook(utils::memory::scan_memory(reinterpret_cast<uint64_t>(calls::binary_checksum_response)), hooks::binary_checksum_response);
		RVA_CALL(calls::sendImpl, unlockable12); // unlock all 

		hook(utils::memory::scan_memory(reinterpret_cast<uint64_t>(calls::sendImpl)), hooks::sendImpl);
		//hook( utils::memory::scan_memory( reinterpret_cast< uint64_t >( calls::sendImpl ) ), hooks::sendImpl );


	}

	inline void uninit()
	{
		for (auto& [ptr, func] : orig_funcs)
			utils::memory::swap_table_ptr(ptr, func);
	}
}