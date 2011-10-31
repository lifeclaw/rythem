package com.jo2.system
{
	import com.jo2.system.OS;
	import com.jo2.utils.StringBuffer;
	
	import flash.desktop.NativeProcess;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	public class Terminal extends NativeProcess
	{
		private static const CHARSET:String = OS.languageIsChinese ? 'GBK' : 'UTF8';
		
		protected var _outputBuffer:StringBuffer;
		protected var _errorBuffer:StringBuffer;
		
		public static function getTerminal():Terminal{
			switch(OS.type){
				case OS.WINDOWS: return new WindowsTerminal(); break;
				default: return null;
			}
		}
		
		public function Terminal(){
			super();
			this.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOuputData);
			this.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
			this.addEventListener(NativeProcessExitEvent.EXIT, onExit);
		}
		
		//TODO OVERRIDE THIS METHOD TO EXECUTE SPECIFY COMMAND
		public function execute(command:String):void{
			_outputBuffer = new StringBuffer();
			_errorBuffer = new StringBuffer();
		}
		
		public function get outputBuffer():StringBuffer{
			return this._outputBuffer;
		}
		
		public function get errorBuffer():StringBuffer{
			return this._errorBuffer;
		}
		
		protected function onOuputData(e:ProgressEvent):void{
			var output:String = standardOutput.readMultiByte(standardOutput.bytesAvailable, CHARSET);
			_outputBuffer.append(output);
			//trace('[Terminal] output:\n' + output);
		}
		
		protected function onErrorData(e:ProgressEvent):void{
			var error:String = standardError.readMultiByte(standardError.bytesAvailable, CHARSET);
			_errorBuffer.append(error);
			//trace('[Terminal] error:\n' + error);
		}
		
		protected function onExit(e:NativeProcessExitEvent):void{
			trace('[Terminal] output:\n' + _outputBuffer);
			trace('[Terminal] error:\n' + _errorBuffer);
			trace('[Terminal] exit');
		}
	}
}