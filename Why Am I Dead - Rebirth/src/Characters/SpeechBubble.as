package Characters 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Setup.GameLoader;
	/**
	 * ...
	 * @author Peltast
	 */
	public class SpeechBubble extends Sprite
	{
		
		private var bubbleAnimation:OneOffAnimation;
		private var bubbleBmp:Bitmap;
		private var bubbleSheet:Bitmap;
		
		public function SpeechBubble() 
		{
			bubbleAnimation = new OneOffAnimation("Bubble", 1, new Point(), 24, 20,
									[new Point(), new Point(1), new Point(2), new Point(3), new Point(4), new Point(5)],
									[new Point(5), new Point(6), new Point(7)], 10);
			bubbleSheet = new GameLoader.Speechbubble() as Bitmap;
			
			bubbleBmp = new Bitmap(new BitmapData(24, 20));
		}
		
		public function updateSpeechBubble():void {		
			bubbleAnimation.updateAnimation();
			updateFrame(bubbleAnimation.getRectangle());	
		}
		
		private function updateFrame(frame:Rectangle):void {
			
			if (this.contains(bubbleBmp))
				this.removeChild(bubbleBmp);
				
			bubbleBmp.bitmapData.copyPixels(bubbleSheet.bitmapData, frame, new Point());
			bubbleBmp.alpha = 1;
			
			this.addChild(bubbleBmp);
		}
		
	}

}