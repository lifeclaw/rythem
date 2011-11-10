package com.webpluz.command
{
	import com.webpluz.model.*;
	import com.webpluz.service.ProxyService;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public final class ModelPrepareCommand extends SimpleCommand implements ICommand
	{
		override public function execute(notification:INotification):void{
			(facade.retrieveProxy(ConfigModel.NAME) as ConfigModel).reload();
			(facade.retrieveProxy(ProxyService.NAME) as ProxyService).listen("127.0.0.1",8080);
		}
	}
}