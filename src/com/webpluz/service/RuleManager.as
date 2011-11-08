package com.webpluz.service{
	public class RuleManager{
		protected static var instance:RuleManager=null;
		private var rulesLow:Array;
		private var rulesNormal:Array;
		private var rulesHigh:Array;
		public function RuleManager(){
			if(instance!=null){
				throw new Error("use RuleManager.getInstance() instead!");
			}
			rulesLow = new Array();
			rulesNormal = new Array();
			rulesHigh = new Array();
		}
		public function addRule(r:Rule):void{
			switch(r.getPriority()){
				case Rule.RULE_PRIORITY_LOW:
					rulesLow.push(r);
					break;
				case Rule.RULE_PRIORITY_HIGH:
					rulesHigh.push(r);
					break;
				case Rule.RULE_PRIORITY_NORMAL:
				default:
					rulesNormal.push(r);
					break;
			}
		}
		public function getRule(headers:Object):Rule{
			for each(var r:Rule in rulesHigh){
				if(r.isMatch(headers)){
					return r;
				}
			}
			for each(r in rulesNormal){
				if(r.isMatch(headers)){
					return r;
				}
			}
			for each(r in rulesLow){
				if(r.isMatch(headers)){
					return r;
				}
			}
			return null;
		}
		public static function getInstance():RuleManager{
			if(!instance){
				instance = new RuleManager();
			}
			return instance;
		}
	}
}