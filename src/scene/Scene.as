package scene
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class Scene extends Sprite
	{
		protected var mgr:SceneManager;
		protected var fadeImg:Image;
		protected var fadeTween:Tween;
		public function Scene(mgr:SceneManager) 
		{
			super();
			this.mgr = mgr;
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		}
		
		protected function removeAndDisposeChildren():void {
			while (numChildren > 0) {
				var asImage:Image = getChildAt(0) as Image;
				if (asImage != null) {
					asImage.texture.dispose();
					removeChildAt(0, true);
				} else {
					removeChildAt(0, true);
				}
			}
			removeChildren(0, -1, true);
		}
		
		protected function addedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		protected function removedFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		}
		
		public function doBlackFade(delay:Number = 0.75):void {
			
			var shp:Shape = new Shape();
			shp.graphics.beginFill(0x000000, 1);
			shp.graphics.drawRect(0,0,GlobalVariables.screenWidth,GlobalVariables.screenHeight);
			shp.graphics.endFill();
			
			var bmd:BitmapData = new BitmapData(GlobalVariables.screenWidth,GlobalVariables.screenHeight);
			bmd.draw(shp);
			var tex:Texture = Texture.fromBitmapData(bmd, false);
			
			fadeImg = new Image(tex);
			
			shp.graphics.clear();
			shp = null;
			bmd = null;
			
			fadeImg.alpha = 0;
			
			fadeTween = new Tween(fadeImg, delay);
			fadeTween.fadeTo(0.75);
			fadeTween.onComplete = function():void {
				Starling.juggler.remove(fadeTween);
				fadeTween = null;
			};
		}
		public function doFadeOutTween(delay:Number = 0.75):void {
			if (fadeTween != null) {
				Starling.juggler.remove(fadeTween);
				fadeTween = null;
			}
			fadeImg.alpha = 0.75;
			fadeTween = new Tween(fadeImg, delay);
			fadeTween.fadeTo(0);
			fadeTween.onComplete = function():void {
				Starling.juggler.remove(fadeTween);
				fadeImg.removeFromParent(true);
				fadeTween = null;
				fadeImg = null;
			};
		}
		
		public function get Manager():SceneManager {
			return mgr;
		}
	}

}