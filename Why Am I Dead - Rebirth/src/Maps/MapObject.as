package Maps 
{
	import adobe.utils.CustomActions;
	import Core.Game;
	import flash.display.BitmapData;
	import Setup.GameLoader;
	import SpectralGraphics.*;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class MapObject extends Sprite
	{
		
		protected var objectBmp:Bitmap;
		protected var collidable:Boolean;
		
		// The collision boundaries relative to the origin of the object's bitmap.
		protected var relativeBounds:Rectangle;
		
		// The boundaries that this object has on instantiation.
		protected var regularBounds:Rectangle;
		
		// The boundaries actively being used.  In the situation of a character whose dimensions change
		//		depending on their animation, regularBounds and currentBounds may not be the same.
		protected var currentBounds:Rectangle;
		
		// The boundaries that are used to find the objects in this object's surrounding area for interaction.
		protected var actionBounds:Rectangle;
		
		// The boundaries that are used to find the objects in this object's surrounding area for potential collision.
		protected var wideBounds:Rectangle;
		
		// Temporary rectangle used and reused to store information being returned.  Used to reduce garbage collection.
		protected var outputBounds:Rectangle;
		
		// If not given any dimensions, we will use a default value.
		protected var defaultBounds:Rectangle;
		
		protected var zPosition:int;
		protected var elevation:int;
		protected var spectralOverlay:SpectralImage;
		protected var personalOverlay:SpectralImage;
		protected var spectralBmpMask:SpectralBitmap;
		protected var personalBmpMask:SpectralBitmap;
		
		public function MapObject(obj:MapObject, objectBmp:Bitmap, collidable:Boolean, bounds:Rectangle, xCoord:int, yCoord:int)
		{
			if (obj != this) throw new Error("MapObject is meant to be used as an abstract class.");
			
			this.relativeBounds = new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
			this.regularBounds = new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
			this.currentBounds = new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
			this.outputBounds = new Rectangle();
			this.defaultBounds = new Rectangle(4, 40, -8, -40);
			this.objectBmp = objectBmp;
			this.collidable = collidable;
			
			this.x = xCoord;
			this.y = yCoord;
			if(objectBmp != null)
				this.addChild(objectBmp);
			
		}
		protected function createActionBounds():void { }
		protected function createWideBounds():void { }
		
		
		public function intersectsObject(mapObject:MapObject, checkCollidable:Boolean):Boolean { return true; }
		
		
		public function getObjectBounds():Rectangle {
			if (currentBounds != null) {
				
				prepareBoundsOutput(currentBounds);
				return outputBounds;
			}
			else {
				var child:DisplayObject = getChildAt(0);
				prepareBoundsOutput(defaultBounds);
				outputBounds.width += child.width;
				outputBounds.height += child.height;
				return outputBounds;
			}
		}
		public function getWideBounds():Rectangle {
			prepareBoundsOutput(wideBounds);
			return outputBounds;
		}
		public function getActionBounds():Rectangle {
			prepareBoundsOutput(actionBounds);
			return outputBounds;
		}
		public function getDefaultBounds():Rectangle {
			outputBounds = new Rectangle(defaultBounds.x, defaultBounds.y, defaultBounds.width, defaultBounds.height);
			return outputBounds;
		}
		
		// Sets outputBounds to the dimensions of a given rectangle.
		protected function prepareBoundsOutput(rectangle:Rectangle):void {
			outputBounds.x = rectangle.x + this.x;
			outputBounds.y = rectangle.y + this.y;
			outputBounds.width = rectangle.width;
			outputBounds.height = rectangle.height;
		}
		
		public function isCollidable():Boolean { return collidable; }
		public function getZPosition():int { return zPosition; }
		public function getElevation():int { return elevation; }
		
		public function setZPosition(newZ:int):void {
			zPosition = newZ;
			objectBmp.y = -newZ - elevation;
		}
		public function setElevation(newElevation:int):void {
			elevation = newElevation;
			objectBmp.y = -newElevation - zPosition;
		}
		
		public function getNearestTilePoint():Point {
			var child:DisplayObject = getChildAt(0);
			var tileSize:int = Game.getTileSize();
			var bounds:Rectangle = getObjectBounds();
			
			if (bounds != null) {
				var xCoord:int = Math.round
					((bounds.x + bounds.width / 2) / tileSize - .5);
				var yCoord:int = Math.round
					((bounds.y + bounds.height / 2) / tileSize - .5);
			}
			else {
				xCoord = Math.round
					((child.x + this.x + 4 + (child.width - 8) / 2) / tileSize - .5);
				yCoord = Math.round
					((child.y + this.y + 40 + (child.height - 40) / 2) / tileSize - .5);
			}
			return new Point(xCoord, yCoord);
		}
		public function tileContainsObject(tile:Point):Boolean {
			
			var bounds:Rectangle = this.getObjectBounds();
			var tileSize:int = Game.getTileSize();
			var tileBound:Rectangle = new Rectangle(tile.x * tileSize, tile.y * tileSize, tileSize, tileSize);
			
			return(tileBound.containsRect(bounds));
		}
		
		public function imageContainsSpectralOverlay(specImage:SpectralImage):Boolean {
			if (spectralOverlay == null || specImage == null) return false;
			return specImage.contains(spectralOverlay);
		}
		
		public function setSpectralOverlay(specImage:SpectralImage):void {
			if(spectralOverlay != null)
				if (this.contains(spectralOverlay))
					this.removeChild(spectralOverlay);
			specImage.beginImage();
			spectralOverlay = specImage;
			this.addChild(spectralOverlay);
		}
		public function removeSpectralOverlay(hostImage:SpectralImage):void {
			if (spectralOverlay == null) return;
			
			if (hostImage.contains(spectralOverlay)) {
				hostImage.removeChild(spectralOverlay);
			}
			spectralOverlay.stopImage();
			spectralBmpMask = null;
			spectralOverlay = null;
		}
		public function setSpectralMask(specImage:SpectralImage, hostImage:SpectralImage,
										layer:int, color:uint, threshold:uint = 0, alpha:Number = 1):void {
			spectralBmpMask = new SpectralBitmap
				(generateSpectralMask(color, threshold), color, 1, objectBmp.width, objectBmp.height, threshold);
			spectralBmpMask.alpha = alpha;
			specImage.addObject(layer, spectralBmpMask, 0, 0);
			specImage.beginImage();
			spectralOverlay = specImage;
			spectralOverlay.x = this.x;
			spectralOverlay.y = this.y;
			hostImage.addChild(spectralOverlay);
		}
		public function updateSpectralMask():void {
			if (spectralBmpMask != null) {
				spectralBmpMask.setBitmap(generateSpectralMask(spectralBmpMask.getColor(), spectralBmpMask.getColorThreshold()));
				spectralOverlay.x = this.x;
				spectralOverlay.y = this.y - this.getZPosition() - this.getElevation();
			}
			if (personalBmpMask != null && personalOverlay != null) {
				personalBmpMask.setBitmap(generateSpectralMask(personalBmpMask.getColor(), personalBmpMask.getColorThreshold()));
				personalOverlay.y = -this.getZPosition() - this.getElevation();
				this.addChild(personalOverlay);
			}
		}
		
		public function setPersonalMask(specImage:SpectralImage, layer:int, color:uint, threshold:uint = 0, alpha:Number = 1):void {
			if (personalOverlay != null)
				if (this.contains(personalOverlay))
					this.removeChild(personalOverlay);
			
			personalBmpMask = new SpectralBitmap
				(generateSpectralMask(color, threshold), color, 1, objectBmp.width, objectBmp.height, threshold);
			personalBmpMask.alpha = alpha;
			specImage.addObject(layer, personalBmpMask, 0, 0);
			specImage.beginImage();
			personalOverlay = specImage;
			personalOverlay.x = 0;
			personalOverlay.y = 0;
			this.addChild(personalOverlay);
		}
		public function removePersonalOverlay():void {
			if (personalOverlay == null) return;
			
			if (this.contains(personalOverlay)) {
				this.removeChild(personalOverlay);
			}
			personalOverlay.stopImage();
			personalOverlay = null;
		}
		
		private function generateSpectralMask(color:uint, threshold:uint):Bitmap {
			var maskBitmapData:BitmapData = this.objectBmp.bitmapData.clone();
			var maskBounds:Rectangle = new Rectangle(0, 0, maskBitmapData.width, maskBitmapData.height);
			maskBitmapData.threshold(maskBitmapData, maskBounds, new Point(), ">", threshold, color, 0xffffffff, true);
			return new Bitmap(maskBitmapData);
		}
		
	}

}