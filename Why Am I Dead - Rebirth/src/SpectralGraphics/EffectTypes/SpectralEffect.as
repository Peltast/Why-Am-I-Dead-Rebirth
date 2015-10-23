package SpectralGraphics.EffectTypes
{
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SpectralEffect 
	{
		private var layer:SpectralLayer;
		private var imgWidth:int;
		private var imgHeight:int;
		private var perObject:Boolean;
		
		public function SpectralEffect(effect:SpectralEffect, perObject:Boolean = true) 
		{
			if (effect != this) throw new Error("SpectralEffect is supposed to be used only as an abstract class!");
			this.perObject = perObject;
		}
		
		public function setLayer(layer:SpectralLayer):void { this.layer = layer; }
		
		public function applyEffect(object:SpectralObject, layer:SpectralLayer):void {
			
		}
		
		public function isPerObject():Boolean { return perObject; }
		
	}

}