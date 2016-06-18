package gameplay 
{
	import flash.geom.Point;
	import starling.animation.Tween;
	import starling.core.Starling;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class SwapInfo 
	{
		public var from:Rune;			// Swap from where?
		public var to:Rune;				// Swap to where?
		private var tweenForFrom:Tween;
		private var tweenForTo:Tween;
		private var oldFromPosition:Point;
		private var oldToPosition:Point;
		private var isActive:Boolean;	// Are we swapping?
		private var game:Game;
		private var useSound:Boolean;

		public function SwapInfo(game:Game, useSound:Boolean) {
			this.game = game;
			this.useSound = useSound;
			tweenForFrom = null;
			tweenForTo = null;
			from = null;
			to = null;
			oldFromPosition = new Point(-1, -1);
			oldToPosition = new Point(-1, -1);
			isActive = false;
		}
		
		public function Init(from:Rune, to:Rune):void {
			//trace("Init swapping info from (" + from.Index.x +", " + from.Index.y +") to (" + to.Index.x + ", " + to.Index.y + ")");
			this.from = from;
			this.to = to;
			oldFromPosition = new Point(from.x, from.y);
			oldToPosition = new Point(to.x, to.y);
			isActive = false;
		}
		
		public function start():void {
			tweenForFrom = new Tween(from, 0.1);
			tweenForTo = new Tween(to, 0.1);
			tweenForFrom.moveTo(oldToPosition.x, oldToPosition.y);
			tweenForTo.moveTo(oldFromPosition.x, oldFromPosition.y);
			Starling.juggler.add(tweenForFrom);
			Starling.juggler.add(tweenForTo);
			/*
			from.x = oldToPosition.x;
			from.y = oldToPosition.y;
			to.x = oldFromPosition.x;
			to.y = oldFromPosition.y;
			*/
			if (useSound)
				game.Manager.SFXSoundManager.play("game_sfx_swap");
			isActive = true;
		}
		
		public function reverse():void {
			Starling.juggler.removeTweens(tweenForFrom);
			Starling.juggler.removeTweens(tweenForTo);
			tweenForFrom = new Tween(from, 0.25);
			tweenForTo = new Tween(to, 0.2);
			tweenForFrom.moveTo(oldFromPosition.x, oldFromPosition.y);
			tweenForTo.moveTo(oldToPosition.x, oldToPosition.y);
			Starling.juggler.add(tweenForFrom);
			Starling.juggler.add(tweenForTo);
			/*
			from.x = oldFromPosition.x;
			from.y = oldFromPosition.y;
			to.x = oldToPosition.x;
			to.y = oldToPosition.y;
			*/
			if (useSound)
				game.Manager.SFXSoundManager.play("game_sfx_swap");
			isActive = false;
		}
		
		public function isReadyToCheck():Boolean {
			return tweenForFrom.isComplete && tweenForTo.isComplete;
		}
		
		public function destroy():void {
			Starling.juggler.removeTweens(tweenForFrom);
			Starling.juggler.removeTweens(tweenForTo);
			tweenForFrom = null;
			tweenForTo = null;
			from = null;
			to = null;
			oldFromPosition = new Point(-1, -1);
			oldToPosition = new Point(-1, -1);
			isActive = false;
		}
		
		public function get OldFromPosition():Point {
			return oldFromPosition;
		}
		
		public function get OldToPosition():Point {
			return oldToPosition;
		}
		
		public function get IsActive():Boolean {
			return isActive;
		}
	}

}