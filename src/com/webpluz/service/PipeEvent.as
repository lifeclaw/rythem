package com.webpluz.service
{
	import com.webpluz.vo.RequestData;
	import com.webpluz.vo.ResponseData;
	
	import flash.events.Event;
	
	public class PipeEvent extends Event{
		
		public static const PIPE_CONNECTED:String = "PIPE_CONNECTED";
		public static const PIPE_COMPLETE:String = "PIPE_COMPLETE";
		public static const PIPE_ERROR:String = "PIPE_ERROR";
		
		public var requestData:RequestData;
		public var responseData:ResponseData;
		public var pipeId:Number;
		public function PipeEvent(type:String, pipeId:Number, requestData:RequestData=null, responseData:ResponseData=null){
			super(type, false, false);
			this.pipeId = pipeId;
			this.requestData = requestData;
			this.responseData = responseData;
		}
		public override function clone():Event{
			var e:PipeEvent = new PipeEvent(this.type,this.pipeId,this.requestData,this.responseData);
			return e;
		}
	}
}