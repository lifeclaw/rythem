package com.webpluz.view
{
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public final class AppMediator extends Mediator implements IMediator
	{
		public static const NAME:String = 'AppMediator';
		
		public function AppMediator(viewComponent:Object)
		{
			super(NAME, viewComponent);
		}
	}
}