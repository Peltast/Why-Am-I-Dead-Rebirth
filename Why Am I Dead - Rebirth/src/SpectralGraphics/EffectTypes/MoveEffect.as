package SpectralGraphics.EffectTypes 
{
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class MoveEffect extends SpectralEffect
	{
		private var speedX:int;
		private var speedY:int;
		
		public function MoveEffect(speedX:int, speedY:int) 
		{
			super(this);
			this.speedX = speedX;
			this.speedY = speedY;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			object.x += speedX;
			object.y += speedY;
		}
		
	}

}