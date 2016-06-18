package character 
{
	import flash.display.Shape;
	import starling.display.Sprite;
	import starling.display.Image;
	import starling.textures.Texture;
	import flash.display.BitmapData;
	import starling.events.Event;
	import starling.events.EnterFrameEvent;
	public class HPBar extends Sprite
	{
		private var bgImage:Image;
		private var barImage:Image;
		private var ent:Entity;
		public function HPBar(ent:Entity, BAR_BG_WIDTH:int, BAR_BG_HEIGHT:int, BAR_BG_COLOR:uint, BAR_BG_ALPHA:Number, BAR_WIDTH:int, BAR_HEIGHT:int, BAR_COLOR:uint, BAR_ALPHA:Number) {
			super();
			this.ent = ent;
			
			bgImage = drawRect(BAR_BG_WIDTH, BAR_BG_HEIGHT, BAR_BG_COLOR, BAR_BG_ALPHA);
			addChild(bgImage);
			
			barImage = drawRect(BAR_WIDTH, BAR_HEIGHT, BAR_COLOR, BAR_ALPHA);
			barImage.x = (BAR_BG_WIDTH - BAR_WIDTH) / 2;
			barImage.y = (BAR_BG_HEIGHT - BAR_HEIGHT) / 2;
			addChild(barImage);
			
			pivotX = width / 2;
			pivotY = height / 2;
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		private function update(e:EnterFrameEvent):void {
			if (ent.CurrentHP > 0) {
				var percent:int = ent.CurrentHP * 100 / ent.MaxHP;
				barImage.scaleX = percent / 100;
			} else {
				removeChildren(0, -1, true);
				removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
			}
		}
		
		private function drawRect(w:int, h:int, color:uint, alpha:Number):Image {
			var shp:Shape = new Shape();
			shp.graphics.beginFill(color, alpha);
			shp.graphics.drawRect(0,0,w,h);
			shp.graphics.endFill();
			
			var bmd:BitmapData = new BitmapData(w, h);
			bmd.draw(shp);
			var tex:Texture = Texture.fromBitmapData(bmd, false);
			
			var img:Image = new Image(tex);
			
			shp.graphics.clear();
			shp = null;
			bmd = null;
			
			return img;
		}
	}
}