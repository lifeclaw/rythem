package com.jo2.system
{
	public final class ProxyConfigs
	{
		public var enabled:Boolean;
		public var autoConfigURL:String;
		public var server:String;
		public var port:uint;
		//username and password ?
		
		public function ProxyConfigs(server:String = '', port:uint = 8080, autoConfigURL:String = '', enabled:Boolean = true){
			this.server = server;
			this.port = port;
			this.autoConfigURL = autoConfigURL;
			this.enabled = enabled;
		}
		
		public function toString():String{
			return 'ProxyConfig{server:' + server + ':' + port
						    + ', autoConfigURL:' + autoConfigURL
						    + ', enabled:' + enabled
						    + '}';
		}
	}
}