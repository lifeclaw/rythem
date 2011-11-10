package com.webpluz.view{
	
	import com.webpluz.service.PipeEvent;
	import com.webpluz.vo.RequestData;
	import com.webpluz.vo.ResponseData;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.events.SelectionEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.GridItem;
	import mx.core.Application;
	import mx.core.WindowedApplication;
	import mx.events.DataGridEvent;
	import mx.events.ListEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Application;
	import spark.components.DataGrid;
	import spark.components.WindowedApplication;
	
	public class PipeListMediator extends Mediator implements IMediator{
		public static const NAME:String = 'PipeListMediator';
		
		
		public static const ListSelectChanged:String="selectChanged";
		
		[Bindable]
		private var pipeList:ArrayCollection;
		private var viewDataIndexMapping:Dictionary;
		
		private var pipeGrid:DataGrid;
		public function PipeListMediator(viewComponent:Object){
			super(NAME, viewComponent);
			pipeGrid = viewComponent as DataGrid;
			pipeList = new ArrayCollection();
			viewDataIndexMapping = new Dictionary();
			//pipeList.addItem({'id':"#","host":"test.test"});
			//pipeList.addItem({'id':"#","host":"test.test"});
			//pipeList.addItem({'id':"#","host":"test.test"});
			pipeGrid.dataProvider = pipeList;
			pipeGrid.addEventListener(SelectionEvent.SELECTION_CHANGE,onGripdClick);
		}
		
		protected function onGripdClick(event:Event):void{
			var g:DataGrid = event.target as DataGrid;
			var item:Object = g.selectedItem;
			this.sendNotification(PipeListMediator.ListSelectChanged,item['pipeId']);
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
					var listIndex:int = pipeList.length;
					item={
						"pipeId":pipeData.pipeId,
						"id":listIndex,
						"protocol":reqData.httpVersion,
						"host":reqData.server,
						"path":reqData.path						
					};
					viewDataIndexMapping[dataIndex] = item;
					pipeList.addItem(item);
					trace("PIPE_CONNECTED:"+listIndex+" dataIndex:"+dataIndex);
					break;
				case PipeEvent.PIPE_COMPLETE:
					//trace("PIPE_COMPLETE:"+dataIndex);
					item = viewDataIndexMapping[dataIndex];
					//var item:Object = pipeList.getItemAt(indexId);
					if(!item || !resData)break;
					var resultCode:String = resData?resData.resultCode:"404";
					var serverIp:String = resData?resData.serverIp:"";
					item['result']=resultCode;
					item['serverIp']=serverIp;
					pipeList.itemUpdated(item);
					break;
				case PipeEvent.PIPE_ERROR:
					item = viewDataIndexMapping[dataIndex];
					if(!item)break;
					item['result']="err";
					pipeList.itemUpdated(item);
					break;
			}
		}
		override public function onRegister( ):void{
			//trace('onRegister-------- ');
		}
	}
}