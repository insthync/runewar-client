package gameload 
{
	import assets.LoadScreenTexturesHelper;
	import scene.Scene;
	import scene.SceneManager;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.EnterFrameEvent;
	import starling.textures.Texture;
	import starling.animation.Tween;
	import starling.utils.deg2rad;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class LoadingScene extends Scene
	{
		private var background:Image;
		private var logo:Image;
		private var preloader:Image;
		private var preloaderTween:Tween;
		protected var loaded:Boolean;
		protected var isStarted:Boolean;
		protected var isEnded:Boolean;
		public function LoadingScene(mgr:SceneManager) 
		{
			super(mgr);
			loaded = false;
			isStarted = false;
			isEnded = false;
		}
		
		protected override function addedToStage(e:Event):void {
			super.addedToStage(e);
			
			background = new Image(LoadScreenTexturesHelper.getTexture("BackgroundLoading"));
			addChild(background);
			
			logo = new Image(LoadScreenTexturesHelper.getTexture("Logo"));
			logo.pivotX = logo.width / 2;
			logo.pivotY = logo.height / 2;
			logo.x = GlobalVariables.screenWidth / 2;
			logo.y = 300;
			addChild(logo);
			
			preloader = new Image(LoadScreenTexturesHelper.getTexture("Preloader"));
			preloader.pivotX = preloader.width / 2;
			preloader.pivotY = preloader.height / 2;
			preloader.x = GlobalVariables.screenWidth / 2;
			preloader.y = GlobalVariables.screenHeight - 200;
			addChild(preloader);
			
			initPreload();
			Starling.juggler.add(preloaderTween);
			
			this.alpha = 0;
		}
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			background.texture.dispose();
			logo.texture.dispose();
			preloader.texture.dispose();
			removeChildren(0, -1, true);
		}
		private function initPreload():void {
			preloader.rotation = deg2rad(-180);
			preloaderTween = new Tween(preloader, 0.75);
			preloaderTween.animate("rotation", deg2rad(180));
			preloaderTween.onComplete = onPreloadComplete;
		}
		private function onPreloadComplete():void {
			Starling.juggler.remove(preloaderTween);
			initPreload();
			Starling.juggler.add(preloaderTween);
		}
		
		public function start():void {
			addEventListener(EnterFrameEvent.ENTER_FRAME, loading);
			var fadeTween:Tween = new Tween(this, 1.5);
			fadeTween.fadeTo(1);
			fadeTween.onComplete = function():void {
				Starling.juggler.remove(fadeTween);
				isStarted = true;
			};
			Starling.juggler.add(fadeTween);
		}
		
		protected function loading(e:EnterFrameEvent):void {
			if (Loaded) {
				removeEventListener(EnterFrameEvent.ENTER_FRAME, loading);
				Starling.juggler.remove(preloaderTween);
			}
			if (isStarted) {
				if (loaded && !isEnded) {
					var fadeTween:Tween = new Tween(this, 0.5);
					fadeTween.fadeTo(0);
					fadeTween.onComplete = function():void {
						Starling.juggler.remove(fadeTween);
						isEnded = true;
					};
					Starling.juggler.add(fadeTween);
				}
			}
		}
		
		public function get Loaded():Boolean {
			return loaded && isStarted && isEnded;
		}
	}

}