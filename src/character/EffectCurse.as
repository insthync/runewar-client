package character 
{
	import assets.EffectsTexturesHelper;
	import flash.utils.getTimer;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	public class EffectCurse extends Sprite
	{
		public static const ID_MALEDICTION:int = 1;
		private var curseID:int;
		private var curseEffect:MovieClip;
		private var charEnt:Entity;
		private var timeToEffect:int;
		private var delayToEffect:int;
		private var count:int;
		private var currentTime:int;
		private var power:int;
		public function EffectCurse(curseID:int, timeToEffect:int, delayToEffect:int, power:int) {
			this.curseID = curseID;
			this.timeToEffect = timeToEffect;
			this.delayToEffect = delayToEffect;
			this.power = power;
			this.count = 0;
			this.currentTime = getTimer();
		}
		
		public function SetCharacterEntity(charEnt:Entity):void {
			this.charEnt = charEnt;
			addCurse();
			addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		}
		
		private function addCurse():void {
			switch (curseID) {
				case EffectCurse.ID_MALEDICTION:
					curseEffect = new MovieClip(EffectsTexturesHelper.getTextureAtlas1().getTextures("Mage_Skill01_"));
				break;
			}
			if (curseEffect != null) {
				curseEffect.pivotX = curseEffect.width / 2;
				curseEffect.pivotY = curseEffect.height;
				curseEffect.touchable = false;
				addChild(curseEffect);
				Starling.juggler.add(curseEffect);
			}
		}
		
		private function enterFrame(e:EnterFrameEvent):void {
			curseEffect.x = charEnt.x;
			curseEffect.y = charEnt.y;
			if (getTimer() - currentTime < delayToEffect) {
				return;
			}
			if (count < timeToEffect) {
				if (!charEnt.IsSimulation) {
					charEnt.CurrentHP -= power;
				}
				currentTime = getTimer();
				count++;
			} else {
				// Removing
				removeEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
				charEnt.removeCurse(curseID);
			}
		}
		
		private function removedFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			removeChildren(0, -1, true);
		}
		
		public function get CurseID():int {
			return curseID;
		}
	}
}