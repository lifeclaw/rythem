package com.webpluz.service{
	import com.webpluz.vo.RequestData;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class ContentReplaceRule extends Rule{
		
		private var _file:File;
		private var _replaceContent:String; // for cache
		private var _replaceUrl:String;
		private var _urlRule:String;
		
		public function ContentReplaceRule(urlRule:String,replaceUrl:String){
			super(Rule.RULE_TYPE_REPLACE_SINGLE_CONTENT);
			this._replaceUrl = replaceUrl;
			this._urlRule = urlRule;
			
			this._replaceContent = "";
		}
		public override function isMatch(requestData:RequestData):Boolean{
			// only exactly match
			trace(this._urlRule,requestData.fullUrl);
			return (this._urlRule.indexOf(requestData.fullUrl) == 0);
		}
		public function getContent():String{
			// TODO monitor the file content's change
			if(!_replaceContent){
				this.readFile();
			}
			return _replaceContent;
		}
		
		private function readFile():void{
			_file = File.userDirectory.resolvePath(this._replaceUrl);
			var fileStream:FileStream = new FileStream();
			if(_file.exists){
				fileStream.open(_file ,FileMode.READ);
				_replaceContent = fileStream.readUTFBytes(fileStream.bytesAvailable);
				fileStream.close();
			
				var contentLength:Number = _replaceContent.length;
				_replaceContent = "HTTP/1.1 200 OK with automatic headers\r\nContent-Length: "
					+contentLength+"\r\nCache-Control: max-age:0, must-revalidate\r\nContent-Type: text/html\r\n\r\n"
					+this._replaceContent;
			}else{
				var noSuchFileError:String = "Rythem cannot resolve this path["+this._replaceUrl+"]";
				_replaceContent = "HTTP/1.1 404 Not Found\r\nRythemTemplate: True\r\nContent-Type: text/html Content-Length:"+noSuchFileError.length+"\r\n\r\n"+noSuchFileError;
			}
		}
	}
}