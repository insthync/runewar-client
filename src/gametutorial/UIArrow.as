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
	import starling.utils.deg2rad;
	
	/**
	 * ...
	 * @author RuneWar
	 */
	public class UIArrow extends UIScene 
	{
		
		private var Arrow:Image;
		private var tween:Tween;
		private var ArrowPosX:Number;
		private var ArrowPosY:Number;
		private var ArrowAngle:Number;
		
		public function UIArrow(atlas:TextureAtlas, from:Scene) 
		{
			super(atlas, from);
			Arrow = new Image(atlas.getTexture("arrow"));
		}
		
		
		protected override function InitEvironment():void {
			addChild(Arrow);
			Tweened1();
		}
		
		protected override function removedFromStage(e:Event):void 
		{
			super.removedFromStage(e);
			Starling.juggler.remove(tween);
			removeAndDisposeChildren();
		}
		
		public function setPosRot(posX:int,posY:int,angle:int):void 
		{
			if (tween != null && !tween.isComplete) {
				Starling.juggler.remove(tween); 
			}
			Arrow.x = ArrowPosX = posX;
			Arrow.y = ArrowPosY = posY;
			Arrow.rotation = ArrowAngle = deg2rad(angle);
			Tweened1();
		}
		
		private function Tweened1():void
		{
			tween = new Tween(Arrow, 0.25);
			tween.animate("y", ArrowPosY + 50);
			if (ArrowAngle > 0) {
				tween.animate("x", ArrowPosX - 50);
			}
			Starling.juggler.add(tween);
			
			tween.onComplete = function():void { 
				Starling.juggler.remove(tween); 
				Tweened2(); 
			};
		}
		
		private function Tweened2():void
		{
			tween = new Tween(Arrow, 0.25);
			tween.animate("y", ArrowPosY);
			if (ArrowAngle > 0) {
				tween.animate("x", ArrowPosX);
			}
			Starling.juggler.add(tween);
			
			tween.onComplete = function():void {
				Starling.juggler.remove(tween);
				Tweened1();
			};
		}
		
	}

}