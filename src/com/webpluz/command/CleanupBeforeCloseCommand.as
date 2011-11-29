package com.webpluz.command
{
	import com.jo2.net.IProxyManager;
	import com.jo2.net.ProxyManager;
	import com.webpluz.model.ConfigModel;
	import com.webpluz.service.ProxyService;
	import com.webpluz.service.RuleManager;
	import com.webpluz.vo.ContentReplaceRule;
	import com.webpluz.vo.IpReplaceRule;
	import com.webpluz.vo.Rule;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public final class CleanupBeforeCloseCommand extends SimpleCommand implements ICommand
	{
		public function CleanupBeforeCloseCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void{
			//close proxy service
			var proxyService:ProxyService = (facade.retrieveProxy(ProxyService.NAME) as ProxyService);
			proxyService.close();
			

			//save rules
			var localText:String = '{"projects": [{"name": "Some Project","enable": true,"rules": [';
			var remoteText:String = '{"projects": [{"name": "Test Env","enable": true,"rules": [';
			
			var rules:Array = RuleManager.getInstance().rules;
			for(var i:int=0,l:int=rules.length;i<l;++i){
				var tmp:Array = rules[i];
				for(var j:int=0;j<tmp.length;++j){
					var r:Rule = tmp[j];
					if(r.type == Rule.RULE_TYPE_REPLACE_IP){
						var r1:IpReplaceRule = r as IpReplaceRule;
						remoteText += '{"type":"File","enable:"'+r1.enable+',"pattern":"'+r1.pattern+'","replace":"'+r1.replace+'"},';
					}else{
						var r2:ContentReplaceRule = r as ContentReplaceRule;
						localText += '{"enable":'+r2.enable+',"pattern":"'+r2.pattern+'","replace":"'+r2.replace+'"},';
					}
				}
			}
			remoteText = remoteText.replace(/,$/g,"");
			localText = localText.replace(/,$/g,"");
			
			remoteText+=']}]}';
			localText+=']}]}';
			var localF:File = File.applicationStorageDirectory.resolvePath(ConfigModel.LOCAL_CONFIG_PATH);
			var remoteF:File = File.applicationStorageDirectory.resolvePath(ConfigModel.REMOTE_CONFIG_PATH);
			var fs:FileStream = new FileStream;
			
			localText = localText.replace(/\\/g,'\\\\');
			fs.open(localF,FileMode.UPDATE);
			fs.writeUTFBytes(localText);
			fs.close();

			//restore proxy configurations
			if(ProxyManager && ProxyManager.newInstance()){
				ProxyManager.newInstance().restoreSystemProxyConfig();
			}else{
				//TODO..
				trace('error here OSCAR have a look');
			}
		}
	}
}