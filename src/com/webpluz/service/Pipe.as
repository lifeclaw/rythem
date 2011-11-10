// from http://httpeek.googlecode.com/
package com.webpluz.service{
	import com.webpluz.vo.RequestData;
	import com.webpluz.vo.ResponseData;
	
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
		private var responseChunkLastLen:Number=0;
		private var responseChunkLastRead:Number=0;
		private var responseBodyBuffer:ByteArray;

		
		private var requestData:RequestData;
		private var responseData:ResponseData;
		
		private var completeEvent:PipeEvent;
		private var connectEvent:PipeEvent;
		private var errorEvent:PipeEvent;
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
		public function Pipe(socket:Socket,indexId:Number=0){
			
			
			_ruleManager = RuleManager.getInstance();
			_indexId = id++;
			this.requestSocket=socket;
			
			this.requestBuffer=new ByteArray();
			this.responseBuffer=new ByteArray();
			this.responseBodyBuffer = new ByteArray();
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
					requestData = new RequestData(headerString);
					requestData.body = bufferString.substr(headerBodyDivision);
					
					headerString = headerString.replace(/proxy\-connection.*?\r\n/i,"");
					
					var matchedRule:Rule = _ruleManager.getRule(requestData.headersObject);
					if(matchedRule){
						var ruleType:String = matchedRule.getType();
						if(ruleType!=Rule.RULE_TYPE_REPLACE_IP){
							switch(ruleType){
								case Rule.RULE_TYPE_COMBINE:
									break;
								case Rule.RULE_TYPE_DICTORY:
									break;
								case Rule.RULE_TYPE_REPLACE_SINGLE_CONTENT:
									break;
								default:
									throw new Error("cannot handle this rule!");
									break;
							}
						}else{
							requestData.server = (matchedRule as IpReplaceRule).getIpToChange();
						}
					}
					var newHeaderSignature:String = this.requestData.method + " " + this.requestData.path + " " + this.requestData.httpVersion + "\r\n";
					
					// Replace the old request signature with the new one.
					headerString = headerString.replace(/^.*?\r\n/, newHeaderSignature);
					var newRequestBuffer:ByteArray=new ByteArray();
					newRequestBuffer.writeUTFBytes(headerString);
					newRequestBuffer.writeUTFBytes("\r\n\r\n");
					newRequestBuffer.writeBytes(this.requestBuffer, headerBodyDivision);
					trace(newRequestBuffer.toString());
					this.requestBuffer=newRequestBuffer;
					if(this.requestData.port == 443){//
						this.done();
					}

					this.responseSocket=new ProxySocket("proxy.tencent.com",8080);
					//this.responseSocket=new Socket();
					//var k:SecureSocket =  new SecureSocket();

					this.responseSocket.addEventListener(Event.CONNECT, onResponseSocketConnect);
					//this.responseSocket.addEventListener(ProxySocketEvent.CONNECTED, onResponseSocketConnect);
					this.responseSocket.addEventListener(ProgressEvent.SOCKET_DATA, onResponseSocketData);
					//this.responseSocket.addEventListener(ProxySocketEvent.SOCKET_DATA, onResponseSocketData);
					this.responseSocket.addEventListener(Event.CLOSE, onResponseSocketClose);
					this.responseSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onResponseSocketIOError);
					this.responseSocket.addEventListener(IOErrorEvent.IO_ERROR, onResponseSocketIOError);
					//this.responseSocket.addEventListener(ProxySocketEvent.ERROR, onResponseSocketIOError);
					//trace("connecting:",requestData.server, requestData.port);
					this.responseSocket.connect(requestData.server, requestData.port);
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
					var pipeEvent:PipeEvent = new PipeEvent(PipeEvent.PIPE_CONNECTED,this._indexId,this.requestData);
					this.dispatchEvent(pipeEvent);
					trace("header "+this._indexId+"  \n"+this.requestBuffer.toString());
				}else{
					trace("no header "+this._indexId);
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
			if (!this.testSocket(this.requestSocket))
				return;
			var position:Number=this.responseBuffer.length;
			this.responseSocket.readBytes(this.responseBuffer, position, this.responseSocket.bytesAvailable);
			this.requestSocket.writeBytes(this.responseBuffer, position);
			this.requestSocket.flush();
			this.responseData.rawData = this.responseBuffer.toString();
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
					
					this.responseBuffer.position = headerCheck + 4;//TODO error when server return "\n\n" as body's seperator
				}
			}

			if (this.responseData.resultCode == "204" ||  this.responseData.resultCode == "304" || this.responseData.resultCode == "302"
				|| this.responseData.resultCode == "307"){
				this.done();
			} else if (this.responseChunked){
				// TODO get body to resposneData
				if (this.readChunckedData(this.responseBuffer)){
					//trace(this.responseData.body);
					this.responseData.body = this.responseBodyBuffer.toString();
					this.done();
				}
			} else if (this.responseBuffer.length == this.responseContentLength){
				// TODO get body to resposneData
				this.responseData.body+=this.responseBuffer.toString();
				//trace(this.responseData.body);
				this.done();
			} else if(this.responseContentLength === 0){
				this.done();
			}
			trace("response data.."+this._indexId+" got header?"+(responseHeaderFound?"YES":this.responseBuffer.toString()));
		}

		private function readChunckedData(response:ByteArray):Boolean{
			response.position=0;
			
			// bug:when buffer has not complete
			var headerTest:String=new String();
			var bodyPosition:int = 0;
			var m:int=0;
			while (response.position < response.length){
				m++;
				if(m>200){
					trace("1 too long:m="+m);
				}
				headerTest+=response.readUTFBytes(1);
				bodyPosition = headerTest.search(SEPERATOR)
				if (bodyPosition != -1){
					bodyPosition += 4
					break;
				}
			}
			responseBodyBuffer.clear();
			response.readBytes(responseBodyBuffer,response.position);
			//trace(responseBodyBuffer.toString());
			
			response.position = bodyPosition;
			//trace("++++++++++bodyPosition:"+bodyPosition);
			
			var lenString:String="0x";
			var len:Number=0;
			var byte:String;
			/*
			 * chunked data example:
			 * \r\nF\r\nthis is content\r\n5\r\nhello\r\n0\r\n\r\n
			 *
			 */
			var n:int=0;
			//trace('======response.length='+response.length+" response.position="+response.position+" response.bytesAvailable="+response.bytesAvailable); 
			while (response.position < response.length){
				n++;
				if(n>200){
					trace("tooooooooooooo long..");
					//trace('response.length='+response.length+" response.position="+response.position+" response.bytesAvailable="+response.bytesAvailable);
				}
				byte=response.readUTFBytes(1);
				if (byte == "\n"){
					len=parseInt(lenString);
					if (len == 0){
						return true;
						break;
					}else{
						response.position+=(len + 2);// TODO:这里不需要判断是\r\n还是\n?
						lenString="0x";
						len=0;
						//trace("body=",responseBodyBuffer.uncompress("gzip"));
					}
				}else{
					lenString+=byte;
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
				trace('not connect');
				this.done();
				return false;
			}
			return true;
		}

		public function tearDown():void{
			if (this.requestSocket != null && this.requestSocket.connected){
				this.requestSocket.flush();
				this.requestSocket.close();
			}

			if (this.responseSocket != null && this.responseSocket.connected){
				this.responseSocket.flush();
				this.responseSocket.close();
			}
		}
	}
}
