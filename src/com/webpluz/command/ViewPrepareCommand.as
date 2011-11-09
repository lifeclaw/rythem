package com.webpluz.command
{
	import com.webpluz.view.InspectorMediator;
	import com.webpluz.view.PipeListMediator;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public final class ViewPrepareCommand extends SimpleCommand implements ICommand
	{
		override public function execute(notification:INotification):void{
			var app:Rythem = notification.getBody() as Rythem;
			facade.registerMediator(new PipeListMediator(app.pipeList));
			facade.registerMediator(new InspectorMediator(app.request,app.response));
		}
	}
}