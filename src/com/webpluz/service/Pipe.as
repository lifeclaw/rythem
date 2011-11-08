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

		
		private var requestData:RequestData;
		private var responseData:ResponseData;
		/*
		public var responseResult:String;
		public var responseHeaderString:String;
		public var responseBody:String;
		*/
		private var _ruleManager:RuleManager;

		private static const SEPERATOR:RegExp=new RegExp(/\r?\n\r?\n/);
		private static const NL:RegExp=new RegExp(/\r?\n/);

		
		private var _indexId:Number;
		public function Pipe(socket:Socket,indexId:Number=0){
			
			_ruleManager = RuleManager.getInstance();
			_indexId = indexId;
			this.requestSocket=socket;
			
			this.requestBuffer=new ByteArray();
			this.responseBuffer=new ByteArray();
			this.requestHeaderFound=false;
			this.responseHeaderFound=false;
			this.responseContentLength=0;
			this.responseChunked=false;
			
			this.requestSocket.addEventListener(ProgressEvent.SOCKET_DATA, onRequestSocketData);
			this.requestSocket.addEventListener(Event.CLOSE, onRequestSocketClose);
		}
		private function onRequestSocketData(e:ProgressEvent):void{
			this.requestSocket.readBytes(this.requestBuffer, this.requestBuffer.length, this.requestSocket.bytesAvailable);
			if (!this.requestHeaderFound){
				// Make a string version and check if we've received all the headers yet.
				var bufferString:String=this.requestBuffer.toString();
				trace("bufferString=\n" + bufferString);
				var headerCheck:Number=bufferString.search(SEPERATOR);
				if (headerCheck != -1){
					this.requestHeaderFound=true;
					var headerString:String=bufferString.substring(0, headerCheck);
					var headerBodyDivision:Number=headerString.length + 4;
					requestData = new RequestData(headerString);
					requestData.body = bufferString.substr(headerBodyDivision);
					
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
					// Replace the header in the buffer with our new and improved header.
					var newRequestBuffer:ByteArray=new ByteArray();
					newRequestBuffer.writeUTFBytes(headerString);
					newRequestBuffer.writeUTFBytes("\r\n\r\n");
					newRequestBuffer.writeBytes(this.requestBuffer, headerBodyDivision);
					this.requestBuffer=newRequestBuffer;


					this.responseSocket=new Socket();
					//var k:SecureSocket =  new SecureSocket();

					this.responseSocket.addEventListener(Event.CONNECT, onResponseSocketConnect);
					this.responseSocket.addEventListener(ProgressEvent.SOCKET_DATA, onResponseSocketData);
					this.responseSocket.addEventListener(Event.CLOSE, onResponseSocketClose);
					this.responseSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onResponseSocketIOError);
					this.responseSocket.addEventListener(IOErrorEvent.IO_ERROR, onResponseSocketIOError);
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
				}
			}else{
				if (this.responseSocket.connected){
					requestData.body += this.requestBuffer.toString();
					this.responseSocket.writeBytes(this.requestBuffer);
					this.responseSocket.flush();
					this.requestBuffer.clear();
				}
			}
		}

		private function onResponseSocketIOError(e:IOErrorEvent):void{
			trace("responseSocketIOError:"+e.errorID, e.type, e.text);
			var pipeEvent:PipeEvent = new PipeEvent(PipeEvent.PIPE_CONNECTED,this._indexId);
			this.dispatchEvent(pipeEvent);
			this.tearDown();
		}

		private function onResponseSocketConnect(e:Event):void{
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
			if (!this.responseHeaderFound){
				// Make a string version and check if we've received all the headers yet.
				var bufferString:String=this.responseBuffer.toString();
				var headerCheck:Number=bufferString.search(SEPERATOR);
				if (headerCheck != -1){
					this.responseHeaderFound=true;
					var headerString:String=bufferString.substring(0, headerCheck);
					this.responseData = new ResponseData(headerString);
					if(this.responseData.headersObject['transfer-encoding'] && 
						this.responseData.headersObject['transfer-encoding'].toString().toLowerCase() == "chunked"){
						this.responseChunked=true;
					}
					if(this.responseData.headersObject.hasOwnProperty('content-length')){
						this.responseContentLength=Number(this.responseData.headersObject['content-length']) + headerString.length + 4;
					}
					this.responseData.body = bufferString.substr(headerString.length+4);
					//this.responseBuffer.clear();
					//TODO need dispath event when got response header?
					//this.dispatchEvent(this.headerEvent);
				}
			}

			if (this.responseData && (this.responseData.resultCode == "204" ||  this.responseData.resultCode == "304")){
				this.done();
			} else if (this.responseChunked){
				if (this.isChunkedResponseDone(this.responseBuffer)){
					this.done();
				}
			} else if (this.responseBuffer.length == this.responseContentLength){
				
				this.done();
			}
		}

		private function isChunkedResponseDone(response:ByteArray):Boolean{
			response.position=0;
			var headerTest:String=new String();
			while (response.position < response.length){
				headerTest+=response.readUTFBytes(1);
				if (headerTest.search(SEPERATOR) != -1){
					break;
				}
			}

			var lenString:String="0x";
			var len:Number=0;
			var byte:String;
			while (response.position < response.length){
				byte=response.readUTFBytes(1);
				if (byte == "\n"){
					len=parseInt(lenString);
					if (len == 0){
						return true;
						break;
					}else{
						//TODO 如果buffer不以段为结束，此处会出错..
						this.responseData.body+=response.readUTFBytes(len);
						response.position+=(len + 2);
						lenString="0x";
						len=0;
					}
				}
				else{
					lenString+=byte;
				}
			}
			return false;
		}

		private function onResponseSocketClose(e:Event):void{
			this.done();
		}

		private function onRequestSocketClose(e:Event):void{
			this.done();
		}

		private function done():void{
			this.tearDown();
			var completEvent:PipeEvent = new PipeEvent(PipeEvent.PIPE_COMPLETE,this._indexId,this.requestData,this.responseData);
			this.dispatchEvent(completEvent);
		}

		private function testSocket(socket:Socket):Boolean{
			if (!socket.connected){
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
