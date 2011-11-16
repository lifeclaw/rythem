package com.webpluz.view
{
	import com.webpluz.event.ProjectConfigEvent;
	import com.webpluz.model.ConfigModel;
	import com.webpluz.vo.ProjectConfig;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Tree;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class RuleTreeMediator extends Mediator implements IMediator
	{
		public static const NAME:String = 'RuleTreeMediator';
		
		public static const CHANGE:String = 'mediator.ruleTree.change';
		
		public function RuleTreeMediator(viewComponent:Object=null){
			super(NAME, viewComponent);
			ruleTree.addEventListener(ProjectConfigEvent.CHANGE, onRuleChange);
		}
		
		public function get ruleTree():Tree{
			return this.viewComponent as Tree;
		}
		
		override public function listNotificationInterests():Array{
			return [
				ConfigModel.UPDATE
			];
		}
		override public function handleNotification(notification:INotification):void{
			switch(notification.getName()){
				case ConfigModel.UPDATE:
					ruleTree.dataProvider = new ArrayCollection(notification.getBody() as Array);
					break;
			}
		}
		
		private function onRuleChange(e:ProjectConfigEvent):void{
			e.stopPropagation();
			this.sendNotification(CHANGE, e.config);
		}
	}
}