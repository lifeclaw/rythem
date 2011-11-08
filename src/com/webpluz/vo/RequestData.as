package com.webpluz.vo {
	public class RequestData {
		public var sig:String;
		public var headersObject:Object;
		public var body:String;
		public var rawData:String;
		public var method:String;
		public var protocol:String;
		public var path:String;
		public var port:Number;
		public var httpVersion:String;
		public var server:String;
		private static const NL:RegExp=new RegExp(/\r?\n/);
		public function RequestData(headerString:String) {
			this.rawData = headerString;
			var lines:Array = headerString.split(NL);
			var initialRequestSignature:String=lines[0];
			var initialRequestSignatureComponents:Array=initialRequestSignature.split(" ");
			method = initialRequestSignatureComponents[0];
			port = 80;
			var serverAndPath:String=initialRequestSignatureComponents[1];
			httpVersion = initialRequestSignatureComponents[2];
			serverAndPath=serverAndPath.replace(/^http(s)?:\/\//, "");
			// fix problem when:CONNECT github.com:443 HTTP/1.0
			var indexOfPath:int=serverAndPath.indexOf("/");
			if (indexOfPath == -1){
				indexOfPath=serverAndPath.length;
			}
			server = serverAndPath.substring(0, indexOfPath);
			if (server.indexOf(":") != -1){
				port = Number(server.substring(server.indexOf(":") + 1, indexOfPath)); 
				server=server.substring(0, server.indexOf(":"));
			}
			path = serverAndPath.substring(serverAndPath.indexOf("/"), serverAndPath.length) || "/";
			
			var reqSig:String=lines.shift();
			headersObject = {};
			for each (var line:String in lines){
				var name:String=line.substring(0, line.indexOf(":"));
				var value:String=line.substring(line.indexOf(":") + 2, line.length);
				headersObject[name.toLowerCase()] = value;
			}
			body="";
		}
	}
}
