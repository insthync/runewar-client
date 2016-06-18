package gametutorial
{
	import flash.geom.Point;
	import scene.Scene;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.TextureAtlas;
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	
	public class UITutorial extends UIScene 
	{
		
		private var Paper:Sprite;
		private var OKButton:Button;
		private var Messages:TextField;
		private var tween:Tween;
		
		public function UITutorial(atlas:TextureAtlas, from:Scene) 
		{
			super(atlas, from);
		}
		
		public function setMessages(str:String):void {
			if (Messages != null)
				Messages.text = str;
		}
		
		public function addOKButtonTriggerEvent(event_function:Function):void {
			if (OKButton != null) {
				OKButton.addEventListener(Event.TRIGGERED, event_function);
			}
		}
		
		public function removeAllOKButtonTriggerEvents():void {
			if (OKButton != null) {
				OKButton.removeEventListeners(Event.TRIGGERED);
			}
		}
		
		protected override function InitEvironment():void {
			Paper = new Sprite();
			Paper.addChild(new Image(atlas.getTexture("paper")));
			OKButton = new Button(atlas.getTexture("ok_button"));
			OKButton.x = (Paper.width / 2) - (OKButton.width / 2);
			OKButton.y = Paper.height - (OKButton.height + 10);
			Messages = new TextField(Paper.width - 140, Paper.height - 140, "", "Verdana", 24);
			Messages.x = 60;
			Messages.y = 60;
			//Messages.autoScale = true;
			Messages.vAlign = VAlign.TOP;
			Messages.hAlign = HAlign.LEFT;
			Messages.color = 0x000000;
			addChild(Paper);
			Paper.addChild(Messages);
			Paper.addChild(OKButton);
			visible = false;
		}
		
		protected override function removedFromStage(e:Event):void 
		{
			super.removedFromStage(e);
			removeAllOKButtonTriggerEvents();
			Starling.juggler.remove(tween);
			removeAndDisposeChildren();
		}
		
		public function open():void {
			if (!visible && (tween == null || tween.isComplete)) {
				visible = true;
				Starling.juggler.remove(tween);
				var stageWidth:int = GlobalVariables.screenWidth;
				var stageHeight:int = GlobalVariables.screenHeight;
				Paper.x = (stageWidth / 2) - (Paper.width / 2);
				Paper.y = -Paper.height;
				tween = new Tween(Paper, 0.75, Transitions.EASE_OUT_ELASTIC);
				tween.animate("y", (stageHeight / 2) - (Paper.height / 2));
				Starling.juggler.add(tween);
				tween.onComplete = function():void {
					Starling.juggler.remove(tween); 
				};
			}
		}
		
		public function close():void {
			if (visible && (tween == null || tween.isComplete)) {
				Starling.juggler.remove(tween);
				var stageWidth:int = GlobalVariables.screenWidth;
				var stageHeight:int = GlobalVariables.screenHeight;
				Paper.x = (stageWidth / 2) - (Paper.width / 2);
				Paper.y = (stageHeight / 2) - (Paper.height / 2);
				tween = new Tween(Paper, 0.25, Transitions.EASE_IN_BACK);
				tween.animate("y", -Paper.height);
				Starling.juggler.add(tween);
				tween.onComplete = function():void {
					Starling.juggler.remove(tween); 
					visible = false;
				};
			}
		}
	}
}