package gamelobby 
{
	import assets.CharacterTextureHelper;
	import assets.LobbyTexturesHelper;
	import character.BaseCharacterInformation;
	import character.BaseCharacterSkill;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import org.flashdevelop.utils.FlashConnect;
	import player.PlayerInformation;
	import scene.Scene;
	import service.LobbyService;
	import starling.animation.Tween;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UIStoreItem extends UIScene
	{
		private var item_id:int;
		private var usetype:int;
		private var data:Object;
		private var icon_container:Sprite;
		private var iconTexture:Texture;
		private var charindex:int;
		private var actionBuy:Sprite;
		private var actionUse:Sprite;
		private var actionUsed:Sprite;
		private var lobbyService:LobbyService;
		private var goldButton:Button;
		private var gemButton:Button;
		private var useButton:Button;
		private var store:UIStore;
		private var shopAtlas:TextureAtlas;
		public function UIStoreItem(atlas:TextureAtlas, shopAtlas:TextureAtlas, from:Scene, userInfo:PlayerInformation, charindex:int, store:UIStore, obj:Array) 
		{
			super(atlas, from, userInfo);
			this.shopAtlas = shopAtlas;
			this.charindex = charindex;
			this.store = store;
			this.usetype = obj[0];
			this.data = obj[1];
			this.item_id = data.id;
			this.lobbyService = new LobbyService(from.Manager);
		}
		
		protected override function InitEvironment():void {
			super.InitEvironment();
			
			var ShadowTex:Texture = shopAtlas.getTexture("Shop_Shadow");
			var gui_shadow:Image = new Image(ShadowTex);
			addChild(gui_shadow);
			
			icon_container = new Sprite();
			icon_container.width = 100;
			icon_container.height = 100;
			icon_container.x = 10;
			icon_container.y = 15;
			addChild(icon_container);
			
			var nameTF:TextField = new TextField(300, 45, data.name, "RWFont", 25, 0xffffff);
			nameTF.autoScale = true;
			nameTF.touchable = false;
			nameTF.vAlign = VAlign.TOP;
			nameTF.hAlign = HAlign.LEFT;
			//nameTF.border = true;
			nameTF.x = 120;
			nameTF.y = 8;
			addChild(nameTF);
			
			var descTF:TextField = new TextField(400, 70, data.description, "Verdana", 18, 0xffffff);
			descTF.autoScale = true;
			descTF.touchable = false;
			descTF.vAlign = VAlign.TOP;
			descTF.hAlign = HAlign.LEFT;
			//descTF.border = true;
			descTF.x = 120;
			descTF.y = 35;
			addChild(descTF);
			
			var IconMoneyTex:Texture = shopAtlas.getTexture("Icon_Money");
			var icon_money:Image = new Image(IconMoneyTex);
			icon_money.x = 120;
			icon_money.y = 75;
			addChild(icon_money);
			
			var IconGemTex:Texture = shopAtlas.getTexture("Icon_Gem");
			var icon_gem:Image = new Image(IconGemTex);
			icon_gem.x = 260;
			icon_gem.y = 75;
			addChild(icon_gem);
			
			var priceGoldTF:TextField = new TextField(90, 32, data.price_gold, "RWFont", 25, 0xffffff);
			priceGoldTF.autoScale = true;
			priceGoldTF.touchable = false;
			priceGoldTF.vAlign = VAlign.TOP;
			priceGoldTF.hAlign = HAlign.LEFT;
			//priceGoldTF.border = true;
			priceGoldTF.x = 160;
			priceGoldTF.y = 80;
			if (data.price_gold < 0) {
				priceGoldTF.text = "Can not be bought with gold";
			}
			if (data.price_gold == 0) {
				priceGoldTF.text = "Free";
			}
			addChild(priceGoldTF);
			
			var priceCrystalTF:TextField = new TextField(90, 32, data.price_crystal, "RWFont", 25, 0xffffff);
			priceCrystalTF.autoScale = true;
			priceCrystalTF.touchable = false;
			priceCrystalTF.vAlign = VAlign.TOP;
			priceCrystalTF.hAlign = HAlign.LEFT;
			//priceCrystalTF.border = true;
			priceCrystalTF.x = 300;
			priceCrystalTF.y = 80;
			if (data.price_crystal < 0) {
				priceCrystalTF.text = "Can not be bought with crystal";
			}
			if (data.price_crystal == 0) {
				priceCrystalTF.text = "Free";
			}
			addChild(priceCrystalTF);
			
			actionBuy = new Sprite();
			addChild(actionBuy);
			var goldBtnTexture:Texture = shopAtlas.getTexture("PriceGold");
			var gemBtnTexture:Texture = shopAtlas.getTexture("PriceGem");
			goldButton = new Button(goldBtnTexture);
			goldButton.addEventListener(Event.TRIGGERED, goldTriggered);
			actionBuy.addChild(goldButton);
			gemButton = new Button(gemBtnTexture);
			gemButton.addEventListener(Event.TRIGGERED, gemTriggered);
			gemButton.y = 52;
			actionBuy.addChild(gemButton);
			actionBuy.x = 515;
			actionBuy.y = 15;
			actionBuy.visible = false;
			
			actionUse = new Sprite();
			addChild(actionUse);
			var useBtnTexture:Texture = shopAtlas.getTexture("Skill_Use");
			useButton = new Button(useBtnTexture);
			useButton.addEventListener(Event.TRIGGERED, useTriggered);
			useButton.y = 26;
			actionUse.addChild(useButton);
			actionUse.x = 515;
			actionUse.y = 15;
			actionUse.visible = false;
			
			actionUsed = new Sprite();
			addChild(actionUsed);
			var itemActiveTexture:Texture = shopAtlas.getTexture("Item_Active");
			var itemActiveImage:Image = new Image(itemActiveTexture);
			actionUsed.addChild(itemActiveImage);
			actionUsed.x = 515;
			actionUsed.y = 10;
			actionUsed.visible = false;
			
			switch (usetype) {
				case 0:
					actionBuy.visible = true;
					break;
				case 1:
					actionUse.visible = true;
					priceGoldTF.visible = false;
					priceCrystalTF.visible = false;
					icon_money.visible = false;
					icon_gem.visible = false;
					break;
				case 2:
					actionUsed.visible = true;
					priceGoldTF.visible = false;
					priceCrystalTF.visible = false;
					icon_money.visible = false;
					icon_gem.visible = false;
					break;
			}
			switch (store.Type) {
				case UIStore.TYPE_AVATAR:
					loadIcon(CharacterTextureHelper.list_avatars_icon_textures);
				break;
				case UIStore.TYPE_SKILL:
					loadIcon(CharacterTextureHelper.list_skills_icon_textures);
				break;
			}
		}
		
		public function enableButtons():void {
			gemButton.enabled = true;
			goldButton.enabled = true;
			useButton.enabled = true;
		}
		
		private function goldTriggered(e:Event):void {
			gemButton.enabled = false;
			goldButton.enabled = false;
			from.Manager.SFXSoundManager.play("click_button");
			switch (store.Type) {
				case UIStore.TYPE_AVATAR:
					lobbyService.initAvatarBuyLoader(item_id, charindex, 0, store, this);
					break;
				case UIStore.TYPE_SKILL:
					lobbyService.initSkillBuyLoader(item_id, charindex, 0, store, this);
					break;
			}
			lobbyService.start();
		}
		
		private function gemTriggered(e:Event):void {
			gemButton.enabled = false;
			goldButton.enabled = false;
			from.Manager.SFXSoundManager.play("click_button");
			switch (store.Type) {
				case UIStore.TYPE_AVATAR:
					lobbyService.initAvatarBuyLoader(item_id, charindex, 1, store, this);
					break;
				case UIStore.TYPE_SKILL:
					lobbyService.initSkillBuyLoader(item_id, charindex, 1, store, this);
					break;
			}
			lobbyService.start();
		}
		
		private function useTriggered(e:Event):void {
			useButton.enabled = false;
			from.Manager.SFXSoundManager.play("click_button");
			switch (store.Type) {
				case UIStore.TYPE_AVATAR:
					lobbyService.initAvatarUsageLoader(item_id, charindex, store, this);
					break;
				case UIStore.TYPE_SKILL:
					lobbyService.initSkillUsageLoader(item_id, charindex, store, this);
					break;
			}
			lobbyService.start();
		}
		
		private function loadIcon(dic:Dictionary):void {
			var img:Image;
			if (dic[charindex] == null)
				dic[charindex] = new Dictionary();
			if (dic[charindex][item_id] == null) {
				var icon_path:String = data.icon;
				if (icon_path != null && icon_path.length > 0) {
					var iconTextureLoad:Loader = new Loader();
					iconTextureLoad.load(new URLRequest(Main.serviceurl + icon_path));
					iconTextureLoad.contentLoaderInfo.addEventListener("complete", function(e:Object):void {
						var bitmapData:BitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;
						iconTexture = Texture.fromBitmapData(bitmapData, false);
						bitmapData.dispose();
						dic[charindex][item_id] = iconTexture;
						img = new Image(iconTexture);
						img.width = 100;
						img.height = 100;
						icon_container.addChild(img);
					});
				} else {
					iconTexture = Texture.empty(80, 80);
					dic[charindex][item_id] = iconTexture;
					img = new Image(iconTexture);
					img.width = 100;
					img.height = 100;
					icon_container.addChild(img);
				}
			} else {
				iconTexture = dic[charindex][item_id];
				img = new Image(iconTexture);
				img.width = 100;
				img.height = 100;
				icon_container.addChild(img);
			}
		}
		
		protected override function removedFromStage(e:Event):void 
		{
			super.removedFromStage(e);
			removeAndDisposeChildren();
		}
	}

}