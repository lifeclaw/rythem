package com.webpluz.vo{

	public class IpReplaceRule extends Rule{
		private var hostName:String;
		private var ipToChange:String;
		public function IpReplaceRule(host:String,ip:String, enable:Boolean = true){
			super(Rule.RULE_TYPE_REPLACE_IP, RULE_PRIORITY_NORMAL, enable);
			this.pattern = host;
			this.replace = ip;
		}
		public override function isMatch(requestData:RequestData):Boolean{
			var headers:Object = requestData.headersObject;
			var host:String = headers['host'];
			return (host && host.toLocaleLowerCase() == this.hostName);
		}
		public function getIpToChange():String{
			return this.ipToChange;
		}
		
		public function get pattern():String{
			return this.hostName;
		}
		public function set pattern(value:String):void{
			this.hostName = value.toLowerCase();
		}
		public function get replace():String{
			return this.ipToChange;
		}
		public function set replace(value:String):void{
			this.ipToChange = value;
		}
		override public function isEqual(anotherRule:*):Boolean{
			if(anotherRule is IpReplaceRule){
				var r:IpReplaceRule = anotherRule as IpReplaceRule;
				return (r.pattern == this.pattern && r.replace == this.replace);
			}
			return false;
		}
		
		override public function toString():String{
			return '{"enable":' + enable + ', "type":"ip", "host":"' + pattern + '", "replace":"' + replace + '"}';
		}
	}
}