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
	public class StairsDown extends Prop
	{
		
		private var homeMap:Map;
		private var triangle:Shape;
		private var triangle2:Shape;
		private var triangle3:Shape;
		
		public function StairsDown(propImg:Bitmap, propTag:String, collidable:Boolean, homeMap:Map, xCoord:Number = 0, yCoord:Number = 0) 
		{
			super(propImg, propTag, collidable, xCoord, yCoord, null);
			
			this.homeMap = homeMap;
			
			//  __
			//  |/
			triangle = new Shape();
			triangle.graphics.beginFill(0xffffff, 0);
			triangle.graphics.moveTo(2, 0);
			triangle.graphics.lineTo(66, 0);
			triangle.graphics.lineTo(2, 64);
			triangle.graphics.lineTo(2, 0);
			triangle.graphics.endFill();
			triangle.x = this.x;
			triangle.y = this.y;
			
			//  /|
			//  --
			triangle2 = new Shape();
			triangle2.graphics.beginFill(0xffffff, 0);
			triangle2.graphics.moveTo(66, 3);
			triangle2.graphics.lineTo(66, 67);
			triangle2.graphics.lineTo(2, 67);
			triangle2.graphics.lineTo(66, 3);
			triangle2.graphics.endFill();
			triangle2.x = this.x;
			triangle2.y = this.y;
			
			//  
			//  __
			//  |/
			triangle3 = new Shape();
			triangle3.graphics.beginFill(0xffffff, 0);
			triangle3.graphics.moveTo(66, 64);
			triangle3.graphics.lineTo(2, 128);
			triangle3.graphics.lineTo(2, 64);
			triangle3.graphics.lineTo(66, 64);
			triangle3.graphics.endFill();
			triangle3.x = this.x;
			triangle3.y = this.y;
			
			
			Main.getSingleton().stage.addChild(triangle);
			Main.getSingleton().stage.addChild(triangle2);
			Main.getSingleton().stage.addChild(triangle3);
			
			Game.getSingleton().stage.addEventListener(Event.ENTER_FRAME, checkCharacters);
		}
		
		override public function intersectsObject(mapObject:MapObject, checkCollidable:Boolean):Boolean 
		{
			var bounds:Rectangle = mapObject.getObjectBounds();
			var height:int = mapObject.getZPosition();
			
			if (bounds == this.getActionBounds())
				return false;
			
			var characterPos:Point = new Point(bounds.x, bounds.y + bounds.height);
			
			if (bounds.intersects(this.getObjectBounds())) {
				
				if (!triangle2.hitTestPoint(characterPos.x, characterPos.y - height, true) 
					&& !triangle3.hitTestPoint(characterPos.x, characterPos.y - height, true)) {
						return true;
				}
			}
			return false;
		}
		
		private function checkCharacters(event:Event):void {
			var collisions:Array = homeMap.checkCharacterCollisions(this, getActionBounds(), false);
			var bounds:Rectangle = this.getActionBounds();
			
			for (var i:int = 0; i < collisions.length; i++) {
				if (collisions[i] is Character) {
					var tempChar:Character = collisions[i] as Character;
					var characterPos:Point = new Point
						(tempChar.getObjectBounds().x, 
						tempChar.getObjectBounds().y + tempChar.getObjectBounds().height - tempChar.getZPosition());
					
					if (triangle2.hitTestPoint(characterPos.x, characterPos.y, true) 
						|| triangle3.hitTestPoint(characterPos.x,characterPos.y)) {
							if (characterPos.x > this.x) 
								tempChar.setZPosition((characterPos.x - this.x) - 64);
							if (tempChar.getXSpeed() > -(characterPos.x - (this.x + this.width))) 
								tempChar.setZPosition(0);
					}
					
					if (triangle.hitTestPoint(characterPos.x, characterPos.y, true) 
						&& tempChar.getYSpeed() < 0 && tempChar.getZPosition() < 0) {
							tempChar.stopYSpeed();
							if (tempChar.getXSpeed() == 0) tempChar.setAnimation("Back Idle");
						
					}
				}
			}
			
		}
		
	}

}