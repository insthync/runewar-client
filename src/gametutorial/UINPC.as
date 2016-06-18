package gametutorial
{
	import flash.geom.Point;
	import scene.Scene;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	
	public class UINPC extends UIScene 
	{
		
		private var NPC:Image;
		private var tween:Tween;
		
		public function UINPC(atlas:TextureAtlas, from:Scene) 
		{
			super(atlas, from);
		}
		
		
		protected override function InitEvironment():void {
			NPC = new Image(atlas.getTexture("npc_tutorial"));
			addChild(NPC);
			visible = false;
		}
		
		protected override function removedFromStage(e:Event):void 
		{
			super.removedFromStage(e);
			Starling.juggler.remove(tween);
			removeAndDisposeChildren();
		}
		
		public function open():void {
			if (!visible && (tween == null || tween.isComplete)) {
				visible = true;
				Starling.juggler.remove(tween);
				var stageWidth:int = GlobalVariables.screenWidth;
				var stageHeight:int = GlobalVariables.screenHeight;
				NPC.x = stageWidth + NPC.width;
				NPC.y = stageHeight - (NPC.height - (NPC.height / 3));
				tween = new Tween(NPC, 0.75, Transitions.EASE_OUT_ELASTIC);
				tween.animate("x", stageWidth - (NPC.width - (NPC.width / 3)));
				Starling.juggler.add(tween);
				tween.onComplete = function():void { 
					Starling.juggler.remove(tween); 
				};
			}
		}
		
		public function close():void {
			if (visible && (tween == null || tween.isComplete)) {
				Starling.juggler.remove(tween);
				var stageWidth:int = GlobalVariables.screenWidth;
				var stageHeight:int = GlobalVariables.screenHeight;
				NPC.x = stageWidth - (NPC.width - (NPC.width / 3));
				NPC.y = stageHeight - (NPC.height - (NPC.height / 3));
				tween = new Tween(NPC, 0.25, Transitions.EASE_IN_BACK);
				tween.animate("x", stageWidth + NPC.width);
				Starling.juggler.add(tween);
				tween.onComplete = function():void { 
					Starling.juggler.remove(tween); 
					visible = false;
				};
			}
		}
	}
}