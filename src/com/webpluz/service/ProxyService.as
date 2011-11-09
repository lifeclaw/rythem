package com.webpluz.service{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.SecureSocket;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.net.URLRequestHeader;
	import flash.text.ReturnKeyLabel;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.INotifier;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.observer.Notifier;


	
	[Event(name="PIPE_CONNECTED", type="com.webpluz.service.PipeEvent")]
	[Event(name="PIPE_COMPLETE", type="com.webpluz.service.PipeEvent")]
	[Event(name="PIPE_ERROR", type="com.webpluz.service.PipeEvent")]

	public class ProxyService extends Notifier implements IProxy {
		private var _address:String="";
		private var _port:Number=0;
		private var _serverSocket:ServerSocket;
		private var _pipes:Array;
		private var _pipeCount:int;
		
		//TODO move this to a model?
		private var _pipeDatas:Dictionary;
		
		protected static var _instance:ProxyService=null;
		public static const NAME:String = "PROXYSERVICE";
		
		public static const BINDFAIL:String = "ProxyService.BINDFAIL";
		public function ProxyService(bindAddress:String="", bindPort:Number=0){
			super();
			if(_instance){
				throw new Error("cannot contruct ProxyService twice!");
			}
			this.setupIpAndPort(bindAddress, bindPort);
			this._serverSocket=new ServerSocket();
			this._pipes=new Array();
			_pipeDatas = new Dictionary();
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
				return false;
			}
			if (this._serverSocket.listening){
				try{
					this._serverSocket.close();
				}catch (e:Error){
					//do nothing? 
					this.sendNotification(BINDFAIL);
				}
			}
			try{
				this._serverSocket.bind(this._port, this._address);
				this._serverSocket.listen();
			}catch (e:Error){
				this.sendNotification(BINDFAIL);
				trace(e.toString());
				return false;
			}
			trace("listened to "+this._address+":"+this._port);
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
			var pipe:Pipe=new Pipe(e.socket,_pipeCount++);
			//_pipeCount++;
			pipe.addEventListener(PipeEvent.PIPE_COMPLETE, this.onPipeComplete);
			pipe.addEventListener(PipeEvent.PIPE_ERROR, this.onPipeError);
			pipe.addEventListener(PipeEvent.PIPE_CONNECTED, this.onPipeConnected);
			this._pipes.push(pipe);
		}
		
		protected function onPipeError(event:PipeEvent):void{
			//trace("event="+event.type,event.pipeId);
			this.dispatchEvent(event.clone());
		}
		
		protected function onPipeConnected(event:PipeEvent):void{
			var e2:PipeEvent = (event.clone() as PipeEvent);
			this.storePipe(e2);
			//trace("event="+event.type,event.pipeId,event.requestData.server,event.requestData.path);
			this.dispatchEvent(e2);
		}
		
		private function onPipeComplete(event:PipeEvent):void{
			var e2:PipeEvent = (event.clone() as PipeEvent);
			this.storePipe(e2);
			var pipeToRemove:Pipe=event.target as Pipe;
			if(event.responseData){
				//trace("event="+event.type,event.pipeId,event.requestData.server,event.requestData.path);
				if(event.responseData){
					//trace(event.responseData.serverIp+" "+event.responseData.resultCode);
				}
				//trace("complete:\n"+event.responseData.body);
			}else{
				//trace("complete: without response");
			}
			this._pipes.splice(this._pipes.indexOf(pipeToRemove), 1);
			this.dispatchEvent(e2);
		}
		
		
		// define a dispatchEvent for pureMVC
		public function dispatchEvent(e:Event):void{
			var event:PipeEvent = e as PipeEvent;
			//trace("event="+event.type,event.pipeId);
			this.sendNotification(event.type,event);
		}
		
		// IProxy
		/**
		 * Get the Proxy name
		 * 
		 * @return the Proxy instance name
		 */
		public function getProxyName():String{
			return NAME;
		}
		
		/**
		 * Set the data object
		 * 
		 * @param data the data object
		 */
		public function setData( data:Object ):void{
			
		}
		
		/**
		 * Get the data object
		 * 
		 * @return the data as type Object
		 */
		public function getData():Object{
			return {};
		}
		
		/**
		 * Called by the Model when the Proxy is registered
		 */ 
		public function onRegister( ):void{
			
		}
		
		/**
		 * Called by the Model when the Proxy is removed
		 */ 
		public function onRemove( ):void{
			
		}
		
		public function getPipeDataById(id:Number):Object{
			return this._pipeDatas[""+id];
		}
		private function storePipe(event:PipeEvent):void{
			trace("====stroePipe:["+event.requestData+"] ["+event.responseData+"] "+" ["+event.pipeId+"] ");
			var pipe:Object = _pipeDatas[""+event.pipeId] || {};
			if(event.requestData){
				pipe.requestData = event.requestData;
			}
			if(event.responseData){
				pipe.responseData = event.responseData;
			}
			_pipeDatas[""+event.pipeId] = pipe;
		}
		
	}
}
