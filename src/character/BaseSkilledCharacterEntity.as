package character 
{
	import flash.geom.Point;
	import gameplay.Game;
	import player.PlayerEntity;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class BaseSkilledCharacterEntity extends CharacterEntity
	{
		protected var currentSkillId:int;
		public function BaseSkilledCharacterEntity(game:Game, id:int, charInfo:BaseCharacterInformation, playerInfo:PlayerEntity, enemyPlayerInfo:PlayerEntity, waypoint:Array, dir_waypoint:int, spawnpoint:Point, isSimulation:Boolean) 
		{
			super(game, id, charInfo, playerInfo, enemyPlayerInfo, waypoint, dir_waypoint, spawnpoint, true, isSimulation);
			currentSkillId = playerInfo.AvailableSkills[charInfo.CharIndex].SkillID;
		}
		
	}

}