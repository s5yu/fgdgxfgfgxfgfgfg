#include "hook.h"
#include "spoofcall/spoof.h"

__int64 hooks::binary_checksum_response(__int64 a1, __int64 a2)
{
	static std::string response{ };
	response = _x(R"({"status":"OK"})");
	utils::str::write_str(*reinterpret_cast<void**>(a2 + 0x30), response.c_str());

	return utils::spoof_call(calls::binary_checksum_response, a1, a2);
}
