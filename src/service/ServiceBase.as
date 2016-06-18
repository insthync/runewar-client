package service
{
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import scene.SceneManager;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class ServiceBase 
	{
		public static const MESSAGE_SUCCESS:int = 0;
		public static const MESSAGE_ERROR:int = 1;
		public static const MESSAGE_ERROR_NOTFOUND:int = 2;
		public static const MESSAGE_ERROR_NOTSIGNED:int = 3;
		public static const MESSAGE_ERROR_GOLD_NOTENOUGH:int = 4;
		public static const MESSAGE_ERROR_CRYSTAL_NOTENOUGH:int = 5;
		public static const MESSAGE_ERROR_GOLD_NOTABLE:int = 6;
		public static const MESSAGE_ERROR_CRYSTAL_NOTABLE:int = 7;
		protected var loader:URLLoader;
		protected var request:URLRequest;
		protected var requestVars:URLVariables;
		protected var started:Boolean;
		protected var sceneMgr:SceneManager;
		public function ServiceBase(sceneMgr:SceneManager) 
		{
			init();
			this.sceneMgr = sceneMgr;
			started = false;
		}
		
		public function init():void {
			loader = new URLLoader();
			request = new URLRequest();
			requestVars = new URLVariables();
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			started = false;
		}
		
		public function start():void {
			if (loader != null && request != null && requestVars != null) {
				loader.load(request);
				started = true;
			}
		}
		
		protected function httpStatusHandler( e:HTTPStatusEvent ):void {
			trace("httpStatusHandler:" + e);
		}
		
		protected function securityErrorHandler( e:SecurityErrorEvent ):void {
			trace("securityErrorHandler:" + e);
		}
		
		protected function ioErrorHandler( e:IOErrorEvent ):void {
			trace("ioErrorHandler: " + e);
			loader.load(request);	// Load until success ?, or tell player to refresh browser ?
			//dispatchEvent( e );
		}
	}

}