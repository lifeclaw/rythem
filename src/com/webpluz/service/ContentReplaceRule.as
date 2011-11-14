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
				var contentOfUrl:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
				fileStream.close();
				if(this._replaceUrl.indexOf(".qzmin")==(this._replaceUrl.length - 5)){
					_replaceContent = this.readFileByMerge(contentOfUrl);
				}else{
					_replaceContent = contentOfUrl;
				}
				var contentLength:Number = _replaceContent.length;
				_replaceContent = "HTTP/1.1 200 OK with automatic headers\r\nContent-Length: "
					+contentLength+"\r\nCache-Control: max-age:0, must-revalidate\r\nContent-Type: text/html\r\n\r\n"
					+this._replaceContent;
			}else{
				var noSuchFileError:String = "Rythem cannot resolve this path["+this._replaceUrl+"]";
				_replaceContent = "HTTP/1.1 404 Not Found\r\nRythemTemplate: True\r\nContent-Type: text/html Content-Length:"+noSuchFileError.length+"\r\n\r\n"+noSuchFileError;
			}
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
		
	}
}