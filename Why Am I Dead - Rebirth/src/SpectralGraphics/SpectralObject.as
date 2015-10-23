package SpectralGraphics 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import Misc.LinkedList;
	import SpectralGraphics.EffectTypes.SpectralEffect;
	import SpectralGraphics.EffectTypes.ZoomEffect;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SpectralObject extends Sprite
	{
		protected var objectColor:uint;
		protected var objectAlpha:Number;
		
		protected var shapeWidth:int;
		protected var shapeHeight:int;
		
		
		public function SpectralObject(specOb:SpectralObject, color:uint, alpha:Number, shapeWidth:int, shapeHeight:int) 
		{
			if (specOb != this) throw new Error("SpectralObject is meant to be used as an abstract class.");
			
			this.shapeWidth = shapeWidth;
			this.shapeHeight = shapeHeight;
			objectColor = color;
			objectAlpha = alpha;
			
		}
		
		public function getShapeWidth():int { return shapeWidth; }
		public function getShapeHeight():int { return shapeHeight; }
		public function getColor():uint { return objectColor; }
		public function getAlpha():Number { return objectAlpha; }
		
		public function getClone():SpectralObject { return null; }
		public function changeColor(color:uint):void { 
			objectColor = color; 
		}
		
		public function reverseEffect(effect:SpectralEffect):void {
			
			if (effect is ZoomEffect) {
				scaleX = 1;
				scaleY = 1;
			}
			
		}
		
	}

}