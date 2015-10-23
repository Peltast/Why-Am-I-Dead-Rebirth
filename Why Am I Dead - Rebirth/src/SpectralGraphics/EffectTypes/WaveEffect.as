package SpectralGraphics.EffectTypes 
{
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class WaveEffect extends SpectralEffect
	{
		private var horizontal:Boolean;
		private var acceleration:Number;
		private var deceleration:Number;
		private var maxSpeed:Number;
		private var wavelength:int;
		
		private var moveSwitch:Boolean;
		private var temp:Number;
		private var delta:Number;
		
		public function WaveEffect(horizontal:Boolean, acc:Number, dec:Number, speed:Number, wavelength:int) 
		{
			super(this);
			
			this.horizontal = horizontal;
			this.acceleration = acc;
			this.deceleration = dec;
			this.maxSpeed = speed;
			this.wavelength = wavelength;
			
			moveSwitch = true;
			temp = 0;
			delta = 0;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			
			if (moveSwitch && temp > wavelength)
				moveSwitch = !moveSwitch;
			else if (!moveSwitch && temp < -wavelength)
				moveSwitch = !moveSwitch;
			
			if (moveSwitch && delta < 0)
				delta += deceleration;
			else if (moveSwitch && delta >= 0 && delta < maxSpeed)
				delta += acceleration;
			else if (moveSwitch && delta > maxSpeed)
				delta = maxSpeed;
			
			else if (!moveSwitch && delta > 0)
				delta -= deceleration;
			else if (!moveSwitch && delta <= 0 && delta > -maxSpeed)
				delta -= acceleration;
			else if (!moveSwitch && delta < -maxSpeed)
				delta = -maxSpeed;
			
			if (horizontal)
				object.x += delta;
			else
				object.y += delta;
			
			temp += delta;
		}
		
	}

}