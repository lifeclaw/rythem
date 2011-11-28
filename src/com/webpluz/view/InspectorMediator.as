package com.webpluz.view{
	
	import com.webpluz.service.*;
	import com.webpluz.vo.RequestData;
	import com.webpluz.vo.ResponseData;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.TextArea;
	
	public class InspectorMediator extends Mediator implements IMediator{
		
		public static const NAME:String = 'InspectorMediator';
		public var requestInspector:TextArea;
		public var responseInspector:TextArea;
		public function InspectorMediator(requestInspector:Object,responseInspector:Object){
			super(NAME);
			this.requestInspector = requestInspector as TextArea;
			this.responseInspector = responseInspector as TextArea;
		}
		public override function listNotificationInterests():Array{
			//trace("-----------------------------listNotificationInterests");
			return [PipeListMediator.ListSelectChanged];
		}
		public override function handleNotification(notification:INotification):void{
			switch(notification.getName()){
				case PipeListMediator.ListSelectChanged:
					var ps:ProxyService = (facade.retrieveProxy(ProxyService.NAME) as ProxyService);
					var id:Number = Number(notification.getBody());
					var item:Object = ps.getPipeDataById(id);
					trace("selected id=["+id+"]");
					if(!item || item == {}){
						requestInspector.text = "error..";
						responseInspector.text = "error..";
						trace('no item!'+id);
						break;
					}
					var req:RequestData = item.requestData as RequestData;
					var res:ResponseData = item.responseData as ResponseData;
					if(req){
						requestInspector.text = req.rawData || "empty...";
					}else{
						requestInspector.text = "empty..";
					}
					if(res){
						//responseInspector.text = res.rawData || "empty...";
						responseInspector.text = res.headerRawData +"\r\n\r\n"+ res.bodyUncompressed;
					}else{
						responseInspector.text = "empty..";
					}
					break;
			}
		}
	}
}