package com.webpluz.event
{
	import com.webpluz.vo.ProjectConfig;
	
	import flash.events.Event;
	
	public final class ProjectConfigEvent extends Event
	{
		public static const CHANGE:String = 'configChange';
		
		public var config:ProjectConfig;
		
		public function ProjectConfigEvent(type:String, config:ProjectConfig, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.config = config;
		}
	}
}