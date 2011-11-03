// from http://httpeek.googlecode.com/
package com.webpluz.service
{
	import flash.events.Event;
	
	public class HTTPHeadersEvent extends Event
	{
		
		public static const HTTP_HEADERS_EVENT:String = "httpHeadersEvent";
		public var requestHost:String;
		public var requestUrl:String;
		public var requestPort:Number;
		
		public var requestHeaders:Array;
		public var requestSignature:String;
		public var responseHeaders:Array;
		public var responseSignature:String;
		
		public function HTTPHeadersEvent()
		{
			super(HTTPHeadersEvent.HTTP_HEADERS_EVENT);
		}
		
	}
}