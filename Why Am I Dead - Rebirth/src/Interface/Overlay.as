package Interface 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Overlay
	{
		private var background:Shape;
		private var overlaySprite:Sprite;
		private var active:Boolean;
		
		public function Overlay(bgAlpha:Number = 0) 
		{
			overlaySprite = new Sprite();
			
			if (bgAlpha > 0) {
				background = new Shape();
				background.graphics.beginFill(0, bgAlpha);
				background.graphics.drawRect(0, 0, 540, 400);
				background.graphics.endFill();
			}
		}
		public function isActive():Boolean { return active; }
		
		public function addToOverlay(overlayItem:OverlayItem):void {
			overlayItem.setOverlay(this);
			overlaySprite.addChild(overlayItem);
		}
		public function removeFromOverlay(overlayItem:OverlayItem):void {
			if (overlaySprite.contains(overlayItem)) 
				overlaySprite.removeChild(overlayItem);
		}
		
		public function addOverlayToClient(client:Sprite):void {
			if (background != null)
				client.addChild(background);
			client.addChild(overlaySprite);
		}
		public function removeOverlayFromClient(client:Sprite):void {
			if (background != null)
				if(client.contains(background)) client.removeChild(background);
			if (client.contains(overlaySprite))
				client.removeChild(overlaySprite);
		}
		
		public function activateOverlay():void {
			for (var i:int = 0; i < overlaySprite.numChildren; i++) {
				var overlayItem:OverlayItem = overlaySprite.getChildAt(i) as OverlayItem;
				overlayItem.activateOverlayItem();
			}
			active = true;
		}
		public function deactivateOverlay():void {
			for (var i:int = 0; i < overlaySprite.numChildren; i++) {
				var overlayItem:OverlayItem = overlaySprite.getChildAt(i) as OverlayItem;
				overlayItem.deactivateOverlayItem();
			}
			active = false;
		}
		
		public function resetItems(item:OverlayItem):void {
			for (var i:int = 0; i < overlaySprite.numChildren; i++) {
				var overlayItem:OverlayItem = overlaySprite.getChildAt(i) as OverlayItem;
				if (item != overlayItem) overlayItem.resetOverlayItem();
			}
		}
		
		
		public function getX():int { return overlaySprite.x; }
		public function getY():int { return overlaySprite.y; }
		
		
	}

}