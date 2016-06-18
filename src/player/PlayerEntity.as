package player 
{
	import assets.EffectsTexturesHelper;
	import character.BaseCharacterInformation;
	import character.BaseCharacterSkill;
	import character.EffectBuff;
	import character.Entity;
	import flash.utils.Dictionary;
	import gameplay.Game;
	import gameplay.UIChooseCharacter;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.EnterFrameEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.display.Image;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class PlayerEntity extends Entity
	{
		private var info:PlayerInformation
		// An informations that load from database
		private var characterList:Array;	// List of player's character
		// Type of player (normal, other player, ai)
		private var type:int;
		private var gates:Vector.<Image>;
		private var homes:Vector.<Image>;
		private var cannons:Vector.<MovieClip>;
		// Died state
		private var died:Boolean;
		// Team Buff
		private var teamBuffQuantity:Dictionary;
		// Kills stats
		private var kills:int;

		public function PlayerEntity(game:Game, id:int, info:PlayerInformation, type:int, charInfo:BaseCharacterInformation, gateAlive:Image, gateDie:Image, homeTop:Image, homeBottom:Image, cannonTop:MovieClip, cannonBottom:MovieClip, isSimulation:Boolean = false) 
		{
			super(game, id, charInfo, isSimulation);
			this.game = game;
			this.info = info;
			this.type = type;
			this.charInfo = charInfo;
			this.gates = new Vector.<Image>();
			this.gates.length = 2;
			this.gates[0] = gateAlive;
			this.gates[1] = gateDie;
			this.gates[0].visible = true;
			this.gates[1].visible = false;
			this.homes = new Vector.<Image>();
			this.homes.length = 2;
			this.homes[0] = homeTop;
			this.homes[1] = homeBottom;
			this.cannons = new Vector.<MovieClip>();
			this.cannons.length = 2;
			this.cannons[0] = cannonTop;
			this.cannons[0].loop = false;
			this.cannons[1] = cannonBottom;
			this.cannons[1].loop = false;
			if (!GlobalVariables.use_cannon) {
				cannonTop.visible = false;
				cannonBottom.visible = false;
			}
			addChild(this.gates[0]);
			addChild(this.gates[1]);
			this.died = false;
			super.curHP = super.maxHP = 1000;
			this.kills = 0;
			teamBuffQuantity = new Dictionary();
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		private function update(e:EnterFrameEvent):void {
			if (curHP <= 0 && !died) {
				game.GameEnd(this);
				gates[0].visible = false;
				gates[1].visible = true;
				died = true;
			}
		}
		
		public function addHomeTopChooseCharacterEvent(target:UIChooseCharacter):void {
			HomeTop.useHandCursor = true;
			HomeTop.addEventListener(TouchEvent.TOUCH, function(e:TouchEvent):void {
				var touch:Touch = e.getTouch(stage, TouchPhase.BEGAN);
				if (touch) {
					if (!game.IsGameStart)
						target.open();
				}
			});
		}
		
		public function addHomeBottomChooseCharacterEvent(target:UIChooseCharacter):void {
			HomeBottom.useHandCursor = true;
			HomeBottom.addEventListener(TouchEvent.TOUCH, function(e:TouchEvent):void {
				var touch:Touch = e.getTouch(stage, TouchPhase.BEGAN);
				if (touch) {
					if (!game.IsGameStart)
						target.open();
				}
			});
		}
		
		public override function Attacked(from:Entity):Vector.<String> {
			var damageInfo:Vector.<String> = null;
			if (!isSimulation) {
				damageInfo = super.Attacked(from);
				appendDamage(damageInfo, from);
			}
			if (game.IsTutorial) {
				if (type == PlayerTypes.NORMAL) {
					curHP = maxHP;
				}
			}
			return damageInfo;
		}
		
		public override function appendDamage(damageInfo:Vector.<String>, from:Entity):void {
			//var effectTexture:String = from.CharacterInfo.AtkType == 1 ? "DamageEffect_" : "DamageEffectMagic_";
			//var effect:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas().getTextures(effectTexture));
			//game.EffectLayer.pushEffect(effect, x, y - effect.height / 2, true);
			if (damageInfo[0] == "miss") {
				game.EffectLayer.pushDamage("Miss", 0xff0000, from.x, from.y - 80);
			}
			if (damageInfo[0] == "critical") {
				game.EffectLayer.pushDamage(damageInfo[1] + "!", 0xff0000, x, y - 80);
				game.Manager.SFXSoundManager.play("game_sfx_hit");
			}
			if (damageInfo[0] == "normal") {
				game.EffectLayer.pushDamage(damageInfo[1], 0xeeeeee, x, y - 80);
				game.Manager.SFXSoundManager.play("game_sfx_hit");
			}
			super.appendDamage(damageInfo, from);
		}
		
		public function addTeamBuff(buffId:int):int {
			var q:int = 0;
			if (teamBuffQuantity[buffId] == null)
				teamBuffQuantity[buffId] = 0;
			++teamBuffQuantity[buffId];
			q = teamBuffQuantity[buffId];
			return q;
		}
		public function delTeamBuff(buffId:int):int {
			var q:int = 0;
			--teamBuffQuantity[buffId];
			if (teamBuffQuantity[buffId] <= 0) 
				delete teamBuffQuantity[buffId];
			else
				q = teamBuffQuantity[buffId];
			return q;
		}
		
		public function addTeamBuffToChar(charEnt:Entity):void {
			for (var key:Object in teamBuffQuantity) {
				if (teamBuffQuantity[key as int] > 0) {
					var buff:EffectBuff = new EffectBuff(key as int);
					charEnt.addBuff(buff, game.EffectLayer);
				}
			}
		}
		public override function destroy():void {
			super.destroy();
			var i:int;
			for (i = 0; i < gates.length; ++i) {
				gates[i].dispose();
			}
			gates.splice(0, gates.length);
			homes.splice(0, homes.length);
			cannons.splice(0, cannons.length);
			removeChildren(0, -1, true);
		}
		
		// Properties
		public function get Information():PlayerInformation {
			return info;
		}
		public function get Type():int {
			return type;
		}
		public function get GateAlive():Image {
			return gates[0];
		}
		public function get GateDie():Image {
			return gates[1];
		}
		public function get HomeTop():Image {
			return homes[0];
		}
		public function get HomeBottom():Image {
			return homes[1];
		}
		public function get CannonTop():MovieClip {
			return cannons[0];
		}
		public function get CannonBottom():MovieClip {
			return cannons[1];
		}
		public function get AvailableCharacters():Vector.<BaseCharacterInformation> {
			return info.AvailableCharacters;
		}
		public function get AvailableSkills():Vector.<BaseCharacterSkill> {
			return info.AvailableSkills;
		}
		public override function get x():Number {
			return super.x + width / 2;
		}
		public override function set x(value:Number):void {
			super.x = value - width / 2;
		}
		public override function get y():Number {
			return super.y + height / 2 + 35;
		}
		public override function set y(value:Number):void {
			super.y = value - height / 2 - 35;
		}
		public function get Kills():int {
			return kills;
		}
		public function set Kills(value:int):void {
			kills = value;
		}
	}

}