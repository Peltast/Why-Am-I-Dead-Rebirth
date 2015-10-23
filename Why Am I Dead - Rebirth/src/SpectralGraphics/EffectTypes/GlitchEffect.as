package SpectralGraphics.EffectTypes 
{
	import flash.geom.Rectangle;
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Peltast
	 */
	public class GlitchEffect extends SpectralEffect
	{
		private var frequency:int;
		private var noise:int;
		private var degree:int;
		private var xAxis:Boolean;
		private var yAxis:Boolean;
		private var glitchCount:int;
		private var xDiff:int;
		private var yDiff:int;
		private var glitchBounds:Rectangle;
		
		public function GlitchEffect(frequency:int, noise:int, degree:int, xAxis:Boolean, yAxis:Boolean, bounds:Rectangle = null) 
		{
			super(this);
			
			this.frequency = frequency;
			this.degree = degree;
			this.noise = noise;
			this.xAxis = xAxis;
			this.yAxis = yAxis;
			this.glitchBounds = bounds;
			this.xDiff = 0;
			this.yDiff = 0;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			glitchCount++;
			
			// Frequency is the minimum amount of time between glitches
			if (glitchCount <= frequency)
				return;
			else
				glitchCount = 0;
			
			var xDieRoll:int;
			var yDieRoll:int;
			
			while (true) {
				var dieRoll:int = Math.random() * 100;
				if (dieRoll > noise) { // Noise is the percentage of times that the effect doesn't fire, to add
										// more randomness to the effect.
					if (xAxis)
						xDieRoll = (Math.random() * (degree * 2)) - degree;
					if (yAxis)
						yDieRoll = (Math.random() * (degree * 2)) - degree;
				}
				else return;
				
				if (glitchBounds == null) break;
				else if (checkBounds(xDieRoll, true) && checkBounds(yDieRoll, false)) break;
			}
			object.x += xDieRoll;
			object.y += yDieRoll;
			xDiff += xDieRoll;
			yDiff += yDieRoll;
		}
		
		private function checkBounds(newRoll:int, xAxis:Boolean):Boolean {
			if (xAxis) {
				if (newRoll + xDiff <= glitchBounds.width && newRoll + xDiff >= glitchBounds.x)
					return true;
				else 
					return false;
			}
			else {
				if (newRoll + yDiff <= glitchBounds.height && newRoll + yDiff >= glitchBounds.y)
					return true;
				else 
					return false;
			}
		}
		
	}

}