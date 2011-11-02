package com.webpluz.command
{
	import com.jo2.event.PayloadEvent;
	import com.jo2.system.IProxyManager;
	import com.jo2.system.ProxyConfigs;
	
	import org.robotlegs.mvcs.Command;
	
	public final class UpdateSystemProxyCommand extends Command
	{
		[Inject]public var event:PayloadEvent; //how does this Inject work ?
		[Inject]public var manager:IProxyManager;
		
		public function UpdateSystemProxyCommand()
		{
			super();
		}
		
		override public function execute():void{
			//change system proxy according to user's selection
			this.commandMap.detain(this);
			if(manager){
				manager.addEventListener(PayloadEvent.COMPLETE, onComplete);
				var config:ProxyConfigs = new ProxyConfigs(
					event.payload.server,
					uint(event.payload.port),
					event.payload.autoConfigURL,
					event.payload.enabled
				);
				manager.proxy = config;
			}
		}
		
		private function onComplete(e:PayloadEvent):void{
			trace(manager.proxy);
			this.commandMap.release(this);
		}
	}
}