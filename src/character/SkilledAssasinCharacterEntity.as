package character 
{
	import assets.EffectsTexturesHelper;
	import flash.geom.Point;
	import gameplay.Game;
	import player.PlayerEntity;
	import starling.display.MovieClip;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class SkilledAssasinCharacterEntity extends BaseSkilledCharacterEntity
	{
		public static const ID_BASH:int = 1;
		public static const ID_CRUSHING_FIST:int = 2;
		public static const ID_SHOCK_ROAR:int = 3;
		public function SkilledAssasinCharacterEntity(game:Game, id:int, charInfo:BaseCharacterInformation, playerEnt:PlayerEntity, enemyPlayerEnt:PlayerEntity, waypoint:Array, dir_waypoint:int, spawnpoint:Point, isSimulation:Boolean) 
		{
			super(game, id, charInfo, playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
			if (currentSkillId == ID_BASH) {
				var buff:EffectBuff = new EffectBuff(EffectBuff.ID_BASH);
				addBuff(buff, game.EffectLayer);
			}
		}
		
		public override function Attacking(to:Entity):void {
			if (currentSkillId == ID_BASH) {
				if (!(to is PlayerEntity)) {
					var effect:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures("Assasin_Skill01_"));
					game.EffectLayer.pushEffect(effect, to.x, to.y - effect.height / 2, true);
				}
			}
			super.Attacking(to);
		}
	}

}