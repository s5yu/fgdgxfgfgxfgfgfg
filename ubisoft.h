#pragma once
#pragma once

#include "moreutil.h"

namespace ubiservices
{
	enum LogCategory : __int32
	{
		ENUM_BEGIN = 0x0,
		ApplicationUsed = 0x0,
		ApplicationInformation = 0x1,
		Async = 0x2,
		Authentication = 0x3,
		Club = 0x4,
		Connection = 0x5,
		Core = 0x6,
		CoreNotification = 0x7,
		Entity = 0x8,
		Event = 0x9,
		Friend = 0xA,
		Http = 0xB,
		HttpEngine = 0xC,
		Job = 0xD,
		Leaderboard = 0xE,
		Localization = 0xF,
		News = 0x10,
		Notification = 0x11,
		Parameters = 0x12,
		Population = 0x13,
		PrimaryStore = 0x14,
		Profile = 0x15,
		RemoteLog = 0x16,
		Scheduler = 0x17,
		SecondaryStore = 0x18,
		SecondaryStoreInstantiation = 0x19,
		Stats = 0x1A,
		Task = 0x1B,
		Test = 0x1C,
		TLog = 0x1D,
		User = 0x1E,
		UserContent = 0x1F,
		Websocket = 0x20,
		ENUM_END = 0x21,
		ENUM_COUNT = 0x21,
	};

	typedef LogCategory HttpMethod;

	struct HttpRequest;
	struct HttpRequest_vtbl;

	struct String
	{
		const char* m_text;
	};

	struct HttpHeader
	{
	};

	struct HttpEntity
	{
		void** __vftable;//0x0
	private:
		char m_pad08[0x8];//0x8
	public:
		const char* m_body;//0x10

		const char* GetBody()
		{
			if (!utils::memory::valid_pointer(this))
				return ("{}");

			//if ( __vftable != ( void** ) ( reinterpret_cast< uintptr_t >( GetModuleHandleA( 0 ) ) + 0x97a6f70 ) )
				//return ( "{}" );

			if (!utils::memory::valid_pointer(*(uint64_t*)(this + 0x10)))
				return ("{}");

			return this->m_body;
		}
	};

	struct HttpRequest
	{
		ubiservices::HttpRequest_vtbl* __vftable /*VFT*/;//0x0
		ubiservices::String* m_url;//0x8
	private:
		char m_pad010[0x8];//0x10
	public:
		ubiservices::HttpHeader* m_header;//0x18
	private:
		char m_pad020[0x20];//0x20
	public:
		ubiservices::HttpEntity* m_entity;//0x40
	};

	struct /*VFT*/ HttpRequest_vtbl
	{
		void(__fastcall* HttpRequestDestructor)(ubiservices::HttpRequest*);//Destructor
		ubiservices::HttpMethod(__fastcall* getMethod)(ubiservices::HttpRequest*);
		ubiservices::String* (__fastcall* getBodyAsString)(ubiservices::HttpRequest*, ubiservices::String* result);
		ubiservices::HttpRequest* (__fastcall* clone)(ubiservices::HttpRequest*);
	};
}
