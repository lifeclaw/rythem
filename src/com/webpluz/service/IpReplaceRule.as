package com.webpluz.service{
	public class IpReplaceRule extends Rule{
		private var hostName:String;
		private var ipToChange:String;
		public function IpReplaceRule(host:String,ip:String){
			super(Rule.RULE_TYPE_REPLACE_IP);
			this.hostName = host.toLocaleLowerCase();
			this.ipToChange = ip;
		}
		public override function isMatch(headers:Object):Boolean{
			var host:String = headers['host'];
			return (host && host.toLocaleLowerCase() == this.hostName);
		}
		public function getIpToChange():String{
			return this.ipToChange;
		}
	}
}