package character 
{
	import flash.geom.Point;
	import gameplay.Game;
	import player.PlayerEntity;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class SkilledKnightCharacterEntity extends BaseSkilledCharacterEntity
	{
		public static const ID_RESOLUTION:int = 1;
		public static const ID_CHARGE:int = 2;
		public static const ID_IRON_SKIN:int = 3;
		public function SkilledKnightCharacterEntity(game:Game, id:int, charInfo:BaseCharacterInformation, playerEnt:PlayerEntity, enemyPlayerEnt:PlayerEntity, waypoint:Array, dir_waypoint:int, spawnpoint:Point, isSimulation:Boolean) 
		{
			super(game, id, charInfo, playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
			if (currentSkillId == ID_RESOLUTION) {
				var buff:EffectBuff = new EffectBuff(EffectBuff.ID_RESOLUTION);
				addBuff(buff, game.EffectLayer);
			}
		}
		
		public override function Attacking(to:Entity):void {
			super.Attacking(to);
		}
		
		public override function Attacked(from:Entity):Vector.<String> {
			var rate:Number = Helper.randomRange(1, 100);
			var dmgInfo:Vector.<String> = new Vector.<String>();
			dmgInfo.length = 2;
			if (currentSkillId == ID_RESOLUTION) {
				if (rate < 50) {
					dmgInfo[0] = "block";
					dmgInfo[1] = "0";
				}
			}
			if (dmgInfo[0] != "block") {
				dmgInfo = super.Attacked(from);
			}
			return dmgInfo;
		}
	}

}