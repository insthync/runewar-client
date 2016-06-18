package character 
{
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import gameplay.Game;
	import gameplay.GameModes;
	import network.PacketHeader;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class Entity extends Sprite
	{
		protected var game:Game;
		protected var id:int;
		protected var charInfo:BaseCharacterInformation;
		protected var curHP:int;
		protected var maxHP:int;
		protected var pauseTimer:Timer;
		protected var isPause:Boolean;
		protected var curses:Vector.<EffectCurse>;
		protected var buffs:Vector.<EffectBuff>;
		protected var lastTime:int;
		protected var lastAttackTime:int;
		protected var currentState:int;
		protected var currentDirection:int;
		protected var currentTarget:Point;
		protected var currentEnemy:Entity;
		// Simulation state
		protected var isSimulation:Boolean;
		public function Entity(game:Game, id:int, charInfo:BaseCharacterInformation, isSimulation:Boolean) 
		{
			this.game = game;
			this.id = id;
			this.charInfo = charInfo;
			this.curses = new Vector.<EffectCurse>();
			this.buffs = new Vector.<EffectBuff>();
			this.curHP = this.maxHP = this.charInfo.Hp;
			this.isSimulation = isSimulation;
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		}
		
		// Events
		private function addedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
		}
		
		private function removedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			this.removeEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:EnterFrameEvent):void {
			sendUpdateToServer();
		}
		
		// Functions
		public function Attacking(to:Entity):void {
			to.Attacked(this);
			
			if (game.GameMode == GameModes.MULTIPLAYER_HOST) {
				var data:Object = new Object();
				data.key = PacketHeader.game_character_attack_to;
				data.values = [ to.ID, ID ];
				game.Manager.clientPacket.writeLine(data);
			}
		}
		
		public function Attacked(from:Entity):Vector.<String> {
			var damageInfo:Vector.<String> = new Vector.<String>();
			damageInfo.length = 2;
			damageInfo[0] = "miss";
			damageInfo[1] = "0";
			// Dodge rate
			var dodgeRate:Number = Helper.randomRange(1, 100);
			if (dodgeRate > CharacterInfo.DodgeRate) {
				damageInfo[0] = "normal";
				// Damage
				var pdmg:Number = (Helper.randomRange(from.CharacterInfo.MinPAtk, from.CharacterInfo.MaxPAtk) - from.CharacterInfo.PDef);
				pdmg = pdmg > 0 ? pdmg : 0;
				var mdmg:Number = (Helper.randomRange(from.CharacterInfo.MinMAtk, from.CharacterInfo.MaxMAtk) - from.CharacterInfo.MDef);
				mdmg = mdmg > 0 ? mdmg : 0;
				var dmg:Number = pdmg + mdmg;
				// Critical
				var criRate:Number = Helper.randomRange(1, 100);
				if (criRate < CharacterInfo.CriRate) {
					damageInfo[1] = "critical";
					dmg += CharacterInfo.CriAtk;
				}
				if (!isSimulation) {
					CurrentHP -= dmg;
				}
				damageInfo[1] = "" + dmg;
			}
			return damageInfo;
		}
		
		public function appendDamage(damageInfo:Vector.<String>, from:Entity):void {
			// Do something ... 
			if (game.GameMode == GameModes.MULTIPLAYER_HOST) {
				var data:Object = new Object();
				data.key = PacketHeader.game_append_character_damage;
				data.values = [ ID, damageInfo[0], damageInfo[1], from.ID ];
				game.Manager.clientPacket.writeLine(data);
			}
		}
		
		public function Pause(pauseTime:Number):void {
			if (pauseTimer != null && pauseTimer.running) {
				pauseTimer.stop();
				pauseTimer = null;
			}
			isPause = true;
			pauseTimer = new Timer(pauseTime, 1);
			pauseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
				isPause = false;
			});
			pauseTimer.start();
		}
		
		public function addCurse(effect:EffectCurse, layer:Sprite):void {
			for (var i:int = 0; i < curses.length; ++i) {
				if (curses[i].CurseID == effect.CurseID) {
					return;
				}
			}
			effect.SetCharacterEntity(this);
			curses.push(effect);
			layer.addChild(effect);
		}
		public function removeCurse(id:int):void {
			for (var i:int = 0; i < curses.length; ++i) {
				if (curses[i].CurseID == id) {
					curses[i].removeFromParent(true);
					curses.splice(i, 1);
					return;
				}
			}
		}
		public function addBuff(effect:EffectBuff, layer:Sprite):void {
			for (var i:int = 0; i < buffs.length; ++i) {
				if (buffs[i].BuffID == effect.BuffID) {
					return;
				}
			}
			effect.SetCharacterEntity(this);
			buffs.push(effect);
			layer.addChild(effect);
		}
		public function removeBuff(id:int):void {
			for (var i:int = 0; i < buffs.length; ++i) {
				if (buffs[i].BuffID == id) {
					buffs[i].removeFromParent(true);
					buffs.splice(i, 1);
					return;
				}
			}
		}
		public function destroy():void {
			// Remove all buff and curse
			var i:int = 0;
			for (i = 0; i < buffs.length; ++i) {
				buffs[i].removeFromParent(true);
			}
			buffs.splice(0, buffs.length);
			for (i = 0; i < curses.length; ++i) {
				curses[i].removeFromParent(true);
			}
			curses.splice(0, curses.length);
		}
		
		private function sendUpdateToServer():void {
			if (game.GameMode == GameModes.MULTIPLAYER_HOST) {
				var data:Object = new Object();
				data.key = PacketHeader.game_update_entity;
				data.values = [ id, curHP, currentState, x, y ];
				game.Manager.clientPacket.writeLine(data);
			}
		}
		
		public function MoveTo(value:Point):void {
			
		}
		
		// Properties
		public function get CharacterInfo():BaseCharacterInformation {
			return charInfo;
		}
		
		public function get CurrentHP():int {
			return curHP;
		}
		
		public function set CurrentHP(value:int):void {
			curHP = value;
			if (curHP < 0) {
				curHP = 0;
			}
			if (curHP > maxHP) {
				curHP = maxHP;
			}
			sendUpdateToServer();
		}
		
		public function get MaxHP():int {
			return maxHP;
		}
		
		public function set CurrentTarget(value:Point):void {
			currentTarget = value;
		}
		
		public function get CurrentTarget():Point {
			return currentTarget;
		}
		
		public function set CurrentState(value:int):void {
			currentState = value;
		}
		
		public function get CurrentState():int {
			return currentState;
		}
		
		public function set CurrentDirection(value:int):void {
			currentDirection = value;
		}
		
		public function get CurrentDirection():int {
			return currentDirection;
		}
		
		public function get CurrentEnemy():Entity {
			return currentEnemy;
		}
		
		public function set CurrentEnemy(value:Entity):void {
			currentEnemy = value;
		}
		
		public function get IsSimulation():Boolean {
			return isSimulation;
		}
		
		public function get ID():int {
			return id;
		}
		
		public override function get x():Number {
			return super.x;
		}
		
		public override function set x(value:Number):void {
			super.x = value;
		}
		
		public override function get y():Number {
			return super.y;
		}
		
		public override function set y(value:Number):void {
			super.y = value;
		}
	}

}