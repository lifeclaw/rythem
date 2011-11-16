package com.webpluz.command
{
	import com.webpluz.event.ProjectConfigEvent;
	import com.webpluz.model.ConfigModel;
	import com.webpluz.service.ContentReplaceRule;
	import com.webpluz.service.IpReplaceRule;
	import com.webpluz.service.Rule;
	import com.webpluz.service.RuleManager;
	import com.webpluz.vo.ProjectConfig;
	import com.webpluz.vo.ReplaceRule;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public final class ProjectConfigChangeCommand extends SimpleCommand
	{
		public function ProjectConfigChangeCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void{
			//NOTE: we don't need to update config model by hand here
			//because it's updated via data binding
			var event:ProjectConfigEvent = notification.getBody() as ProjectConfigEvent;
			
			//update rule manager
			var ruleManager:RuleManager = RuleManager.getInstance();
			event.changeRules.forEach(function(changeRule:ReplaceRule, index:int, arr:Array):void{
				var enable:Boolean = changeRule.enable && event.config.enable;
				var rule:Rule;
				switch(changeRule.type){
					case ReplaceRule.HOST:
						rule = new IpReplaceRule(changeRule.pattern, changeRule.replace);
						break;		
					default:
						rule = new ContentReplaceRule(changeRule.pattern, changeRule.replace);
						break;
				}
				if(enable){
					ruleManager.addRule(rule);
					trace('add rule ' + changeRule);
				}
				else{
					ruleManager.removeRule(rule);
					trace('remove rule ' + changeRule);
				}
			});
		}
	}
}