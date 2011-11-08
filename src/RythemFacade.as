package
{
	import com.webpluz.command.*;
	import com.webpluz.model.*;
	import com.webpluz.service.ProxyService;
	import com.webpluz.view.*;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	
	public final class RythemFacade extends Facade implements IFacade
	{
		public static const STARTUP:String = 'app.startup';
		
		private var app:Rythem;
		
		/**
		 * get an instance of the facade singleton
		 * DON'T USE CONSTRUCTOR TO INSTANTIATE THE FACADE!
		 */
		public static function getInstance():RythemFacade{
			if(!instance) instance = new RythemFacade();
			return instance as RythemFacade;
		}
		
		/**
		 * start up the app
		 * the STARTUP notification will trigger the StartupCommand
		 */
		public function startup(app:Rythem):void{
			this.app = app;
			this.sendNotification(STARTUP, app);
		}
		
		override protected function initializeController():void{
			super.initializeController();
			this.registerCommand(STARTUP, StartupCommand);
		}
		
		override protected function initializeModel():void{
			super.initializeModel();
			this.registerProxy(new ConfigModel);
			this.registerProxy(new ProxyService());
		}
		
		override protected function initializeView():void{
			super.initializeView();
			//this.registerMediator(new AppMediator(app));//TODO app==null @oscar
		}
	}
}
