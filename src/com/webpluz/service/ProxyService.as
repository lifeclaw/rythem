package com.webpluz.service{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.URLRequestHeader;
	import mx.collections.ArrayCollection;
	
	
	
	[Event(name="connect", type="flash.events.ServerSocketConnectEvent")]
	[Event(name="complete",type="flash.events.Event")]
	
	public class ProxyService extends EventDispatcher{
		private var _address:String="";
		private var _port:Number=0;
		private var _serverSocket:ServerSocket;
		private var _pipes:Array;
		
		public function ProxyService(bindAddress:String="",bindPort:Number=0){
			super();
			this.setupIpAndPort(bindAddress,bindPort);
			this._serverSocket = new ServerSocket();
			this._pipes = new Array();
			this._serverSocket.addEventListener(Event.CONNECT,this.onConnect);
		}
		public function listen(bindIp:String="",bindPort:Number=0):Boolean{
			this.setupIpAndPort(bindIp,bindPort);
			if(this._address=="" || this._port ==0){
				throw new Error("fail to listen ip="+this._address+" and port="+this._port);
				return;
			}
			if(this._serverSocket.listening){
				try{
					this._serverSocket.close();
				}catch(e:Error){
					//do nothing? 
				}
			}
			this._serverSocket.bind(this._port,this._address);
			try{
				this._serverSocket.listen();
			}catch(e:Error){
				return false;
			}
			return true;
		}
		public function close():void{
			if(this._serverSocket.listening){
				try{
					this._serverSocket.close();
				}catch(e:Error){
					//do nothing? 
				}
			}			
		}
		public function setupIpAndPort(address:String="",port:Number=0):void{
			if(address!=""){
				this._address = address;
			}
			if(port!=0){
				this._port = port;
			}
		}
		
		private function onConnect(e:ServerSocketConnectEvent):void{
			var pipe:Pipe = new Pipe(e.socket);
			pipe.addEventListener(Event.COMPLETE,this.onPipeComplete);
			pipe.addEventListener(HTTPHeadersEvent.HTTP_HEADERS_EVENT,this.onIncomingHeaders);
			this._pipes.push(pipe);
			this.dispatchEvent( (new ProxyServiceEvent(ProxyServiceEvent.PROXYSERVICEEVENT_CONNECTED,pipe)));
		}
		private function onIncomingHeaders(e:HTTPHeadersEvent):void{
			/*
			this.output.text += (e.requestSignature + "\n");
			this.outputHeaders(e.requestHeaders);
			this.output.text += "\n";
			this.output.text += (e.responseSignature + "\n");
			this.outputHeaders(e.responseHeaders);
			this.output.text += HR;
			*/
		}
		
		private function outputHeaders(headers:Array):void{
			for each (var header:URLRequestHeader in headers)
			{
				if (header.value == null || header.value.length == 0) continue;
				//this.output.text += (header.name + ": " + header.value + "\n");
			}
		}
		
		private function onPipeComplete(e:Event):void{
			var pipeToRemove:Pipe = e.target as Pipe;
			this._pipes.splice(this._pipes.indexOf(pipeToRemove), 1);
			this.dispatchEvent( (new ProxyServiceEvent(ProxyServiceEvent.PROXYSERVICEEVENT_COMPLETE,pipeToRemove)));
		}
	}
}
