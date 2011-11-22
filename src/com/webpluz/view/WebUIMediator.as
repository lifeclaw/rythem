package com.webpluz.view{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.HTML;
	
	import org.puremvc.as3.patterns.mediator.Mediator;
	
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
	}
}