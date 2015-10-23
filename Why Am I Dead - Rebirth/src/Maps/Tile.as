package Maps 
{
	import Core.Game;
	import flash.display.Shape;
	import Interface.OverlayStack;
	import Main;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import Setup.GameLoader;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Tile extends Sprite
	{
		protected var tileType:int;
		protected var tileLoader:Loader;
		protected var tileBounds:Rectangle;
		protected var foreground:Boolean;
		protected var xCoord:int;
		protected var yCoord:int;
		
		public function Tile(index:int, tileSet:Bitmap, xCoord:int, yCoord:int, tileType:int)
		{
			var tileSize:int = Game.getTileSize();
			tileBounds = new Rectangle(xCoord * tileSize, yCoord * tileSize, tileSize, tileSize);
			this.xCoord = xCoord;
			this.yCoord = yCoord;
			this.tileType = tileType;
			
			if (tileType == 6 || tileType == 7)
				foreground = true;
			else foreground = false;
			
			var setWidth:int = tileSet.width / tileSize - 1;
			var setHeight:int = tileSet.height / tileSize - 1;
			var tempXCount:int = 0;
			var tempYCount:int = 0;
			for (var i:int = 1; i < index; i++) {
				tempXCount++;
				if (tempXCount > setWidth) {
					tempXCount = 0;
					tempYCount++;
				}
				if (tempYCount > setHeight)
					throw new Error("Error: Tileset loaded and tileset used in map file are not matching up.");
			}
			
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = new BitmapData(tileSize, tileSize);
			bitmap.bitmapData.copyPixels(tileSet.bitmapData, new Rectangle(tempXCount * tileSize, tempYCount * tileSize, tileSize, tileSize), new Point(0, 0));
			this.addChild(bitmap);
			
		}
		
		public function getTileType():int {
			return tileType;
		}
		public function isTileForeground():Boolean {
			return foreground;
		}
		public function getTileBounds():Rectangle {
			return tileBounds;
		}
		public function getTileCoords():Point { return new Point(xCoord, yCoord); }
		
		public function collidesWithTile(bounds:Rectangle):Boolean {
			// type 5 / 6 is for a solid passable block
			if (tileType == 5 || tileType == 6) {
				return false;
			}
			// type 0 / 7 is for a solid impassable block
			if (tileType == 0 || tileType == 7) {
				return true;
			}
			// type 1 is for a half block impassable on the northwest half
			else if (this.tileType == 1) {
				// we create a temporary triangle to simulate the block's bounds, and then delete it after
				// we've checked collision with it so we don't actually waste time drawing it.
				var triangleNW:Shape = new Shape();
				triangleNW.graphics.beginFill(0x000000);
				triangleNW.visible = false;
				triangleNW.graphics.moveTo(this.x - 5, this.y - 5);
				triangleNW.graphics.lineTo(this.x + this.width, this.y - 5);
				triangleNW.graphics.lineTo(this.x - 5, this.y + this.height);
				triangleNW.graphics.lineTo(this.x - 5, this.y - 5);
				Main.getSingleton().addChild(triangleNW);
				triangleNW.visible = true;
				if (triangleNW.hitTestPoint(bounds.x, bounds.y, true)) {
					Main.getSingleton().removeChild(triangleNW);
					return true;
				}
				Main.getSingleton().removeChild(triangleNW);
			}
			// type 2 is for a half block impassable on the northeast half
			else if (this.tileType == 2) {
				var triangleNE:Shape = new Shape();
				triangleNE.graphics.beginFill(0x000000);
				triangleNE.visible = false;
				triangleNE.graphics.moveTo(this.x + this.width + 5, this.y - 5);
				triangleNE.graphics.lineTo(this.x + this.width + 5, this.y + this.height);
				triangleNE.graphics.lineTo(this.x, this.y - 5);
				triangleNE.graphics.lineTo(this.x + this.width + 5, this.y - 5);
				Main.getSingleton().addChild(triangleNE);
				if (triangleNE.hitTestPoint(bounds.x + bounds.width , bounds.y, true )) {
					Main.getSingleton().removeChild(triangleNE);
					return true;
				}
				Main.getSingleton().removeChild(triangleNE);
			}
			// type 3 is for a half block impassable on the southwest half
			else if (this.tileType == 3) {
				var triangleSW:Shape = new Shape();
				triangleSW.graphics.beginFill(0x000000);
				triangleSW.visible = true;
				triangleSW.graphics.moveTo(this.x - 5, this.y);
				triangleSW.graphics.lineTo(this.x + this.width, this.y + this.height + 10);
				triangleSW.graphics.lineTo(this.x - 5, this.y + this.height + 10);
				triangleSW.graphics.lineTo(this.x - 5, this.y);
				Main.getSingleton().addChild(triangleSW);
				if (triangleSW.hitTestPoint(bounds.x, bounds.y + bounds.height, true )) {
					Main.getSingleton().removeChild(triangleSW);
					return true;
				}
				Main.getSingleton().removeChild(triangleSW);
			}
			// type 4 is for a half block impassable on the southeast half
			else if (this.tileType == 4) {
				var triangleSE:Shape = new Shape();
				triangleSE.graphics.beginFill(0x000000);
				triangleSE.visible = false;
				triangleSE.graphics.moveTo(this.x + this.width + 5, this.y);
				triangleSE.graphics.lineTo(this.x + this.width + 5, this.y + this.height + 10);
				triangleSE.graphics.lineTo(this.x, this.y + this.height + 10);
				triangleSE.graphics.lineTo(this.x + this.width + 5, this.y);
				Main.getSingleton().addChild(triangleSE);
				if (triangleSE.hitTestPoint(bounds.x + bounds.width , bounds.y + bounds.height, true )) {
					Main.getSingleton().removeChild(triangleSE);
					return true;
				}
				Main.getSingleton().removeChild(triangleSE);
			}
			
			return false;
		}
		
	}

}