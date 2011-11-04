// from http://httpeek.googlecode.com/
package com.webpluz.service
{
	import flash.events.Event;

	public class HTTPHeadersEvent extends Event
	{

		public static const HTTP_HEADERS_EVENT:String="httpHeadersEvent";
		public var remoteAddress:String;
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

		public override function clone():Event
		{
			var e:HTTPHeadersEvent=new HTTPHeadersEvent();
			e.requestHeaders=this.requestHeaders;
			e.requestSignature=this.requestSignature;
			e.responseHeaders=this.responseHeaders;
			e.responseSignature=this.responseSignature;
			e.remoteAddress=this.remoteAddress;
			return e;
		}
	}
}
