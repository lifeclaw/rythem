package com.webpluz.view{
	
	import com.webpluz.service.PipeEvent;
	import com.webpluz.vo.RequestData;
	import com.webpluz.vo.ResponseData;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.WindowedApplication;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Application;
	import spark.components.DataGrid;
	import spark.components.WindowedApplication;
	
	public class PipeListMediator extends Mediator implements IMediator{
		public static const NAME:String = 'AppMediator';
		
		[Bindable]
		private var pipeList:ArrayCollection;
		
		private var pipeGrid:DataGrid;
		public function PipeListMediator(viewComponent:Object){
			super(NAME, viewComponent);
			pipeGrid = viewComponent as DataGrid;
			pipeList = new ArrayCollection();
			pipeGrid.dataProvider = pipeList;
		}
		override public function listNotificationInterests():Array{
			var a:Array = [PipeEvent.PIPE_COMPLETE,PipeEvent.PIPE_CONNECTED,PipeEvent.PIPE_ERROR];
			return a;
		}
		override public function handleNotification( notification:INotification ):void{
			var t:String = notification.getName();
			var orientEvent:PipeEvent = notification.getBody() as PipeEvent;
			var reqData:RequestData = orientEvent.requestData;
			var resData:ResponseData = orientEvent.responseData;
			var indexId:Number = orientEvent.pipeId;
			switch(t){
				case PipeEvent.PIPE_CONNECTED:
					pipeList.addItem({
						"id":indexId,
						"protocol":reqData.httpVersion,
						"host":reqData.server,
						"path":reqData.path
					});
					trace("PIPE_CONNECTED:"+indexId);
					break;
				case PipeEvent.PIPE_COMPLETE:
					trace("PIPE_COMPLETE:"+indexId);
					var item:Object = pipeList.getItemAt(indexId);
					if(!item || !resData)break;
					item['result']=resData.resultCode;
					pipeList.itemUpdated(item);
					break;
				case PipeEvent.PIPE_ERROR:
					break;
			}
		}
		override public function onRegister( ):void{
			trace('onRegister-------- ');
		}
	}
}