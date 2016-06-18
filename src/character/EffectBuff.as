package character 
{
	import assets.EffectsTexturesHelper;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	public class EffectBuff extends Sprite
	{
		public static const ID_EAGLE_EYE:int = 1;
		public static const ID_BASH:int = 2;
		public static const ID_BLESSING:int = 3;
		public static const ID_RESOLUTION:int = 4;
		private var buffID:int;
		private var buffEffect:MovieClip;
		private var charEnt:Entity;
		public function EffectBuff(buffID:int) {
			this.buffID = buffID;
		}
		
		public function SetCharacterEntity(charEnt:Entity):void {
			this.charEnt = charEnt;
			addBuff();
			addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		}
		
		private function addBuff():void {
			var charInfo:BaseCharacterInformation = charEnt.CharacterInfo;
			switch (buffID) {
				case EffectBuff.ID_EAGLE_EYE:
					charInfo.addExtraAbility("crirate", 50);
					buffEffect = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures("Archer_Skill01_"));
					break;
				case EffectBuff.ID_BASH:
					charInfo.addExtraAbility("min_patk", charInfo.MinPAtk * 0.5);
					charInfo.addExtraAbility("max_patk", charInfo.MaxPAtk * 0.5);
					break;
				case EffectBuff.ID_BLESSING:
					charInfo.addExtraAbility("str", 2);
					charInfo.addExtraAbility("agi", 2);
					charInfo.addExtraAbility("int", 2);
					buffEffect = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures("Hermit_Skill01_"), 8);
					buffEffect.loop = false;
					buffEffect.addEventListener(Event.COMPLETE, function(e:Event):void {
						buffEffect.visible = false;
					});
					break;
				case EffectBuff.ID_RESOLUTION:
					buffEffect = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures("Knight_Skill01_"));
					break;
			}
			if (buffEffect != null) {
				buffEffect.pivotX = buffEffect.width / 2;
				buffEffect.pivotY = buffEffect.height;
				buffEffect.touchable = false;
				addChild(buffEffect);
				Starling.juggler.add(buffEffect);
			}
		}
		
		private function delBuff():void {
			var charInfo:BaseCharacterInformation = charEnt.CharacterInfo;
			switch (buffID) {
				case EffectBuff.ID_EAGLE_EYE:
					charInfo.addExtraAbility("crirate", -50);
					break;
				case EffectBuff.ID_BASH:
					charInfo.addExtraAbility("min_patk", -charInfo.MinPAtk * 0.5);
					charInfo.addExtraAbility("max_patk", -charInfo.MaxPAtk * 0.5);
					break;
				case EffectBuff.ID_BLESSING:
					charInfo.addExtraAbility("str", -2);
					charInfo.addExtraAbility("agi", -2);
					charInfo.addExtraAbility("int", -2);
					break;
				case EffectBuff.ID_RESOLUTION:
					break;
			}
		}
		
		private function enterFrame(e:EnterFrameEvent):void {
			if (buffEffect != null) {
				buffEffect.x = charEnt.x;
				buffEffect.y = charEnt.y;
			}
		}
		
		private function removedFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			if (charEnt != null) {
				delBuff();
			}
			removeChildren(0, -1, true);
		}
		
		public function get BuffID():int {
			return buffID;
		}
	}
}