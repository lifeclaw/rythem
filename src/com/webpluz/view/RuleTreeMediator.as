package com.webpluz.view
{
	import com.webpluz.model.ConfigModel;
	import com.webpluz.vo.ProjectConfig;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Tree;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class RuleTreeMediator extends Mediator implements IMediator
	{
		public static const NAME:String = 'RuleTreeMediator';
		
		public function RuleTreeMediator(viewComponent:Object=null){
			super(NAME, viewComponent);
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
	}
}