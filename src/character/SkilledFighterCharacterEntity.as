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
	public class SkilledFighterCharacterEntity extends BaseSkilledCharacterEntity
	{
		public static const ID_DOUBLE_ATTACK:int = 1;
		public static const ID_INCREASE_SPEED:int = 2;
		public static const ID_SNEAK_ATTACK:int = 3;
		public function SkilledFighterCharacterEntity(game:Game, id:int, charInfo:BaseCharacterInformation, playerEnt:PlayerEntity, enemyPlayerEnt:PlayerEntity, waypoint:Array, dir_waypoint:int, spawnpoint:Point, isSimulation:Boolean) 
		{
			super(game, id, charInfo, playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
		}
		
		public override function Attacking(to:Entity):void {
			var rate:Number = Helper.randomRange(1, 100);
			if (currentSkillId == ID_DOUBLE_ATTACK) {
				if (rate < 50) {
					var effect:MovieClip = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures("Fighter_Skill01_"));
					game.EffectLayer.pushEffect(effect, to.x, to.y - effect.height / 2, true);
					super.Attacking(to);
				}
			}
			super.Attacking(to);
		}
	}

}