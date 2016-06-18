package gamelobby 
{
	import assets.LobbyTexturesHelper;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import gameplay.GameModes;
	import network.PacketHeader;
	import player.PlayerInformation;
	import scene.Scene;
	import service.BattleService;
	import starling.animation.Tween;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UIFightStart extends UIScene
	{
		// Mode
		public static const MODE_REQUEST:int = 0;
		public static const MODE_RECEIVE:int = 1;
		protected var mode:int;
		private var Dialog:Image;
		private var Frame:Image;
		private var ImageContainer:Sprite;
		private var target:PlayerInformation;
		private var pastTarget:PlayerInformation;
		private var FightButton:Button;
		private var RequestButton:Button;
		private var AcceptButton:Button;
		private var CloseButton:Button;
		private var arenaAtlas:TextureAtlas;
		private var requestReceived:Boolean;
		private var preventTargetChange:Boolean;
		public function UIFightStart(atlas:TextureAtlas, arenaAtlas:TextureAtlas, from:Scene, userInfo:PlayerInformation, mode:int = UIFightStart.MODE_REQUEST) 
		{
			super(atlas, from, userInfo);
			this.arenaAtlas = arenaAtlas;
			this.mode = mode;
			this.requestReceived = false;
			this.preventTargetChange = false;
		}
		
		protected override function InitEvironment():void {
			super.InitEvironment();
			
			Dialog = new Image(arenaAtlas.getTexture("Shield01"));
			addChild(Dialog);
			
			ImageContainer = new Sprite();
			addChild(ImageContainer);
			
			Frame = new Image(arenaAtlas.getTexture("Shield02"));
			addChild(Frame);
			Frame.useHandCursor = true;
			
			// An buttons
			FightButton = new Button(arenaAtlas.getTexture("Fight_Button"));
			FightButton.pivotX = FightButton.width / 2;
			FightButton.pivotY = FightButton.height / 2;
			FightButton.x = width / 2;
			FightButton.y = 370 + FightButton.height / 2;
			addChild(FightButton);
			AcceptButton = new Button(arenaAtlas.getTexture("Accept_Button"));
			AcceptButton.pivotX = AcceptButton.width / 2;
			AcceptButton.pivotY = AcceptButton.height / 2;
			AcceptButton.x = width / 2;
			AcceptButton.y = 370 + AcceptButton.height / 2;
			addChild(AcceptButton);
			RequestButton = new Button(arenaAtlas.getTexture("Request_Button"));
			RequestButton.pivotX = RequestButton.width / 2;
			RequestButton.pivotY = RequestButton.height / 2;
			RequestButton.x = width / 2;
			RequestButton.y = 370 + RequestButton.height / 2;
			addChild(RequestButton);
			CloseButton = new Button(arenaAtlas.getTexture("Cross"));
			CloseButton.pivotX = CloseButton.width / 2;
			CloseButton.pivotY = CloseButton.height / 2;
			CloseButton.x = width - 15;
			CloseButton.y = 15;
			addChild(CloseButton);
			
			pivotX = width / 2;
			pivotY = height / 2;
			
			x = GlobalVariables.screenWidth / 2;
			y = GlobalVariables.screenHeight / 2;
			
			FightButton.addEventListener(Event.TRIGGERED, onPressFight);
			AcceptButton.addEventListener(Event.TRIGGERED, onPressAccept);
			RequestButton.addEventListener(Event.TRIGGERED, onPressRequest);
			CloseButton.addEventListener(Event.TRIGGERED, onPressClose);
			
			visible = false;
		}
		
		public function onPressClose(e:Event):void {
			from.Manager.SFXSoundManager.play("click_button");
			trace("closing...");
			disposeTarget();
		}
		
		public function disposeTarget():void {
			if (preventTargetChange) {
				return;
			} else {
				trace("not prevent");
			}
			if (requestReceived) {
				trace("have request");
				requestReceived = false;
				// Tell server that player decline request
				if (from.Manager.IsOnline) {
					var data:Object = new Object();
					data.key = PacketHeader.request_decline;
					data.values = [ target.UserID ];
					from.Manager.clientPacket.writeLine(data);
				}
			}
			if (pastTarget != null) {
				trace("have pastTarget");
				Target = pastTarget;
				pastTarget = null;
			} else {
				trace("haven't pastTarget");
				Target = null;
			}
		}
		
		public function selectTarget(target:PlayerInformation):void {
			if (preventTargetChange)
				return;
			if (requestReceived) {
				requestReceived = false;
				// Tell server that player decline request
				if (from.Manager.IsOnline) {
					var data:Object = new Object();
					data.key = PacketHeader.request_decline;
					data.values = [ target.UserID ];
					from.Manager.clientPacket.writeLine(data);
				}
				pastTarget = null;
			}
			Target = target;
		}
		
		public function receiveRequest(from:PlayerInformation):void {
			if (!requestReceived) {
				requestReceived = true;
				if (target != null) {
					pastTarget = target;
				}
				Target = from;
			}
		}
		
		private function playFightStartAnim(completeFunc:Function):void {
			// Method that play tween when fight starting
			scaleX = 1;
			scaleY = 1;
			var fightStartTween:Tween;
			fightStartTween = new Tween(this, 0.5, Transitions.EASE_IN_OUT);
			fightStartTween.scaleTo(20);
			fightStartTween.fadeTo(0.25);
			fightStartTween.onComplete = completeFunc;
			Starling.juggler.add(fightStartTween);
		}
		
		public function startFightAsHost():void {
			// Connect to battle service to tell that start fight as host
			trace("start as host");
			touchable = false;
			from.Manager.SFXSoundManager.play("click_button");
			
			playFightStartAnim(function():void {
				touchable = true;
				disableButtons();
				if (target != null) {
					var battleService:BattleService = new BattleService(from.Manager);
					battleService.initBattleStartOnline(userInfo.UserID, target.UserID, GameModes.MULTIPLAYER_HOST);
					battleService.start();
				}
			});
		}
		
		public function startFightAsClient():void {
			// Connect to battle service to tell that start fight as client
			trace("start as client");
			touchable = false;
			from.Manager.SFXSoundManager.play("click_button");
			
			playFightStartAnim(function():void {
				touchable = true;
				disableButtons();
				if (target != null) {
					var battleService:BattleService = new BattleService(from.Manager);
					battleService.initBattleStartOnline(target.UserID, userInfo.UserID, GameModes.MULTIPLAYER_JOIN);
					battleService.start();
				}
			});
		}
		
		private function onPressFight(event:Event):void {
			touchable = false;
			if (from is Arena) {
				(from as Arena).TutorialState = 3;
			}
			from.Manager.SFXSoundManager.play("click_button");
			
			playFightStartAnim(function():void {
				touchable = true;
				disableButtons();
				if (target != null) {
					var battleService:BattleService = new BattleService(from.Manager);
					battleService.initBattleStart(target.UserID);
					battleService.start();
				}
			});
		}
		
		private function onPressAccept(event:Event):void {
			disableButtons();
			from.Manager.SFXSoundManager.play("click_button");
			try {
				if (from.Manager.IsOnline) {
					var data:Object = new Object();
					data.key = PacketHeader.request_accept;
					data.values = [ target.UserID ];
					from.Manager.clientPacket.writeLine(data);
				}
			} catch (ex:Error) {
				trace(ex);
				enableButtons();
			}
		}
		
		private function onPressRequest(event:Event):void {
			disableButtons();
			from.Manager.SFXSoundManager.play("click_button");
			try {
				if (from.Manager.IsOnline) {
					var data:Object = new Object();
					data.key = PacketHeader.send_request;
					data.values = [ target.UserID ];
					from.Manager.clientPacket.writeLine(data);
				}
			} catch (ex:Error) {
				trace(ex);
				enableButtons();
			}
		}
		
		public function enableButtons():void {
			FightButton.enabled = true;
			AcceptButton.enabled = true;
			RequestButton.enabled = true;
			CloseButton.enabled = true;
			preventTargetChange = false;
		}
		
		public function disableButtons():void {
			FightButton.enabled = false;
			AcceptButton.enabled = false;
			RequestButton.enabled = false;
			CloseButton.enabled = false;
			preventTargetChange = true;
		}
		
		public function get Target():PlayerInformation {
			return target;
		}
		
		public function set Target(value:PlayerInformation):void {
			var buttonHideTween:Tween;
			var buttonShowTween:Tween;
			var dialogCloseTween:Tween;
			var dialogOpenTween:Tween;
			var that:Arena = from as Arena;
			var isTutorial:Boolean = (from is Arena && (from as Arena).IsTutorial);
			var oldTarget:PlayerInformation = target;
			var targetButton:Button;
			target = value;
			FightButton.visible = false;
			AcceptButton.visible = false;
			RequestButton.visible = false;
			if (requestReceived) {
				targetButton = AcceptButton;
			} else {
				if (target != null && target.OnlineStatus == PlayerInformation.ONLINE_ONLINE) {
					targetButton = RequestButton;
				} else {
					targetButton = FightButton;
				}
			}
			targetButton.visible = true;
			// prevent player touching any button that will make bugs occur
			touchable = false;
			// setting an tweens
			// Button hide
			buttonHideTween = new Tween(targetButton, 0.1, Transitions.EASE_IN_OUT);
			buttonHideTween.animate("scaleX", 0);
			buttonHideTween.animate("scaleY", 0);
			// Button show
			buttonShowTween = new Tween(targetButton, 0.25, Transitions.EASE_OUT_BACK);
			buttonShowTween.animate("scaleX", 1);
			buttonShowTween.animate("scaleY", 1);
			// Dialog close
			dialogCloseTween = new Tween(this, 0.25, Transitions.EASE_IN_BACK);
			dialogCloseTween.animate("scaleX", 0);
			dialogCloseTween.animate("scaleY", 0);
			// Dialog open
			dialogOpenTween = new Tween(this, 0.25, Transitions.EASE_OUT_BACK);
			dialogOpenTween.animate("scaleX", 1);
			dialogOpenTween.animate("scaleY", 1);
			if (target != null) {
				dialogOpenTween.onComplete = function():void {
					// After opened dialog show button
					Starling.juggler.add(buttonShowTween);
				}
				buttonShowTween.onComplete = function():void {
					// After button showed, allow player to touch
					touchable = true;
					if (isTutorial) {
						that.TutorialState = 2;
					}
				}
				if (oldTarget == null) {
					// Just open a dialog
					scaleX = 0;
					scaleY = 0;
					targetButton.scaleX = 0;
					targetButton.scaleY = 0;
					visible = true;
					ImageContainer.removeChildren(0, -1, true);
					target.appendImageTo(ImageContainer);
					ImageContainer.width = 120;
					ImageContainer.height = 120;
					ImageContainer.x = Frame.x + 136
					ImageContainer.y = Frame.y + 171;
					Starling.juggler.add(dialogOpenTween);
				} else {
					// Hide a dialog then open
					scaleX = 1;
					scaleY = 1;
					buttonHideTween.onComplete = function():void {
						// Hide button then close a dialog
						Starling.juggler.add(dialogCloseTween);
					}
					dialogCloseTween.onComplete = function():void {
						// After closed dialog open dialog
						ImageContainer.removeChildren(0, -1, true);
						target.appendImageTo(ImageContainer);
						ImageContainer.width = 120;
						ImageContainer.height = 120;
						ImageContainer.x = Frame.x + 136
						ImageContainer.y = Frame.y + 171;
						Starling.juggler.add(dialogOpenTween);
					}
					Starling.juggler.add(buttonHideTween);
				}
			} else {
				// Just close a dialog
				scaleX = 1;
				scaleY = 1;
				buttonHideTween.onComplete = function():void {
					// Hide button then close a dialog
					Starling.juggler.add(dialogCloseTween);
				}
				dialogCloseTween.onComplete = function():void {
					// After closed dialog open dialog
					visible = false;
					touchable = false;
					if (isTutorial) {
						that.TutorialState = 1;
					}
				}
				Starling.juggler.add(buttonHideTween);
			}
		}
		
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			Frame.removeEventListeners(TouchEvent.TOUCH);
			removeAndDisposeChildren();
		}
	}

}