package com.webpluz.service{
	import com.webpluz.vo.RequestData;
	
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
			}
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
		public function getRule(requestData:RequestData):Rule{
			for each(var r:Rule in rulesHigh){
				if(r.isMatch(requestData)){
					return r;
				}
			}
			for each(r in rulesNormal){
				if(r.isMatch(requestData)){
					return r;
				}
			}
			for each(r in rulesLow){
				if(r.isMatch(requestData)){
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