package SpectralGraphics 
{
	import adobe.utils.CustomActions;
	import flash.automation.ActionGenerator;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.geom.Point;
	import Misc.LinkedList;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class ObjectFactory 
	{
		
		public function ObjectFactory() 
		{
			
		}
		
	/*	public function createTriangle(base:int, height:int, angle:int, color:uint):SpectralObject {
			var triangle:LinkedList = new LinkedList();
			triangle.insertAfterCurrent(new Point(0, 0));
			triangle.insertAfterCurrent(new Point(base / 2, height));
		}*/
		
		public function createSquare(size:int, color:uint, alpha:Number):SpectralObject {
			return createRectangle(size, size, color, alpha);
		}
		public function createRectangle(width:int, height:int, color:uint, alpha:Number):SpectralObject {
			var rectangle:LinkedList = new LinkedList();
			rectangle.insertAfterCurrent(new Point( -width / 2, -height / 2));
			rectangle.insertAfterCurrent(new Point(width / 2, -height / 2));
			rectangle.insertAfterCurrent(new Point(width / 2, height / 2));
			rectangle.insertAfterCurrent(new Point( -width / 2, height / 2));
			
			return new SpectralShape(rectangle, color, alpha, width, height);
		}
		public function createDiamond(width:int, height:int, color:uint, alpha:Number):SpectralObject {
			var diamond:LinkedList = new LinkedList();
			diamond.insertAfterCurrent(new Point(0, -height / 2));
			diamond.insertAfterCurrent(new Point(width / 2, 0));
			diamond.insertAfterCurrent(new Point(0, height / 2));
			diamond.insertAfterCurrent(new Point( -width / 2, 0));
			
			return new SpectralShape(diamond, color, alpha, width, height);
		}
		
		public function createCircle(radius:int, color:uint, alpha:Number):SpectralObject {
			var circle:LinkedList = createArc(0, 0, radius, 0, 360, 50);
			
			return new SpectralShape(circle, color, alpha, radius * 2, radius * 2);
		}
		public function createSemiCircle(radius:int, color:uint, alpha:Number):SpectralObject {
			var semiCircle:LinkedList = createArc(0, 0, radius, 0, 180, 25);
			
			return new SpectralShape(semiCircle, color, alpha, radius * 2, radius);
		}
		public function createCrescent(radiusA:int, radiusB:int, arcLength:int, color:uint, alpha:Number):SpectralObject {
			var crescent:LinkedList = createArc(0, 0, radiusA, 0, arcLength, 25);
			crescent = createArc(0, 0, radiusB, arcLength + 90, -arcLength, 25, crescent);
			
			return new SpectralShape(crescent, color, alpha, radiusA * 2, radiusB * 2);
		}
		
		
		private function createArc(centerX:int, centerY:int, radius:int, startAng:int, endAng:int, steps:int, list:LinkedList = null):LinkedList {
			if (list == null) list = new LinkedList();
			
			startAng -= 90;
			var startRadian:Number = (startAng * Math.PI) / 180;
			var endRadian:Number = (endAng * Math.PI) / 180;
			var angleIterate:Number = endRadian / steps;
			var tempAngle:Number;
			
			var tempX:int = centerX + Math.cos(startRadian) * radius;
			var tempY:int = centerY + Math.sin(startRadian) * radius;
			list.insertAfterCurrent(new Point(tempX, tempY));
			
			for (var i:int = 0; i < steps; i++) {
				tempAngle = startRadian + i * angleIterate;
				tempX = centerX + Math.cos(tempAngle) * radius;
				tempY = centerY + Math.sin(tempAngle) * radius;
				list.insertAfterCurrent(new Point(tempX, tempY));
			}
			return list;
		}
		
	}

}