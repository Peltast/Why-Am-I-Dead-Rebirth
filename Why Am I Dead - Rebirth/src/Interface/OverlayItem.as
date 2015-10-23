package Interface 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Peltast
	 */
	public class OverlayItem extends Sprite
	{
		private var parentOverlay:Overlay;
		
		protected var active:Boolean;
		protected var exclusiveActivity:Boolean;
		
		public function OverlayItem(overlayItem:OverlayItem, exclusiveActivity:Boolean) 
		{
			if (this != overlayItem) throw new Error("OverlayItem is meant to be used as an abstract class.");
			active = false;
			this.exclusiveActivity = exclusiveActivity;
		}
		
		public function setOverlay(parent:Overlay):void {
			parentOverlay = parent;
		}
		
		public function resetOverlayItem():void { }
		public function activateOverlayItem():void {
			active = true;
			
			if (exclusiveActivity && parentOverlay != null) parentOverlay.resetItems(this);
		}
		public function deactivateOverlayItem():void { 
			active = false;
		}
		
		public function isActive():Boolean { return active; }
		public function requiresExclusiveActivity():Boolean { return exclusiveActivity; }
	}

}