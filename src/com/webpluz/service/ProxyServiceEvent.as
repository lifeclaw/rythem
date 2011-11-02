package com.webpluz.service
{
	import flash.events.Event;
	
	public class ProxyServiceEvent extends Event
	{
		public static const PROXYSERVICEEVENT_CONNECTED:String = "PROXYSERVICEEVENT_CONNECTED";
		public static const PROXYSERVICEEVENT_COMPLETE:String = "PROXYSERVICEEVENT_COMPLETE";
		public static const PROXYSERVICEEVENT_ERROR:String = "PROXYSERVICEEVENT_ERROR";
		public var pipe:Pipe;
		public function ProxyServiceEvent(type:String, pipe:Pipe)
		{
			super(type, false, false);
			this.pipe=pipe;
		}
	}
}