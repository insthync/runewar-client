package  
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class GlobalVariables 
	{
		public static const screenWidth:int = 1200;
		public static const screenHeight:int = 800;
		public static var player_exp:Array;
		public static var use_cannon:Boolean = true;
		public static const AIDelay:Array = [
			3250, 3200, 3150, 3100, 3050, // 5
			3000, 2900, 2800, 2700, 2600, // 10
			2500, 2400, 2300, 2200, 2100, // 15
			2050, 2000, 1950, 1900, 1850, // 20
			1800, 1750, 1700, 1650, 1600, // 25
			1550, 1500, 1450, 1400, 1350, // 30
			1325, 1300, 1250, 1200, 1150, // 35
			1100, 1050, 1000, 950, 900  // 40
		];
		public static var playerCurrentLevel:int = 0;
		public static var AchievementsIndex:Dictionary = new Dictionary();
		AchievementsIndex["" + 0] = "Beginnercertification";
		AchievementsIndex["" + 100051] = "Beginnercertification";
		AchievementsIndex["" + 100052] = "PlayerCertification";
		AchievementsIndex["" + 100053] = "DefenderLv1";
		AchievementsIndex["" + 100054] = "DefenderLv2";
		AchievementsIndex["" + 100055] = "DefenderLv3";
		AchievementsIndex["" + 100056] = "DefenderLv4";
		AchievementsIndex["" + 100057] = "KillerLv1";
		AchievementsIndex["" + 100058] = "KillerLv2";
		AchievementsIndex["" + 100059] = "KillerLv3";
		AchievementsIndex["" + 100060] = "KillerLv4";
		AchievementsIndex["" + 100067] = "GoldSpenderLv1";
		AchievementsIndex["" + 100068] = "GoldSpenderLv2";
		AchievementsIndex["" + 100069] = "GoldSpenderLv3";
		AchievementsIndex["" + 100070] = "GoldSpenderLv4";
		AchievementsIndex["" + 100071] = "CrystalSpenderLv1";
		AchievementsIndex["" + 100072] = "CrystalSpenderLv2";
		AchievementsIndex["" + 100073] = "CrystalSpenderLv3";
		AchievementsIndex["" + 100074] = "CrystalSpenderLv4";
	}

}