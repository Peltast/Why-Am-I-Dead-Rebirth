package Interface.MenuSystem 
{
	import adobe.utils.CustomActions;
	import Characters.CharacterManager;
	import Core.Game;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Maps.MapManager;
	import Setup.GameLoader;
	/**
	 * ...
	 * @author Peltast
	 */
	public class MenuBox extends Sprite
	{
		private var menuSkin:Bitmap;
		
		public function MenuBox(bounds:Rectangle, skin:Bitmap)
		{
			bounds = new Rectangle(Math.round(bounds.x), Math.round(bounds.y), 
				Math.round(bounds.width), Math.round(bounds.height));
			this.menuSkin = skin;
			
			drawMenuBox(bounds);
		}
		
		public function redrawBounds(bounds:Rectangle):void {
			bounds = new Rectangle(Math.round(bounds.x), Math.round(bounds.y), 
				Math.round(bounds.width), Math.round(bounds.height));
			while (this.numChildren > 0)
				this.removeChildAt(0);
			drawMenuBox(bounds);
		}
		
		private function drawMenuBox(bounds:Rectangle):void {
			var tileSize:int = Game.getTileSize();
			
			if (bounds.height == 0 || bounds.width == 0) return;
			
			// First, the four corners.
			
			var xSpace:int;
			var ySpace:int;
			if (bounds.width >= tileSize * 2) xSpace = tileSize;
			else xSpace = bounds.width / 2;
			if (bounds.height >= tileSize * 2) ySpace = tileSize;
			else ySpace = bounds.height / 2;
			var xDifference:int = tileSize - xSpace;
			var yDifference:int = tileSize - ySpace;
			
			var topLeftCorner:Bitmap = new Bitmap(new BitmapData(xSpace, ySpace));
			var topRightCorner:Bitmap = new Bitmap(new BitmapData(xSpace, ySpace));
			var bottomLeftCorner:Bitmap = new Bitmap(new BitmapData(xSpace, ySpace));
			var bottomRightCorner:Bitmap = new Bitmap(new BitmapData(xSpace, ySpace));
			
			topLeftCorner.bitmapData.copyPixels
				(menuSkin.bitmapData, new Rectangle(0, 0, xSpace, ySpace), new Point());
			topRightCorner.bitmapData.copyPixels
				(menuSkin.bitmapData, new Rectangle(tileSize * 2 + xDifference, 0, xSpace, ySpace), new Point());
			bottomLeftCorner.bitmapData.copyPixels
				(menuSkin.bitmapData, new Rectangle(0, tileSize * 2 + yDifference, xSpace, ySpace), new Point());
			bottomRightCorner.bitmapData.copyPixels
				(menuSkin.bitmapData, new Rectangle(tileSize * 2 + xDifference, tileSize * 2 + yDifference,
				xSpace, ySpace), new Point());
			
			topRightCorner.x = bounds.width - tileSize + xDifference - 1;
			bottomLeftCorner.y = bounds.height - tileSize + yDifference - 1;
			bottomRightCorner.x = bounds.width - tileSize + xDifference - 1;
			bottomRightCorner.y = bounds.height - tileSize + yDifference - 1;
			
			// The sides and center.
			
			var boxWidth:int = topRightCorner.x - tileSize;
			var boxHeight:int = bottomLeftCorner.y - tileSize;
			
			var topSide:Bitmap = new Bitmap(new BitmapData(xSpace, ySpace));
			var bottomSide:Bitmap = new Bitmap(new BitmapData(xSpace, ySpace));
			topSide.smoothing = false;
			bottomSide.smoothing = false;
			topSide.bitmapData.copyPixels
				(menuSkin.bitmapData, new Rectangle(tileSize, 0, xSpace, ySpace), new Point());
			bottomSide.bitmapData.copyPixels
				(menuSkin.bitmapData, new Rectangle
					(tileSize, tileSize * 2 + yDifference, xSpace, ySpace), new Point());
			topSide.x = xSpace;
			topSide.scaleX = (boxWidth + 5) / topSide.width;
			bottomSide.x = xSpace;
			bottomSide.y = boxHeight + ySpace + yDifference;
			bottomSide.scaleX = (boxWidth + 5) / bottomSide.width;
			this.addChild(topSide);
			this.addChild(bottomSide);
			
			var leftSide:Bitmap = new Bitmap(new BitmapData(tileSize, tileSize));
			var rightSide:Bitmap = new Bitmap(new BitmapData(tileSize, tileSize));
			leftSide.smoothing = false;
			rightSide.smoothing = false;
			leftSide.bitmapData.copyPixels
				(menuSkin.bitmapData, new Rectangle(0, tileSize, tileSize, tileSize), new Point());
			rightSide.bitmapData.copyPixels
				(menuSkin.bitmapData, new Rectangle
					(tileSize * 2, tileSize, tileSize, tileSize), new Point());
			leftSide.y = tileSize;
			leftSide.scaleY = boxHeight / leftSide.height;
			rightSide.x = boxWidth + xSpace;
			rightSide.y = tileSize;
			rightSide.scaleY = boxHeight / rightSide.height;
			this.addChild(leftSide);
			this.addChild(rightSide);
			
			var center:Bitmap = new Bitmap(new BitmapData(tileSize, tileSize));
			
			center.bitmapData.copyPixels
				(menuSkin.bitmapData, new Rectangle(tileSize, tileSize, tileSize, tileSize), new Point());
			center.smoothing = false;
			center.x = tileSize;
			center.y = tileSize;
			center.scaleX = boxWidth / center.width;
			center.scaleY = boxHeight / center.height;
			
			this.addChild(center);
			this.addChild(topLeftCorner);
			this.addChild(topRightCorner);
			this.addChild(bottomLeftCorner);
			this.addChild(bottomRightCorner);
		}
		
	}

}