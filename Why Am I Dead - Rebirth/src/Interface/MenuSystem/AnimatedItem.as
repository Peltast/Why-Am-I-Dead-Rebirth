package Interface.MenuSystem 
{
	import Characters.Animation;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import Setup.GameLoader;
	/**
	 * ...
	 * @author Peltast
	 */
	public class AnimatedItem extends Sprite
	{
		private var animation:Animation;
		private var itemBmp:Bitmap;
		
		private var bitmap:Bitmap;
		private var frames:Array;
		private var animationSpeed:int;
		private var animationWidth:int;
		private var animationHeight:int;
		
		public function AnimatedItem(bitmap:Bitmap, frames:Array, animationSpeed:int, width:int, height:int) 
		{
			this.bitmap = bitmap;
			this.frames = frames;
			this.animationSpeed = animationSpeed;
			this.animationWidth = animationWidth;
			this.animationHeight = animationHeight;
			
			itemBmp = new Bitmap(new BitmapData(width, height));
			
			this.animation = new Animation("MenuAnimation", animationSpeed, new Point(), width, height, frames);
		}
		
		public function updateItem():void {
			if (this.contains(itemBmp))
				this.removeChild(itemBmp);
			
			animation.updateAnimation();
			itemBmp = new Bitmap(new BitmapData(animation.getWidth(), animation.getHeight()));
			itemBmp.bitmapData.copyPixels(bitmap.bitmapData, animation.getRectangle(), new Point(0, 0));
			
			this.addChild(itemBmp);
		}
		
	}

}