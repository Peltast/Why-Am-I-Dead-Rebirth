package SpectralGraphics.EffectTypes 
{
	import air.update.ApplicationUpdater;
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Peltast
	 */
	public class BlinkEffect extends SpectralEffect
	{
		private var blinkingObjects:Vector.<SpectralObject>;
		
		private var frequency:int;
		private var duration:int;
		private var alpha:Number;
		private var noise:int;
		
		private var timer:int;
		private var objectsOn:Boolean;
		
		public function BlinkEffect(blinkingObjects:Vector.<SpectralObject>, frequency:int, duration:int, alpha:Number, noise:int) 
		{
			super(this, false);
			this.blinkingObjects = blinkingObjects;
			this.frequency = frequency;
			this.duration = duration;
			this.alpha = alpha;
			this.noise = noise;
			
			this.timer = 0;
			this.objectsOn = false;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			timer++;
			
			var diceRoll:int = Math.random() * 100;
			
			if (timer > frequency && !objectsOn) {
				
				timer = 0;
				
				objectsOn = true;
				
				for each(var object:SpectralObject in blinkingObjects)
					layer.addObject(object, 0, 0);
			}
			else if (timer > duration && objectsOn) {
				
				timer = 0;
				
				if (diceRoll < noise) return;
				objectsOn = false;
				
				for each(object in blinkingObjects)
					layer.removeObject(object);
			}
			
		}
		
	}

}