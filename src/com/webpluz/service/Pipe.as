// from http://httpeek.googlecode.com/
package com.webpluz.service{
	import com.jo2.net.URI;
	import com.webpluz.vo.ContentReplaceRule;
	import com.webpluz.vo.IpReplaceRule;
	import com.webpluz.vo.RequestData;
	import com.webpluz.vo.ResponseData;
	import com.webpluz.vo.Rule;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.SecureSocket;
	import flash.net.Socket;
	import flash.net.URLRequestHeader;
	import flash.net.dns.DNSResolver;
	import flash.utils.ByteArray;
	
	[Event(name="PIPE_CONNECTED", type="com.webpluz.service.PipeEvent")]
	[Event(name="PIPE_COMPLETE", type="com.webpluz.service.PipeEvent")]
	[Event(name="PIPE_ERROR", type="com.webpluz.service.PipeEvent")]
	
	public class Pipe extends EventDispatcher{
		private var requestSocket:Socket;
		private var responseSocket:Socket;
		
		private var requestBuffer:ByteArray;
		private var responseBuffer:ByteArray;
		
		private var requestHeaderFound:Boolean;
		private var responseHeaderFound:Boolean;
		
		private var responseContentLength:Number;
		private var responseChunked:Boolean;
		
		
		private var requestData:RequestData;
		private var responseData:ResponseData;
		
		private var completeEvent:PipeEvent;
		private var connectEvent:PipeEvent;
		private var errorEvent:PipeEvent;
		
		private var _tearDowned:Boolean=false;
		/*
		public var responseResult:String;
		public var responseHeaderString:String;
		public var responseBody:String;
		*/
		private var _ruleManager:RuleManager;
		
		private static const SEPERATOR:RegExp=new RegExp(/\r?\n\r?\n/);
		private static const NL:RegExp=new RegExp(/\r?\n/);
		private static var id:Number=0;
		private var _indexId:Number;
		private var _proxy:URI;
		public function Pipe(socket:Socket,indexId:Number=0, proxy:URI = null){
			
			this._proxy = proxy;
			
			_ruleManager = RuleManager.getInstance();
			_indexId = id++;
			this.requestSocket=socket;
			
			this.requestBuffer=new ByteArray();
			this.responseBuffer=new ByteArray();
			this.requestHeaderFound=false;
			this.responseHeaderFound=false;
			this.responseContentLength=0;
			this.responseChunked=false;
			this.requestData = new RequestData();
			this.responseData = new ResponseData();
			
			this.requestSocket.addEventListener(ProgressEvent.SOCKET_DATA, onRequestSocketData);
			this.requestSocket.addEventListener(Event.CLOSE, onRequestSocketClose);
		}
		private function onRequestSocketData(e:ProgressEvent):void{
			this.requestSocket.readBytes(this.requestBuffer, this.requestBuffer.length, this.requestSocket.bytesAvailable);
			if (!this.requestHeaderFound){
				// Make a string version and check if we've received all the headers yet.
				var bufferString:String=this.requestBuffer.toString();
				//trace("bufferString=\n" + bufferString);
				var headerCheck:Number=bufferString.search(SEPERATOR);
				if (headerCheck != -1){
					this.requestHeaderFound=true;
					var headerString:String=bufferString.substring(0, headerCheck);
					var headerBodyDivision:Number=headerString.length + 4;
					var serverToConnect:String;
					requestData = new RequestData(headerString);
					serverToConnect = requestData.server;
					if(bufferString.length > headerBodyDivision){
						requestData.body = bufferString.substr(headerBodyDivision);
					}
					
					if(true){//@TODO disable cache,remove "If-Modified-Since"
						headerString = headerString.replace(/If\-modified\-since.*?\r\n/i,"");
					}
					headerString = headerString.replace(/proxy\-connection.*?\r\n/i,"");
					
					
					var pipeEvent:PipeEvent = new PipeEvent(PipeEvent.PIPE_CONNECTED,this._indexId,this.requestData);
					this.dispatchEvent(pipeEvent);
					
					var matchedRule:Rule = _ruleManager.getRule(requestData);
					if(matchedRule){
						var ruleType:String = matchedRule.getType();
						if(ruleType!=Rule.RULE_TYPE_REPLACE_IP){
							switch(ruleType){
								case Rule.RULE_TYPE_REPLACE_CONTENT:
									var autoResponse:String = (matchedRule as ContentReplaceRule).getContent(requestData);
									var headerAndBody:Array = autoResponse.split("\r\n\r\n");
									this.responseData.parseHeader(headerAndBody[0]);
									this.responseData.rawData = autoResponse;
									this.responseData.body = headerAndBody[1];
									this.requestSocket.writeUTFBytes(autoResponse);
									this.done();
									return;
									break;
								default:
									throw new Error("cannot handle this rule!");
									break;
							}
						}else{
							serverToConnect = (matchedRule as IpReplaceRule).getIpToChange();
						}
					}
					var newHeaderSignature:String = this.requestData.method + " " + this.requestData.path + " " + this.requestData.httpVersion + "\r\n";
					
					// Replace the old request signature with the new one.
					headerString = headerString.replace(/^.*?\r\n/, newHeaderSignature);
					var newRequestBuffer:ByteArray=new ByteArray();
					newRequestBuffer.writeUTFBytes(headerString);
					newRequestBuffer.writeUTFBytes("\r\n\r\n");
					if(this.requestBuffer.bytesAvailable > headerBodyDivision){
						newRequestBuffer.writeBytes(this.requestBuffer, headerBodyDivision);
					}
					//(newRequestBuffer.toString());
					this.requestBuffer=newRequestBuffer;
					if(this.requestData.port == 443){//
						this.done();
					}
					

					//if proxy is needed here, create a ProxySocket rather than a normal Socket
					if(this._proxy){
						trace('RESPONSE SOCKET AS PROXY SOCKET', _proxy);
						this.responseSocket=new ProxySocket(_proxy.authority, int(_proxy.port));
					}
					else{
						this.responseSocket=new Socket();
					}
					//var k:SecureSocket =  new SecureSocket();
					
					this.responseSocket.addEventListener(Event.CONNECT, onResponseSocketConnect);
					this.responseSocket.addEventListener(ProgressEvent.SOCKET_DATA, onResponseSocketData);
					this.responseSocket.addEventListener(Event.CLOSE, onResponseSocketClose);
					this.responseSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onResponseSocketIOError);
					this.responseSocket.addEventListener(IOErrorEvent.IO_ERROR, onResponseSocketIOError);
					//trace("connecting:",requestData.server, requestData.port);
					this.responseSocket.connect(serverToConnect, requestData.port);
					/*
					if (this.requestHeaders['Method'] == "CONNECT"){ //HTTP/1.1 200 Connection established\r\nConnection: keep-alive\r\n\r\n
					//HTTP/1.1 200 Connection established
					trace("secureSocket---------------");
					
					var responseBuffer:ByteArray=new ByteArray();
					responseBuffer.writeUTFBytes("HTTP/1.1 200 Connection established\r\n\r\n");
					this.requestSocket.writeBytes(responseBuffer);
					this.requestSocket.flush();
					}
					*/
				
					//trace("header "+this._indexId+"  \n"+this.requestBuffer.toString());
				}else{
					//trace("no header "+this._indexId);
				}
			}else{
				if (this.responseSocket.connected){
					trace("has header, and responseSocket connected"+this._indexId);
					requestData.body += this.requestBuffer.toString();
					this.responseSocket.writeBytes(this.requestBuffer);
					this.responseSocket.flush();
					this.requestBuffer.clear();
				}else{
					trace("has header, but responseSocket NOCONNECT"+this._indexId);
				}
			}
		}
		
		private function onResponseSocketIOError(e:IOErrorEvent):void{
			trace("responseSocketIOError:"+e.errorID, e.type, e.text);
			errorEvent = new PipeEvent(PipeEvent.PIPE_ERROR,this._indexId);
			this.dispatchEvent(errorEvent);
			this.tearDown();
		}
		
		private function onResponseSocketConnect(e:Event):void{
			trace("onResponseSocketCOnnect"+this._indexId);
			this.responseSocket.writeBytes(this.requestBuffer);
			this.responseSocket.flush();
			//var _headerEvent:HTTPHeadersEvent = new HTTPHeadersEvent();
			//this.dispatchEvent(_headerEvent);
		}
		
		private function onResponseSocketData(e:ProgressEvent):void{
			if(_tearDowned){
				return;
			}
			if (!this.testSocket(this.requestSocket))
				return;
			var position:Number=this.responseBuffer.length;
			this.responseSocket.readBytes(this.responseBuffer, position, this.responseSocket.bytesAvailable);
			this.requestSocket.writeBytes(this.responseBuffer, position);
			this.requestSocket.flush();
			if (!this.responseHeaderFound){
				// Make a string version and check if we've received all the headers yet.
				var bufferString:String=this.responseBuffer.toString();
				var headerCheck:Number=bufferString.search(SEPERATOR);
				if (headerCheck != -1){
					this.responseHeaderFound=true;
					var headerString:String=bufferString.substring(0, headerCheck);
					this.responseData.parseHeader(headerString);
					this.responseData.serverIp = this.responseSocket.remoteAddress;
					if(this.responseData.headersObject['transfer-encoding'] && 
						this.responseData.headersObject['transfer-encoding'].toString().toLowerCase() == "chunked"){
						this.responseChunked=true;
					}
					if(this.responseData.headersObject.hasOwnProperty('content-length')){
						this.responseContentLength=Number(this.responseData.headersObject['content-length']) + headerString.length + 4;
					}
					//TODO need dispath event when got response header?
					//this.dispatchEvent(this.headerEvent);
					
					this.responseData.rawDataInByteArray = this.responseBuffer;
				}
				
			}
			
			if (this.responseData.resultCode == "204" ||  this.responseData.resultCode == "304" || this.responseData.resultCode == "302"
				|| this.responseData.resultCode == "307"){
				this.responseData.rawDataInByteArray = this.responseBuffer;
				this.done();
			} else if (this.responseChunked){
				// TODO get body to resposneData
				if (this.isChunkedResponseDone(this.responseBuffer)){
					this.responseData.rawDataInByteArray = this.responseBuffer;
					this.done();
				}
			} else if (this.responseBuffer.length == this.responseContentLength){
				//TODO responseData.body
				//trace(this.responseData.body);
				
				// TODO  got the end and not found header(broken http response)
				this.responseData.rawDataInByteArray = this.responseBuffer;
			} else if(this.responseContentLength === 0){
				this.responseData.rawDataInByteArray = this.responseBuffer;
				this.done();
			}
			//trace("response data.."+this._indexId+" got header?"+(responseHeaderFound?"YES":this.responseBuffer.toString()));
		}
		
		
		private function isChunkedResponseDone(response:ByteArray):Boolean{
			response.position = 0;
			var headerTest:String = new String();
			while (response.position < response.length)
			{
				headerTest += response.readUTFBytes(1);
				if (headerTest.search(SEPERATOR) != -1)
				{
					break;
				}
			}
			
			var lenString:String = "0x";
			var len:Number = 0;
			var byte:String;
			while (response.position < response.length)
			{
				byte = response.readUTFBytes(1);
				if (byte == "\n")
				{
					len = parseInt(lenString);
					if (len == 0)
					{
						return true;
						break;
					}
					else
					{
						response.position += (len + 2);
						lenString = "0x";
						len = 0;
					}
				}
				else
				{
					lenString += byte;
				}
			}
			return false;
		}
		
		private function onResponseSocketClose(e:Event):void{
			trace('response close');
			this.done();
		}
		
		private function onRequestSocketClose(e:Event):void{
			trace('request close');
			this.done();
		}
		
		private function done():void{
			this.tearDown();
			completeEvent = new PipeEvent(PipeEvent.PIPE_COMPLETE,this._indexId,this.requestData,this.responseData);
			this.dispatchEvent(completeEvent);
		}
		
		private function testSocket(socket:Socket):Boolean{
			if (!socket.connected){
				//trace('not connect');
				this.done();
				return false;
			}
			return true;
		}
		
		public function tearDown():void{
			//trace('teardown..');
			_tearDowned = true;
			if (this.requestSocket != null){
				//trace('teardown..1');
				this.requestSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onRequestSocketData);
				this.requestSocket.removeEventListener(Event.CLOSE, onRequestSocketClose);
				if(this.requestSocket.connected){
					this.requestSocket.flush();
					this.requestSocket.close();
				}
			}
			
			if (this.responseSocket != null){
				//trace('teardown..2');
				this.responseSocket.removeEventListener(Event.CONNECT, onResponseSocketConnect);
				this.responseSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onResponseSocketData);
				this.responseSocket.removeEventListener(Event.CLOSE, onResponseSocketClose);
				this.responseSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onResponseSocketIOError);
				this.responseSocket.removeEventListener(IOErrorEvent.IO_ERROR, onResponseSocketIOError);
				if(this.responseSocket.connected){
					this.responseSocket.flush();
					this.responseSocket.close();
				}
			}
		}
	}
}
