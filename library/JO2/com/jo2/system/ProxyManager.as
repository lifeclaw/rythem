package com.jo2.system
{
	import com.jo2.system.windows.WindowsProxyManager;

	public final class ProxyManager
	{
		public static function getProxyManager():IProxyManager{
			switch(OS.type){
				case OS.WINDOWS: return new WindowsProxyManager(); break;
				default: trace('[ProxyManager] unsupported os!'); return null;
			}
		}
	}
}