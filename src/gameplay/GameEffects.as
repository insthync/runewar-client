package gameplay
{
	import assets.EffectsTexturesHelper;
	import character.Entity;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.external.ExternalInterface;
	import network.PacketHeader;
	import player.PlayerEntity;
	import starling.animation.Tween;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EnterFrameEvent;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	public class GameEffects extends Sprite
	{
		private var game:Game;
		public function GameEffects(game:Game) {
			super();
			this.game = game;
		}
		
		public function pushEffect(clip:MovieClip, x:Number, y:Number, dispose:Boolean):void {
			//if (numChildren > 25)
			//	return;
			clip.touchable = false;
			clip.pivotX = clip.width / 2;
			clip.pivotY = clip.height / 2;
			clip.x = x;
			clip.y = y;
			addChild(clip);
			clip.loop = false;
			clip.currentFrame = 0;
			Starling.juggler.add(clip);
			clip.addEventListener(Event.COMPLETE, function(e:Event):void {
				removeChild(clip, dispose);
			});
		}
		
		public function pushDamage(dmg:String, color:uint, x:Number, y:Number):void {
			//if (numChildren > 25)
			//	return;
			var tf:TextField = new TextField(100, 100, dmg, "RWFont", 80, color, true);
			tf.touchable = false;
			tf.hAlign = HAlign.CENTER;
			tf.vAlign = VAlign.CENTER;
			tf.autoScale = true;
			tf.pivotX = tf.width / 2;
			tf.pivotY = tf.height / 2;
			tf.x = x;
			tf.y = y;
			addChild(tf);
			
			var myGlow:GlowFilter = new GlowFilter(); 
			myGlow.inner = false;
			myGlow.color = 0x000000; 
			myGlow.blurX = 10; 
			myGlow.blurY = 10; 
			tf.nativeFilters = [myGlow];

			var tfTween:Tween = new Tween(tf, 0.5);
			tfTween.animate("scaleX", 0.5);
			tfTween.animate("scaleY", 0.5);
			tfTween.animate("alpha", 0);
			tfTween.moveTo(x, y - 100);
			Starling.juggler.add(tfTween);
			tfTween.onComplete = function():void {
				removeChild(tf, true);
			};
		}
		
		public function cannonTo(target:Entity, from:PlayerEntity, cannonidx:int, collected_cannon:int, damage:int):void {
			if (cannonidx == 0) {
				from.CannonTop.currentFrame = 0;
				Starling.juggler.add(from.CannonTop);
			}
			
			if (cannonidx == 1) {
				from.CannonBottom.currentFrame = 0;
				Starling.juggler.add(from.CannonBottom);
			}
			
			var damage:int = damage + (2 * collected_cannon);
			var smoke_mc:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas2().getTextures("Meteor_Boom"));
			
			
			game.Manager.SFXSoundManager.play("cannon_blast");
			if (target != null) {
				pushEffect(smoke_mc, target.x, target.y - smoke_mc.height / 2, true);
				pushDamage(damage + "!", 0xff0000, target.x, target.y);
				target.CurrentHP -= damage;
			}
			
			// Send data to client
			var data:Object = new Object();
			if (game.GameMode == GameModes.MULTIPLAYER_HOST) {
				data.key = PacketHeader.game_cannon_to;
				data.values = [ game.checkPlayerIndex(from), target.ID, cannonidx, collected_cannon ];
				game.Manager.clientPacket.writeLine(data);
			}
		}
		
		public function healTo(target:Entity, power:int):void {
			var mc:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas2().getTextures("Heal_Skill"));
			
			mc.touchable = false;
			mc.pivotX = mc.width / 2;
			mc.x = target.x;
			mc.y = target.y - 150;
			mc.loop = false;
			addChild(mc);
			
			Starling.juggler.add(mc);
			mc.addEventListener(Event.COMPLETE, function(e:Event):void {
				removeChild(mc, true);
			});
			
			if (target != null) {
				pushDamage("+" + power, 0x008800, target.x, target.y);
				target.CurrentHP += power;
			}
			
			// Send data to client
			var data:Object = new Object();
			if (game.GameMode == GameModes.MULTIPLAYER_HOST) {
				data.key = PacketHeader.game_heal_to;
				data.values = [ target.ID ];
				game.Manager.clientPacket.writeLine(data);
			}
		}
		
		public function meteorAttackTo(target:Entity, damage:int):void {
			var time:int = Helper.randomRange(0, 1500);
			var attackTime:int = getTimer();
			var func:Function = function(e:EnterFrameEvent):void {
				if (getTimer() - attackTime >= time) {
					meteorTo(target, damage);
					removeEventListener(EnterFrameEvent.ENTER_FRAME, func);
				}
			};
			addEventListener(EnterFrameEvent.ENTER_FRAME, func);
		}
		
		public function meteorTo(target:Entity, damage:int):void {
			game.Manager.SFXSoundManager.play("game_sfx_wind" + Helper.randomRange(1, 3));
			var smoke_mc:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas2().getTextures("Meteor_Boom"));
			var mc:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas2().getTextures("Meteor_Skill"));
			
			mc.touchable = false;
			mc.pivotX = mc.width / 2;
			mc.pivotY = mc.height / 2;
			mc.x = target.x;
			mc.y = target.y - 800;
			mc.loop = true;
			addChild(mc);
			
			var tw:Tween = new Tween(mc, 0.60);
			tw.animate("y", target.y - 150);
			tw.onComplete = function():void {
				removeChild(mc, true);
				game.Manager.SFXSoundManager.play("game_sfx_explosion" + Helper.randomRange(1, 2));
				if (target != null) {
					pushEffect(smoke_mc, target.x, target.y - smoke_mc.height / 2, true);
					pushDamage(damage + "!", 0xff0000, target.x, target.y);
					target.CurrentHP -= damage;
				}
			};
			
			Starling.juggler.add(mc);
			Starling.juggler.add(tw);
			
			// Send data to client
			var data:Object = new Object();
			if (game.GameMode == GameModes.MULTIPLAYER_HOST) {
				data.key = PacketHeader.game_meteor_to;
				data.values = [ target.ID ];
				game.Manager.clientPacket.writeLine(data);
			}
		}
		
		public function stunTo(target:Entity, time:Number):void {
			var mc:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas2().getTextures("Stun_Skill"));
			
			mc.touchable = false;
			mc.pivotX = mc.width / 2;
			mc.x = target.x;
			mc.y = target.y - 150;
			mc.loop = true;
			addChild(mc);
			
			var tw:Tween = new Tween(mc, time / 1000);
			tw.moveTo(mc.x, mc.y);
			tw.onComplete = function():void {
				removeChild(mc, true);
			};
			Starling.juggler.add(mc);
			Starling.juggler.add(tw);
			if (target != null) {
				target.Pause(time);
			}
			
			// Send data to client
			var data:Object = new Object();
			if (game.GameMode == GameModes.MULTIPLAYER_HOST) {
				data.key = PacketHeader.game_stun_to;
				data.values = [ target.ID ];
				game.Manager.clientPacket.writeLine(data);
			}
		}
	}
}