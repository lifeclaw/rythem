package com.webpluz.model
{
	import com.jo2.filesystem.FileUtils;
	import com.webpluz.vo.ProjectConfig;
	import com.webpluz.vo.ReplaceRule;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public final class ConfigModel extends Proxy implements IProxy
	{
		public static const NAME:String = 'ConfigModel';
		public static const UPDATE:String = 'model.config.update';
		
		private static const LOCAL_CONFIG_PATH:String = 'configurations/config.local.json';
		private static const REMOTE_CONFIG_PATH:String = 'configurations/config.remote.json';
		
		private var localConfig:File;
		private var remoteConfig:URLLoader;
		private var loading:Boolean;
		private var config:Vector.<ProjectConfig>;
		
		public function ConfigModel(){
			super(NAME);
			localConfig = File.applicationDirectory.resolvePath(LOCAL_CONFIG_PATH);
			remoteConfig = new URLLoader();
			remoteConfig.addEventListener(Event.COMPLETE, onRemoteConfigComplete);
			remoteConfig.addEventListener(IOErrorEvent.IO_ERROR, onRemoteConfigError);
			config = new Vector.<ProjectConfig>();
			trace('[ConfigModel] ready');
		}
		
		/**
		 * reload all configurations (from local and remote)
		 * a UPDATE notification is sent when local or remote config is loaded
		 */
		public function reload():void{
			this.loadLocalConfig();
			this.loadRemoteConfig();
		}
		
		/**
		 * load local configuration from file system
		 */
		public function loadLocalConfig():void{
			if(localConfig.exists){
				trace('[ConfigModel] local config complete');
				this.processRawConfigDate(FileUtils.readUTFBytes(localConfig));
				this.sendNotification(UPDATE);
			}
			else trace('[ConfigModel] local config is missing');
		}
		
		/**
		 * loadl remote configuration from remote server
		 */
		public function loadRemoteConfig():void{
			if(loading){
				remoteConfig.close();
			}
			remoteConfig.load(new URLRequest(REMOTE_CONFIG_PATH));
			loading = true;
			trace('[ConfigModel] loading remote config');
		}
		
		public function get projects():Vector.<ProjectConfig>{
			return this.config;
		}
		
		public function matchRule(value:String):ReplaceRule{
			var result:ReplaceRule;
			this.config.some(
				function(project:ProjectConfig, index:uint, all:Vector.<ProjectConfig>):Boolean{
					if(project.enable){
						result = project.matchRule(value);
						return Boolean(result);
					}
					else return false;
				}
			);
			return result;
		}
		
		/**
		 * process raw configuration content (in JSON format)
		 * @param {String} rawContent raw configuration content
		 */
		private function processRawConfigDate(rawContent:String):void{
			try{
				var json:Object = JSON.parse(rawContent);
			}
			catch(e:Error){
				trace('[ConfigModel] CONFIG FORMAT ERROR: ' + e.message);
				return;
			}
			var projects:Array = json['projects'];
			for each(var project:Object in projects){
				config.push(ProjectConfig.instantiateFromObject(project));
			}
		}
		
		private function onRemoteConfigComplete(e:Event):void{
			trace('[ConfigModel] remote config complete');
			loading = false;
			this.processRawConfigDate(remoteConfig.data);
			this.sendNotification(UPDATE);
		}
		
		private function onRemoteConfigError(e:IOErrorEvent):void{
			trace('[ConfigModel] REMOTE CONFIG IO ERROR');
			loading = false;
		}
	}
}