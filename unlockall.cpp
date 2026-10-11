#include "hook.h"
#include <stdio.h>
#include <intrin.h>
#include "spoofcall/spoof.h"

#pragma intrinsic(_ReturnAddress)

std::string list[] = { _x("/inventory"), /*_x( "/parameters" )*/ };

__int64 hooks::sendImpl(void* HttpClientImpl, __int64 result, ubiservices::HttpRequest* request, __int64 requestRetryhandler, __int64 requestConfig)
{
	std::string url = request->m_url->m_text;

	for (auto endpoint : list)
	{
		if (strstr(request->m_url->m_text, endpoint.c_str()) && !strstr(request->m_url->m_text, _x("/inventory/rulesexecution")))
		{
			if (auto pos = url.find(_x("public-ubiservices.ubi.com")); pos != std::string::npos)
			{
				utils::str::write_str((void*)request->m_url->m_text, _x("http://127.0.0.1:8080")); // replace this wiht your own backend.
			}
		}
	}

	if (strstr(request->m_url->m_text, _x("/sessions")))
	{
		auto header = request->m_header;
		uint64_t PlatformAuthHeader = *reinterpret_cast<std::uint64_t*>(header + 0x10);
		if (!utils::memory::valid_pointer(PlatformAuthHeader))
			goto end;

		uint64_t PlatformAuthHeaderData = *reinterpret_cast<std::uint64_t*>(PlatformAuthHeader + 0x30);
		if (!utils::memory::valid_pointer(PlatformAuthHeaderData))
			goto end;

		//utils::str::write_str( ( void* )( PlatformAuthHeaderData ), _x( "xbl" ) );
	}

	/*printf( "%s\n", request->m_url->m_text );
	if ( request->m_entity )
	{
		printf( "%s\n\n", request->m_entity->GetBody( ) );
	}*/
end:
	auto ret = utils::spoof_call(calls::sendImpl, HttpClientImpl, result, request, requestRetryhandler, requestConfig);

	return ret;
}