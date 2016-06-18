package gamelobby 
{
	import player.PlayerInformation;
	import scene.Scene;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UIScene extends Sprite
	{
		protected var atlas:TextureAtlas;
		protected var from:Scene;
		protected var userInfo:PlayerInformation;
		protected var activate:Boolean;
		public function UIScene(atlas:TextureAtlas, from:Scene, userInfo:PlayerInformation) 
		{
			this.atlas = atlas;
			this.from = from;
			this.userInfo = userInfo;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			this.activate = true;
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
		
		public function get PlayerInfo():PlayerInformation {
			return userInfo;
		}
		
		public function get From():Scene {
			return from;
		}
	}

}