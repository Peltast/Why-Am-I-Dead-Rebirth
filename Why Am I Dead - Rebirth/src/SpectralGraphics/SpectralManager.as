 package SpectralGraphics 
{
	import Characters.Character;
	import Cinematics.Trigger;
	import Core.Game;
	import Core.SpectralState;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display3D.textures.RectangleTexture;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.sampler.NewObjectSample;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import Props.SpectralImageProp;
	import Setup.GameLoader;
	import SpectralGraphics.EffectTypes.*;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SpectralManager 
	{
		private static var singleton:SpectralManager;
		private var specGraphics:Dictionary;
		private var mindReadThemes:Dictionary;
		
		public static function getSingleton():SpectralManager {
			if (singleton == null)
				singleton = new SpectralManager();
			return singleton;
		}
		
		public function SpectralManager() 
		{
			var objectFactory:ObjectFactory = new ObjectFactory();
			specGraphics = new Dictionary();
			mindReadThemes = new Dictionary();
			
			var stageWidth:int = Main.getSingleton().getStageWidth();
			var stageHeight:int = Main.getSingleton().getStageHeight();
			
			var tutorialOne:SpectralImage = new SpectralImage(1, 128, 128);
			tutorialOne.addObject(0, new SpectralBitmap(new GameLoader.Tutorial1() as Bitmap, 0, 1, 128, 128), 0, 0);
			tutorialOne.addEffect(0, new WaveEffect(false, .1, .05, 1, 2));
			specGraphics["Tutorial1"] = tutorialOne;
			
			var tutorialTwo:SpectralImage = new SpectralImage(1, 96, 128);
			tutorialTwo.addObject(0, new SpectralBitmap(new GameLoader.Tutorial2() as Bitmap, 0, 1, 96, 128), 0, 0);
			tutorialTwo.addEffect(0, new WaveEffect(false, .1, .05, 1, 2));
			specGraphics["Tutorial2"] = tutorialTwo;
			
			var tutorialThree:SpectralImage = new SpectralImage(1, 96, 96);
			tutorialThree.addObject(0, new SpectralBitmap(new GameLoader.Tutorial3() as Bitmap, 0, 1, 96, 96), 0, 0);
			tutorialThree.addEffect(0, new WaveEffect(false, .1, .05, 1, 2));
			specGraphics["Tutorial3"] = tutorialThree;
			
			var tutorialFour:SpectralImage = new SpectralImage(1, 128, 96);
			tutorialFour.addObject(0, new SpectralBitmap(new GameLoader.Tutorial4() as Bitmap, 0, 1, 128, 96), 0, 0);
			tutorialFour.addEffect(0, new WaveEffect(false, .1, .05, 1, 2));
			specGraphics["Tutorial4"] = tutorialFour;
			
		}
		
		public function getSpecGraphic(name:String):SpectralImage {
			return specGraphics[name];
		}
		public function getMindReadTheme(host:Character):String {
			if (host == null) return "";
			return mindReadThemes[host.getName()];
		}
		
		public function listenToTrigger(parsedRequirement:Array):Boolean {
			
			return false;
		}
		
		public function performTriggerEffect(parsedEffect:Array):void {
			
			if (parsedEffect[0] == "startSpectralState") {
				var spectralImg:String = parsedEffect[1];
				var keyEscape:Boolean = true;
				if (parsedEffect[2] == "true") keyEscape = true;
				else if (parsedEffect[2] == "false") keyEscape = false;
				if (parsedEffect.length > 3) var duration:int = parseInt(parsedEffect[3]);
				
				if (specGraphics[spectralImg] != null)
					Game.pushState(new SpectralState(spectralImg, keyEscape, duration));
			}
			else if (parsedEffect[0] == "endSpectralState") {
				if (Game.getState() is SpectralState) {
					Game.popState();
				}
			}
			
			else if (parsedEffect[0] == "addToSpectralImage") {
				var addToSpecImg:String = parsedEffect[1];
				var specImgToAdd:String = parsedEffect[2];
				var layerIndex:int = parseInt(parsedEffect[3]);
				var offsetX:int = parseInt(parsedEffect[4]);
				var offsetY:int = parseInt(parsedEffect[5]);
				
				if (specGraphics[addToSpecImg] == null || specGraphics[specImgToAdd] == null) return;
				
				specGraphics[addToSpecImg].addSpectralImage(layerIndex, specGraphics[specImgToAdd], offsetX, offsetY);
			}
			else if (parsedEffect[0] == "removeFromSpectralImage") {
				var removeFromSpecImage:String = parsedEffect[1];
				var specImageToRemove:String = parsedEffect[2];
				layerIndex = parseInt(parsedEffect[3]);
				
				if (specGraphics[removeFromSpecImage] == null || specGraphics[specImageToRemove] == null) return;
				
				specGraphics[removeFromSpecImage].removeSpectralImage(layerIndex, specGraphics[specImageToRemove]);
			}
			
		}
		
		
		public function findVacantArea(bounds:Rectangle, boundList:Array, area:Rectangle):Point {
			var k:int = 0;
			var intersects:Boolean = true;
			var objectCenter:Point = new Point(bounds.width / 2, bounds.height / 2);
			
			while (k < 15) {
				intersects = false;
				var randomX:int = (Math.random() * (area.width - objectCenter.x - area.x)) + area.x;
				var randomY:int = (Math.random() * (area.height - objectCenter.y - area.y)) + area.y;
				
				for (var i:int = 0; i < boundList.length; i++) {
					var tempSpectralObj:SpectralObject = boundList[i] as SpectralObject;
					var tempRectangle:Rectangle = new Rectangle
						(tempSpectralObj.x, tempSpectralObj.y, tempSpectralObj.width, tempSpectralObj.height);
					if (tempRectangle.containsPoint(new Point(randomX, randomY)))
						intersects = true;
				}
				if (!intersects) {
					return new Point(randomX, randomY);
				}
				k++;
			}
			return null;
		}
		
		
	}

}