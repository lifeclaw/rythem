package com.jo2.system
{
	import com.jo2.core.Watcher;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	
	/**
	 * watch changes in the system clipboard
	 * currently this watcher could only handle text data in the clipboard
	 * so any other data that is saved into the clipboard would not be handled
	 */
	public final class ClipboardWatcher extends Watcher
	{
		private var _data:*;
		
		public function get data():*{
			return this._data;
		}
		
		/**
		 * update clipboard data
		 * @param {*} data
		 * @param {String} format data format, default is text
		 */
		public function updateClipboard(data:*, format:String = ClipboardFormats.TEXT_FORMAT):void{
			this._data = data;
			Clipboard.generalClipboard.setData(format, data);
			trace('[ClipboardWatcher] updated (' + format + ') ' + data);
		}
		
		/**
		 * read the content of clipboard and store it if it's changed
		 * return true if clipboard data is changed
		 */
		override public function checkChange():*{
			if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
				var data:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
				if(this._data != data){
					this._data = data;
					trace('[ClipboardWatcher] changed ' + data);
					return data;
				}
			}
			return null;
		}
	}
}