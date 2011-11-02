package com.jo2.core
{
	import com.jo2.event.PayloadEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * watcher changes of specify target
	 * when the target is changed, a CHANGE event is dispatched
	 * this is just a base class, it does not watch anything, don't use this class directly
	 */
	[Event(name="change", type="com.jo2.event.PayloadEvent")]
	public class Watcher extends Timer
	{
		public function Watcher(delay:uint = 1000){
			super(delay);
			this.addEventListener(TimerEvent.TIMER, onTimer);
			this.checkChange();
		}
		
		/**
		 * restrict min delay to 1000ms
		 * if you set a value smaller then 1000ms, an error will be throwed
		 */
		override public function set delay(value:Number):void{
			if(value < 1000) throw new Error('delay must be bigger then 1000ms');
			else super.delay = value;
		}
		
		/**
		 * TODO override this method in your subclasses to check whether the target is changed or not
		 * if the target is changed, return something, for example the new value of the target, otherwise return null
		 */
		public function checkChange():*{
			return null;
		}
		
		protected function onTimer(e:TimerEvent):void{
			if(this.checkChange()){
				this.dispatchEvent(new PayloadEvent(PayloadEvent.CHANGE));
			}
		}
	}
}