package com.webpluz.vo
{
	public final class ReplaceRule
	{
		//replacement types
		public static const HOST:String 		= 'host';
		public static const FILE:String 		= 'file';
		public static const DIRECTORY:String 	= 'dir';
		public static const COMBINE:String 		= 'combine';
		
		public var enable:Boolean;
		public var type:String;
		public var pattern:String;
		public var replace:String;
		
		public function ReplaceRule(pattern:String, replace:String, type:String = FILE, enable:Boolean = true){
			this.enable = enable;
			this.type = type;
			this.pattern = pattern;
			this.replace = replace;
		}
		
		public function toString():String{
			return '{"type":"' + type
			   + '", "pattern":"' + pattern
			   + '", "replace":"' + replace
			   + '", "enable":' + enable
			   + '}';
		}
	}
}