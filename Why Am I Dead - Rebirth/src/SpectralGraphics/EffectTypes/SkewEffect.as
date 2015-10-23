package SpectralGraphics.EffectTypes 
{
	
	import flash.geom.Matrix;
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SkewEffect extends SpectralEffect
	{		
		private var skewLength:Number;
		private var horizontalSkew:Boolean;
		private var verticalSkew:Boolean;
		private var acceleration:Number;
		private var deceleration:Number;
		private var maxSpeed:Number;
		
		private var skewSwitch:Boolean;
		private var temp:Number;
		private var delta:Number;
		
		public function SkewEffect(acc:Number, dec:Number, maxSpeed:Number, horSkew:Boolean, verSkew:Boolean, skewLength:Number) 
		{
			super(this);
			
			this.skewLength = skewLength;
			this.acceleration = acc;
			this.deceleration = dec;
			this.maxSpeed = maxSpeed;
			this.horizontalSkew = horSkew;
			this.verticalSkew = verSkew;
			
			skewSwitch = true;
			// This is really important; temp cannot start at 0, otherwise it will only skew in one way and then back
			// to center.
			// This is because the skew value doesn't indicate the actual degree of skew, but the speed at which it
			// changes.  So, really, temp is delta and delta is deltadelta.
			temp = skewLength;
			delta = 0;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			
			if (skewSwitch && temp > skewLength)
				skewSwitch = !skewSwitch;
			else if (!skewSwitch && temp < -skewLength)
				skewSwitch = !skewSwitch;
			
			if (skewSwitch && delta < 0)
				delta += deceleration;
			else if (skewSwitch && delta >= 0 && delta < maxSpeed)
				delta += acceleration;
			else if (skewSwitch && delta > maxSpeed)
				delta = maxSpeed;
			
			else if (!skewSwitch && delta > 0)
				delta -= deceleration;
			else if (!skewSwitch && delta <= 0 && delta > -maxSpeed)
				delta -= acceleration;
			else if (!skewSwitch && delta < -maxSpeed)
				delta = -maxSpeed;
			
			temp += delta;
			
			var tempMatrix:Matrix = new Matrix();
			if (horizontalSkew)
				tempMatrix.c = temp * Math.PI/180;
			if (verticalSkew)
				tempMatrix.b = temp * Math.PI/180;
			tempMatrix.concat(object.transform.matrix);
			
			object.transform.matrix = tempMatrix;
			
		}
		
	}

}