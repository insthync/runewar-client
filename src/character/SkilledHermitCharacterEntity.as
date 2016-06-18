package character 
{
	import flash.geom.Point;
	import gameplay.Game;
	import player.PlayerEntity;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class SkilledHermitCharacterEntity extends BaseSkilledCharacterEntity
	{
		public static const ID_BLESSING:int = 1;
		public static const ID_HEAL:int = 2;
		public static const ID_FORCE_FIELD:int = 3;
		public function SkilledHermitCharacterEntity(game:Game, id:int, charInfo:BaseCharacterInformation, playerEnt:PlayerEntity, enemyPlayerEnt:PlayerEntity, waypoint:Array, dir_waypoint:int, spawnpoint:Point, isSimulation:Boolean) 
		{
			super(game, id, charInfo, playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
			if (currentSkillId == ID_BLESSING) {
				game.addTeamBuff(playerEnt, EffectBuff.ID_BLESSING);
			}
		}
		
		public override function destroy():void {
			game.delTeamBuff(playerEnt, currentSkillId);
			super.destroy();
		}
		
		public override function Attacking(to:Entity):void {
			super.Attacking(to);
		}
	}

}