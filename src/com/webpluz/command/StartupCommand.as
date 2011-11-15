package com.webpluz.command
{
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.patterns.command.MacroCommand;
	
	public final class StartupCommand extends MacroCommand implements ICommand
	{
		override protected function initializeMacroCommand():void{
			this.addSubCommand(ModelPrepareCommand);
			this.addSubCommand(ViewPrepareCommand);
		}
	}
}