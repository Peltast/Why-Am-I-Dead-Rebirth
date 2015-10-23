package SpectralGraphics 
{
	import flash.display.Shape;
	import flash.geom.Point;
	import Misc.LinkedList;
	/**
	 * ...
	 * @author Peltast
	 */
	public class SpectralShape extends SpectralObject
	{
		
		private var objectPoints:LinkedList;
		private var currentShape:Shape;
		
		public function SpectralShape(points:LinkedList, color:uint, alpha:Number, shapeWidth:int, shapeHeight:int) 
		{
			super(this, color, alpha, shapeWidth, shapeHeight);
			
			objectPoints = points;
			currentShape = drawObjectShape(objectPoints, objectColor, objectAlpha);
			
			this.addChild(currentShape);
		}
		
		private function drawObjectShape(objectPoints:LinkedList, color:uint, alpha:Number):Shape {
			var tempShape:Shape = new Shape();
			tempShape.graphics.beginFill(color, alpha);
			
			objectPoints.setCurrentNodeEnd();
			var startNode:Point = objectPoints.getCurrent() as Point;
			var tempNode:Point = startNode;
			var count:int = 0;
			
			tempShape.graphics.moveTo(startNode.x, startNode.y);
			
			while (tempNode != startNode || count == 0) {
				
				tempShape.graphics.lineTo(tempNode.x, tempNode.y);
				
				count++;
				objectPoints.setForward();
				tempNode = objectPoints.getCurrent() as Point;
			}
			
			tempShape.graphics.endFill();
			return tempShape;
		}
		
		
		public function getPoints():LinkedList { return objectPoints; }
		
		public function changeShape(newShape:Shape):void {
			this.removeChild(currentShape);
			currentShape = newShape;
			this.addChild(currentShape);
		}
		
		public override function changeColor(color:uint):void {
			objectColor = color;
			this.removeChild(currentShape);
			currentShape = drawObjectShape(objectPoints, objectColor, objectAlpha);
			this.addChild(currentShape);
		}
		
		public override function getClone():SpectralObject {
			var specShape:SpectralShape = new SpectralShape(objectPoints, objectColor, objectAlpha, shapeWidth, shapeHeight);
			specShape.alpha = this.alpha;
			return specShape;
		}
		
	}

}