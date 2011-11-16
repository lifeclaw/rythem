package com.webpluz.command
{
	import com.webpluz.view.InspectorMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public final class MainTabNavigatorChangeCommand extends SimpleCommand
	{
		public function MainTabNavigatorChangeCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void{
			var app:Rythem = notification.getBody() as Rythem;
			if(app.mainTabNavigator.selectedIndex == 0){
				facade.registerMediator(new InspectorMediator(app.request, app.response));
			}
		}
	}
}