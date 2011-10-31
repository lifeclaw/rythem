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
		protected var _file:File;
		protected var _stream:FileStream;
		
		public function FileUtils(file:File){
			this._file = file;
			this._stream = new FileStream();
		}
		
		public function readUTFBytes(length:uint = 0, position:uint = 0):String{
			if(this._file.exists){
				this._stream.open(this._file, FileMode.READ);
				this._stream.position = position;
				var result:String = this._stream.readUTFBytes(length || this._stream.bytesAvailable);
				this._stream.close();
				return result;
			}
			return '';
		}
		
		public function writeUTFBytes(value:String, position:uint = 0):void{
			this._stream.open(this._file, FileMode.WRITE);
			this._stream.position = position;
			this._stream.writeUTFBytes(value);
			this._stream.close();
		}
	}
}