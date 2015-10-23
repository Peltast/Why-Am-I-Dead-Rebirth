package Props 
{
	import Characters.Character;
	import Core.Game;
	import Dialogue.Dialogue;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Maps.Map;
	import Maps.MapObject;
	/**
	 * ...
	 * @author ...
	 */
	public class StairsUp extends Prop
	{
		private var homeMap:Map;
		private var triangle:Shape;
		private var triangle2:Shape;
		private var bounds:Rectangle;
		
		public function StairsUp(propImg:Bitmap, propTag:String, collidable:Boolean, homeMap:Map, xCoord:Number = 0, yCoord:Number = 0) 
		{
			super(propImg, propTag, collidable, xCoord, yCoord, null);
			
			this.homeMap = homeMap;
			
			triangle = new Shape();
			triangle.graphics.beginFill(0x000000, 0);
			triangle.graphics.moveTo(64, 0);
			triangle.graphics.lineTo(64, 64);
			triangle.graphics.lineTo(0, 64);
			triangle.graphics.lineTo(64, 0);
			triangle.graphics.endFill();
			triangle.x = this.x;
			triangle.y = this.y;
			
			triangle2 = new Shape();
			triangle2.graphics.lineStyle(3, 0xffffff, 0);
			triangle2.graphics.beginFill(0xffffff, 0);
			triangle2.graphics.moveTo(-10, 64);
			triangle2.graphics.lineTo(64, 64);
			triangle2.graphics.lineTo(-10, 128);
			triangle2.graphics.lineTo( -10, 64);
			triangle2.graphics.endFill();
			triangle2.x = this.x;
			triangle2.y = this.y;
			
			Main.getSingleton().addChild(triangle);
			Main.getSingleton().addChild(triangle2);
			
			Game.getSingleton().stage.addEventListener(Event.ENTER_FRAME, checkCharacters);
			
			var child:DisplayObject = getChildAt(0);
			bounds = new Rectangle(child.x + this.x - 1, child.y + this.y, child.width + 1, child.height);
		}
		
		
		override public function intersectsObject(mapObject:MapObject, checkCollidable:Boolean):Boolean 
		{
			var bounds:Rectangle = mapObject.getObjectBounds();
			var height:int = mapObject.getZPosition();
			
			if (bounds.height == Game.getTileSize() - 2 && bounds.width == Game.getTileSize() - 2)
				return this.bounds.containsPoint(new Point(bounds.x + bounds.width / 2, bounds.y + bounds.height / 2));
			if (bounds == this.getActionBounds())
				return false;
			
			var characterPos:Point = new Point
						(bounds.x + bounds.width, bounds.y + bounds.height);
			
			if (bounds.intersects(this.getObjectBounds())) {
				if (characterPos.y < triangle2.y + 64 && !triangle.hitTestPoint(characterPos.x, characterPos.y))
					return false;
				if ((triangle.hitTestPoint(characterPos.x, characterPos.y) && height == 0)
					|| !triangle2.hitTestPoint(characterPos.x, characterPos.y)) {
						return true;
				}
			}
			return false;
		}
		
		private function checkCharacters(event:Event):void {
			var collisions:Array = homeMap.checkCharacterCollisions(this, this.getActionBounds(), false);
			var bounds:Rectangle = this.getActionBounds();
			
			for (var i:int = 0; i < collisions.length; i++) {
				if (collisions[i] is Character) {
					var tempChar:Character = collisions[i] as Character;
					var characterPos:Point = new Point
						(tempChar.getObjectBounds().x + tempChar.getObjectBounds().width, 
						tempChar.getObjectBounds().y + tempChar.getObjectBounds().height);
					
					if ((triangle.hitTestPoint(characterPos.x, characterPos.y) && tempChar.getZPosition() > 0)
						|| triangle2.hitTestPoint(characterPos.x, characterPos.y)) {
							if (characterPos.x > this.x) 
								tempChar.setZPosition(characterPos.x - this.x);
							if (tempChar.getXSpeed() < -(characterPos.x - this.x)) 
								tempChar.setZPosition(0);
					}
					if (triangle2.hitTestPoint(characterPos.x, characterPos.y - 64)
						&& tempChar.getYSpeed() > 0 && tempChar.getZPosition() > 0){
							tempChar.stopYSpeed();
							if (tempChar.getXSpeed() == 0) tempChar.setAnimation("Front Idle");
					}
				}
			}
		}
		
		
	}

}