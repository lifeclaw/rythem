package com.jo2.utils
{
	public final class StringBuffer
	{
		private var _buffer:String;
		private var _components:Array
		
		public function StringBuffer(){
			this.clear();
		}
		
		public function append(value:String):void{
			_buffer += value;
			_components = _buffer.split('\r\n').filter(function(item:String, index:uint, arr:Array):Boolean{
				return !item.match(/^\s*$/);
			});
		}
		
		public function clear():void{
			_buffer = '';
			_components = [ ];
		}
		
		public function get components():Array{
			return _components;
		}
		
		public function toString():String{
			return _components.join('\n');
		}
	}
}