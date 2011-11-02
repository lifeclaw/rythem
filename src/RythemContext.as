package
{
	import com.jo2.event.PayloadEvent;
	import com.jo2.system.IProxyManager;
	import com.jo2.system.ProxyManager;
	import com.webpluz.command.UpdateSystemProxyCommand;
	import com.webpluz.view.*;
	import com.webpluz.service.*;
	
	import flash.display.DisplayObjectContainer;
	
	import org.robotlegs.mvcs.Context;

	
	public final class RythemContext extends Context
	{
		
		public function RythemContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true){
			super(contextView, autoStartup);
		}
		
		override public function startup():void{
			this.bootstrapCommands();
			this.bootstrapInjector();
			this.bootstrapMediators();
			super.startup();
		}
		
		//綁定事件和命令，當事件發生的時候，相應的命令會被實例化執行
		private function bootstrapCommands():void{
			this.commandMap.mapEvent(PayloadEvent.CHANGE, UpdateSystemProxyCommand);			
		}
		
		//初始化注入
		private function bootstrapInjector():void{
			this.injector.mapValue(IProxyManager, ProxyManager.getProxyManager());
			injector.mapSingleton(ProxyService);
		}
		
		//綁定視圖組件與代理
		private function bootstrapMediators():void{
			this.mediatorMap.mapView(ProxySelector, ProxySelectorMediator);
		}
	}
}