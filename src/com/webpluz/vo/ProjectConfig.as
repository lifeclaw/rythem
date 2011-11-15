package com.webpluz.vo
{
	public final class ProjectConfig
	{
		public var name:String;
		public var enable:Boolean;
		public var rules:Object;
		
		public static function instantiateFromObject(value:Object):ProjectConfig{
			var instance:ProjectConfig = new ProjectConfig(value.name, value.enable);
			for each(var rule:Object in value.rules){
				instance.addRule(new ReplaceRule(rule.pattern, rule.replace, rule.type));
			}
			return instance;
		}
		
		public function ProjectConfig(name:String, enable:Boolean = true){
			this.name = name;
			this.enable = enable;
			rules = {};
		}
		
		public function addRule(value:ReplaceRule):void{
			rules[value.pattern] = value;
		}
		
		public function matchRule(value:String):ReplaceRule{
			for each(var rule:ReplaceRule in rules){
				
			}
			return null;
		}
		
		public function toString():String{
			var rulesStr:Vector.<String> = new Vector.<String>();
			for each(var rule:ReplaceRule in this.rules){
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