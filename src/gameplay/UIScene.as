package gameplay 
{
	import scene.Scene;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UIScene extends Sprite
	{
		protected var game:Game;
		public function UIScene(game:Game) 
		{
			this.game = game;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		}
		
		protected function addedToStage(e:Event):void {
			InitEvironment();
		}
		
		protected function removedFromStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
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
		
		protected function InitEvironment():void {
			
		}
	}

}