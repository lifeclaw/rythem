package com.jo2.system
{
	import com.jo2.event.PayloadEvent;
	import com.jo2.system.OS;
	import com.jo2.system.windows.WindowsTerminal;
	import com.jo2.utils.StringBuffer;
	
	import flash.desktop.NativeProcess;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	/**
	 * Terminal (or known as Command Line in Windows)
	 * the main purpose of this class is to run the system's terminal and execute specify command
	 * DON'T use this class directly, instead, use Terminal.getTerminal to get a instance for your operating system
	 * once the command execution is complete, the result/error will be fill into the output/errorBuffer, and the process will exit
	 */
	[Event(name="complete", type="com.jo2.event.PayloadEvent")]
	public class Terminal extends NativeProcess implements ITerminal
	{
		private static const CHARSET:String = OS.languageIsChinese ? 'GBK' : 'UTF8';
		
		protected var _outputBuffer:StringBuffer;
		protected var _errorBuffer:StringBuffer;
		protected var _executing:Boolean;
		
		public static function getTerminal():ITerminal{
			switch(OS.type){
				case OS.WINDOWS: return new WindowsTerminal(); break;
				default: trace('[Terminal] unsupported os!'); return null;
			}
		}
		
		public function Terminal(){
			super();
			this.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOuputData);
			this.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
			this.addEventListener(NativeProcessExitEvent.EXIT, onExit);
		}
		
		//TODO OVERRIDE THIS METHOD TO EXECUTE COMMAND IN SPECIFY OS
		public function execute(command:String):void{
			if(!this.executing){
				_outputBuffer = new StringBuffer();
				_errorBuffer = new StringBuffer();
				_executing = true;
			}
			else throw new Error('terminal is still running');
		}
		
		public function get outputBuffer():StringBuffer{
			return this._outputBuffer;
		}
		
		public function get errorBuffer():StringBuffer{
			return this._errorBuffer;
		}
		
		public function get executing():Boolean{
			return this._executing;
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
			_executing = false;
			trace('[Terminal] output:\n' + _outputBuffer);
			trace('[Terminal] error:\n' + _errorBuffer);
			trace('[Terminal] exit');
			this.dispatchCompleteEvent();
		}
		
		protected function dispatchCompleteEvent():void{
			this.dispatchEvent(new PayloadEvent(PayloadEvent.COMPLETE, this.outputBuffer));
		}
	}
}