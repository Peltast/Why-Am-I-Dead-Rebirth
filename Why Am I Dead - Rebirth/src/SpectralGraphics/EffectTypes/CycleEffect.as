package SpectralGraphics.EffectTypes 
{
	import flash.geom.Point;
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Peltast
	 */
	public class CycleEffect extends SpectralEffect
	{
		private var center:Point;
		private var radius:int;
		private var delta:Number;
		private var clockwise:Boolean;
		private var spinLength:Number;
		private var maxSpeed:Number;
		private var acc:Number;
		private var dec:Number;
		
		private var currentSpin:int;
		
		public function CycleEffect(center:Point, radius:int, clockwise:Boolean, spinLength:Number = -1,
			maxSpeed:Number = 1 / (Math.PI * 3), acc:Number =  1 / (Math.PI * 3), dec:Number = 1 / (Math.PI * 3)) 
		{
			super(this);
			this.center = center;
			this.radius = radius;
			this.clockwise = clockwise;
			this.spinLength = spinLength;
			this.maxSpeed = maxSpeed;
			this.acc = acc;
			this.dec = dec;
			currentSpin = 0;
			delta = maxSpeed;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			// a = arccos(x - cx / r)
			var currentAngle:Number =  Math.atan2(object.y - center.y, object.x - center.x);
			
			var newAngle:Number = currentAngle + delta;
			currentSpin += delta;
			
			// x = cx + r * cos(a)
			// y = cy + r * sin(a)
			var newX:int = center.x + radius * Math.cos(newAngle);
			var newY:int = center.y + radius * Math.sin(newAngle);
			object.x = newX;
			object.y = newY;
			
			if (currentSpin > spinLength && spinLength > 0) {
				currentSpin = 0;
				clockwise = !clockwise;
			}
			
			if (clockwise && delta <= 0)
				delta += dec;
			else if (clockwise)
				delta += acc;
			if (!clockwise && delta >= 0)
				delta -= dec;
			else if (!clockwise)
				delta -= acc;
			
			if (clockwise && delta > maxSpeed)
				delta = maxSpeed;
			if (!clockwise && delta < -maxSpeed)
				delta = -maxSpeed;
			
		}
		
		
	}

}