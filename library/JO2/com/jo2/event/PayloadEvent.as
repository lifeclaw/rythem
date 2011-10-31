package com.jo2.event
{
	import flash.events.Event;
	
	public class PayloadEvent extends Event
	{
		public static const COMPLETE:String 	= 'complete';
		public static const CHANGE:String 		= 'change';
		
		protected var _payload:*;
		
		/**
		 * 攜帶有數據的事件，沒啥特別就是多了個payload
		 * 這樣接收到事件時就可以直接從事件裏獲取到需要的數據，不需要去找event.target ...
		 */
		public function PayloadEvent(type:String, payload:*=null, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
			_payload = payload;
		}
		
		public function get payload():*{
			return _payload;
		}
	}
}