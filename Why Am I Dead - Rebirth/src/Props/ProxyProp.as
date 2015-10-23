package Props 
{
	import Dialogue.Dialogue;
	import Dialogue.Response;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Peltast
	 */
	public class ProxyProp extends Prop
	{
		
		public function ProxyProp(propImg:Bitmap, propTag:String, collidable:Boolean = true, xCoord:Number = 0, yCoord:Number = 0,
			bounds:Rectangle = null, permissions:Vector.<String> = null, sucDia:Dialogue = null, failDia:Dialogue = null)
		{
			super(propImg, propTag, collidable, xCoord, yCoord, bounds, permissions, sucDia, failDia);
		}
		
		public function resetBounds(newBounds:Rectangle):void {
			
			this.relativeBounds = new Rectangle(newBounds.x, newBounds.y, newBounds.width, newBounds.height);
			this.regularBounds = new Rectangle(newBounds.x, newBounds.y, newBounds.width, newBounds.height);
			this.currentBounds = new Rectangle(newBounds.x, newBounds.y, newBounds.width, newBounds.height);
		}
	}

}