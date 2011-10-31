package com.jo2.system
{
	import flash.system.Capabilities;

	/**
	 * 獲取或判斷系統類型、系統語言等東東
	 * TODO 是否需要加個方法獲取系統版本？（各個系統的字符串格式詳見Capabilities的文檔）
	 */
	public final class OS
	{
		public static const WINDOWS:String = 'windows';
		public static const MAC:String = 'mac';
		public static const LINUX:String = 'linux';
		
		private static const OS:String = Capabilities.os;
		private static const OS_TYPE:String = OS.split(' ')[0].toLowerCase();
		private static const IS_WINDOWS:Boolean = (OS.toLowerCase().indexOf(WINDOWS) != -1);
		private static const IS_MAC:Boolean = (OS.toLowerCase().indexOf(MAC) != -1);
		private static const IS_LINUX:Boolean = (OS.toLowerCase().indexOf(LINUX) != -1);
		
		//check/get system type
		public static function get isWindows():Boolean{	return IS_WINDOWS;	}
		public static function get isMac():Boolean{		return IS_MAC;		}
		public static function get isLinux():Boolean{		return IS_LINUX;		}
		public static function get type():String{			return OS_TYPE;		}
		
		//check whether the system language is Chinese or not
		public static function get languageIsChinese():Boolean{
			return Capabilities.language == 'zh-CN' || Capabilities.language == 'zh-TW';
		}
		
		public static function toString():String{
			return OS;
		}
	}
}