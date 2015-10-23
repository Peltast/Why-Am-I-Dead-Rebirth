package Props 
{
	import Characters.Animation;
	import Characters.Character;
	import Characters.OneOffAnimation;
	import Main;
	import Dialogue.Dialogue;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Maps.Map;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class AnimatedProp extends Prop
	{
		private var currentAnimation:Animation;
		private var animationSpeed:int;
		private var propSheet:Bitmap;
		private var oneOffAnimation:Boolean;
		private var animationAlpha:Number;
		
		public function AnimatedProp(propImg:Bitmap, propTag:String, collidable:Boolean, xCoord:Number, yCoord:Number,
					animationSpeed:int, propWidth:int, propHeight:int, oneOff:Boolean, frames:Array, oneOffFrames:Array = null,
					bounds:Rectangle = null, permissions:Vector.<String> = null,
					sucDia:Dialogue = null, failDia:Dialogue = null, alpha:Number = 1)
		{
			super(new Bitmap(), propTag, collidable, xCoord, yCoord, bounds, permissions, sucDia, failDia);
			
			propSheet = propImg;
			this.objectBmp.bitmapData = new BitmapData(propWidth, propHeight);
			this.animationSpeed = animationSpeed;
			this.oneOffAnimation = oneOff;
			
			animationAlpha = alpha;
			
			if (oneOff && oneOffFrames != null) {
				currentAnimation = new OneOffAnimation
					("Idle", animationSpeed, new Point(), propWidth, propHeight, frames, oneOffFrames);
			}
			else
				currentAnimation = new Animation("Idle", animationSpeed, new Point(), propWidth, propHeight, frames);
			
		}
		
		public override function updateProp():void {
			super.updateProp();
			
			if (this.contains(objectBmp))
				this.removeChild(objectBmp);
			
			currentAnimation.updateAnimation();
			objectBmp = new Bitmap(new BitmapData(currentAnimation.getWidth(), currentAnimation.getHeight()));
			objectBmp.bitmapData.copyPixels(propSheet.bitmapData, currentAnimation.getRectangle(), new Point(0, 0));
			objectBmp.alpha = animationAlpha;
			
			this.addChild(objectBmp);
		}
		
	}

}