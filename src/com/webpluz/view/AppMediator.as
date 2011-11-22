package com.webpluz.view
{
	import com.adobe.net.URI;
	import com.jo2.system.IProxyManager;
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
		
		public static const MAIN_TAB_CHANGE:String = 'mediator.app.mainTabChange';
		public static const CLOSING:String = 'mediator.app.closing';
		
		public function AppMediator(viewComponent:Object)
		{
			super(NAME, viewComponent);
			app.webContainer.htmlLoader.window.airCall = function(type:String,param:Object){
					
			}
			app.addEventListener(Event.CLOSING, onAppClosing);
			//app.mainTabNavigator.addEventListener(Event.CHANGE, onTabChildChanged);
		}
		
		public function get app():Rythem{
			return this.viewComponent as Rythem;
		}
		
		protected function onTabChildChanged(e:Event):void{
			this.sendNotification(MAIN_TAB_CHANGE, app);
		}
		
		protected function onAppClosing(e:Event):void{
			e.preventDefault();
			e.stopPropagation();
			app.visible = false;
			trace('[AppMediator] cleaning up ...');
			this.sendNotification(CLOSING);
			setTimeout(function():void{
				trace('[AppMediator] exit');
				NativeApplication.nativeApplication.exit();
			}, 2000);
		}
	}
}