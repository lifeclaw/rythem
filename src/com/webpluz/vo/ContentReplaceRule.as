package com.webpluz.vo{
	
	
	
	import com.webpluz.utils.StringUtil;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import mx.core.ByteArrayAsset;
	
	public class ContentReplaceRule extends Rule{
		
		private var _file:File;
		private var _replaceContent:String; // for cache
		
		private var _replace:String;
		private var _pattern:String;
		
		private var _isDirectoryRule:Boolean = false;
		
		public function ContentReplaceRule(urlRule:String,replaceUrl:String, enbale:Boolean = true){
			super(Rule.RULE_TYPE_REPLACE_CONTENT, RULE_PRIORITY_NORMAL, enbale);
			this.replace = replaceUrl;
			this.pattern = urlRule;
			
			this._replaceContent = "";
		}
		public override function isMatch(requestData:RequestData):Boolean{
			// only exactly match
			// trace(this._urlRule,requestData.fullUrl);
			
			if(this._isDirectoryRule){
				/*
				*  rule:  http://a.b.c/d/    => d:/dsite/
				*  rule:  /e/f/g/            => d:/anysite/efg/
				*  rule:  a.b.c/d/           => 
				*    any rule above without '/'
				*/
				//if(requestData.path.lastIndexOf('/') != requestData.path.length-1){
				
				if(requestData.fullUrl.indexOf(this._pattern) !=-1){// (requestData.fullUrl.lastIndexOf('/') - this._pattern.length +(isPatternHasEnd?1:0))){
					return true;
				}
				return false;
				//}else{
				//	return false;
				//}
			}else{
				// pattern: http://a.b.c/
				// url: http://a.b.c/adfs
				return (requestData.fullUrl.indexOf(this._pattern) == 0);
			}
		}
		public function getContent(requestData:RequestData=null):String{
			// TODO monitor the file content's change
			//if(this._isDirectoryRule || !_replaceContent){// @TODO  directory rule need to refresh content in every request,do some cache. 
				_replaceContent = this.readFile(requestData);
			//}
			return _replaceContent;
		}
		
		private function readFile(requestData:RequestData=null):String{
			_file = File.userDirectory.resolvePath(this._replace);
			var fileStream:FileStream = new FileStream();
			var noSuchFileError:String;
			var contentLength:Number;
			var contentOfUrl:String;
			// TODO set this as member
			var contentTypeMappings:Object = {
				"html":"text/html",
				"htm":"text/html",
				"text":"text/plain",
				"css":"text/css",
				"js":"application/x-javascript",
				"jpg":"image/jpeg",
				"jpeg":"image/jpeg",
				"gif":"image/gif",
				"png":"image/png",
				"bmp":"applicatoin/x-bmp",
				"qzmin":"application/x-javascript"
			};
			var tmp:Array = requestData.path.split("/");
			var fileName:String = tmp[tmp.length-1];
			var tmp2:Array = fileName.split(".");
			var contentType:String = contentTypeMappings[tmp2[tmp2.length-1].toString().toLowerCase()] || "text/html";
			if(_file.exists){
				if(_isDirectoryRule){// directory match
					var filePath:String;
					var isPatternHasEnd:Boolean = this._replace.charAt(this._replace.length-1) == "/";
					var additionalPath:String =  requestData.fullUrl.substr(this._pattern.indexOf(requestData.fullUrl)+this._pattern.length+1);
					if(Capabilities.os.indexOf("Windows")!=-1){
						isPatternHasEnd = this._replace.charAt(this._replace.length-1) == "\\";
						additionalPath = additionalPath.replace(new RegExp(/\//g),"\\");
						filePath = this._replace+(isPatternHasEnd?'':"\\")+additionalPath;
					}else{
						filePath = this._replace+(isPatternHasEnd?'':'/')+additionalPath;
					}
					
					_file = File.userDirectory.resolvePath(filePath);
					if(_file.exists){
						fileStream.open(_file ,FileMode.READ);
						contentOfUrl = "";
						contentOfUrl += fileStream.readUTFBytes(_file.size);
						fileStream.close();
						var tmp3:ByteArray=new ByteArray();
						tmp3.writeUTFBytes(contentOfUrl);
						contentLength = tmp3.length;
						_replaceContent = "HTTP/1.1 200 OK with automatic headers\r\nContent-Length: "
							+contentLength+"\r\nCache-Control: max-age:0, must-revalidate\r\nContent-Type: "+contentType+"\r\n\r\n"
							+contentOfUrl;
					}else{// no such file...
						noSuchFileError = "Rythem cannot resolve this path["+filePath+"] Directory Rule";
						contentLength = StringUtil.getByteLength(noSuchFileError);;
						_replaceContent = "HTTP/1.1 404 Not Found\r\nRythemTemplate: True\r\nContent-Type: text/html\r\nContent-Length:"+noSuchFileError.length+"\r\n\r\n"+noSuchFileError;
					}
					
				}else{// single match
					fileStream.open(_file ,FileMode.READ);
					contentOfUrl = "";
					contentOfUrl = fileStream.readUTFBytes(_file.size);
					fileStream.close();
					if(this._replace.indexOf(".qzmin")==(this._replace.length - 6)){// qzmin combine match
						_replaceContent = this.readFileByMerge(contentOfUrl);
					}else{// exact file match
						_replaceContent = contentOfUrl;
					}
					
					contentLength = StringUtil.getByteLength(_replaceContent);;
					_replaceContent = "HTTP/1.1 200 OK with automatic headers\r\nContent-Length: "
						+contentLength+"\r\nCache-Control: max-age:0, must-revalidate\r\nContent-Type: "+contentType+"\r\n\r\n"
						+this._replaceContent;
				}
			}else{
				noSuchFileError = "Rythem cannot resolve this path["+this._replace+"]";
				contentLength = StringUtil.getByteLength(noSuchFileError);;
				_replaceContent = "HTTP/1.1 404 Not Found\r\nRythemTemplate: True\r\nContent-Type: text/html Content-Length:"+noSuchFileError.length+"\r\n\r\n"+noSuchFileError;
			}
			return _replaceContent;
		}
		
		private function readFileByMerge(qzminContent:String):String{
			var result:String="";
			trace(qzminContent);
			qzminContent = qzminContent.replace(/\r|\n/g,"");
			qzminContent = qzminContent.replace(/\s+([^\s:\"{}]+):/g,"\"$1\":");
			trace(qzminContent);
			var obj:Object;
			try{
				obj = JSON.parse(qzminContent);
			}catch(e:Error){
				trace(e.message,qzminContent);
				
				return qzminContent+" is not a validate json data";
			}
			var fileToRead:File;
			//TODO validate the qzmin file content
			//if(obj && obj.projects && obj.projects[0] && obj.projects[0]){
			var includes:Array = obj.projects[0]['include'];
			var fileStream:FileStream = new FileStream();
			var folder:String = this._replace.substring(0,this._replace.lastIndexOf("/")+1);
			for each(var i:String in includes){
				i = i.replace("./","");
				fileToRead = File.userDirectory.resolvePath(folder+i);
				//fileToRead = new File(i);
				if(fileToRead.exists){
					fileStream.open(fileToRead,FileMode.READ);
					result += fileStream.readUTFBytes(fileToRead.size);
					fileStream.close();
				}else{
					//TODO 
					trace("no such file "+i);
				}
			}
			//}
			trace(result);
			return result;
		}
		
		public function get pattern():String{
			return this._pattern;
		}
		public function set pattern(value:String):void{
			if(this._pattern == value){
				return;
			}
			this._replaceContent = '';
			this._pattern = value;
			
		}
		public function get replace():String{
			return this._replace;
		}
		public function set replace(value:String):void{
			if(this._replace != value){
				this._replaceContent = '';
				this._replace = value;
				var tmpFile:File = File.userDirectory.resolvePath(value);
				if(tmpFile.exists){
					this._isDirectoryRule = tmpFile.isDirectory;
				}else{
					// TODO need to warn user?
				}
			}
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
