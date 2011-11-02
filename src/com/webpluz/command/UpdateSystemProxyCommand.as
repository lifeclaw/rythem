package com.webpluz.command
{
	import com.jo2.event.PayloadEvent;
	import com.jo2.system.IProxyManager;
	import com.jo2.system.ProxyConfigs;
	import com.jo2.system.ProxyManager;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateSystemProxyCommand extends Command
	{
		[Inject]public var event:PayloadEvent; //how does this Inject work ?
		
		public function UpdateSystemProxyCommand()
		{
			super();
		}
		
		override public function execute():void{
			//change system proxy according to user's selection
			var config:ProxyConfigs = new ProxyConfigs(
				event.payload.server,
				uint(event.payload.port),
				event.payload.autoConfigURL,
				event.payload.enabled
			);
			var manager:IProxyManager = ProxyManager.getProxyManager();
			manager.proxy = config;
		}
	}
}