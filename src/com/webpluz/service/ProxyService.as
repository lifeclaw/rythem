package com.webpluz.service{
	import com.webpluz.vo.RequestData;
	import com.webpluz.vo.ResponseData;
	
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
		private var _waitingSockets:Array;
		
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
			this._waitingSockets = new Array();
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
			for each(var s:Socket in this._waitingSockets){
				try{
					s.close();
				}catch(e:Error){
					trace("close waiting socket error");
				}
			}
			for each(var p:Pipe in this._pipes){
				p.tearDown();
			}
			if (this._serverSocket.listening){
				try{
					this._serverSocket.close();
				}catch (e:Error){
					//do nothing? 
					trace("close socket error...");
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
		
		private function generateConnecttion():void{
			while(true || this._pipes.length <2){//TODO 
				if(this._waitingSockets.length==0){
					break;
				}
				var pipe:Pipe=new Pipe((this._waitingSockets.shift() as Socket),_pipeCount++);
				//_pipeCount++;
				pipe.addEventListener(PipeEvent.PIPE_COMPLETE, this.onPipeComplete);
				pipe.addEventListener(PipeEvent.PIPE_ERROR, this.onPipeError);
				pipe.addEventListener(PipeEvent.PIPE_CONNECTED, this.onPipeConnected);
				this._pipes.push(pipe);
				trace("socket connections:"+this._pipes.length);
			}
			trace("generateConnection end"+this._pipes.length+"  "+this._waitingSockets.length);
		}
		private function onConnect(e:ServerSocketConnectEvent):void{
			//if(this._pipes.length >=10){
			this._waitingSockets.push(e.socket);
			//	return;
			//}
			this.generateConnecttion();
		}
		
		protected function onPipeError(event:PipeEvent):void{
			//trace("event="+event.type,event.pipeId);
			//this.dispatchEvent(event.clone());
			var pipeToRemove:Pipe=event.target as Pipe;
			this._pipes.splice(this._pipes.indexOf(pipeToRemove), 1);
			this.sendNotification(event.type,this.getPipeDataById(event.pipeId));
			this.generateConnecttion();
		}
		
		protected function onPipeConnected(event:PipeEvent):void{
			var e2:PipeEvent = (event.clone() as PipeEvent);
			if(this.storePipe(e2)){
				trace("remove pipe when CONNECT "+e2.pipeId);
				var pipeToRemove:Pipe=event.target as Pipe;
				trace("onPipeConnected before remove:"+this._pipes.length);
				this._pipes.splice(this._pipes.indexOf(pipeToRemove), 1);
				trace("onPipeConnected after remove:"+this._pipes.length);
				this.generateConnecttion();
			}
			//trace("event="+event.type,event.pipeId,event.requestData.server,event.requestData.path);
			//this.dispatchEvent(e2);
			this.sendNotification(event.type,this.getPipeDataById(event.pipeId));
		}
		
		private function onPipeComplete(event:PipeEvent):void{
			var e2:PipeEvent = (event.clone() as PipeEvent);
			if(this.storePipe(e2)){
				var pipeToRemove:Pipe=event.target as Pipe;
				trace("before remove:"+this._pipes.length);
				this._pipes.splice(this._pipes.indexOf(pipeToRemove), 1);
				trace("after remove:"+this._pipes.length);
				this.generateConnecttion();
			}
			//this.dispatchEvent(e2);
			this.sendNotification(event.type,this.getPipeDataById(event.pipeId));
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
			var o:Object = this._pipeDatas["-"+id];
			//trace("getting by id="+id+" "+(o?" exists":" NODATA"));
			return o;
		}
		private function storePipe(event:PipeEvent):Boolean{
			trace("====stroePipe:"+event.type+" ["+event.requestData+"] ["+event.responseData+"] "+" ["+event.pipeId+"] ");
			var pipeDataExists:Boolean = true;
			var pipe:Object = getPipeDataById(event.pipeId);
			if(!pipe){
				pipe = {};
				pipeDataExists = false;
			}
			var req:RequestData = event.requestData;
			var res:ResponseData = event.responseData;
			if(req && req.rawData){
				pipe.requestData = req;
				//req.update(event.requestData);
			}
			if(res && res.rawData){
				pipe.responseData = res;
				//res.update(event.responseData);
			}
			pipe['pipeId'] = event.pipeId;
			_pipeDatas["-"+event.pipeId] = pipe;
			trace("====stroePipe END:"+event.type+" ["+pipe.requestData+"] ["+pipe.responseData+"] "+" ["+pipe.pipeId+"] ");
			
			return pipeDataExists;
		}
		
	}
}
