package com.webpluz.view{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.HTML;
	import com.webpluz.service.*;
	import com.webpluz.vo.*;
	
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.puremvc.as3.interfaces.INotification;
	
	public class WebUIMediator extends Mediator{
		public static const NAME:String = 'mediator.app.WebUIMediator';
		private var webkit:HTML;
		public function WebUIMediator(mediatorName:String, viewComponent:Object){
			super(mediatorName, viewComponent);
			this.webkit = viewComponent as HTML;
			this.initWebkit();
		}
		
		
		private function initWebkit():void{
			
			this.webkit.htmlLoader.window.notify = this.notifyFromWeb;
			
			// add api to webkit
			var tmp:File = File.applicationDirectory.resolvePath("configurations/container.html");
			var fileStream:FileStream = new FileStream();
			fileStream.open(tmp,FileMode.READ);
			var s:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
			fileStream.close();
			this.webkit.htmlLoader.loadString(s);
		}
		
		private function notifyFromWeb(msgType:String,params:Object=null):void{
			trace("web done..:"+msgType);
			var s:String = this.sendToWeb("hello","com from client") as String;
			trace(s);
		}
		private function sendToWeb(msgType:String,params:Object=null):Object{
			return webkit.htmlLoader.window.handleMessageFromClient(msgType,params);
		}
		override public function listNotificationInterests():Array{
			var a:Array = [PipeEvent.PIPE_COMPLETE,PipeEvent.PIPE_CONNECTED,PipeEvent.PIPE_ERROR];
			return a;
		}
		override public function handleNotification( notification:INotification ):void{
			//return;
			var t:String = notification.getName();
			//			var orientEvent:PipeEvent = notification.getBody() as PipeEvent;
			//			var reqData:RequestData = orientEvent.requestData;
			//			var resData:ResponseData = orientEvent.responseData;
			//			var dataIndex:Number = orientEvent.pipeId;
			var pipeData:Object = notification.getBody();			
			var reqData:RequestData = pipeData.requestData;
			var resData:ResponseData = pipeData.responseData;
			var dataIndex:Number = pipeData.pipeId;
			var item:Object;
			
			switch(t){
				case PipeEvent.PIPE_CONNECTED:
					item={
						"pipeId":pipeData.pipeId,
						"protocol":reqData.httpVersion,
						"host":reqData.server,
						"path":reqData.path						
					};
					this.sendToWeb('addPipeListItem',item);
					break;
				case PipeEvent.PIPE_COMPLETE:
					/*
					//trace("PIPE_COMPLETE:"+dataIndex);
					item = viewDataIndexMapping[dataIndex];
					//var item:Object = pipeList.getItemAt(indexId);
					if(!item || !resData)break;
					var resultCode:String = resData?resData.resultCode:"404";
					var serverIp:String = resData?resData.serverIp:"";
					item['result']=resultCode;
					item['serverIp']=serverIp;
					pipeList.itemUpdated(item);
					*/
					break;
				case PipeEvent.PIPE_ERROR:
					/*
					item = viewDataIndexMapping[dataIndex];
					if(!item)break;
					item['result']="err";
					pipeList.itemUpdated(item);
					*/
					break;
			}
		}
		override public function onRegister( ):void{
			//trace('onRegister-------- ');
		}
	}
}	