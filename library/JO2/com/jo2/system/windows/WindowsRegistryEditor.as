package com.jo2.system.windows
{
	import com.jo2.filesystem.FileUtils;
	
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;

	/**
	 * Windows Registry Editor
	 * modify windows registry by executing a .bat file which contains registry commands
	 */
	public class WindowsRegistryEditor extends WindowsTerminal
	{
		//registry data types
		public static const REG_SZ:String 							= 'REG_SZ';
		public static const REG_MULTI_SZ:String 					= 'REG_MULTI_SZ';
		public static const REG_DWORD:String 						= 'REG_DWORD';
		public static const REG_DWORD_BIG_ENDIAN:String 			= 'REG_DWORD_BIG_ENDIAN';
		public static const REG_DWORD_LITTLE_ENDIAN:String 		= 'REG_DWORD_LITTLE_ENDIAN';
		public static const REG_BINARY:String						= 'REG_BINARY';
		public static const REG_LINK:String						= 'REG_LINK';
		public static const REG_FULL_RESOURCE_DESCRIPTOR:String	= 'REG_FULL_RESOURCE_DESCRIPTOR';
		public static const REG_EXPAND_SZ:String					= 'REG_EXPAND_SZ';
		
		//tep folder to store the .bat files
		//TODO clear these tmp files after we are done
		protected static const TMP_DIR:File = File.createTempDirectory();
		
		protected var _commands:Vector.<String>;
		
		public function WindowsRegistryEditor(){
			this._commands = new Vector.<String>();
		}
		
		override public function execute(command:String):void{
			//i do nothing
		}
		public function executeRegCommands():void{
			var commands:String = this._commands.join('\n');
			trace(commands);
			if(commands){
				//create a tmp bat file and execute it
				var name:String = 'reg.' + new Date().time + '.bat';
				var file:File = TMP_DIR.resolvePath(name);
				FileUtils.writeUTFBytes(file, commands);
				super.execute(file.nativePath);
			}
			else trace('[WindowsRegistryEditor] nothing to execute');
			this._commands = new Vector.<String>();
		}
		
		/**
		 * add a key(and entry) into the windows registry
		 * @param {String} key key name, something like "HKEY_CURRENT_USER\\Software\\..."
		 * @param {String} entry entry name
		 * @param {String} value
		 * @param {String} dataType
		 */
		public function addReg(key:String, entry:String = '', value:String = '', dataType:String = REG_SZ):void{
			this._commands.push(
				'REG ADD ' + key
				+ (entry ? ' /v ' + entry : '')
				+ ' /t ' + dataType
				+ (value ? ' /d ' + value : '')
			);
		}
		
		/**
		 * delete a key(and entry) from the windows registry
		 * @param {String} key key name, something like "HKEY_CURRENT_USER\\Software\\..."
		 * @param {String} entry entry name
		 */
		public function deleteReg(key:String, entry:String = ''):void{
			this._commands.push(
				'REG DELETE ' + key
				+ (entry ? ' /v ' + entry : '')
				+ ' /f'
			);
		}
		
		/**
		 * query results from the windows registry
		 * @param {String} key key name, something like "HKEY_CURRENT_USER\\Software\\..."
		 * @param {String} entry entry name
		 * @param {Boolean} allSubKeysAndEntries should the result contains all subkeys and their entries
		 */
		public function queryReg(key:String, entry:String = '', allSubKeysAndEntries:Boolean = false):void{
			this._commands.push(
				'REG QUERY ' + key
				+ (entry ? ' /v ' + entry : '')
				+ (allSubKeysAndEntries ? ' /s ' : '')
			);
		}
	}
}