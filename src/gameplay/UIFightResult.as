package gameplay 
{
	import assets.GameTexturesHelper;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import network.PacketHeader;
	import service.BattleService;
	import service.LobbyService;
	import starling.animation.Tween;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UIFightResult extends UIScene
	{
		private var WinDialog:Image;
		private var LoseDialog:Image;
		private var OKButton:Button;
		private var TFGold:TextField;
		private var TFExp:TextField;
		public function UIFightResult(game:Game) 
		{
			super(game);
		}
		
		protected override function InitEvironment():void {
			super.InitEvironment();
			
			WinDialog = new Image(game.Atlas.getTexture("WinTexture"));
			WinDialog.y = -35;
			addChild(WinDialog);
			
			LoseDialog = new Image(game.Atlas.getTexture("LoseTexture"));
			LoseDialog.y = -35;
			addChild(LoseDialog);
			
			OKButton = new Button(game.Atlas.getTexture("WinLoseOKTexture"));
			OKButton.pivotX = OKButton.width / 2;
			OKButton.pivotY = OKButton.height / 2;
			OKButton.x = width / 2;
			OKButton.y = 375 + OKButton.height / 2;
			addChild(OKButton);
			
			TFExp = new TextField(150, 40, "", "RWFont", 32, 0xffffff);
			TFExp.vAlign = VAlign.CENTER;
			TFExp.hAlign = HAlign.RIGHT;
			TFExp.pivotX = TFExp.width;
			TFExp.pivotY = 0;
			TFExp.x = 290;
			TFExp.y = 188;
			TFExp.autoScale = true;
			addChild(TFExp);
			
			TFGold = new TextField(150, 40, "", "RWFont", 32, 0xffffff);
			TFGold.vAlign = VAlign.CENTER;
			TFGold.hAlign = HAlign.RIGHT;
			TFGold.pivotX = TFGold.width;
			TFGold.pivotY = 0;
			TFGold.x = 290;
			TFGold.y = 243;
			TFGold.autoScale = true;
			addChild(TFGold);
			
			pivotX = width / 2;
			pivotY = height / 2;
			
			x = GlobalVariables.screenWidth / 2;
			y = GlobalVariables.screenHeight / 2;
			
			OKButton.addEventListener(Event.TRIGGERED, onOK);
			visible = false;
		}
		
		public function end(isWin:Boolean):void {
			var resultflag:int = isWin ? 0 : 1;
			var winnerPlayerIdx:int;
			// Prepare form before opening
			if (isWin) {
				WinDialog.visible = true;
				LoseDialog.visible = false;
			} else {
				WinDialog.visible = false;
				LoseDialog.visible = true;
				TFExp.visible = false;
				TFGold.visible = false;
			}
			OKButton.visible = false;
			// case to end
			if (game.GameMode == GameModes.SINGLEPLAYER) {
				var battleService:BattleService = new BattleService(game.Manager);
				battleService.initBattleEnd(game.BattleId, game.Players[0].Kills, game.Players[1].Kills , resultflag, this);
				battleService.start();
			} else {
				open();
			}
		}
		
		public function open():void {
			this.visible = true;
			game.doBlackFade();
			// Play window opening sound
			game.Manager.SFXSoundManager.play("ui_sfx_open");
			
			OKButton.touchable = false;
			OKButton.visible = true;
			OKButton.scaleX = 0;
			OKButton.scaleY = 0;
			var OKButtonTween:Tween = new Tween(OKButton, 0.25, Transitions.EASE_OUT_BACK);
			OKButtonTween.animate("scaleX", 1);
			OKButtonTween.animate("scaleY", 1);
			OKButtonTween.onComplete = function():void {
				OKButton.touchable = true;
			}
			
			scaleX = 0.1;
			scaleY = 0.1;
			var fightResultTween:Tween = new Tween(this, 0.5, Transitions.EASE_OUT_BACK);
			fightResultTween.animate("scaleX", 1);
			fightResultTween.animate("scaleY", 1);
			fightResultTween.onComplete = function():void {
				Starling.juggler.add(OKButtonTween);
			};
			Starling.juggler.add(fightResultTween);
		}
		
		public function setRewardTotalExp(value:int):void {
			TFExp.text = "" + value;
		}
		
		public function setRewardTotalGold(value:int):void {
			TFGold.text = "" + value;
		}
		
		public function setRewards(rewards:Array):void {
			var totalGold:int = 0;
			var totalExp:int = 0;
			for (var i:int = 0; i < rewards.length; ++i) {
				totalGold += rewards[i].gold;
				totalExp += rewards[i].exp;
			}
			
			TFGold.text = "" + totalGold;
			TFExp.text = "" + totalExp;
		}
		
		private function onOK(event:Event):void {
			game.Manager.SFXSoundManager.play("click_button");
			// Go to load lobby scene
			scaleX = 1;
			scaleY = 1;
			var fightResultTween:Tween;
			fightResultTween = new Tween(this, 0.5, Transitions.EASE_IN_OUT);
			fightResultTween.scaleTo(20);
			fightResultTween.fadeTo(0.25);
			fightResultTween.onComplete = function():void {
				if (game.GameMode != GameModes.SINGLEPLAYER) {
					var data:Object = new Object();
					data.key = PacketHeader.game_end;
					data.values = null;
					game.Manager.clientPacket.writeLine(data);
				}
				var lobbyService:LobbyService = new LobbyService(game.Manager);
				lobbyService.initLobbyLoader();
				lobbyService.start();
			}
			Starling.juggler.add(fightResultTween);
		}
		
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			OKButton.removeEventListeners(Event.TRIGGERED);
			removeAndDisposeChildren();
		}
	}

}