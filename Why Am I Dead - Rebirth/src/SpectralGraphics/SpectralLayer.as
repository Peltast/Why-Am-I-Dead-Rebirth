package SpectralGraphics 
{
	import flash.display.Sprite;
	import SpectralGraphics.EffectTypes.SpectralEffect;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SpectralLayer extends Sprite
	{
		private var layerObjects:Vector.<SpectralObject>;
		private var layerEffects:Vector.<SpectralEffect>;
		
		public function SpectralLayer() 
		{
			layerObjects = new Vector.<SpectralObject>();
			layerEffects = new Vector.<SpectralEffect>();
		}
		
		public function updateLayer():void {
			
			for (var i:int = 0; i < layerEffects.length; i++) {
				var tempEffect:SpectralEffect = layerEffects[i];
				
				if(tempEffect.isPerObject()){
					for (var j:int = 0; j < layerObjects.length; j++) {
						var tempObject:SpectralObject = layerObjects[j];
						
						tempEffect.applyEffect(tempObject, this);
					}
				}
				else tempEffect.applyEffect(null, this);
			}
		}
		
		public function addSpectralImage(object:SpectralImage, offsetX:int, offsetY:int):void {
			object.x += offsetX;
			object.y += offsetY;
			layerObjects.push(object);
			this.addChild(object);
		}
		public function addObject(object:SpectralObject, offsetX:int, offsetY:int):void {
			object.x += offsetX;
			object.y += offsetY;
			layerObjects.push(object);
			this.addChild(object);
		}
		
		public function removeSpectralImage(object:SpectralImage):void {
			for (var i:int = 0; i < layerObjects.length; i++) {
				if (layerObjects[i] == object) {
					this.removeChild(layerObjects[i]);
					layerObjects.splice(i, 1);
					return;
				}
			}
		}
		public function removeObject(object:SpectralObject):void {
			for (var i:int = 0; i < layerObjects.length; i++) {
				if (layerObjects[i] == object) {
					this.removeChild(layerObjects[i]);
					layerObjects.splice(i, 1);
					return;
				}
			}
		}
		public function addEffect(effect:SpectralEffect):void {
			layerEffects.push(effect);
			effect.setLayer(this);
		}
		public function removeEffect(reverseEffect:Boolean):void {
			if (layerEffects.length == 0) return;
			
			var effect:SpectralEffect = layerEffects[layerEffects.length - 1];
			if (reverseEffect) {
				for each(var object:SpectralObject in layerObjects)
					object.reverseEffect(effect);
			}
			layerEffects.pop();
		}
		
		public function setAlpha(newAlpha:Number):void {
			for each(var spectralObject:SpectralObject in layerObjects) {
				for (var i:int = 0; i < spectralObject.numChildren; i++) {
					spectralObject.getChildAt(i).alpha = newAlpha;
				}
			}
		}
		
		public function getNoOfObjects():int {
			return layerObjects.length;
		}
		
		public function getClone():SpectralLayer {
			var newLayer:SpectralLayer = new SpectralLayer();
			
			for each(var spectralObj:SpectralObject in layerObjects) {
				newLayer.addObject(spectralObj.getClone(), spectralObj.x, spectralObj.y);
			}
			for each(var spectralEffect:SpectralEffect in layerEffects) {
				newLayer.addEffect(spectralEffect);
			}
			return newLayer;
		}
		
	}

}