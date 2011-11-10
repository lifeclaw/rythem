package com.webpluz.vo {
	
	public class ResponseData {
		public var sig:String;
		public var headersObject:Object;
		public var body:String;
		public var rawData:String;
		public var resultCode:String;
		public var isChuncked:Boolean=false;
		
		private static const NL:RegExp=new RegExp(/\r?\n/);
		public var serverIp:String;
		public function ResponseData(headerString:String="") {
			if(headerString!=""){
				this.parseHeader(headerString);
			}
			body="";
			rawData="";
		}
		public function parseHeader(headerString:String):void{
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
	}
}
