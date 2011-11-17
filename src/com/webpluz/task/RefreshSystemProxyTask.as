package com.webpluz.task
{
	import com.jo2.core.Task;
	import com.jo2.system.*;
	import com.jo2.system.windows.Wininet;
	
	import flash.events.Event;
	
	public final class RefreshSystemProxyTask extends Task
	{
		private var wininet:Wininet;
		
		public function RefreshSystemProxyTask()
		{
			super();
			wininet = new Wininet();
			wininet.addEventListener(Event.COMPLETE, onWininetComplete);
		}
		
		override protected function startRunningTasks():void{
			wininet.refreshSystemProxy();
		}
		
		private function onWininetComplete(e:Event):void{
			trace(wininet.outputBuffer);
			this.complete();
		}
	}
}