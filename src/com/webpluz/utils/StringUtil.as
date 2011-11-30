package com.webpluz.utils{
	import flash.utils.ByteArray;

	public class StringUtil{
		public function StringUtil(){
		}
		
		
		private static var tempByteArray:ByteArray = new ByteArray;
		public static function getByteLength(str:String):uint{
			tempByteArray.clear();
			tempByteArray.writeUTFBytes(str);
			return tempByteArray.length;
		}
		
	}
}