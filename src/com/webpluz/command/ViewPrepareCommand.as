package com.webpluz.command
{
	import com.webpluz.view.AppMediator;
	import com.webpluz.view.WebUIMediator;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public final class ViewPrepareCommand extends SimpleCommand implements ICommand
	{
		override public function execute(notification:INotification):void{
			var app:Rythem = notification.getBody() as Rythem;
			facade.registerMediator(new AppMediator(app));
			facade.registerMediator(new WebUIMediator(WebUIMediator.NAME,app.webContainer));
		}
	}
}