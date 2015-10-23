package Interface.MenuSystem 
{
	import flash.geom.Rectangle;
	import Interface.OverlayItem;
	/**
	 * ...
	 * @author Peltast
	 */
	public class MenuTree extends Menu
	{
		
		private var currentMenu:Menu;
		
		public function MenuTree(exclusiveActivity:Boolean = false) 
		{
			// The inherited variables are pointless since this is a container;
			// the real menu will be via composition, not inheritance.
			super(true, new Rectangle(), null, exclusiveActivity);
			
		}
		
		public function setMenu(newMenu:Menu):void {
			if (currentMenu != null)
				this.removeMenuItem(currentMenu);
			currentMenu = newMenu;
			this.addMenuItem(currentMenu);
		}
		
		override public function resetOverlayItem():void 
		{
			super.resetOverlayItem();
			if (currentMenu != null)
				currentMenu.resetOverlayItem();
		}
		
	}

}