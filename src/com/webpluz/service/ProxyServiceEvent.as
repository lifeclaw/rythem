package com.webpluz.service {
	import flash.events.Event;

	public class ProxyServiceEvent extends Event {
		public static const PROXYSERVICEEVENT_CONNECTED:String="PROXYSERVICEEVENT_CONNECTED";
		public static const PROXYSERVICEEVENT_COMPLETE:String="PROXYSERVICEEVENT_COMPLETE";
		public static const PROXYSERVICEEVENT_ERROR:String="PROXYSERVICEEVENT_ERROR";
		public var requestHeaders:Object;
		public var responseHeaders:Object;
		public var requestBody:String;
		public var responseBody:String;

		public function ProxyServiceEvent(type:String) {
			super(type, false, false);
		}
	}
}
