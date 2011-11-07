package com.webpluz.model
{
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public final class ConfigModel extends Proxy implements IProxy
	{
		public static const NAME:String = 'ConfigModel';
		
		public static const COMPLETE:String = 'complete';
		
		public function ConfigModel(){
			super(NAME);
		}
		
		/**
		 * reload all configurations (from local and remote)
		 * a COMPLETE notification is sent when local or remote config is loaded
		 */
		public function reload():void{
			this.loadLocalConfig();
			this.loadRemoteConfig();
		}
		
		public function loadLocalConfig():void{
			
		}
		
		public function loadRemoteConfig():void{
			
		}
	}
}