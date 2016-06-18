package gameplay 
{
	import assets.*;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import player.PlayerTypes;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	
	public class Rune extends Sprite
	{
		private var runeTexture:Image;
		private var runeSpecialTexture:Image;
		
		private var runeNameTextureInfo:Array;
		
		private var type:int;					// Type of rune
		private var level:int;					// Level of rune which affect by triplets
		private var board:Board;				// the parent board
		private var index:Point;
		private var tweener:Tween;
		private var moveSlots:int;
		private var readyToGo:Boolean;			// Checking is rune ready to do next task
		private var lastMoveTime:Number;		// To checking when is last move
		
		public function Rune(board:Board, type:int = RuneTypes.NULL, level:int = RuneLevels.NORMAL) {
			super();
			this.board = board;
			this.Type = type;
			this.level = level;
			this.Index = new Point();
			this.moveSlots = 0;
			this.readyToGo = true;
			this.lastMoveTime = (new Date()).getTime();
			
			touchable = false;
			if (board.Player.Type == PlayerTypes.NORMAL) {
				this.addEventListener(TouchEvent.TOUCH, onTouch);
				useHandCursor = true;
				touchable = true;
			}
		}
		public function updateMoveTime():void {
			this.lastMoveTime = (new Date()).getTime();
		}
		public function getMoveTime():Number {
			return lastMoveTime;
		}
		private function onTouch(event:TouchEvent):void {
			var activeIndex:Point;
			var thisIndex:Point;
			var movement:Point;
			if (board.Activable) {
				var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
				var move:Touch = event.getTouch(this, TouchPhase.MOVED);
				
				if (move) {
					//trace("MMovementX: " + move.getMovement(stage).x + "MMovementY: " + move.getMovement(stage).y);
					//trace("PMMoveX: " + move.previousGlobalX + "PMMoveY: " + move.previousGlobalX);
					//trace("MMoveX: " + move.globalX + "MMoveY: " + move.globalY);
					movement = move.getMovement(stage);
					if (Math.abs(movement.x) > 5 || Math.abs(movement.y) > 5) {
						if (Math.abs(movement.x) > Math.abs(movement.y)) {
							if (movement.x > 0) {
								movement.x = 1;
							} else if (movement.x < 0) {
								movement.x = -1;
							} else {
								movement.x = 0;
							}
						} else {
							if (movement.y > 0) {
								movement.y = 1;
							} else if (movement.y < 0) {
								movement.y = -1;
							} else {
								movement.y = 0;
							}
						}
						activeIndex = index;
						thisIndex = new Point(activeIndex.x + movement.x, activeIndex.y + movement.y);
						if (thisIndex.x >= 0 && thisIndex.y >= 0 
							&& thisIndex.x < board.BOARD_SIZE && thisIndex.y < board.BOARD_SIZE
							&& (((thisIndex.y == activeIndex.y + 1 || thisIndex.y == activeIndex.y - 1) && thisIndex.x == activeIndex.x) ||
								((thisIndex.x == activeIndex.x + 1 || thisIndex.x == activeIndex.x - 1) && thisIndex.y == activeIndex.y))) 
						{
							// swapping
							board.swapping(activeIndex, thisIndex);
							board.ActiveIndex = board.UNACTIVE_INDEX;
						}
					}
				} else if (touch) {
					select(touch);
				}
			}
		}
		private function select(touch:Touch):void {
			var activeIndex:Point;
			var thisIndex:Point;
			var movement:Point;
			if (type > RuneTypes.NULL && type <= RuneTypes.SP_RAND) {
				activeIndex = board.ActiveIndex;
				thisIndex = index;
				//trace("click (" + activeIndex.x + ", " + activeIndex.y + ") to (" + thisIndex.x + ", " + thisIndex.y + ")");
				//trace("Cursor X: " + touch.globalX + ", " + touch.globalY);
				//trace("touch area (left, top): " + this.x + ", " + this.y + " (right, bottom): " + (this.x + this.width) + ", " + (this.y + this.height));
				if (activeIndex.equals(thisIndex)) {
					board.ActiveIndex = board.UNACTIVE_INDEX;
				} else {
					if (!(((thisIndex.y == activeIndex.y + 1 || thisIndex.y == activeIndex.y - 1) && thisIndex.x == activeIndex.x) ||
						((thisIndex.x == activeIndex.x + 1 || thisIndex.x == activeIndex.x - 1) && thisIndex.y == activeIndex.y)))
					{
						// if this index is far from current active index, change active index to this
						board.ActiveIndex = thisIndex;
					} else {
						// swapping
						//trace("Swap from (" + activeIndex.x + ", " + activeIndex.y + ") to (" + thisIndex.x + ", " + thisIndex.y + ")");
						board.swapping(activeIndex, thisIndex);
						board.ActiveIndex = board.UNACTIVE_INDEX;
					}
				}
			} else {
				//trace("active special rune");
				activateSRune();
			}
		}
		public function stop():void {
			if (board.Player.Type == PlayerTypes.NORMAL) {
				this.removeEventListener(TouchEvent.TOUCH, onTouch);
				useHandCursor = false;
				touchable = false;
			}
		}
		public function destroy():void {
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
		public static function GetRandomRune():int {
			//Random by size of all runes - size of special runes
			var idx:int = Helper.randomRange(0, RuneTypes.MAX - RuneTypes.SPECIAL_NUM);
			if (idx > RuneTypes.MAX - RuneTypes.SPECIAL_NUM) 
				idx = RuneTypes.MAX - RuneTypes.SPECIAL_NUM;
			if (idx < 0)
				idx = 0;
			return idx;
		}
		public static function GetRandomNormalRune():int {
			//Random by size of all runes - size of special runes - ? rune
			var idx:int = Helper.randomRange(0, RuneTypes.MAX - RuneTypes.SPECIAL_NUM - 1);
			if (idx > RuneTypes.MAX - RuneTypes.SPECIAL_NUM - 1) 
				idx = RuneTypes.MAX - RuneTypes.SPECIAL_NUM - 1;
			if (idx < 0)
				idx = 0;
			return idx;
		}
		public static function GetRandomSpecialRune():int {
			//Random all special runes except orange rune
			var idx:int = Helper.randomRange(RuneTypes.MAX - RuneTypes.SPECIAL_NUM + 1, RuneTypes.MAX - 1);
			if (idx > RuneTypes.MAX - 1) 
				idx = RuneTypes.MAX - 1;
			if (idx < RuneTypes.MAX - RuneTypes.SPECIAL_NUM + 1)
				idx = RuneTypes.MAX - RuneTypes.SPECIAL_NUM + 1;
			return idx;
		}
		public function InitTween(duration:Number = 0.23):void {
			tweener = new Tween(this, duration);
		}
		public function Dying(duration:Number = 0.23):void {
			// Add smoke effect
			if (board.Player.Type == PlayerTypes.NORMAL) {
				var effect:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures("SmokeEffect_"));
				board.ParentGame.EffectLayer.pushEffect(effect, board.x + x + width / 2, board.y + y + height / 2, true);
			}
			
			readyToGo = false;
			tweener = new Tween(this, duration);
			tweener.animate("alpha", 0);
			tweener.onComplete = function():void { alpha = 1; readyToGo = true; Level = RuneLevels.NORMAL; Type = RuneTypes.NULL };
		}
		public function activateSRune():void {
			if (readyToGo && (Tweener == null || Tweener.isComplete)) {
				Dying();
				Starling.juggler.add(Tweener);
				switch(type) {
					case RuneTypes.SP_HEAL:
						// Group heal
						board.ParentGame.Heal(board.Player);
					break;
					case RuneTypes.SP_MAGC:
						// Group attack
						board.ParentGame.Meto(board.Player);
					break;
					case RuneTypes.SP_STUN:
						// Group stun
						board.ParentGame.Stun(board.Player);
					break;
				}
			}
		}
		// Properties
		public function get Index():Point {
			return index;
		}
		public function set Index(index:Point):void {
			this.index = index;
		}
		public function get Type():int {
			return type;
		}
		public function set Type(type:int):void {
			for (var i:int = 0; i < numChildren;++i) {
				this.removeChildAt(i, true);
			}
			if (type > RuneTypes.NULL && type < RuneTypes.MAX) {
				if (type < RuneTypes.SP_RAND) {
					//trace(type);
					//trace(RuneTypes.RuneSpriteInfoName[type]);
					//trace(board.getChosenCharacter(type).RuneSpriteInfoName);
					//trace(RuneTypes.RuneSpriteInfoName[type] + "_" + board.getChosenCharacter(type).RuneSpriteInfoName);
					addChild(runeTexture = new Image(board.ParentGame.RuneAtlas.getTexture(RuneTypes.RuneSpriteInfoName[type] + "_" + board.getChosenCharacter(type).RuneSpriteInfoName)));
				} else {
					switch(type) {
						case RuneTypes.SP_RAND:
							addChild(runeTexture = new Image(board.ParentGame.RuneAtlas.getTexture("Orange_Questionmark")));
						break;
						case RuneTypes.SP_HEAL:
							addChild(runeTexture = new Image(board.ParentGame.RuneAtlas.getTexture("X5-Skill01")));
						break;
						case RuneTypes.SP_MAGC:
							addChild(runeTexture = new Image(board.ParentGame.RuneAtlas.getTexture("X5-Skill03")));
						break;
						case RuneTypes.SP_STUN:
							addChild(runeTexture = new Image(board.ParentGame.RuneAtlas.getTexture("X5-Skill02")));
						break;
					}
					
				}
			}
			this.type = type;
		}
		public function get Level():int {
			return level;
		}
		public function set Level(value:int):void {
			level = value;
			if (runeSpecialTexture != null && this.contains(runeSpecialTexture))
				this.removeChild(runeSpecialTexture, true);
			switch (level) {
				case RuneLevels.FORTH:
					addChild(runeSpecialTexture = new Image(board.ParentGame.RuneAtlas.getTexture("X4-Skill")));
					break;
				case RuneLevels.FIFTH:
					//addChild(runeSpecialTexture = new Image(board.ParentGame.RuneAtlas.getTexture("X5-Skill")));
					// Random new type
					Type = Rune.GetRandomSpecialRune();
					break;
				default:
					break;
			}
		}
		public function get Tweener():Tween {
			return tweener;
		}
		public function get MoveSlots():int {
			return moveSlots;
		}
		public function set MoveSlots(value:int):void {
			moveSlots = value;
		}
		public function get ReadyToGo():Boolean {
			return readyToGo;
		}
	}
}