// from http://httpeek.googlecode.com/
package com.webpluz.service
{
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

	[Event(name="complete", type="flash.events.Event")]
	[Event(name="httpHeadersEvent", type="com.adobe.httscout.HTTPHeadersEvent")]

	public class Pipe extends EventDispatcher
	{
		private var requestSocket:Socket;
		private var responseSocket:Socket;
		private var requestBuffer:ByteArray;
		private var responseBuffer:ByteArray;
		private var requestHeaderFound:Boolean;
		private var responseHeaderFound:Boolean;
		private var responseContentLength:Number;
		private var headerEvent:HTTPHeadersEvent;
		private var responseChunked:Boolean;
		public var requestSignature:String;

		public var server:String;

		private static const SEPERATOR:RegExp=new RegExp(/\r?\n\r?\n/);
		private static const NL:RegExp=new RegExp(/\r?\n/);

		public function Pipe(socket:Socket)
		{
			this.requestSocket=socket;
			this.requestBuffer=new ByteArray();
			this.responseBuffer=new ByteArray();
			this.requestHeaderFound=false;
			this.responseHeaderFound=false;
			this.responseContentLength=0;
			this.responseChunked=false;
			this.headerEvent=new HTTPHeadersEvent();
			this.requestSocket.addEventListener(ProgressEvent.SOCKET_DATA, onRequestSocketData);
			this.requestSocket.addEventListener(Event.CLOSE, onRequestSocketClose);
		}

		private function onRequestSocketData(e:ProgressEvent):void
		{
			this.requestSocket.readBytes(this.requestBuffer, this.requestBuffer.length, this.requestSocket.bytesAvailable);
			if (!this.requestHeaderFound)
			{
				// Make a string version and check if we've received all the headers yet.
				var bufferString:String=this.requestBuffer.toString();
				trace("bufferString=\n" + bufferString);
				var headerCheck:Number=bufferString.search(SEPERATOR);
				if (headerCheck != -1)
				{
					this.requestHeaderFound=true;
					var headerString:String=bufferString.substring(0, headerCheck);
					var headerBodyDivision:Number=headerString.length + 4;


					//trace("old request header"+headerString);

					// Remove anything we don't need from the headers.
					headerString=headerString.replace(/proxy\-connection.*?\r\n/i, "");
					//headerString = headerString.replace(/keep\-alive.*?\r\n/i, "");
					//headerString = headerString.replace(/accept\-encoding.*?\r\n/i, "");

					// Parse the request signature.
					var initialRequestSignature:String=headerString.substring(0, headerString.search(NL));
					var initialRequestSignatureComponents:Array=initialRequestSignature.split(" ");
					var method:String=initialRequestSignatureComponents[0];
					var serverAndPath:String=initialRequestSignatureComponents[1];
					var httpVersion:String=initialRequestSignatureComponents[2];
					var port:Number=80;
					serverAndPath=serverAndPath.replace(/^http(s)?:\/\//, "");

					// fix problem when:CONNECT github.com:443 HTTP/1.0
					var indexOfPath:int=serverAndPath.indexOf("/");
					if (indexOfPath == -1)
					{
						indexOfPath=serverAndPath.length;
					}
					var server:String=serverAndPath.substring(0, indexOfPath);
					if (server.indexOf(":") != -1)
					{
						port=Number(server.substring(server.indexOf(":") + 1, indexOfPath));
						server=server.substring(0, server.indexOf(":"));
					}
					var path:String=serverAndPath.substring(serverAndPath.indexOf("/"), serverAndPath.length);
					var newHeaderSignature:String=method + " " + path + " " + httpVersion + "\r\n";

					// Replace the old request signature with the new one.
					headerString=headerString.replace(/^.*?\r\n/, newHeaderSignature);
					//trace("new header string:\r\n"+headerString+"\r\nendof new header");

					// Replace the header in the buffer with our new and improved header.
					var newRequestBuffer:ByteArray=new ByteArray();
					newRequestBuffer.writeUTFBytes(headerString);
					newRequestBuffer.writeUTFBytes("\r\n\r\n");

					newRequestBuffer.writeBytes(this.requestBuffer, headerBodyDivision);

					this.requestBuffer=newRequestBuffer;

					// Parse the headers up to put in an array.
					var headerArray:Array=headerString.split(NL);
					var reqSig:String=headerArray.shift();
					this.headerEvent.requestSignature=("REQUEST: " + reqSig);
					this.requestSignature=reqSig;
					this.headerEvent.requestHeaders=new Array();
					for each (var line:String in headerArray)
					{
						var name:String=line.substring(0, line.indexOf(":"));
						var value:String=line.substring(line.indexOf(":") + 2, line.length);
						var header:URLRequestHeader=new URLRequestHeader(name, value);
						this.headerEvent.requestHeaders.push(header);
							//trace(line);
					}


					trace(method + " " + server + ":" + port);
					// Create the response socket.

					this.server=server;

					this.responseSocket=new Socket();
					//var k:SecureSocket =  new SecureSocket();

					this.responseSocket.addEventListener(Event.CONNECT, onResponseSocketConnect);
					this.responseSocket.addEventListener(ProgressEvent.SOCKET_DATA, onResponseSocketData);
					this.responseSocket.addEventListener(Event.CLOSE, onResponseSocketClose);
					this.responseSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onResponseSocketIOError);
					this.responseSocket.addEventListener(IOErrorEvent.IO_ERROR, onResponseSocketIOError);
					this.responseSocket.connect(server, port);
					this.server=server;
					if (method == "CONNECT")
					{ //HTTP/1.1 200 Connection established\r\nConnection: keep-alive\r\n\r\n
						//HTTP/1.1 200 Connection established
						trace("secureSocket---------------");

						var responseBuffer:ByteArray=new ByteArray();
						responseBuffer.writeUTFBytes("HTTP/1.1 200 Connection established\r\n\r\n");
						this.requestSocket.writeBytes(responseBuffer);
						this.requestSocket.flush();
					}
				}
				else
				{
					trace('...');
				}
			}
			else
			{
				if (!this.responseSocket)
				{
					this.responseSocket=new SecureSocket();
					this.responseSocket.addEventListener(Event.CONNECT, onResponseSocketConnect);
					this.responseSocket.addEventListener(ProgressEvent.SOCKET_DATA, onResponseSocketData);
					this.responseSocket.addEventListener(Event.CLOSE, onResponseSocketClose);
					this.responseSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onResponseSocketIOError);
					this.responseSocket.addEventListener(IOErrorEvent.IO_ERROR, onResponseSocketIOError);
					this.responseSocket.connect(this.server, 443);
				}
				else if (this.responseSocket.connected)
				{
					trace('has header and connected');
					this.responseSocket.writeBytes(this.requestBuffer);
					this.responseSocket.flush();
					this.requestBuffer.clear();
				}
				else
				{
					trace("is https?:" + bufferString);
					this.responseSocket.writeBytes(this.requestBuffer);
					this.responseSocket.flush();
					this.requestBuffer.clear();
				}
			}
		}

		private function onResponseSocketIOError(e:IOErrorEvent):void
		{
			trace(e.errorID, e.type, e.text);
		}

		private function onResponseSocketConnect(e:Event):void
		{
			this.responseSocket.writeBytes(this.requestBuffer);
			this.responseSocket.flush();
			this.headerEvent.remoteAddress=this.responseSocket.remoteAddress;
			trace("response connected:" + this.headerEvent.remoteAddress);
			//var _headerEvent:HTTPHeadersEvent = new HTTPHeadersEvent();
			//this.dispatchEvent(_headerEvent);
		}

		private function onResponseSocketData(e:ProgressEvent):void
		{
			if (!this.testSocket(this.requestSocket))
				return;
			var position:Number=this.responseBuffer.length;
			this.responseSocket.readBytes(this.responseBuffer, position, this.responseSocket.bytesAvailable);
			this.requestSocket.writeBytes(this.responseBuffer, position);
			this.requestSocket.flush();
			if (!this.responseHeaderFound)
			{
				// Make a string version and check if we've received all the headers yet.
				var bufferString:String=this.responseBuffer.toString();
				var headerCheck:Number=bufferString.search(SEPERATOR);
				if (headerCheck != -1)
				{
					this.responseHeaderFound=true;
					var headerString:String=bufferString.substring(0, headerCheck);
					var headerArray:Array=headerString.split(NL);
					var responseSignature:String=headerArray.shift();
					this.headerEvent.responseSignature="RESPONSE: " + responseSignature;
					this.headerEvent.responseHeaders=new Array();
					var dns:DNSResolver=new DNSResolver();
					for each (var line:String in headerArray)
					{
						var name:String=line.substring(0, line.indexOf(":"));
						var value:String=line.substring(line.indexOf(":") + 2, line.length);
						var header:URLRequestHeader=new URLRequestHeader(name, value);
						this.headerEvent.responseHeaders.push(header);
						if (name.toLowerCase() == "content-length")
						{
							this.responseContentLength=(Number(value) + headerString.length + 4);
						}
						else if (name.toLocaleLowerCase() == "transfer-encoding" && value.toLocaleLowerCase() == "chunked")
						{
							this.responseChunked=true;
						}
					}
					this.dispatchEvent(this.headerEvent);
				}
			}

			if (this.headerEvent.responseSignature != null && (this.headerEvent.responseSignature.search(/204 No Content/i) != -1 || this.headerEvent.responseSignature.search(/304 Not Modified/i) != -1))
			{
				this.done();
			}
			else if (this.responseChunked)
			{
				if (this.isChunkedResponseDone(this.responseBuffer))
				{
					this.done();
				}
			}
			else if (this.responseBuffer.length == this.responseContentLength)
			{
				this.done();
			}
		}

		private function isChunkedResponseDone(response:ByteArray):Boolean
		{
			response.position=0;
			var headerTest:String=new String();
			while (response.position < response.length)
			{
				headerTest+=response.readUTFBytes(1);
				if (headerTest.search(SEPERATOR) != -1)
				{
					break;
				}
			}

			var lenString:String="0x";
			var len:Number=0;
			var byte:String;
			while (response.position < response.length)
			{
				byte=response.readUTFBytes(1);
				if (byte == "\n")
				{
					len=parseInt(lenString);
					if (len == 0)
					{
						return true;
						break;
					}
					else
					{
						response.position+=(len + 2);
						lenString="0x";
						len=0;
					}
				}
				else
				{
					lenString+=byte;
				}
			}
			return false;
		}

		private function onResponseSocketClose(e:Event):void
		{
			this.done();
		}

		private function onRequestSocketClose(e:Event):void
		{
			this.done();
		}

		private function done():void
		{
			this.tearDown();
			var completeEvent:Event=new Event(Event.COMPLETE);
			this.dispatchEvent(completeEvent);
		}

		private function testSocket(socket:Socket):Boolean
		{
			if (!socket.connected)
			{
				this.done();
				return false;
			}
			return true;
		}

		public function tearDown():void
		{
			if (this.requestSocket != null && this.requestSocket.connected)
			{
				this.requestSocket.flush();
				this.requestSocket.close();
			}

			if (this.responseSocket != null && this.responseSocket.connected)
			{
				this.responseSocket.flush();
				this.responseSocket.close();
			}
		}
	}
}
