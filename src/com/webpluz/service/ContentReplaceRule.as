package com.webpluz.service{
	public class ContentReplaceRule extends Rule{
		public function ContentReplaceRule(urlRule:String,replaceContent:String){
			super(Rule.RULE_TYPE_REPLACE_SINGLE_CONTENT);
		}
		public override function isMatch(headers:Object):Boolean{
			return false;
		}
	}
}