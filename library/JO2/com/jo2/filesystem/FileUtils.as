package com.jo2.filesystem
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	/**
	 * File Utils is use for simply write or read a file
	 * nothing special, just save you the time to create a filestream to open, read/write, close the file
	 * NOTE: don't use this one to read large file or write huge data to file! it might froze the app!
	 */
	public class FileUtils
	{
		public static function readUTFBytes(file:File, length:uint = 0, position:uint = 0):String{
			if(file.exists){
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				stream.position = position;
				var result:String = stream.readUTFBytes(length || stream.bytesAvailable);
				stream.close();
				return result;
			}
			return '';
		}
		
		public static function writeUTFBytes(file:File, value:String, position:uint = 0):void{
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.position = position;
			stream.writeUTFBytes(value);
			stream.close();
		}
	}
}