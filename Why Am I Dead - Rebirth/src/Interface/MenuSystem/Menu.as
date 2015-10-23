package Interface.MenuSystem 
{
	import Core.Game;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Interface.OverlayItem;
	import Setup.ControlsManager;
	/**
	 * ...
	 * @author Peltast
	 */
	public class Menu extends OverlayItem
	{
		private var menuBox:MenuBox;
		private var itemList:Vector.<OverlayItem>;
		private var activeItem:OverlayItem;
		private var selection:int;
		
		private var menuWidth:int;
		private var menuHeight:int;
		private var horizontal:Boolean;
		private var margins:Rectangle;
		
		private var keyless:Boolean;
		
		public function Menu(horizontal:Boolean, margins:Rectangle, menuBox:MenuBox = null, exclusiveActivity:Boolean = false, keyless:Boolean = false) 
		{
			super(this, exclusiveActivity);
			this.menuBox = menuBox;
			itemList = new Vector.<OverlayItem>();
			activeItem = null;
			selection = -1;
			
			this.menuWidth = 0;
			this.menuHeight = 0;
			this.horizontal = horizontal;
			this.margins = margins;
			this.keyless = keyless;
			
			if (menuBox != null) {
				menuBox.x = -margins.x - 5;
				menuBox.y = -margins.y - 5;
				this.addChild(menuBox);
			}
		}
		override public function resetOverlayItem():void 
		{
			super.resetOverlayItem();
			for each(var overlayItem:OverlayItem in itemList)
				if (overlayItem.isActive())
					overlayItem.resetOverlayItem();
		}
		override public function activateOverlayItem():void 
		{
			super.activateOverlayItem();
			if(!keyless) Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, keyboardSelection);
			Game.getSingleton().stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseSelection);
		}
		override public function deactivateOverlayItem():void 
		{
			super.deactivateOverlayItem();
			selection = -1;
			if(!keyless) Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, keyboardSelection);
			Game.getSingleton().stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseSelection);
			for each(var overlayItem:OverlayItem in itemList)
				if (overlayItem.isActive())
					overlayItem.deactivateOverlayItem();
		}
		
		public function addMenuItem(overlayItem:OverlayItem):void {
			if (overlayItem == null) return;
			
			itemList.push(overlayItem);
			this.addChild(overlayItem);
			
			if (horizontal) {
				overlayItem.y = margins.y;
				overlayItem.x = Math.ceil(menuWidth + margins.x);
			}
			else
				overlayItem.y = Math.ceil(menuHeight + margins.y);
			
			adjustItemPos(overlayItem);
			adjustBorders();
			
			if (this.active)
				overlayItem.activateOverlayItem();
		}
		protected function adjustItemPos(overlayItem:OverlayItem):void {
			
			if(!horizontal)
				overlayItem.x = Math.ceil((menuWidth / 2) - (overlayItem.width / 2) + margins.x);
		}
		
		protected function emptyMenu():void {
			while (itemList.length > 0)
				removeMenuItem(itemList[0]);
		}
		public function removeMenuItem(overlayItem:OverlayItem):void {
			if (overlayItem == null) return;
			
			overlayItem.deactivateOverlayItem();
			if (this.contains(overlayItem))
				this.removeChild(overlayItem);
			for (var i:int = 0; i < itemList.length; i++) {
				if (itemList[i] == overlayItem)
					itemList.splice(i, 1);
			}
			adjustBorders();
		}
		
		private function adjustBorders():void {
			var longestWidth:int = 0;
			var longestHeight:int = 0;
			
			for (var i:int = 0; i < itemList.length; i++) {
				var tempMenuItem:OverlayItem = itemList[i] as OverlayItem;
				
				if (tempMenuItem.width + tempMenuItem.x > longestWidth)
					longestWidth = tempMenuItem.width + tempMenuItem.x;
				if (tempMenuItem.height + tempMenuItem.y > longestHeight)
					longestHeight = tempMenuItem.height + tempMenuItem.y;
			}
			
			if (longestWidth != menuWidth || longestHeight != menuHeight) {
				menuWidth = longestWidth;
				menuHeight = longestHeight;
				
				if (menuBox != null)
					menuBox.redrawBounds(new Rectangle(this.x - margins.width * 2, this.y, 
						menuWidth + margins.width * 4, 5 + menuHeight + margins.height * 2));
			}
			for each(var item:OverlayItem in itemList)
				adjustItemPos(item);
		}
		
		private function keyboardSelection(keyboard:KeyboardEvent):void {
			if (activeItem is Menu) return;
			
			var inputDirection:int = keyboardInputDirection(keyboard);
			
			if (inputDirection == 0) // There's no reason to change the selection with irrelevant key presses. 
				return;					// In fact there's good reason not to, it can activate buttons at inconvenient times.
						// For instance if a button has an effect that deactivates it, this would reactivate it after the effect.
			changeSelection(selection + inputDirection);
		}
		private function keyboardInputDirection(keyboard:KeyboardEvent):int {
			if (horizontal) {
				if (checkKeyInput("Left Key", keyboard.keyCode) || checkKeyInput("Alt Left Key", keyboard.keyCode))
					return -1;
				else if (checkKeyInput("Right Key", keyboard.keyCode) || checkKeyInput("Alt Right Key", keyboard.keyCode))
					return 1;
			}
			else {
				if (checkKeyInput("Up Key", keyboard.keyCode) || checkKeyInput("Alt Up Key", keyboard.keyCode))
					return -1;
				else if (checkKeyInput("Down Key", keyboard.keyCode) || checkKeyInput("Alt Down Key", keyboard.keyCode))
					return 1;
			}
			return 0;
		}
		private function mouseSelection(mouse:MouseEvent):void {
			var i:int = 0;
			for each(var overlayItem:OverlayItem in itemList) {
				
				if (overlayItem.hitTestPoint(mouse.stageX, mouse.stageY)) {
					if (selection == i) return;
					
					changeSelection(i);
					for each(var otherItem:OverlayItem in itemList) {
						if (otherItem != overlayItem)
							otherItem.deactivateOverlayItem();
					}
					return;
				}
				i++;
				
			}
		}
		
		private function changeSelection(newSelection:int):void {
			if (itemList.length == 0) return;
			
			if (newSelection < 0) newSelection = 0;
			if (newSelection > itemList.length - 1) newSelection = itemList.length - 1;
			if (newSelection == selection) return;
			
			if (selection != -1) {
				if (itemList[selection].isActive())
					itemList[selection].deactivateOverlayItem();
			}
			selection = newSelection;
			if(!itemList[selection].isActive())
				itemList[selection].activateOverlayItem();
			activeItem = itemList[selection];
		}
		
		private function checkKeyInput(keyName:String, keyCode:uint):Boolean {
			if (ControlsManager.getSingleton().getKey(keyName) == keyCode)
				return true;
			return false;
		}
		
		public function getMenuHeight():int { return menuHeight; }
		public function getMenuWidth():int { return menuWidth; }
		
	}

}