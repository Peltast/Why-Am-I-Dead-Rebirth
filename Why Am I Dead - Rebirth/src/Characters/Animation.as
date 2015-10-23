package Characters 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Animation 
	{
		protected var frames:Array; // Array of rectangles describing the masks for each pose in the animation.
		private var name:String;
		private var animStart:Point;
		private var animWidth:int;
		private var animHeight:int;
		private var animFrames:Array;
		protected var tickCount:int;	// Timer for animation
		protected var speed:int; // Number of ticks before animation progresses
		protected var currentFrame:Rectangle;
		
		public function Animation(name:String, speed:int, animStart:Point, animWidth:int, animHeight:int, animFrames:Array) 
		{
			this.name = name;
			this.speed = speed;
			this.animStart = animStart;
			this.animWidth = animWidth;
			this.animHeight = animHeight;
			this.animFrames = animFrames;
			
			frames = [];
			for (var i:int = 0; i < animFrames.length; i++) {
				var tempRectangle:Rectangle =  new Rectangle(animStart.x + (animFrames[i].x * animWidth), 
													animStart.y + (animFrames[i].y * animHeight), animWidth, animHeight);
				frames.push(tempRectangle);
			}
			currentFrame = frames[0];
		}
		
		public function updateAnimation():Rectangle {
			if (currentFrame == null) {
				currentFrame = frames[0];
				return currentFrame;
			}
			if (speed < 0) return currentFrame;
			
			tickCount++;
			if (tickCount > speed) {
				tickCount = 0;
				for (var i:int = 0; i < frames.length; i++) {
					if (currentFrame == frames[i]) {
						// If this is the last frame in the array, go back to the beginning.
						if (frames.length - 1 == i) currentFrame = frames[0];
						// Otherwise, move to the next.
						else currentFrame = frames[i + 1];
						return currentFrame;
					}
				}
				
				throw new Error("Somehow, the animation's current frame isn't contained in its array of frames.");
			}
			
			return currentFrame;
		}
		
		public function getFrameIndex():int {
			for (var i:int = 0; i < frames.length; i++) {
				if (currentFrame == frames[i])
					return i;
			}
			return -1;
		}
		public function getRectangle():Rectangle { return currentFrame; }
		public function getWidth():int { return currentFrame.width; }
		public function getHeight():int { return currentFrame.height; }
		public function getName():String { return name; }
		
		public function getClone(newSpeed:int = -1):Animation {
			if (newSpeed == -1) newSpeed = this.speed;
			return new Animation(this.name, newSpeed, this.animStart, this.animWidth, this.animHeight, this.animFrames);
		}
	}

}