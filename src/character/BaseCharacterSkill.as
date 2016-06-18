package character 
{
	import assets.CharacterTextureHelper;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	public class BaseCharacterSkill
	{
		// General information
		protected var name:String;
		protected var description:String;
		protected var iconTexture:Texture;
		protected var skillid:int;
		protected var charindex:int;
		// Loading state
		protected var loadedFromXML:Boolean;
		// Appending display object list
		protected var appendingList:Array;
		public function BaseCharacterSkill() 
		{
			name = "";
			description = "";
			appendingList = new Array();
			loadedFromXML = false;
		}
		
		public function LoadCharacterData(skillid:int, charindex:int):void {
			this.skillid = skillid;
			this.charindex = charindex;
			var list_path:String = CharacterTextureHelper.list_skill_path[charindex];
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.load(new URLRequest(list_path));
			urlLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var xmlData:XML = new XML(e.target.data);
				var path:String = xmlData.skill.(@id == skillid).@path;
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
			
			if (CharacterTextureHelper.list_skills_icon_textures[charindex] == null)
				CharacterTextureHelper.list_skills_icon_textures[charindex] = new Dictionary();
			if (CharacterTextureHelper.list_skills_icon_textures[charindex][skillid] == null) {
				var icon_path:String = xmlData.icon[0];
				if (icon_path != null && icon_path.length > 0) {
					var iconTextureLoad:Loader = new Loader();
					iconTextureLoad.load(new URLRequest(Main.serviceurl + icon_path));
					iconTextureLoad.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
						var bitmapData:BitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;
						iconTexture = Texture.fromBitmapData(bitmapData, false);
						bitmapData.dispose();
						CharacterTextureHelper.list_skills_icon_textures[charindex][skillid] = iconTexture;
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
					CharacterTextureHelper.list_skills_icon_textures[charindex][skillid] = iconTexture;
				}
			} else {
				iconTexture = CharacterTextureHelper.list_skills_icon_textures[charindex][skillid];
			}
			loadedFromXML = true;
		}
		
		public function appendIconTo(place:DisplayObjectContainer):void {
			if (iconTexture != null) {
				place.removeChildren(0, -1, true);
				place.addChild(new Image(iconTexture));
			} else {
				appendingList.push(place);
			}
		}
		
		public function get LoadedFromXML():Boolean {
			return loadedFromXML;
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
		public function get SkillID():int {
			return skillid;
		}
		public function set SkillID(value:int):void {
			skillid = value;
		}
		public function get CharIndex():int {
			return charindex;
		}
		public function set CharIndex(value:int):void {
			charindex = value;
		}
	}
}