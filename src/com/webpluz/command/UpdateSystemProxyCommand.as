package com.webpluz.command
{
	import com.jo2.event.PayloadEvent;
	import com.jo2.system.IProxyManager;
	import com.jo2.system.ProxyConfigs;
	
	import flash.desktop.NativeApplication;
	
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
			//specify that this command needs to wait for something, so don't release me so fast
			this.commandMap.detain(this);
			//change system proxy according to user's selection
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
			//tell commandMap this command is done
			this.commandMap.release(this);
		}
	}
}