package com.webpluz.service{
	import com.webpluz.vo.ContentReplaceRule;
	import com.webpluz.vo.RequestData;
	import com.webpluz.vo.Rule;
	
	import flash.system.Capabilities;
	import flash.utils.Proxy;

	public class RuleManager extends Proxy{
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
			instance = this;
			/*
			rulesLow.push(new IpReplaceRule("web2.qq.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("0.web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("1.web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("2.web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("3.web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("4.web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("5.web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("6.web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("7.web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("8.web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("9.web.qstatic.com","113.108.4.143"));
			rulesLow.push(new IpReplaceRule("cgi.web2.qq.com","113.108.4.143"));
			if(Capabilities.os.indexOf("Windows")!=-1){
				rulesLow.push(new ContentReplaceRule("http://iptton.com/","E:/rythemReplace/test.html"));
			}else{
				rulesLow.push(new ContentReplaceRule("http://iptton.com/","./rythemReplace/test.html"));
			}*/
			/*
			//examples for adding content replace rules
			rulesLow.push(new ContentReplaceRule("/hello/world/","./rythemReplace/folderRule/"));
			rulesLow.push(new ContentReplaceRule("http://iptton.com/combine.html","./rythemReplace/combineRule/combine.qzmin"));
			*/
		}
		public function addRule(r:Rule):void{
			trace('adding rule: ' + r.type);
			var index:int;
			switch(r.getPriority()){
				case Rule.RULE_PRIORITY_LOW:
					index = this.findRule(r, rulesLow);
					if(index == -1) rulesLow.push(r);
					break;
				case Rule.RULE_PRIORITY_HIGH:
					index = this.findRule(r, rulesHigh);
					if(index == -1) rulesHigh.push(r);
					break;
				case Rule.RULE_PRIORITY_NORMAL:
				default:
					index = this.findRule(r, rulesNormal);
					if(index == -1) rulesNormal.push(r);
					break;
			}
		}
		public function removeRule(r:Rule):void{
			trace('removing rule: ' + r.type);
			var index:int;
			switch(r.getPriority()){
				case Rule.RULE_PRIORITY_LOW:
					index = this.findRule(r, rulesLow);
					if(index != -1) rulesLow.splice(index);
					break;
					
				case Rule.RULE_PRIORITY_HIGH:
					index = this.findRule(r, rulesHigh);
					if(index != -1) rulesHigh.splice(index);
					break;
				
				case Rule.RULE_PRIORITY_NORMAL:
					index = this.findRule(r, rulesNormal);
					if(index != -1) rulesNormal.splice(index);
					break;
			}
		}
		public function getRule(requestData:RequestData):Rule{
			for(var i:int=0,l:int=rulesHigh.length;i<l;++i){
				if(rulesHigh[i].isMatch(requestData)){
					return rulesHigh[i];
				}
			}
			for(i=0,l=rulesNormal.length;i<l;++i){
				if(rulesNormal[i].isMatch(requestData)){
					return rulesNormal[i];
				}
			}
			for(i=0,l=rulesLow.length;i<l;++i){
				if(rulesLow[i].isMatch(requestData)){
					return rulesLow[i];
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
		
		private function findRule(r:Rule, array:Array):int{
			var i:uint=0, ln:uint=array.length;
			for(i; i<ln; i++){
				if(r.isEqual(array[i])) return i;
			}
			return -1;
		}
		
		public function toJSON(k:String):*{
			return {
				low: 	rulesLow,
				normal: rulesNormal,
				high: 	rulesHigh
			};
		}
		
		public function toString():String{
			return JSON.stringify(this, null, 4);
		}
	}
}
