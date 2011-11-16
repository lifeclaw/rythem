package com.webpluz.event
{
	import com.webpluz.vo.ProjectConfig;
	
	import flash.events.Event;
	
	public final class ProjectConfigEvent extends Event
	{
		public static const CHANGE:String = 'configChange';
		
		public var config:ProjectConfig;
		public var changeRules:Array;
		
		public function ProjectConfigEvent(type:String, config:ProjectConfig, changeRules:Array = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.config = config;
			this.changeRules = changeRules;
		}
	}
}