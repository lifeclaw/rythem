package
{
	import com.webpluz.command.*;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	
	public final class RythemFacade extends Facade implements IFacade
	{
		public static const STARTUP:String = 'app.startup';
		
		public static function getInstance():RythemFacade{
			if(!instance) instance = new RythemFacade();
			return instance as RythemFacade;
		}
		
		public function startup(app:Rythem):void{
			this.sendNotification(STARTUP, app);
		}
		
		override protected function initializeController():void{
			super.initializeController();
			this.registerCommand(STARTUP, StartupCommand);
		}
	}
}