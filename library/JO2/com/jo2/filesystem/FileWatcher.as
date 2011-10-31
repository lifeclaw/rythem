package com.jo2.filesystem
{
	import com.jo2.core.Watcher;
	import com.jo2.event.PayloadEvent;
	
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	/**
	 * watch changes of a file, changes including creating, removing and modifing
	 * the default and min check delay is 1 second, when the file is changed, a payload event will be dispatched
	 * the payload event will carry the change type in its data property
	 */
	public final class FileWatcher extends Watcher
	{
		public static const NOCHANGE:uint = 0;
		public static const CREATED:uint = 1;
		public static const REMOVED:uint = 2;
		public static const MODIFIED:uint = 3;
		
		private var _file:File;
		private var _lastModifyDate:Date;
		private var _exists:Boolean;
		
		public function FileWatcher(file:File = null, delay:uint = 1000){
			this.file = file;
			super(delay);
		}
		
		public function get file():File{
			return this._file;
		}
		
		public function set file(value:File):void{
			this._file = value;
			this._exists = value.exists;
			if(value.exists) this._lastModifyDate = value.modificationDate;
			trace('[FileWatcher] watching file ' + value.nativePath + ' (exist ? ' + value.exists + ')');
		}
		
		/**
		 * check to see the file is changed or not (including added, moved, modified)
		 * -------------------------------------------------------------------------------------
		 * property :	_exists		_file.exists		_file.modificationDate	CHANGED?
		 * -------------------------------------------------------------------------------------
		 * value :		false			false			-					false
		 * 			false			true			-					created
		 * 			true			false			-					removed
		 * 			true			true			no change			false
		 * 			true			true			changed				modified
		 * -------------------------------------------------------------------------------------
		 * @return {Boolean} true if the file is changed
		 */
		override public function checkChange():*{
			if(!this._exists){
				if(this._file.exists){
					//file is added
					this._exists = true;
					this._lastModifyDate = this._file.modificationDate;
					trace('[FileWather] created ' + this._file.nativePath);
					return CREATED;
				}
				else return NOCHANGE;
			}
			else{
				if(this._file.exists){
					if(this._file.modificationDate.time != this._lastModifyDate.time){
						//file is modified
						this._lastModifyDate = this._file.modificationDate;
						trace('[FileWatcher] changed ' + this._file.nativePath);
						return MODIFIED;
					}
					else return NOCHANGE;
				}
				else{
					//file is removed
					this._exists = false;
					trace('[FileWatcher] removed ' + this._file.nativePath);
					return REMOVED;
				}
			}
		}
		
		override protected function onTimer(e:TimerEvent):void{
			switch(this.checkChange()){
				case CREATED:		this.dispatchEvent(new PayloadEvent(PayloadEvent.CHANGE, CREATED)); break;
				case MODIFIED:	this.dispatchEvent(new PayloadEvent(PayloadEvent.CHANGE, MODIFIED)); break;
				case REMOVED:	this.dispatchEvent(new PayloadEvent(PayloadEvent.CHANGE, REMOVED)); break;
			}
		}
	}
}