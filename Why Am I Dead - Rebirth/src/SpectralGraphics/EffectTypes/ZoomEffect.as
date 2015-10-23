package SpectralGraphics.EffectTypes 
{
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class ZoomEffect extends SpectralEffect
	{
		private var xZoom:Boolean;
		private var yZoom:Boolean;
		private var acceleration:Number;
		private var deceleration:Number;
		private var maxSpeed:Number;
		private var magnification:Number
		
		private var oscillate:Boolean;
		private var zoomSwitch:Boolean;
		private var temp:Number;
		private var delta:Number;
		
		public function ZoomEffect(xZoom:Boolean, yZoom:Boolean, acc:Number, dec:Number, maxSpeed:Number, mag:Number, oscillate:Boolean = true) 
		{
			super(this);
			
			this.xZoom = xZoom;
			this.yZoom = yZoom;
			this.acceleration = acc;
			this.deceleration = dec;
			this.maxSpeed = maxSpeed;
			this.magnification = mag;
			this.oscillate = oscillate;
			
			zoomSwitch = true;
			temp = 0;
			delta = 0;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			
			if (zoomSwitch && temp > magnification) {
				if(oscillate)
					zoomSwitch = !zoomSwitch;
				else {
					delta = 0;
					acceleration = 0;
				}
			}
			else if (!zoomSwitch && temp < -magnification) {
				if(oscillate)
					zoomSwitch = !zoomSwitch;
				else {
					delta = 0;
					acceleration = 0;
				}
			}
			
			if (zoomSwitch && delta < 0)
				delta += deceleration;
			else if (zoomSwitch && delta >= 0 && delta < maxSpeed)
				delta += acceleration;
			else if (zoomSwitch && delta > maxSpeed)
				delta = maxSpeed;
			
			else if (!zoomSwitch && delta > 0)
				delta -= deceleration;
			else if (!zoomSwitch && delta <= 0 && delta > -maxSpeed)
				delta -= acceleration;
			else if (!zoomSwitch && delta < -maxSpeed)
				delta = -maxSpeed;
			
			if (xZoom)
				object.scaleX += delta;
			if(yZoom)
				object.scaleY += delta;
			
			temp += delta;
		}
	}

}