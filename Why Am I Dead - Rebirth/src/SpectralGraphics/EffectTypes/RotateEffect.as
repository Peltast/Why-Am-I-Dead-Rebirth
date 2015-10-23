package SpectralGraphics.EffectTypes 
{
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class RotateEffect extends SpectralEffect
	{
		private var clockwise:Boolean;
		private var speed:Number;
		
		public function RotateEffect(clockwise:Boolean, speed:Number) 
		{
			super(this);
			this.clockwise = clockwise;
			this.speed = speed;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			var matrix:Matrix= object.transform.matrix; 
			var rect:Rectangle = object.getBounds(object.parent); 
			
			matrix.translate( - (rect.left + (rect.width / 2)), - (rect.top + (rect.height / 2)));
			if (clockwise)
				matrix.rotate((speed / 180) * Math.PI);
			else
				matrix.rotate(( -speed / 180) * Math.PI);
			matrix.translate(rect.left + (rect.width / 2), rect.top + (rect.height / 2));
			
			object.transform.matrix = matrix;
		}
		
	}

}