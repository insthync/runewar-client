package character 
{
	import flash.geom.Point;
	import gameplay.Game;
	import player.PlayerEntity;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class SkilledMageCharacterEntity extends BaseSkilledCharacterEntity
	{
		public static const ID_MALEDICTION:int = 1;
		public static const ID_SWARM_WASP:int = 2;
		public static const ID_BUFFALO_ARROW:int = 3;
		public function SkilledMageCharacterEntity(game:Game, id:int, charInfo:BaseCharacterInformation, playerEnt:PlayerEntity, enemyPlayerEnt:PlayerEntity, waypoint:Array, dir_waypoint:int, spawnpoint:Point, isSimulation:Boolean) 
		{
			super(game, id, charInfo, playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
		}
		
		public override function Attacking(to:Entity):void {
			if (currentSkillId == ID_MALEDICTION) {
				var curse:EffectCurse = new EffectCurse(EffectCurse.ID_MALEDICTION, 5, 1000, 25);
				to.addCurse(curse, game.EffectLayer);
			}
			super.Attacking(to);
		}
	}

}