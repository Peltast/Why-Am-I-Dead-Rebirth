package SpectralGraphics.EffectTypes 
{
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Peltast
	 */
	public class FadeEffect extends SpectralEffect
	{
		private var startAlpha:Number;
		private var endAlpha:Number;
		private var delta:Number;
		
		private var initiateLayer:SpectralLayer;
		private var currentAlpha:Number;
		private var fadeOut:Boolean;
		
		public function FadeEffect(startAlpha:Number, endAlpha:Number, delta:Number) 
		{
			super(this, false);
			
			this.startAlpha = startAlpha;
			this.endAlpha = endAlpha;
			this.delta = delta;
			
			this.currentAlpha = startAlpha;
			if (endAlpha < startAlpha) fadeOut = true;
			else fadeOut = false;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			super.applyEffect(object, layer);
			
			if (layer != initiateLayer) {
   				layer.alpha = startAlpha;
				currentAlpha = startAlpha;
				initiateLayer = layer;
			}
			
			if (fadeOut && currentAlpha <= endAlpha) return;
			else if (!fadeOut && currentAlpha >= endAlpha) return;
			
			if (fadeOut) currentAlpha -= delta;
			else currentAlpha += delta;
			
			if (currentAlpha > 1 || currentAlpha < 0) return;
			layer.alpha = currentAlpha;
		}
		
	}

}