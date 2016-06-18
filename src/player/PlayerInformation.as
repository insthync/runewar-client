package player 
{
	import assets.LobbyTexturesHelper;
	import character.BaseCharacterInformation;
	import character.BaseCharacterSkill;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import flash.utils.getTimer;
	public class PlayerInformation
	{
		private var availableCharacters:Vector.<BaseCharacterInformation>;
		private var availableSkills:Vector.<BaseCharacterSkill>;
		private var userid:int;
		private var name:String;
		private var level:int;
		private var exp:int;
		private var gold:int;
		private var crystal:int;
		private var heart:int;
		private var date_heart_refill:Number;
		private var profileImageTexture:Texture;
		private var used_achievement:int;
		// Appending display object list
		protected var appendingList:Array;
		// Loading mode
		public static const MODE_LOBBY:int = 0;
		public static const MODE_GAME:int = 1;
		protected var mode:int;
		// Online Status
		public static const ONLINE_OFFLINE:int = 0;
		public static const ONLINE_ONLINE:int = 1;
		public static const ONLINE_BUSY:int = 2;
		private var onlineStatus:int;
		public function PlayerInformation(mode:int, info:Object) {
			var i:int = 0;
			this.mode = mode;
			this.onlineStatus = PlayerInformation.ONLINE_OFFLINE;
			availableCharacters = new Vector.<BaseCharacterInformation>();
			availableSkills = new Vector.<BaseCharacterSkill>();
			appendingList = new Array();
			userid = info.userid;
			if (info.name != null) {
				name = info.name;
			} else {
				name = "AI";
			}
			if (info.level != null) {
				level = info.level;
			} else {
				level = 1;
			}
			if (info.exp != null) {
				exp = info.exp;
			} else {
				exp = 0;
			}
			if (info.gold != null) {
				gold = info.gold;
			} else {
				gold = 0;
			}
			if (info.crystal != null) {
				crystal = info.crystal;
			} else {
				crystal = 0;
			}
			if (info.heartnum != null) {
				heart = info.heartnum;
			} else {
				heart = 0;
			}
			if (info.date_heart_refill != null) {
				date_heart_refill = (info.date_heart_refill) * 1000;
			} else {
				date_heart_refill = (new Date()).getTime();
			}
			
			if (info.profile_image != null && info.profile_image.length > 0) {
				// Append a profile image
				var save_key:String = "" + userid;
				if (LobbyTexturesHelper.list_profile_textures[save_key] == null) {
					var urlLoader:Loader = new Loader();
					urlLoader.load(new URLRequest(info.profile_image), Main.loaderContext);
					urlLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
						var bitmapData:BitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;
						profileImageTexture = Texture.fromBitmapData(bitmapData, false);
						bitmapData.dispose();
						LobbyTexturesHelper.list_profile_textures[save_key] = profileImageTexture;
						// Append icon to appending list
						for (var c:int = 0; c < appendingList.length; ++c) {
							var place:DisplayObjectContainer = appendingList[c] as DisplayObjectContainer;
							place.removeChildren(0, -1, true);
							place.addChild(new Image(profileImageTexture));
						}
						appendingList.splice(0);
					});
				} else {
					profileImageTexture = LobbyTexturesHelper.list_profile_textures[save_key];
					
					// Append icon to appending list
					for (var c:int = 0; c < appendingList.length; ++c) {
						var place:DisplayObjectContainer = appendingList[c] as DisplayObjectContainer;
						place.removeChildren(0, -1, true);
						place.addChild(new Image(profileImageTexture));
					}
					appendingList.splice(0);
				}
			} else {
				profileImageTexture = Texture.empty();
			}
			if (info.usage_avatar != null && info.usage_avatar.length == 6) {
				// Append available characters
				availableCharacters.length = 6;
				for (i = 0; i < availableCharacters.length; ++i) {
					var charInfo:BaseCharacterInformation = new BaseCharacterInformation(mode);
					charInfo.LoadCharacterData(info.usage_avatar[i], i);
					availableCharacters[i] = charInfo;
				}
			}
			if (info.usage_skill != null && info.usage_skill.length == 6) {
				// Append available skills
				availableSkills.length = 6;
				for (i = 0; i < availableSkills.length; ++i) {
					var charSk:BaseCharacterSkill = new BaseCharacterSkill();
					charSk.LoadCharacterData(info.usage_skill[i], i);
					availableSkills[i] = charSk;
				}
				
			}
			if (info.used_achievement != null) {
				used_achievement = info.used_achievement;
			} else {
				used_achievement = 0;
			}
		}
		public function updateAvailableCharacter(charindex:int, avatarid:int):void {
			var charInfo:BaseCharacterInformation = new BaseCharacterInformation(mode);
			charInfo.LoadCharacterData(avatarid, charindex);
			availableCharacters[charindex] = charInfo;
		}
		public function updateAvailableSkill(charindex:int, skillid:int):void {
			var charSk:BaseCharacterSkill = new BaseCharacterSkill();
			charSk.LoadCharacterData(skillid, charindex);
			availableSkills[charindex] = charSk;
		}
		public function appendImageTo(place:DisplayObjectContainer):void {
			if (profileImageTexture != null) {
				place.removeChildren(0, -1, true);
				place.addChild(new Image(profileImageTexture));
			} else {
				appendingList.push(place);
			}
		}
		public function get AvailableCharacters():Vector.<BaseCharacterInformation> {
			return availableCharacters;
		}
		public function get AvailableSkills():Vector.<BaseCharacterSkill> {
			return availableSkills;
		}
		public function get Loaded():Boolean {
			var i:int = 0;
			for (i = 0; i < availableCharacters.length; ++i) {
				if (availableCharacters[i] == null || !availableCharacters[i].LoadedFromXML || !availableCharacters[i].AnimReady || availableCharacters[i].IconTexture == null || availableCharacters[i].StatusTexture == null)
					return false;
			}
			for (i = 0; i < availableSkills.length; ++i) {
				if (availableSkills[i] == null || !availableSkills[i].LoadedFromXML || availableSkills[i].IconTexture == null)
					return false;
			}
			return true;
		}
		public function get UserID():int {
			return userid;
		}
		public function get Name():String {
			return name;
		}
		public function set Name(value:String):void {
			name = value;
		}
		public function get Level():int {
			return level;
		}
		public function set Level(value:int):void {
			level = value;
		}
		public function get Exp():int {
			return exp;
		}
		public function set Exp(value:int):void {
			exp = value;
		}
		public function get Gold():int {
			return gold;
		}
		public function set Gold(value:int):void {
			gold = value;
		}
		public function get Crystal():int {
			return crystal;
		}
		public function set Crystal(value:int):void {
			crystal = value;
		}
		public function get Heart():int {
			return heart;
		}
		public function set Heart(value:int):void {
			heart = value;
		}
		public function get ProfileImageTexture():Texture {
			return profileImageTexture;
		}
		public function set ProfileImageTexture(value:Texture):void {
			profileImageTexture = value;
		}
		public function get UsedAchievement():int {
			return used_achievement;
		}
		public function set UsedAchievement(value:int):void {
			used_achievement = value;
		}
		public function get OnlineStatus():int {
			return onlineStatus;
		}
		public function set OnlineStatus(value:int):void {
			onlineStatus = value;
		}
	}
}