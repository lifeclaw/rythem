package com.webpluz.view
{
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class ProxySelectorMediator extends Mediator
	{
		[Inject]public var proxySelector:ProxySelector;
		
		public function ProxySelectorMediator()
		{
			super();
		}
		
		public function get selectedItem():String{
			return this.proxySelector.selectedItem;
		}
		
		//覆蓋此方法來註冊UI組件的事件
		override public function onRegister():void{
			this.eventMap.mapListener(proxySelector, Event.CHANGE, onProxySelectorChange);
		}
		
		//處理UI組件的事件
		private function onProxySelectorChange(e:Event):void{
			this.dispatch(new Event(Event.CHANGE));
		}
	}
}