package Characters 
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Peltast
	 */
	public class StationaryCharacter extends Character
	{
		
		public function StationaryCharacter(characterImg:Bitmap, name:String, animations:Dictionary, xCoord:int, yCoord:int,
			charBounds:Rectangle = null, collision:Boolean = true, maxSpeed:int = 6, 
			acceleration:Number = 1, deceleration:Number = 1, animationSpeed:int = 3, possessStat:int = 0) 
		{
			super(characterImg, name, animations, xCoord, yCoord, charBounds, collision,
					maxSpeed, acceleration, deceleration, animationSpeed, possessStat);
			
			
		}
		
		override protected function updateSpeed(event:Event):void 
		{
			
			var playerPos:Point = this.currentMap.getGhostPos();
			if (playerPos != null) {
				var xDifference:int = playerPos.x - this.x;
				var yDifference:int = playerPos.y - this.y;
				if (Math.abs(xDifference) < 20)
					this.currentAnimation = this.animations["Paulo Front"];
				else if (xDifference > yDifference) 
					this.currentAnimation = this.animations["Paulo Right"];
				else if (xDifference > 0)
					this.currentAnimation = this.animations["Paulo Right Front"];
				else if (xDifference < 0 && Math.abs(xDifference) > yDifference)
					this.currentAnimation = this.animations["Paulo Left"];
				else 
					this.currentAnimation = this.animations["Paulo Left Front"];
			}
			else this.currentAnimation = this.animations["Paulo Front"];
			
		}
		
		
	}

}