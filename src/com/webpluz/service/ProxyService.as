package com.webpluz.service{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.SecureSocket;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.net.URLRequestHeader;
	
	import mx.collections.ArrayCollection;


	
	[Event(name="PIPE_CONNECTED", type="com.webpluz.service.PipeEvent")]
	[Event(name="PIPE_COMPLETE", type="com.webpluz.service.PipeEvent")]
	[Event(name="PIPE_ERROR", type="com.webpluz.service.PipeEvent")]

	public class ProxyService extends EventDispatcher{
		private var _address:String="";
		private var _port:Number=0;
		private var _serverSocket:ServerSocket;
		private var _pipes:Array;
		private var _pipeCount:int;
		protected static var _instance:ProxyService=null;
		public function ProxyService(bindAddress:String="", bindPort:Number=0){
			super();
			if(_instance){
				throw new Error("cannot contruct ProxyService twice!");
			}
			this.setupIpAndPort(bindAddress, bindPort);
			this._serverSocket=new ServerSocket();
			this._pipes=new Array();
			this._serverSocket.addEventListener(Event.CONNECT, this.onConnect);
			_pipeCount = 0;
		}
		public static function getInstance(bindAddress:String="", bindPort:Number=0):ProxyService{
			if(!_instance){
				_instance = new ProxyService(bindAddress,bindPort);
			}
			return _instance;
		}
		
		public function listen(bindIp:String="", bindPort:Number=0):Boolean{
			this.setupIpAndPort(bindIp, bindPort);
			if (this._address == "" || this._port == 0){
				throw new Error("fail to listen ip=" + this._address + " and port=" + this._port);
				return;
			}
			if (this._serverSocket.listening){
				try{
					this._serverSocket.close();
				}catch (e:Error){
					//do nothing? 
				}
			}
			this._serverSocket.bind(this._port, this._address);
			try{
				this._serverSocket.listen();
			}catch (e:Error){
				return false;
			}
			return true;
		}

		public function close():void{
			if (this._serverSocket.listening){
				try{
					this._serverSocket.close();
				}catch (e:Error){
					//do nothing? 
				}
			}
		}

		public function setupIpAndPort(address:String="", port:Number=0):void{
			if (address != ""){
				this._address=address;
			}
			if (port != 0){
				this._port=port;
			}
		}

		private function onConnect(e:ServerSocketConnectEvent):void{
			var pipe:Pipe=new Pipe(e.socket,_pipeCount);
			_pipeCount++;
			pipe.addEventListener(PipeEvent.PIPE_COMPLETE, this.onPipeComplete);
			pipe.addEventListener(PipeEvent.PIPE_ERROR, this.onPipeError);
			pipe.addEventListener(PipeEvent.PIPE_CONNECTED, this.onPipeConnected);
			this._pipes.push(pipe);
		}
		
		protected function onPipeError(event:PipeEvent):void{
			this.dispatchEvent(event);
		}
		
		protected function onPipeConnected(event:PipeEvent):void{
			this.dispatchEvent(event);
		}
		
		private function onPipeComplete(event:PipeEvent):void{
			var pipeToRemove:Pipe=event.target as Pipe;
			this._pipes.splice(this._pipes.indexOf(pipeToRemove), 1);
			this.dispatchEvent(event);
		}
	}
}
