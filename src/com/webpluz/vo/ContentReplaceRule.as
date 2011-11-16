package com.webpluz.vo{
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class ContentReplaceRule extends Rule{
		
		private var _file:File;
		private var _replaceContent:String; // for cache
		
		private var _replaceUrl:String;
		private var _urlRule:String;
		
		private var _isDirectoryRule:Boolean = false;
		
		public function ContentReplaceRule(urlRule:String,replaceUrl:String, enbale:Boolean = true){
			super(Rule.RULE_TYPE_REPLACE_CONTENT, RULE_PRIORITY_NORMAL, enbale);
			this._replaceUrl = replaceUrl;
			this._urlRule = urlRule;
			
			if(this._urlRule.charAt(this._urlRule.length-1) == '/'){
				this._isDirectoryRule = true;
			}
			
			this._replaceContent = "";
		}
		public override function isMatch(requestData:RequestData):Boolean{
			// only exactly match
			// trace(this._urlRule,requestData.fullUrl);
			
			if(this._isDirectoryRule){// direcory rule,request must no end with "/"
				if(requestData.path.lastIndexOf('/') != requestData.path.length-1){
					if(requestData.path.indexOf(this._urlRule) == (requestData.path.lastIndexOf('/') - this._urlRule.length +1)){
						return true;
					}
					return false;
				}else{
					return false;
				}
			}else{
				return (this._urlRule.indexOf(requestData.fullUrl) == 0);
			}
		}
		public function getContent(requestData:RequestData=null):String{
			// TODO monitor the file content's change
			if(this._isDirectoryRule || !_replaceContent){// @TODO  directory rule need to refresh content in every request,do some cache. 
				_replaceContent = this.readFile(requestData);
			}
			return _replaceContent;
		}
		
		private function readFile(requestData:RequestData=null):String{
			_file = File.userDirectory.resolvePath(this._replaceUrl);
			var fileStream:FileStream = new FileStream();
			var noSuchFileError:String;
			var contentLength:Number;
			var contentOfUrl:String;
			if(_file.exists){
				if(_isDirectoryRule){// directory
					var tmp:Array = requestData.path.split("/");
					var fileName:String = tmp[tmp.length-1];
					_file = File.userDirectory.resolvePath(this._replaceUrl+fileName);
					if(_file.exists){
						fileStream.open(_file ,FileMode.READ);
						contentOfUrl = fileStream.readUTFBytes(fileStream.bytesAvailable);
						fileStream.close();
						contentLength = contentOfUrl.length;
						_replaceContent = "HTTP/1.1 200 OK with automatic headers\r\nContent-Length: "
							+contentLength+"\r\nCache-Control: max-age:0, must-revalidate\r\nContent-Type: text/html\r\n\r\n"
							+this._replaceContent;
					}else{
						noSuchFileError = "Rythem cannot resolve this path["+this._replaceUrl+fileName+"] Directory Rule";
						_replaceContent = "HTTP/1.1 404 Not Found\r\nRythemTemplate: True\r\nContent-Type: text/html Content-Length:"+noSuchFileError.length+"\r\n\r\n"+noSuchFileError;
					}
					
				}else{
					fileStream.open(_file ,FileMode.READ);
					contentOfUrl = fileStream.readUTFBytes(fileStream.bytesAvailable);
					fileStream.close();
					if(this._replaceUrl.indexOf(".qzmin")==(this._replaceUrl.length - 5)){
						_replaceContent = this.readFileByMerge(contentOfUrl);
					}else{
						_replaceContent = contentOfUrl;
					}
					contentLength = _replaceContent.length;
					_replaceContent = "HTTP/1.1 200 OK with automatic headers\r\nContent-Length: "
						+contentLength+"\r\nCache-Control: max-age:0, must-revalidate\r\nContent-Type: text/html\r\n\r\n"
						+this._replaceContent;
				}
			}else{
				noSuchFileError = "Rythem cannot resolve this path["+this._replaceUrl+"]";
				_replaceContent = "HTTP/1.1 404 Not Found\r\nRythemTemplate: True\r\nContent-Type: text/html Content-Length:"+noSuchFileError.length+"\r\n\r\n"+noSuchFileError;
			}
			return _replaceContent;
		}
		
		private function readFileByMerge(qzminContent:String):String{
			var result:String="";
			var obj:Object = JSON.parse(qzminContent);
			var fileToRead:File;
			//TODO validate the qzmin file content
			//if(obj && obj.projects && obj.projects[0] && obj.projects[0]){
				var includes:Array = obj.projects[0]['include'];
				var fileStream:FileStream = new FileStream();
				for each(var i:String in includes){
					fileToRead = new File(i);
					if(fileToRead.exists){
						fileStream.open(fileToRead,FileMode.READ);
						result += fileStream.readUTFBytes(fileStream.bytesAvailable);
						fileStream.close();
					}else{
						//TODO 
						trace("no such file "+i);
					}
				}
			//}
			
			return result;
		}
		
		public function get pattern():String{
			return this._urlRule;
		}
		public function get replace():String{
			return this._replaceUrl;
		}
		
		override public function isEqual(anotherRule:*):Boolean{
			if(anotherRule is ContentReplaceRule){
				var r:ContentReplaceRule = anotherRule as ContentReplaceRule;
				return (r.pattern == this.pattern && r.replace == this.replace);
			}
			return false;
		}
		
		override public function toString():String{
			return '{"enable":' + enable + ', "type":"content", "url":"' + pattern + '", "replace":"' + replace + '"}';
		}
		
	}
}