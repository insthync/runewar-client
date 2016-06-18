package character 
{
	import assets.CharacterTextureHelper;
	import gamelobby.Lobby;
	import gamelobby.UICharacterInfo;
	import flash.utils.getTimer;
	import player.PlayerInformation;
	import scene.Scene;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class CharacterLobby extends Sprite
	{
		public static const STATE_NONE:int = -1;
		public static const STATE_IDLE_UNTOGGLE:int = 0;
		public static const STATE_IDLE_TOGGLE:int = 1;
		private var currentState:int;
		private var movieVector:Vector.<MovieClip>;
		private var from:Scene;
		private var playerInfo:PlayerInformation;
		private var charInfo:BaseCharacterInformation;
		public function CharacterLobby(from:Scene, playerInfo:PlayerInformation, charInfo:BaseCharacterInformation) 
		{
			this.from = from;
			this.playerInfo = playerInfo;
			this.charInfo = charInfo;
			var lobbyTextureAtlas:TextureAtlas = charInfo.Animation[CharacterTextureHelper.ANIM_LOBBY][0];
			var lobbyFPS:Number = charInfo.Animation[CharacterTextureHelper.ANIM_LOBBY][1];
			
			this.movieVector = new Vector.<MovieClip>();
			this.movieVector.length = 3;
			
			this.movieVector[STATE_IDLE_UNTOGGLE] = new MovieClip(lobbyTextureAtlas.getTextures("Idle_Lobby_"));
			this.movieVector[STATE_IDLE_UNTOGGLE].loop = true;
			this.movieVector[STATE_IDLE_UNTOGGLE].fps = lobbyFPS;
			
			this.movieVector[STATE_IDLE_TOGGLE] = new MovieClip(lobbyTextureAtlas.getTextures("Idle_See_"));
			this.movieVector[STATE_IDLE_TOGGLE].loop = true;
			this.movieVector[STATE_IDLE_TOGGLE].fps = lobbyFPS;
			
			touchable = true;
			useHandCursor = true;
			currentState = STATE_NONE;
			CurrentState = STATE_IDLE_UNTOGGLE;
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onTouch(event:TouchEvent):void {
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			var hover:Touch = event.getTouch(this, TouchPhase.HOVER);
			if (hover)
			{
				if (CurrentState == STATE_IDLE_UNTOGGLE)
					from.Manager.SFXSoundManager.play("game_sfx_swap");
				// Start playing toggle
				CurrentState = STATE_IDLE_TOGGLE;
			} else {
				// Start playing idle
				CurrentState = STATE_IDLE_UNTOGGLE;
			}
			if (touch)
			{
				// Start playing idle
				CurrentState = STATE_IDLE_UNTOGGLE;
				// Open character information dialog
				var from:Lobby = this.from as Lobby;
				if (from != null && !from.CharInfoState && !from.IsTutorial) {
					from.Manager.SFXSoundManager.play("click_button");
					from.addChild(new UICharacterInfo(from.Atlas, from.ShopAtlas, from, playerInfo, charInfo.CharIndex));
				}
			}
		}
		
		public function restartAnim():void {
			Starling.juggler.add(movieVector[currentState]);
		}
		
		public function set CurrentState(value:int):void {
			if (value != currentState)
			{
				if (currentState != STATE_NONE) {
					removeChild(movieVector[currentState]);
					Starling.juggler.remove(movieVector[currentState]);
				}
 				
				currentState = value;
				movieVector[currentState].currentFrame = 0;
				addChild(movieVector[currentState]);
				Starling.juggler.add(movieVector[currentState]);										
			}
		}
		
		public function get CurrentState():int {
			return currentState;
		}
		
		public override function get x():Number {
			return super.x + width / 2;
		}
		
		public override function get y():Number {
			return super.y + height;
		}
		
		public override function set x(value:Number):void {
			super.x = value - width / 2;
		}
		
		public override function set y(value:Number):void {
			super.y = value - height;
		}
	}

}