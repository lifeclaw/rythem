package com.jo2.system
{
	public interface IProxyManager extends ITerminal
	{
		function queryProxy():void;
		function set proxy(configs:ProxyConfigs):void;
		function get proxy():ProxyConfigs;
	}
}