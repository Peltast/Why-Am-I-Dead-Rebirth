package Props 
{
	import Dialogue.Dialogue;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import Maps.Map;
	import SpectralGraphics.SpectralImage;
	/**
	 * ...
	 * @author Peltast
	 */
	public class SpectralImageProp extends Prop
	{
		private var propSpectralImg:SpectralImage;
		
		public function SpectralImageProp(propSpectralImg:SpectralImage, propTag:String, collidable:Boolean = true,
			xCoord:Number = 0, yCoord:Number = 0, bounds:Rectangle = null, permissions:Vector.<String> = null,
			sucDia:Dialogue = null, failDia:Dialogue = null) 
		{
			super(new Bitmap(), propTag, collidable, xCoord, yCoord, bounds, permissions, sucDia, failDia);
			
			this.propSpectralImg = propSpectralImg;
			this.addChild(propSpectralImg);
			propSpectralImg.beginImage();
		}
		
		public function resumeSpectralImage():void {
			propSpectralImg.beginImage();
		}
		public function pauseSpectralImage():void {
			propSpectralImg.stopImage();
		}
		
	}

}