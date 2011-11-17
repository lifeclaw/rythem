package com.webpluz.task
{
	import com.jo2.core.Task;
	import com.jo2.system.IProxyManager;
	import com.jo2.system.ProxyConfig;
	import com.jo2.system.ProxyManager;
	
	import flash.events.Event;

	public class SetSystemProxyTask extends Task
	{
		public function SetSystemProxyTask()
		{
			super();
		}
		
		override protected function startRunningTasks():void{
			var config:ProxyConfig = args as ProxyConfig;
			var pm:IProxyManager = ProxyManager.getProxyManagerInstance();
			if(config && pm){
				pm.addEventListener(Event.COMPLETE, onComplete);
				pm.proxy = config;
			}
		}
		
		private function onComplete(e:Event):void{
			this.complete();
		}
	}
}