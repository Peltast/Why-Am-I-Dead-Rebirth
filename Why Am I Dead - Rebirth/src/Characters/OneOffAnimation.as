package Characters 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Peltast
	 */
	public class OneOffAnimation extends Animation
	{
		private var secondSetFrames:Array;
		private var usedFrameSet:Array;
		private var usedSpeed:int;
		private var secondFrames:Array;
		private var secondSetSpeed:int;
		
		public function OneOffAnimation(name:String, speed:int, animStart:Point, animWidth:int, animHeight:int,
										animFrames:Array, secondSetFrames:Array, secondSetSpeed:int = -1) 
		{
			super(name, speed, animStart, animWidth, animHeight, animFrames);
			this.secondSetFrames = secondSetFrames;
			this.usedFrameSet = frames;
			if (secondSetSpeed < 0)
				this.secondSetSpeed = speed;
			else
				this.secondSetSpeed = secondSetSpeed;
			
			secondFrames = [];
			for (var i:int = 0; i < secondSetFrames.length; i++) {
				var tempRectangle:Rectangle =  new Rectangle(animStart.x + (secondSetFrames[i].x * animWidth), 
													animStart.y + (secondSetFrames[i].y * animHeight), animWidth, animHeight);
				secondFrames.push(tempRectangle);
			}
		}
		
		public function resetAnimation():void {
			usedFrameSet = frames;
			usedSpeed = speed;
			currentFrame = null;
		}
		
		public override function updateAnimation():Rectangle {
			if (currentFrame == null) {
				currentFrame = usedFrameSet[0];
				return currentFrame;
			}
			if (speed < 0) return currentFrame;
			
			tickCount++;
			if (tickCount > usedSpeed) {
				tickCount = 0;
				for (var i:int = 0; i < usedFrameSet.length; i++) {
					if (currentFrame == usedFrameSet[i]) {
						// If this is the last frame in the array, go back to the beginning.
						if (usedFrameSet.length - 1 == i) {
							usedFrameSet = secondFrames;
							usedSpeed = secondSetSpeed;
							currentFrame = usedFrameSet[0];
						}
						// Otherwise, move to the next.
						else currentFrame = usedFrameSet[i + 1];
						return currentFrame;
					}
				}
				
				throw new Error("Somehow, the animation's current frame isn't contained in its array of frames.");
			}
			
			return currentFrame;
		}
		
	}

}