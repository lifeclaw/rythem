package com.webpluz.command
{
	import com.jo2.system.IProxyManager;
	import com.jo2.system.ProxyManager;
	import com.webpluz.service.ProxyService;
	import com.webpluz.task.SetAndRefreshSystemProxyTaskQueue;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public final class CleanupBeforeCloseCommand extends SimpleCommand implements ICommand
	{
		public function CleanupBeforeCloseCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void{
			//close proxy service
			var proxyService:ProxyService = (facade.retrieveProxy(ProxyService.NAME) as ProxyService);
			proxyService.close();
			//restore proxy configurations
			new SetAndRefreshSystemProxyTaskQueue().run(proxyService.systemProxyConfig);
		}
	}
}