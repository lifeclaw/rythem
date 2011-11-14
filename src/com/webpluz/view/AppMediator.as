package com.webpluz.view
{
	import com.jo2.system.ProxyConfig;
	import com.jo2.system.ProxyManager;
	import com.webpluz.service.ProxyService;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public final class AppMediator extends Mediator implements IMediator
	{
		public static const NAME:String = 'AppMediator';
		
		public function AppMediator(viewComponent:Object)
		{
			super(NAME, viewComponent);
			app.addEventListener(Event.CLOSING, onAppClosing);
		}
		
		public function get app():Rythem{
			return this.viewComponent as Rythem;
		}
		
		protected function cleanup():void{
			trace('[AppMediator] cleaning up ...');
			//close proxy service
			(facade.retrieveProxy(ProxyService.NAME) as ProxyService).close();
			//restore proxy configurations
			var config:ProxyConfig = new ProxyConfig(null, 'http://txp-01.tencent.com/lvsproxy.pac');
			ProxyManager.getProxyManager().proxy = config;
		}
		
		protected function onAppClosing(e:Event):void{
			e.preventDefault();
			e.stopPropagation();
			app.visible = false;
			this.cleanup();
			setTimeout(function():void{
				trace('[AppMediator] exit');
				NativeApplication.nativeApplication.exit();
			}, 2000);
		}
		
		override public function listNotificationInterests():Array{
			return [];
		}
		override public function onRegister( ):void{
			trace("on register..AppMediator");
		}
	}
}