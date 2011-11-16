package com.webpluz.command
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public final class ProjectConfigChangeCommand extends SimpleCommand
	{
		public function ProjectConfigChangeCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void{
			//TODO tell config model to update, and also update rule manager
			trace('[ProjectConfigChangeCommand] tell config model to update');
			trace(notification.getBody());
		}
	}
}