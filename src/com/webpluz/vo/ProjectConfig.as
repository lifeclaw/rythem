package com.webpluz.vo
{
	import flash.events.EventDispatcher;

	public final class ProjectConfig
	{
		[Bindable]public var name:String;
		[Bindable]public var enable:Boolean;
		[Bindable]public var rules:Array;
		
		public static function instantiateFromObject(value:Object):ProjectConfig{
			var instance:ProjectConfig = new ProjectConfig(value.name, value.enable);
			for each(var rule:Object in value.rules){
				var r:Rule = (rule.type == Rule.HOST) ? new IpReplaceRule(rule.pattern, rule.replace, rule.enable) :
														new ContentReplaceRule(rule.pattern, rule.replace, rule.enable);
				instance.addRule(r);
				//instance.addRule(new ReplaceRule(rule.pattern, rule.replace, rule.type, rule.enable));
			}
			return instance;
		}
		
		public function ProjectConfig(name:String, enable:Boolean = true){
			this.name = name;
			this.enable = enable;
			rules = [];
		}
		
		public function addRule(value:Rule):void{
			var exist:Boolean = rules.some(function(item:Rule, index:uint, arr:Array):Boolean{
				return item.isEqual(value);
			});
			if(!exist){
				rules.push(value);
			}
		}
		
		public function matchRule(value:String):Rule{
			return null;
		}
		
		public function toString():String{
			var rulesStr:Vector.<String> = new Vector.<String>();
			for each(var rule:Rule in this.rules){
				rulesStr.push('\t\t' + rule.toString());
			}
			return '{\n' +
				'\t"name":"' + name + '",\n' +
				'\t"enable":' + enable + ',\n' +
				'\t"rules": [\n' +
				rulesStr.join('\n') + '\n' +
				'\t]\n' +
			'}';
		}
	}
}