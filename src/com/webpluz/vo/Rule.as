package com.webpluz.vo{

	public class Rule{
		public static var RULE_TYPE_REPLACE_IP:String = "RULE_TYPE_REPLACE_IP";
		public static var RULE_TYPE_REPLACE_CONTENT:String = "RULE_TYPE_REPLACE_CONTENT";
		/*public static var RULE_TYPE_DICTORY:String = "RULE_TYPE_DICTORY";
		public static var RULE_TYPE_COMBINE:String = "RULE_TYPE_COMBINE";*/
		public static var ruleTypes:Array = [RULE_TYPE_REPLACE_IP,RULE_TYPE_REPLACE_CONTENT/*,RULE_TYPE_DICTORY,RULE_TYPE_COMBINE*/];
		
		public static var RULE_PRIORITY_LOW:int = 0;
		public static var RULE_PRIORITY_NORMAL:int = 1;
		public static var RULE_PRIORITY_HIGH:int = 2;
		
		//replacement types (in configuration file)
		public static const HOST:String 		= 'host';
		public static const FILE:String 		= 'file';
		public static const DIRECTORY:String 	= 'dir';
		public static const COMBINE:String 		= 'combine';
		
		public var enable:Boolean;
		private var _ruleType:String;
		private var _priority:int;
		public function Rule(ruleType:String,priority:int=1, enable:Boolean = true){
			this.enable = enable;
			if(ruleTypes.indexOf(ruleType)==-1){
				throw new Error("wrong rule type:"+ruleType+", ruleType should be :"+ruleTypes.join(" or "));
			}
			_ruleType = ruleType;
			if(priority<RULE_PRIORITY_LOW)priority = RULE_PRIORITY_LOW;
			if(priority>RULE_PRIORITY_HIGH)priority = RULE_PRIORITY_HIGH;
			_priority = priority;
		}
		public function getType():String{
			return _ruleType;
		}
		public function getPriority():int{
			return _priority;
		}
		public function get type():String{
			return _ruleType;
		}
		public function get priority():int{
			return _priority;
		}
		public function isMatch(requestData:RequestData):Boolean{
			throw new Error("override this method!(Rule::isRuleMatch");
			return false;
		}
		
		//OVERRIDE THIS METHOD TO COMPARE TWO RULES
		public function isEqual(anotherRule:*):Boolean{
			return false;
		}
		
		public function toString():String{
			return '{}';
		}
	}
}