package character 
{
	import flash.geom.Point;
	import gameplay.Game;
	import player.PlayerEntity;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class SkilledArcherCharacterEntity extends BaseSkilledCharacterEntity
	{
		public static const ID_EAGLE_EYE:int = 1;
		public static const ID_SHARP_SHOOTER:int = 2;
		public static const ID_SHOWER_ARROW:int = 3;
		public function SkilledArcherCharacterEntity(game:Game, id:int, charInfo:BaseCharacterInformation, playerEnt:PlayerEntity, enemyPlayerEnt:PlayerEntity, waypoint:Array, dir_waypoint:int, spawnpoint:Point, isSimulation:Boolean) 
		{
			super(game, id, charInfo, playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
			if (currentSkillId == ID_EAGLE_EYE) {
				var buff:EffectBuff = new EffectBuff(EffectBuff.ID_EAGLE_EYE);
				addBuff(buff, game.EffectLayer);
			}
		}
		
		public override function Attacking(to:Entity):void {
			super.Attacking(to);
		}
	}

}