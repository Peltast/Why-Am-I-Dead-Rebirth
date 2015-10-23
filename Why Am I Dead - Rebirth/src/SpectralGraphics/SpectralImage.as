package SpectralGraphics
{
	import adobe.utils.CustomActions;
	import Core.Game;
	import flash.display.Sprite;
	import flash.events.Event;
	import SpectralGraphics.EffectTypes.SpectralEffect;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SpectralImage extends SpectralObject
	{
		private var noLayers:int;
		private var layers:Vector.<SpectralLayer>;
		private var imgWidth:int;
		private var imgHeight:int;
		
		public function SpectralImage(noLayers:int, width:int, height:int) 
		{
			super(this, 0xffffff, 1, 0, 0);
			
			imgWidth = width;
			imgHeight = height;
			layers = new Vector.<SpectralLayer>();
			this.noLayers = noLayers;
			
			for (var i:int = 0; i < noLayers; i++) {
				layers.push(new SpectralLayer());
				this.addChild(layers[i]);
			}
		}
		
		public function beginImage():void {
			Game.getSingleton().stage.addEventListener(Event.ENTER_FRAME, updateImage);
		}
		public function stopImage():void {
			Game.getSingleton().stage.removeEventListener(Event.ENTER_FRAME, updateImage);
		}
		
		private function updateImage(event:Event):void {
			
			for (var i:int = 0; i < layers.length; i++) {
				layers[i].updateLayer();
			}
		}
		
		public function getImageWidth():int { return imgWidth; }
		public function getImageHeight():int { return imgHeight; }
		public function getLayerAlpha(index:int):Number { return layers[index].alpha; }
		
		public function addSpectralImage(layerIndex:int, specImage:SpectralImage, offsetX:int, offsetY:int):void {
			if (layerIndex<0|| layerIndex>layers.length-1)return;
			
			layers[layerIndex].addSpectralImage(specImage, offsetX, offsetY);
		}
		public function addObject(layerIndex:int, object:SpectralObject, offsetX:int, offsetY:int):void {
			if (layerIndex<0 || layerIndex > layers.length - 1) return;
			
			layers[layerIndex].addObject(object, offsetX, offsetY);
		}
		public function addEffect(layerIndex:int, effect:SpectralEffect):void {
			if (layerIndex<0||layerIndex>layers.length-1) return;
			
			layers[layerIndex].addEffect(effect);
		}
		
		public function removeSpectralImage(layerIndex:int, specImage:SpectralImage):void {
			if (layerIndex < 0 || layerIndex > layers.length - 1) return;
			
			layers[layerIndex].removeSpectralImage(specImage);
		}
		public function removeSpectralObject(layerIndex:int, specObj:SpectralObject):void {
			if (layerIndex < 0 || layerIndex > layers.length - 1) return;
			
			layers[layerIndex].removeObject(specObj);
		}
		public function removeEffect(layerIndex:int, reverseEffect:Boolean = false):void {
			if (layerIndex < 0 || layerIndex > layers.length - 1) return;
			
			layers[layerIndex].removeEffect(reverseEffect);
		}
		
		public function clearImage():void {
			layers = new Vector.<SpectralLayer>();
			
			for (var i:int = 0; i < noLayers; i++) {
				layers.push(new SpectralLayer());
				this.addChild(layers[i]);
			}
		}
		
		public function setImageAlpha(newAlpha:Number):void {
			for each(var layer:SpectralLayer in layers)
				layer.setAlpha(newAlpha);
			this.alpha = newAlpha;
		}
		
		public override function getClone():SpectralObject{
			var clone:SpectralImage = new SpectralImage(noLayers, imgWidth, imgHeight);
			for (var j:int = noLayers - 1; j >= 0; j--)
				clone.removeChildAt(j);
			for (var i:int = 0; i < noLayers; i++) {
				clone.layers[i] = this.layers[i].getClone();
				clone.addChild(clone.layers[i]);
			}
			
			return clone;
		}
	}

}