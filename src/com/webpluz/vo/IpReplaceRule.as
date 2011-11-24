package com.webpluz.vo{

	public class IpReplaceRule extends Rule{
		private var _pattern:String;
		private var _replace:String;
		public function IpReplaceRule(host:String,ip:String, enable:Boolean = true){
			super(Rule.RULE_TYPE_REPLACE_IP, RULE_PRIORITY_NORMAL, enable);
			this.pattern = host;
			this.replace = ip;
		}
		public override function isMatch(requestData:RequestData):Boolean{
			var headers:Object = requestData.headersObject;
			var host:String = headers['host'];
			return (host && host.toLocaleLowerCase() == this._pattern);
		}
		public function getIpToChange():String{
			return this._replace;
		}
		
		public function get pattern():String{
			return this._pattern;
		}
		public function set pattern(value:String):void{
			this._pattern = value.toLowerCase();
		}
		public function get replace():String{
			return this._replace;
		}
		public function set replace(value:String):void{
			this._replace = value;
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