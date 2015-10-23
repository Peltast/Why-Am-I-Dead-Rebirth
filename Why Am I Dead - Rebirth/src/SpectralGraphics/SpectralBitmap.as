package SpectralGraphics 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Peltast
	 */
	public class SpectralBitmap extends SpectralObject
	{
		private var objectBitmap:Bitmap;
		private var colorThreshold:uint;
		
		public function SpectralBitmap
			(bitmap:Bitmap, color:uint, alpha:Number, shapeWidth:int, shapeHeight:int, colorThreshold:uint = 0xffffffff) 
		{
			super(this, color, alpha, shapeWidth, shapeHeight);
			
			objectBitmap = bitmap;
			objectBitmap.alpha = alpha;
			this.colorThreshold = colorThreshold;
			
			if (colorThreshold < 0xffffffff) {
				var bmpData:BitmapData = objectBitmap.bitmapData;
				var bmpRect:Rectangle = new Rectangle(0, 0, bmpData.width, bmpData.height);
				bmpData.threshold(bmpData, bmpRect, new Point(), ">", colorThreshold, color, 0xffffffff, true);
				objectBitmap = new Bitmap(bmpData);
			}
			
			this.addChild(objectBitmap);
		}
		
		override public function changeColor(color:uint):void 
		{
			super.changeColor(color);
			
			if (colorThreshold < 0xffffffff) {
				var bmpData:BitmapData = objectBitmap.bitmapData;
				var bmpRect:Rectangle = new Rectangle(0, 0, bmpData.width, bmpData.height);
				bmpData.threshold(bmpData, bmpRect, new Point(), ">", colorThreshold, color, 0xffffffff, true);
				if (this.contains(objectBitmap))
					this.removeChild(objectBitmap);
				objectBitmap = new Bitmap(bmpData);
				this.addChild(objectBitmap);
			}
		}
		
		public function getBitmap():Bitmap { return objectBitmap; }
		public function setBitmap(bmp:Bitmap):void { 
			if (this.contains(objectBitmap))
				this.removeChild(objectBitmap);
			objectBitmap = bmp; 
			this.addChild(objectBitmap);
		}
		public function getColorThreshold():uint { return colorThreshold; }
		
		override public function getClone():SpectralObject 
		{
			var specBmp:SpectralBitmap = new SpectralBitmap
				(new Bitmap(objectBitmap.bitmapData), objectColor, objectAlpha, shapeWidth, shapeHeight);
			return specBmp;
		}
		
	}

}