package com.webpluz.vo {
	import com.probertson.utils.GZIPBytesEncoder;
	
	import flash.utils.ByteArray;
	
	public class ResponseData {
		public var sig:String;
		public var headersObject:Object;
		public var body:String;
		public var rawData:String;
		public var resultCode:String;
		public var isChuncked:Boolean=false;
		public var headerRawData:String;
		
		private var _bodyUncompressed:String;
		private var _rawByteArray:ByteArray = new ByteArray();
		private static const NL:RegExp=new RegExp(/\r?\n/);
		private static const SEPERATOR:RegExp=new RegExp(/\r?\n\r?\n/);
		public var serverIp:String;
		private var decoded:Boolean = false;
		public function ResponseData(headerString:String="") {
			if(headerString!=""){
				this.parseHeader(headerString);
			}
			body="";
			rawData="";
		}
		public function parseHeader(headerString:String):void{
			this.headerRawData = headerString;
			var headerArray:Array=headerString.split(NL);
			sig = headerArray.shift();//HTTP/1.1 200 OK
			resultCode = sig.split(" ")[1];
			//trace(sig+" resultCode:"+resultCode);
			headersObject = {};
			for each (var line:String in headerArray){
				var name:String=line.substring(0, line.indexOf(":"));
				var value:String=line.substring(line.indexOf(":") + 2, line.length);
				headersObject[name.toLowerCase()]=value;
				
				
			}
			body="";
		}
		
		public function set rawDataInByteArray(ba:ByteArray):void{
			_rawByteArray.clear();
			//trace("writing bodyRawDataByteArray:"+ba.toString());
			//Content-Type: text/html; charset=iso-8859-1
			var tmp:Array;
			if(this.headersObject){
				tmp = String(this.headersObject['content-type']).split('; ');
				if(tmp.length>=2){
					tmp = tmp[1].split('=');
				}
			}
			var charSet:String = tmp[1] || 'gb18030';
			ba.position = 0;
			this.rawData = ba.readMultiByte(ba.length,charSet);
			//this.rawData = ba.toString();
			_rawByteArray.writeBytes(ba);
		}
		public function get rawDataInByteArray():ByteArray{
			return _rawByteArray;
		}
		public function get bodyUncompressed():String{
			if(!this.headersObject){
				return "requesting...";
			}
			if(!this.decoded){
				this.decoded = true;
				var tmp:ByteArray;
				
				
				
				if(this.headersObject['content-encoding'] != 'gzip' &&
					this.headersObject['transfer-encoding'] != 'chunked'){
					_bodyUncompressed = this.rawData.split(SEPERATOR)[1];
				}else{
					
					// check chunked
					if(this.headersObject['transfer-encoding'] == 'chunked'){
						tmp = parseChunkedData(rawDataInByteArray);
					}else{
						tmp = rawDataInByteArray;
					}
					
					// check gzip
					if(tmp && this.headersObject['content-encoding'] == 'gzip'){
						var gzipBytesEncoder:GZIPBytesEncoder = new GZIPBytesEncoder();
						//trace(this.rawDataInByteArray.toString());
						try{
							tmp.position = 0;//重要!!!!!!!
							tmp = gzipBytesEncoder.uncompressToByteArray(tmp);
						}catch(e:Error){
							trace(e.message);
						}
					}
					_bodyUncompressed = tmp.toString();
				}
			}
			return _bodyUncompressed;
		}
		
		
		protected function parseChunkedData(src:ByteArray):ByteArray{
			var retArray:ByteArray = new ByteArray();
			var tmpPosition:uint = src.position;
			
			
			src.position = 0;
			var headerTest:String = new String();
			while (src.position < src.length){
				headerTest += src.readUTFBytes(1);
				if (headerTest.search(SEPERATOR) != -1){
					break;
				}
			}
			//retArray.writeBytes(src,0,src.position); no need header string
			
			var lenString:String = "0x";
			var len:Number = 0;
			var byte:String;
			while (src.position < src.length){
				byte = src.readUTFBytes(1);
				if (byte == "\n"){
					len = parseInt(lenString);
					if (len == 0){
						retArray.writeUTF("\r\n");
						break;
					}else{
						retArray.writeBytes(src,src.position,len);
						src.position += (len + 2);//TODO check if the newline is \r\n or \n
						lenString = "0x";
						len = 0;
					}
				}else{
					lenString += byte;
				}
			}
			
			src.position = tmpPosition;
			return retArray;
		}
		
	}
}
