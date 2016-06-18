package character 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import assets.CharacterTextureHelper;
	public class BaseCharacterInformation 
	{
		// General information
		protected var name:String;
		protected var description:String;
		protected var iconTexture:Texture;
		protected var statusTexture:Texture;
		protected var avatarid:int;
		protected var charindex:int;
		// Ability
		protected var a_str:int;
		protected var a_agi:int;
		protected var a_int:int;
		protected var a_wil:int;
		protected var a_luk:int;
		protected var atkrange:Number;
		protected var atktype:int;	// 0 = physical damage, 1 = magical damage
		// Additional ability
		protected var add_str:int;
		protected var add_agi:int;
		protected var add_int:int;
		protected var add_wil:int;
		protected var add_luk:int;
		protected var add_atkrange:Number;
		
		protected var add_min_patk:int;
		protected var add_max_patk:int;
		protected var add_pdef:int;
		protected var add_min_matk:int;
		protected var add_max_matk:int;
		protected var add_mdef:int;
		protected var add_movespd:Number;
		protected var add_atkspd:Number;
		protected var add_dodgerate:Number;
		protected var add_criatk:int;
		protected var add_crirate:Number;
		protected var add_hpregen:int;
		protected var add_hp:int;
		// Offset
		protected var offset_floor:Number;
		protected var offset_effect:Number;
		protected var offset_damage:Number;
		// Animation
		protected var animation:Dictionary;
		// Loading state
		protected var loadedFromXML:Boolean;
		// Appending display object list
		protected var appendingList:Array;
		protected var statusAppendingList:Array;
		// Loading mode
		public static const MODE_LOBBY:int = 0;
		public static const MODE_GAME:int = 1;
		protected var mode:int;
		
		public function BaseCharacterInformation(mode:int, name:String = "", description:String = "",
			a_str:int = 1, a_agi:int = 1, a_int:int = 1, a_wil:int = 1, atkrange:Number = 100.0, atktype:int = 0,
			animation:Dictionary = null, loadedFromXML:Boolean = false
		) 
		{
			this.mode = mode;
			this.name = name;
			this.description = description;
			this.a_str = a_str;
			this.a_agi = a_agi;
			this.a_int = a_int;
			this.a_wil = a_wil;
			this.a_luk = a_luk;
			this.atkrange = atkrange;
			this.atktype = atktype;
			
			add_str = 0;
			add_agi = 0;
			add_int = 0;
			add_wil = 0;
			add_luk = 0;
			add_atkrange = 0;
			
			add_min_patk = 0;
			add_max_patk = 0;
			add_pdef = 0;
			add_min_matk = 0;
			add_max_matk = 0;
			add_mdef = 0;
			add_movespd = 0;
			add_atkspd = 0;
			add_dodgerate = 0;
			add_criatk = 0;
			add_crirate = 0;
			add_hpregen = 0;
			add_hp = 0;
			
			this.animation = animation == null ? new Dictionary() : animation;
			this.loadedFromXML = loadedFromXML;
			
			this.appendingList = new Array();
			this.statusAppendingList = new Array();
		}
		
		public function Clone():BaseCharacterInformation {
			return new BaseCharacterInformation(mode, name, description, a_str, a_agi, a_int, a_wil, atkrange, atktype, animation, loadedFromXML);
		}
		
		public function InsertAnimationData(key:int, textureAtlas:TextureAtlas, fps:Number):void {
			if (animation[key] == null)
				animation[key] = new Array(textureAtlas, fps);
			if (AnimReady) {
				// Put to helper
				if (CharacterTextureHelper.list_avatars_textures[charindex] == null)
					CharacterTextureHelper.list_avatars_textures[charindex] = new Dictionary();
				CharacterTextureHelper.list_avatars_textures[charindex][avatarid] = animation;
			}
		}
		
		public function LoadCharacterData(avatarid:int, charindex:int):void {
			this.avatarid = avatarid;
			this.charindex = charindex;
			this.animation = new Dictionary();
			var list_path:String = CharacterTextureHelper.list_avatars_path[charindex];
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.load(new URLRequest(list_path));
			urlLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var xmlData:XML = new XML(e.target.data);
				var path:String = xmlData.avatar.(@id == avatarid).@path;
				LoadDataFromXML(Main.serviceurl + path);
				urlLoader.close();
			});
		}
		
		private function LoadDataFromXML(path:String):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.load(new URLRequest(path));
			urlLoader.addEventListener(Event.COMPLETE, ReadDataFromXML);
		}
		
		private function ReadDataFromXML(e:Event):void {
			var xmlData:XML = new XML(e.target.data);
			
			this.name = xmlData.avatar[0];
			this.description = xmlData.description[0];
			
			this.a_str = xmlData.ability[0].@strength;
			this.a_agi = xmlData.ability[0].@agility;
			this.a_int = xmlData.ability[0].@intelligent;
			this.a_wil = xmlData.ability[0].@will;
			this.a_luk = xmlData.ability[0].@luck;
			this.atkrange = xmlData.ability[0].@atkrange;
			this.atktype = (xmlData.ability[0].@atktype == "mag") ? 1 : 0;
			
			this.offset_floor = xmlData.offset[0].@floor;
			this.offset_effect = xmlData.offset[0].@effect;
			this.offset_damage = xmlData.offset[0].@damage;
			
			if (CharacterTextureHelper.list_avatars_textures[charindex] == null)
				CharacterTextureHelper.list_avatars_textures[charindex] = new Dictionary();
			if (CharacterTextureHelper.list_avatars_textures[charindex][avatarid] == null) {
				for (var i:int = 0; i < xmlData.animation.length(); ++i) {
					var anim_data:XML = xmlData.animation[i];
					var key:int = anim_data.@key;
					var path_atlas:String = anim_data.@atlas;
					var path_texture:String = anim_data.@texture;
					var fps:Number = anim_data.@fps;
					if (mode == MODE_LOBBY && key == CharacterTextureHelper.ANIM_LOBBY) {
						LoadAnimationFromXML(key, path_atlas, path_texture, fps);
					}
					if (mode != MODE_LOBBY && key != CharacterTextureHelper.ANIM_LOBBY) {
						LoadAnimationFromXML(key, path_atlas, path_texture, fps);
					}
				}
			} else {
				animation = CharacterTextureHelper.list_avatars_textures[charindex][avatarid];
			}
			
			if (mode == MODE_LOBBY) {
				if (CharacterTextureHelper.list_avatars_icon_textures[charindex] == null)
					CharacterTextureHelper.list_avatars_icon_textures[charindex] = new Dictionary();
				if (CharacterTextureHelper.list_avatars_icon_textures[charindex][avatarid] == null) {
					var icon_path:String = xmlData.icon[0];
					if (icon_path != null && icon_path.length > 0) {
						var iconTextureLoad:Loader = new Loader();
						iconTextureLoad.load(new URLRequest(Main.serviceurl + icon_path), Main.loaderContext);
						iconTextureLoad.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
							var bitmapData:BitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;
							iconTexture = Texture.fromBitmapData(bitmapData, false);
							bitmapData.dispose();
							CharacterTextureHelper.list_avatars_icon_textures[charindex][avatarid] = iconTexture;
							// Append icon to appending list
							for (var c:int = 0; c < appendingList.length; ++c) {
								var place:DisplayObjectContainer = appendingList[c] as DisplayObjectContainer;
								place.removeChildren(0, -1, true);
								place.addChild(new Image(iconTexture));
							}
							appendingList.splice(0);
						});
					} else {
						iconTexture = Texture.empty(80, 80);
						CharacterTextureHelper.list_avatars_icon_textures[charindex][avatarid] = iconTexture;
					}
				} else {
					iconTexture = CharacterTextureHelper.list_avatars_icon_textures[charindex][avatarid];
				}
				if (CharacterTextureHelper.list_avatars_status_textures[charindex] == null)
					CharacterTextureHelper.list_avatars_status_textures[charindex] = new Dictionary();
				if (CharacterTextureHelper.list_avatars_status_textures[charindex][avatarid] == null) {
					var status_path:String = xmlData.status[0];
					if (status_path != null && status_path.length > 0) {
						var statusTextureLoad:Loader = new Loader();
						statusTextureLoad.load(new URLRequest(Main.serviceurl + status_path));
						statusTextureLoad.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
							var bitmapData:BitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;
							statusTexture = Texture.fromBitmapData(bitmapData, false);
							bitmapData.dispose();
							CharacterTextureHelper.list_avatars_status_textures[charindex][avatarid] = statusTexture;
							// Append icon to appending list
							for (var c:int = 0; c < statusAppendingList.length; ++c) {
								var place:DisplayObjectContainer = statusAppendingList[c] as DisplayObjectContainer;
								place.removeChildren(0, -1, true);
								place.addChild(new Image(statusTexture));
							}
							appendingList.splice(0);
						});
					} else {
						statusTexture = Texture.empty(80, 80);
						CharacterTextureHelper.list_avatars_status_textures[charindex][avatarid] = statusTexture;
					}
				} else {
					statusTexture = CharacterTextureHelper.list_avatars_status_textures[charindex][avatarid];
				}
			} else {
				iconTexture = Texture.empty(2, 2);
				statusTexture = Texture.empty(2, 2);
			}
			
			loadedFromXML = true;
		}
		
		private function LoadAnimationFromXML(key:int, path_atlas:String, path_texture:String, fps:Number):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.load(new URLRequest(Main.serviceurl + path_atlas));
			urlLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var atlas:XML = new XML(e.target.data);
				var textureLoad:Loader = new Loader();
				textureLoad.load(new URLRequest(Main.serviceurl + path_texture));
				textureLoad.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
					var bitmapData:BitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;
					var texture:Texture = Texture.fromBitmapData(bitmapData, false);
					bitmapData.dispose();
					InsertAnimationData(key, new TextureAtlas(texture, atlas), fps);
				});
			});
		}
		
		public function appendIconTo(place:DisplayObjectContainer):void {
			if (iconTexture != null) {
				place.removeChildren(0, -1, true);
				place.addChild(new Image(iconTexture));
			} else {
				appendingList.push(place);
			}
		}
		
		public function appendStatusTo(place:DisplayObjectContainer):void {
			if (statusTexture != null) {
				place.removeChildren(0, -1, true);
				place.addChild(new Image(statusTexture));
			} else {
				statusAppendingList.push(place);
			}
		}
		public function addExtraAbility(name:String, value:Number):void {
			name = name.toLowerCase();
			switch (name) {
				case "str":
					add_str += value;
					break;
				case "agi":
					add_agi += value;
					break;
				case "int":
					add_int += value;
					break;
				case "wil":
					add_wil += value;
					break;
				case "luk":
					add_luk += value;
					break;
				case "atkrange":
					add_atkrange += value;
					break;
				case "min_patk":
					add_min_patk += value;
					break;
				case "max_patk":
					add_max_patk += value;
					break;
				case "pdef":
					add_pdef += value;
					break;
				case "min_matk":
					add_min_matk += value;
					break;
				case "max_matk":
					add_max_matk += value;
					break;
				case "mdef":
					add_mdef += value;
					break;
				case "movespd":
					add_movespd += value;
					break;
				case "atkspd":
					add_atkspd += value;
					break;
				case "dodgerate":
					add_dodgerate += value;
					break;
				case "criatk":
					add_criatk += value;
					break;
				case "crirate":
					add_crirate += value;
					break;
				case "hpregen":
					add_hpregen += value;
					break;
				case "hp":
					add_hp += value;
					break;
			}
		}
		
		// STR
		public function get MinPAtk():int {
			return ((a_str + add_str) * 6) + add_min_patk;
		}
		
		public function get MaxPAtk():int {
			return ((a_str + add_str) * 8) + add_max_patk;
		}
		
		public function get PDef():int {
			return ((a_str + add_str) * 2) + add_pdef;
		}
		
		// INT
		public function get MinMAtk():int {
			return ((a_int + add_int) * 6) + add_min_matk;
		}
		
		public function get MaxMAtk():int {
			return ((a_int + add_int) * 9) + add_max_matk;
		}
		
		public function get MDef():int {
			return ((a_int + add_int) * 3) + add_mdef;
		}
		
		// AGI
		public function get MoveSpd():Number {
			return (200 + ((a_agi + add_agi) * 5)) + add_movespd;
		}
		
		public function get AtkSpd():Number {
			return ((2 / (a_agi + add_agi)) * 1000) + add_atkspd;
		}
		
		public function get DodgeRate():Number {
			return ((a_agi + add_agi) * 5) + add_dodgerate;
		}
		
		// LUK	
		public function get CriAtk():int {
			return ((a_luk + add_luk) * 10) + add_criatk;
		}
		
		public function get CriRate():Number {
			return ((a_luk + add_luk) * 5) + add_crirate;
		}
		
		// WIL
		public function get HpRegen():Number {
			return ((a_wil + add_wil) * 3) + add_hpregen;
		}
		
		public function get Hp():int {
			return (75 + ((a_wil + add_wil) * 20)) + add_hp;
		}
		
		// Another
		public function get AtkRange():Number {
			return atkrange + add_atkrange;
		}
		
		public function get AtkType():int {
			return atktype;
		}
		
		public function get OffsetFloor():Number {
			return offset_floor;
		}
		
		public function get OffsetEffect():Number {
			return offset_effect;
		}
		
		public function get OffsetDamage():Number {
			return offset_damage;
		}
		
		public function get RuneSpriteInfoName():String {
			return CharacterTextureHelper.runeTextureName[charindex];
		}
		
		public function get Animation():Dictionary {
			return animation;
		}
		public function get LoadedFromXML():Boolean {
			return loadedFromXML;
		}
		public function get AnimReady():Boolean {
			if (mode == MODE_LOBBY) {
				if (animation[CharacterTextureHelper.ANIM_LOBBY] != null)
				{
					return true;
				}
			} else {
				if (animation[CharacterTextureHelper.ANIM_IDLE] != null
					&& animation[CharacterTextureHelper.ANIM_RUN] != null
					&& animation[CharacterTextureHelper.ANIM_ATTACK] != null)
				{
					return true;
				}
			}
			return false;
		}
		// General Information
		public function get Name():String {
			return name;
		}
		public function set Name(value:String):void {
			name = value;
		}
		public function get Description():String {
			return description;
		}
		public function set Description(value:String):void {
			description = value
		}
		public function get IconTexture():Texture {
			return iconTexture;
		}
		public function set IconTexture(value:Texture):void {
			iconTexture = value;
		}
		public function get StatusTexture():Texture {
			return statusTexture;
		}
		public function set StatusTexture(value:Texture):void {
			statusTexture = value;
		}
		public function get AvatarID():int {
			return avatarid;
		}
		public function set AvatarID(value:int):void {
			avatarid = value;
		}
		public function get CharIndex():int {
			return charindex;
		}
		public function set CharIndex(value:int):void {
			charindex = value;
		}
	}

}