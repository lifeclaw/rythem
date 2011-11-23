package com.webpluz.command
{
	import com.webpluz.service.RuleManager;
	import com.webpluz.vo.ProjectConfig;
	import com.webpluz.vo.Rule;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public final class ConfigModelUpdateCommand extends SimpleCommand
	{
		public function ConfigModelUpdateCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void{
			var projects:Array = notification.getBody() as Array;
			var ruleManager:RuleManager = RuleManager.getInstance();
			for each(var config:ProjectConfig in projects){
				for each(var rule:Rule in config.rules){
					ruleManager.addRule(rule);
				}
			}
			trace(ruleManager);
		}
	}
}