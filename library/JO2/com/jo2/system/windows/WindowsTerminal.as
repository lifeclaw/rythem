package com.jo2.system.windows
{
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import com.jo2.system.Terminal;

	/**
	 * this is the windows command line process
	 */
	public class WindowsTerminal extends Terminal
	{
		protected static const CMD:String = 'C:\\Windows\\System32\\cmd.exe';
		
		//execute the specify command in windows command line
		override public function execute(command:String):void{
			super.execute(command);
			trace('[Terminal] execute: cmd /C ' + command);
			var args:Vector.<String> = new Vector.<String>();
			args.push('/C');
			args.push(command);
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = new File(CMD);
			info.arguments = args;
			this.start(info);
		}
	}
}