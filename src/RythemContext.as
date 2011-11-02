package
{
	import com.webpluz.view.*;
	
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
			
		}
		
		//初始化注入
		private function bootstrapInjector():void{
			
		}
		
		//綁定視圖組件與代理
		private function bootstrapMediators():void{
			this.mediatorMap.mapView(ProxySelector, ProxySelectorMediator);
		}
	}
}