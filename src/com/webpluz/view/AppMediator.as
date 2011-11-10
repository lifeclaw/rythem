package com.webpluz.view
{
	import com.webpluz.service.ProxyService;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public final class AppMediator extends Mediator implements IMediator
	{
		public static const NAME:String = 'AppMediator';
		
		public function AppMediator(viewComponent:Object)
		{
			super(NAME, viewComponent);
			var app:Rythem = viewComponent as Rythem;
			app.addEventListener(Event.CLOSE,onWindowClose);
		}
		
		protected function onWindowClose(event:Event):void
		{
			trace("window close");
			(facade.retrieveProxy(ProxyService.NAME) as ProxyService).close();
		}
		
		override public function listNotificationInterests():Array{
			return [];
		}
		override public function onRegister( ):void{
			trace("on register..AppMediator");
		}
	}
}