package character 
{
	import assets.*;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import gameplay.Game;
	import gameplay.GameModes;
	import player.PlayerEntity;
	import flash.utils.getTimer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import starling.animation.Juggler;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.MovieClip;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class CharacterEntity extends Entity
	{
		public static const STATE_NONE:int = -1;
		public static const STATE_IDLE_FRONT:int = 0;
		public static const STATE_IDLE_BACK:int = 1;
		public static const STATE_IDLE_LEFT:int = 2;
		public static const STATE_IDLE_RIGHT:int = 3;
		public static const STATE_RUN_FRONT:int = 4;
		public static const STATE_RUN_BACK:int = 5;
		public static const STATE_RUN_LEFT:int = 6;
		public static const STATE_RUN_RIGHT:int = 7;
		public static const STATE_ATTACK_FRONT:int = 8;
		public static const STATE_ATTACK_BACK:int = 9;
		public static const STATE_ATTACK_LEFT:int = 10;
		public static const STATE_ATTACK_RIGHT:int = 11;
		public static const DIRECTION_DOWN:int = 0;
		public static const DIRECTION_UP:int = 1;
		public static const DIRECTION_LEFT:int = 2;
		public static const DIRECTION_RIGHT:int = 3;
		
		protected var playerEnt:PlayerEntity;
		protected var enemyPlayerEnt:PlayerEntity;
		protected var movieVector:Vector.<MovieClip>;
		protected var waypoint:Array;
		protected var waypoint_index:int;
		protected var dir_waypoint:int;
		protected var spawnpoint:Point;
		protected var moveTween:Tween;
		protected var fadeTween:Tween;
		protected var hpBar:HPBar;
		protected var hurtTimer:Timer;
		protected var isHurt:Boolean;
		protected var isSkill:Boolean;
		protected var skilledEffect:MovieClip;
		// An offsets 
		protected var offset_floor:Number;
		protected var offset_effects:Number;
		// Client fields
		protected var clientLastMoveTime:int;
		
		public function CharacterEntity(game:Game, id:int, charInfo:BaseCharacterInformation, playerEnt:PlayerEntity, enemyPlayerEnt:PlayerEntity, waypoint:Array, dir_waypoint:int, spawnpoint:Point, isSkill:Boolean, isSimulation:Boolean) 
		{
			super(game, id, charInfo, isSimulation);
			
			var idleTextureAtlas:TextureAtlas = charInfo.Animation[CharacterTextureHelper.ANIM_IDLE][0];
			var idleFPS:Number = charInfo.Animation[CharacterTextureHelper.ANIM_IDLE][1];
			
			var runTextureAtlas:TextureAtlas = charInfo.Animation[CharacterTextureHelper.ANIM_RUN][0];
			var runFPS:Number = charInfo.Animation[CharacterTextureHelper.ANIM_RUN][1];
			
			var attackTextureAtlas:TextureAtlas = charInfo.Animation[CharacterTextureHelper.ANIM_ATTACK][0];
			var attackFPS:Number = charInfo.Animation[CharacterTextureHelper.ANIM_ATTACK][1];
			
			this.game = game;
			this.currentState = STATE_NONE;
			this.playerEnt = playerEnt;
			this.enemyPlayerEnt = enemyPlayerEnt;
			this.movieVector = new Vector.<MovieClip>();
			this.waypoint = waypoint;
			this.dir_waypoint = dir_waypoint;
			this.spawnpoint = spawnpoint;
			this.isSkill = isSkill;
			switch (dir_waypoint) {
				case Game.DIR_WAYPOINT_TO_LEFT:
					waypoint_index = waypoint.length - 2;
					break;
				case Game.DIR_WAYPOINT_TO_RIGHT:
					waypoint_index = 1;
					break;
			}
			// Set an character animation
			// Idle
			this.movieVector[STATE_IDLE_FRONT] = new MovieClip(idleTextureAtlas.getTextures("Idle_Front_"));
			this.movieVector[STATE_IDLE_FRONT].loop = true;
			this.movieVector[STATE_IDLE_FRONT].fps = idleFPS;
			
			this.movieVector[STATE_IDLE_BACK] = new MovieClip(idleTextureAtlas.getTextures("Idle_Back_"));
			this.movieVector[STATE_IDLE_BACK].loop = true;
			this.movieVector[STATE_IDLE_BACK].fps = idleFPS;
			
			this.movieVector[STATE_IDLE_LEFT] = new MovieClip(idleTextureAtlas.getTextures("Idle_Left_"));
			this.movieVector[STATE_IDLE_LEFT].loop = true;
			this.movieVector[STATE_IDLE_LEFT].fps = idleFPS;
			
			this.movieVector[STATE_IDLE_RIGHT] = new MovieClip(idleTextureAtlas.getTextures("Idle_Right_"));
			this.movieVector[STATE_IDLE_RIGHT].loop = true;
			this.movieVector[STATE_IDLE_RIGHT].fps = idleFPS;
			
			// Run
			this.movieVector[STATE_RUN_FRONT] = new MovieClip(runTextureAtlas.getTextures("Run_Front_"));
			this.movieVector[STATE_RUN_FRONT].loop = true;
			this.movieVector[STATE_RUN_FRONT].fps = runFPS;
			
			this.movieVector[STATE_RUN_BACK] = new MovieClip(runTextureAtlas.getTextures("Run_Back_"));
			this.movieVector[STATE_RUN_BACK].loop = true;
			this.movieVector[STATE_RUN_BACK].fps = runFPS;
			
			this.movieVector[STATE_RUN_LEFT] = new MovieClip(runTextureAtlas.getTextures("Run_Left_"));
			this.movieVector[STATE_RUN_LEFT].loop = true;
			this.movieVector[STATE_RUN_LEFT].fps = runFPS;
			
			this.movieVector[STATE_RUN_RIGHT] = new MovieClip(runTextureAtlas.getTextures("Run_Right_"));
			this.movieVector[STATE_RUN_RIGHT].loop = true;
			this.movieVector[STATE_RUN_RIGHT].fps = runFPS;
			
			// Attack
			this.movieVector[STATE_ATTACK_FRONT] = new MovieClip(attackTextureAtlas.getTextures("Attack_Front_"));
			this.movieVector[STATE_ATTACK_FRONT].loop = false;
			this.movieVector[STATE_ATTACK_FRONT].fps = attackFPS;
			
			this.movieVector[STATE_ATTACK_BACK] = new MovieClip(attackTextureAtlas.getTextures("Attack_Back_"));
			this.movieVector[STATE_ATTACK_BACK].loop = false;
			this.movieVector[STATE_ATTACK_BACK].fps = attackFPS;
			
			this.movieVector[STATE_ATTACK_LEFT] = new MovieClip(attackTextureAtlas.getTextures("Attack_Left_"));
			this.movieVector[STATE_ATTACK_LEFT].loop = false;
			this.movieVector[STATE_ATTACK_LEFT].fps = attackFPS;
			
			this.movieVector[STATE_ATTACK_RIGHT] = new MovieClip(attackTextureAtlas.getTextures("Attack_Right_"));
			this.movieVector[STATE_ATTACK_RIGHT].loop = false;
			this.movieVector[STATE_ATTACK_RIGHT].fps = attackFPS;
			
			// Set current animation state
			this.touchable = false;
			this.CurrentState = STATE_IDLE_FRONT;
			this.clientLastMoveTime = this.lastTime = getTimer();
			this.lastAttackTime = getTimer();
			var hpBarColor:uint = 0xff0000;
			if (game.checkPlayerIndex(playerEnt) == 0) {
				hpBarColor = 0x92d050;
			}
			hpBar = new HPBar(this, 47, 7, 0xffffff, 1, 45, 5, hpBarColor, 1);
			isHurt = false;
			isPause = false;
			if (isSkill) {
				skilledEffect = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures("Skill_Active"));
				skilledEffect.loop = true;
				skilledEffect.touchable = false;
				skilledEffect.pivotX = skilledEffect.width / 2;
				skilledEffect.pivotY = skilledEffect.height;
			}
			doFadeIn();
		}
		
		// fade in / fade out function
		public function doFadeIn():void {
			var that:CharacterEntity = this;
			alpha = 0;
			if (fadeTween != null) {
				Starling.juggler.remove(fadeTween);
				fadeTween = null;
			}
			x = spawnpoint.x;
			y = spawnpoint.y;
			
			if (isSkill) {
				Starling.juggler.add(skilledEffect);
				game.FloorLayer.addChild(skilledEffect);
				addEventListener(EnterFrameEvent.ENTER_FRAME, updateSkilledEffect);
			}
			
			// Add smoke effect
			var effect:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures("SmokeEffect_"));
			game.EffectLayer.pushEffect(effect, x, y - effect.height / 2, true);
			if (!isSimulation) {
				currentTarget = waypoint[waypoint_index];
			}
			fadeTween = new Tween(this, 0.5);
			fadeTween.fadeTo(1);
			fadeTween.onComplete = function():void {
				hpBar.x = x;
				hpBar.y = y;
				game.FloorLayer.addChild(hpBar);
				that.addEventListener(Event.ENTER_FRAME, update);
			};
			Starling.juggler.add(fadeTween);
		}
		
		private function updateSkilledEffect(e:EnterFrameEvent):void {
			skilledEffect.x = x;
			skilledEffect.y = y;
		}
		
		public function doFadeOut():void {
			var that:CharacterEntity = this;
			that.enemyPlayerEnt.Kills += 1;
			game.FloorLayer.removeChild(hpBar, true);
			that.removeEventListener(Event.ENTER_FRAME, update);
			
			movieVector[currentState].stop();
			alpha = 1;
			if (fadeTween != null) {
				Starling.juggler.remove(fadeTween);
				fadeTween = null;
			}
			
			// Add smoke effect
			var effect:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures("SmokeEffect_"));
			game.EffectLayer.pushEffect(effect, x, y - effect.height / 2, true);
			
			fadeTween = new Tween(this, 0.5);
			fadeTween.fadeTo(0);
			fadeTween.onComplete = function():void {
				destroy();
			};
			Starling.juggler.add(fadeTween);
		}
		
		public override function destroy():void {
			super.destroy();
			if (isSkill) {
				removeEventListener(EnterFrameEvent.ENTER_FRAME, updateSkilledEffect);
				game.FloorLayer.removeChild(skilledEffect, true);
			}
			if (hurtTimer != null && hurtTimer.running) {
				hurtTimer.stop();
				hurtTimer = null;
			}
			Starling.juggler.remove(movieVector[currentState]);
			for (var i:int = 0; i < movieVector.length; ++i) {
				movieVector[i].dispose();
			}
			removeEventListeners(EnterFrameEvent.ENTER_FRAME);
			movieVector.splice(0, movieVector.length);
			removeChildren(0, -1, true);
			game.RemoveCharacterFromList(this);
			removeFromParent(true);
			delete this;
		}
		
		public function update(e:Event):void
		{
			var timeDiff:int = getTimer() - lastTime;
			if (curHP <= 0) {
				// Clear
				Starling.juggler.remove(moveTween);
				currentEnemy = null;
				doFadeOut();
				return;
			}
			hpBar.x = x;
			hpBar.y = y;
			if (timeDiff >= 1000 && !isSimulation) {
				// Regen HP
				curHP += charInfo.HpRegen;
				if (curHP > maxHP) {
					curHP = maxHP;
				}
			}
			if (!isPause && !isSimulation) {
				if (currentEnemy == null) {
					// Checking for enemy
					game.FindForEnemy(this);
					if (currentEnemy == null) {
						if (setCurrentDirectionFromXY(currentTarget.x, currentTarget.y)) {
							CurrentState = STATE_RUN_FRONT + currentDirection;
							if (moveTween == null) {
								CurrentTarget = currentTarget;
							}
						} else {
							// get new point
							if (waypoint_index - 1 >= 0 && waypoint_index + 1 < waypoint.length) {
								waypoint_index += dir_waypoint;
								CurrentTarget = waypoint[waypoint_index];
							} else {
								// Die
								CurrentHP = 0;
							}
							/*
							if (waypoint.length > 0) {
								waypoint.pop();
								if (waypoint.length > 0)
									CurrentTarget = waypoint[waypoint.length - 1];
							} else {
								// attacking enemy base
								CurrentState = STATE_IDLE_FRONT + currentDirection;
							}
							*/
						}
					} else {
						if (moveTween != null) {
							Starling.juggler.remove(moveTween);
							moveTween = null;
						}
					}
				} else {
					var attackTimeDiff:int = getTimer() - lastAttackTime;
					if (moveTween != null) {
						Starling.juggler.remove(moveTween);
						moveTween = null;
					}
					if (currentEnemy.CurrentHP <= 0) {
						currentEnemy.CurrentEnemy = null;
						currentEnemy = null;
						return;
					}
					setCurrentDirectionFromXY(currentEnemy.x, currentEnemy.y);
					if (CurrentState >= STATE_ATTACK_FRONT && CurrentState <= STATE_ATTACK_RIGHT) {
						// If attack animation end
						if (movieVector[currentState].isComplete) {
							// Take damage to enemy
							Attacking(currentEnemy);
							if (currentEnemy is PlayerEntity) {
								// Attack the base then die
								CurrentHP = 0;
							}
						}
					}
					if (attackTimeDiff >= CharacterInfo.AtkSpd) {
						// Start attack animation
						CurrentState = STATE_ATTACK_FRONT + currentDirection;
						lastAttackTime += attackTimeDiff;
					} else {
						// Idle before attack
						if (movieVector[currentState].isComplete)
							CurrentState = STATE_IDLE_FRONT + currentDirection;
					}
				}
			}
			lastTime += timeDiff;
		}
		
		private function setCurrentDirectionFromXY(tox:int, toy:int):Boolean {
			// Attack the enemy
			if (Math.abs(tox - x) > 0) {
				// Move left / right
				if (tox > x) {
					// right
					this.currentDirection = DIRECTION_RIGHT;
				} else {
					// left
					this.currentDirection = DIRECTION_LEFT;
				}
				return true;
			} else if (Math.abs(toy - y) > 0) {
				// Move up / Down
				if (toy > y) {
					// down
					this.currentDirection = DIRECTION_DOWN;
				} else {
					// up
					this.currentDirection = DIRECTION_UP;
				}
				return true;
			}
			return false;
		}
		
		public function isInSamePath(target:CharacterEntity):Boolean {
			if ((this.currentDirection == DIRECTION_UP || this.currentDirection == DIRECTION_DOWN)
				&& (target.CurrentDirection == DIRECTION_UP || target.CurrentDirection == DIRECTION_DOWN)
				&& Math.abs(x - target.x) <= 0)
			{
				return true;
			}
			if ((this.currentDirection == DIRECTION_LEFT || this.currentDirection == DIRECTION_RIGHT)
				&& (target.CurrentDirection == DIRECTION_LEFT || target.CurrentDirection == DIRECTION_RIGHT)
				&& Math.abs(y - target.y) <= 0) 
			{
				return true;
			}
			return false;
		}
		
		public override function Attacked(from:Entity):Vector.<String> {
			var damageInfo:Vector.<String> = null; 
			if (!isSimulation) {
				damageInfo = super.Attacked(from);
				appendDamage(damageInfo, from);
			}
			if (hurtTimer != null && hurtTimer.running) {
				hurtTimer.stop();
				hurtTimer = null;
			}
			isHurt = true;
			if (movieVector.length > 0 && currentState > CharacterEntity.STATE_NONE)
				movieVector[currentState].color = 0xff0000;
			hurtTimer = new Timer(500, 1);
			hurtTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
				isHurt = false;
				if (movieVector.length > 0 && currentState > CharacterEntity.STATE_NONE)
					movieVector[currentState].color = 0xffffff;
			});
			hurtTimer.start();
			return damageInfo;
		}
		
		public override function appendDamage(damageInfo:Vector.<String>, from:Entity):void {
			//var effectTexture:String = from.CharacterInfo.AtkType == 1 ? "DamageEffect_" : "DamageEffectMagic_";
			//var effect:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures(effectTexture));
			//game.EffectLayer.pushEffect(effect, x, y - effect.height / 2, true);
			if (damageInfo[0] == "block") {
				game.EffectLayer.pushDamage("Block", 0xeeeeee, x, y - 80);
			}
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
		
		public override function Pause(pauseTime:Number):void {
			super.Pause(pauseTime);
			CurrentState = CharacterEntity.STATE_IDLE_FRONT + currentDirection;
			Starling.juggler.remove(moveTween);
			moveTween = null;
		}
		
		public override function MoveTo(value:Point):void {
			var timeDiff:int = getTimer() - clientLastMoveTime;
			super.MoveTo(value);
			var distance:Number = Math.sqrt(Math.pow(x - value.x, 2) + Math.pow(y - value.y, 2));
			var speed:Number = charInfo.MoveSpd;
			var time:Number = distance / speed;
			if (game.GameMode == GameModes.MULTIPLAYER_JOIN) {
				//speed *= (1 + (timeDiff / 1000));
				time -= (timeDiff / 1000);
			}
			if (moveTween != null) {
				Starling.juggler.remove(moveTween);
				moveTween = null;
			}
			moveTween = new Tween(this, time);
			moveTween.moveTo(value.x, value.y);
			Starling.juggler.add(moveTween);
			clientLastMoveTime += timeDiff;
		}
		
		// Properties
		public override function set CurrentTarget(value:Point):void {
			super.CurrentTarget = value;
			if (!isSimulation) {
				MoveTo(currentTarget);
			}
		}
		
		public override function set CurrentState(value:int):void {
			if (value != currentState || movieVector[currentState].isComplete)
			{
				if (currentState != STATE_NONE) {
					removeChild(movieVector[currentState]);
					Starling.juggler.remove(movieVector[currentState]);
				}
 				
				super.CurrentState = value;
				movieVector[currentState].currentFrame = 0;
				
				if (isHurt)
					movieVector[currentState].color = 0xff0000;
				else
					movieVector[currentState].color = 0xffffff;
					
				addChild(movieVector[currentState]);
				Starling.juggler.add(movieVector[currentState]);										
			}
		}
		
		public function get Player():PlayerEntity {
			return playerEnt;
		}
		
		public function get Enemy():PlayerEntity {
			return enemyPlayerEnt;
		}
		
		public function get isReachedToBase():Boolean {
			return waypoint.length <= 0;
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
		public function get IsPause():Boolean {
			return isPause;
		}
		public function set IsPause(value:Boolean):void {
			isPause = value;
		}
	}
}