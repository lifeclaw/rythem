package com.jo2.system
{
	import com.jo2.utils.StringBuffer;
	
	import flash.events.IEventDispatcher;
	
	public interface ITerminal extends IEventDispatcher
	{
		function execute(command:String):void;
		function get outputBuffer():StringBuffer;
		function get errorBuffer():StringBuffer;
		function get executing():Boolean;
	}
}