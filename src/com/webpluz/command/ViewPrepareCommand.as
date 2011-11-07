package com.webpluz.command
{
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public final class ViewPrepareCommand extends SimpleCommand implements ICommand
	{
		override public function execute(notification:INotification):void{
			
		}
	}
}