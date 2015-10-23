package SpectralGraphics.EffectTypes 
{
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SpinEffect extends SpectralEffect
	{
		private var maxSpeed:Number;
		private var acceleration:Number;
		private var deceleration:Number;
		private var spinSwitch:Boolean;
		private var spinLength:Number;
		
		private var delta:Number;
		private var temp:Number;
		
		public function SpinEffect(maxSpeed:Number, acc:Number, dec:Number, spinLength:Number) 
		{
			super(this);
			this.maxSpeed = maxSpeed;
			this.acceleration = acc;
			this.deceleration = dec;
			this.spinLength = spinLength;
			
			spinSwitch = true;
			delta = 0;
			temp = 0;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			
			if (spinSwitch && temp > spinLength)
				spinSwitch = !spinSwitch;
			else if (!spinSwitch && temp < -spinLength)
				spinSwitch = !spinSwitch;
			
			if (spinSwitch && delta < 0)
				delta += deceleration;
			else if (spinSwitch && delta >= 0 && delta < maxSpeed)
				delta += acceleration;
			else if (spinSwitch && delta > maxSpeed)
				delta = maxSpeed;
			
			else if (!spinSwitch && delta > 0)
				delta -= deceleration;
			else if (!spinSwitch && delta <= 0 && delta > -maxSpeed)
				delta -= acceleration;
			else if (!spinSwitch && delta < -maxSpeed)
				delta = -maxSpeed;
			
			object.rotation += delta;
			
			temp += delta;
			
		}
		
	}

}