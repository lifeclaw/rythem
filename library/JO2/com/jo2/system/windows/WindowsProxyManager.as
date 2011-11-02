package com.jo2.system.windows
{
	import com.jo2.event.PayloadEvent;
	import com.jo2.system.IProxyManager;
	import com.jo2.system.ProxyConfigs;
	
	import flash.events.NativeProcessExitEvent;

	public final class WindowsProxyManager extends WindowsRegistryEditor implements IProxyManager
	{
		private static const REG_KEY:String = '"HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings"';
		private static const PROXY_ENABLE:String = 'ProxyEnable';
		private static const PROXY_SERVER:String = 'ProxyServer';
		private static const AUTO_CONFIG_URL:String = 'AutoConfigURL';
		
		private var _needsUpdate:Boolean;
		private var _currentSetting:ProxyConfigs;
		
		public function queryProxy():void{
			this._needsUpdate = true;
			this.queryReg(REG_KEY);
			this.executeRegCommands();
		}
		
		public function set proxy(configs:ProxyConfigs):void{
			this.deleteReg(REG_KEY, PROXY_ENABLE);
			this.deleteReg(REG_KEY, PROXY_SERVER);
			this.deleteReg(REG_KEY, AUTO_CONFIG_URL);
			if(configs.enabled) 			this.addReg(REG_KEY, PROXY_ENABLE, '0x00000001', REG_DWORD);
			if(configs.server) 			this.addReg(REG_KEY, PROXY_SERVER, '"' + configs.server + ':' + configs.port + '"');
			if(configs.autoConfigURL) 	this.addReg(REG_KEY, AUTO_CONFIG_URL, '"' + configs.autoConfigURL + '"');
			this.executeRegCommands();
		}
		
		public function get proxy():ProxyConfigs{
			return this._currentSetting;
		}
		
		override protected function dispatchCompleteEvent():void{
			if(this._needsUpdate){
				this._needsUpdate = false;
				var output:String = this._outputBuffer.toString();
				var enabled:Boolean = (output.indexOf(PROXY_ENABLE + '    ' + REG_DWORD + '    0x1') != -1);
				var serverAndPort:Array = output.match(new RegExp(PROXY_SERVER + '    ' + REG_SZ + '    (.*?)\n'));
				var autoConfigURL:Array = output.match(new RegExp(AUTO_CONFIG_URL + '    ' + REG_SZ + '    (.*?)\n'));
				var sp:Array = serverAndPort ? serverAndPort[1].split(':') : ['', 8080];
				var url:String = autoConfigURL ? autoConfigURL[1] : '';
				this._currentSetting = new ProxyConfigs(sp[0], sp[1], url, enabled);
			}
			this.dispatchEvent(new PayloadEvent(PayloadEvent.COMPLETE, this.proxy));
		}
	}
}