package Interface.MenuSystem 
{
	import Core.Game;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import Interface.OverlayItem;
	/**
	 * ...
	 * @author Peltast
	 */
	public class ButtonGrid extends OverlayItem
	{
		private var buttonContainer:Sprite;
		private var buttons:Array;
		private var margins:Rectangle;
		private var horizontal:Boolean;
		private var cells:int;
		private var cellLength:int;
		
		private var title:String;
		private var titleField:TextField;
		private var selection:Point;
		
		private var listWidth:int;
		private var listHeight:int;
		
		public function ButtonGrid(buttons:Array, margins:Rectangle, horizontal:Boolean, cells:int, cellLength:int,
									title:String = "", titleSize:int = 0, titleColor:uint = 0, exclusiveActivity:Boolean = false)
		{
			super(this, exclusiveActivity);
			
			buttonContainer = new Sprite();
			this.margins = margins;
			this.horizontal = horizontal;
			this.cells = cells;
			this.cellLength = cellLength;
			this.title = title;
			titleField = new TextField();
			this.buttons = new Array([]);
			this.selection = new Point();
			
			var i:int = 0;
			while (i < buttons.length) {
				addButton(buttons[i]);
				i++;
			}
			
			this.addChild(buttonContainer);
		}
		
		public function addButton(newButton:Button):void {
			var currentRow:Array = this.buttons[buttons.length - 1];
			if (currentRow.length >= cells) {
				currentRow = new Array();
				this.buttons.push(currentRow);
				
				if (horizontal) {
					listWidth += cellLength;
					listHeight = 0;
				}
				else {
					listHeight += newButton.height;
					listWidth = 0;
				}
			}
			currentRow.push(newButton);
			
			if (horizontal) {
				newButton.x = listWidth + margins.width;
				newButton.y = listHeight + margins.height;
				listHeight += newButton.height;
			}
			else {
				newButton.x = listWidth + margins.width;
				newButton.y = listHeight + margins.height;
				listWidth += cellLength;
			}
			
			buttonContainer.addChild(newButton);
		}
		
		override public function resetOverlayItem():void 
		{
			super.resetOverlayItem();
			selection = new Point();
			for each(var row:Array in buttons)
				for each(var button:Button in row)
					if (button.isActive())
						button.deactivateOverlayItem();
		}
		override public function activateOverlayItem():void 
		{
			super.activateOverlayItem();
			
			Game.getSingleton().stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseSelection);
			Game.getSingleton().stage.addEventListener(MouseEvent.MOUSE_OUT, mouseDeselection);
			if (buttons.length > 0)
				selection = new Point();
		}
		override public function deactivateOverlayItem():void 
		{
			super.deactivateOverlayItem();
			
			selection = null;
			Game.getSingleton().stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseSelection);
			Game.getSingleton().stage.addEventListener(MouseEvent.MOUSE_OUT, mouseDeselection);
			for each(var row:Array in buttons)
				for each(var button:Button in row)
					if (button.isActive())
						button.deactivateOverlayItem();
			this.active = false;
		}
		
		private function mouseDeselection(mouse:MouseEvent):void {
			if (selection == null) return;
			var currentButton:Button = buttons[selection.y][selection.x] as Button;
			
			if (!currentButton.hitTestPoint(mouse.stageX, mouse.stageY)) {
				selection = new Point();
				currentButton.deactivateOverlayItem();
			}
		}
		private function mouseSelection(mouse:MouseEvent):void {			
			var i:int = 0;
			var cellCount:int = 0;
			for each(var row:Array in buttons) {
				
				for each(var button:Button in row){
					
					if (button.hitTestPoint(mouse.stageX, mouse.stageY)) {
						
						var newSelection:Point;
						if (horizontal) newSelection = new Point(cellCount, i);
						else newSelection = new Point(i, cellCount);
						
						changeSelection(newSelection);
						return;
					}
					i++;
				}
				cellCount++;
				i = 0;
			}
		}
		
		private function changeSelection(newSelection:Point):void {
			if (buttons.length == 0) return;
			if (newSelection.x == selection.x && newSelection.y == selection.y) return;
			
			if (newSelection.x < 0) newSelection.x = 0;
			if (newSelection.y < 0) newSelection.y = 0;
			if (newSelection.x > buttons.length - 1 && horizontal) newSelection.x = buttons.length - 1;
			else if (newSelection.y > buttons.length - 1 && !horizontal) newSelection.y = buttons.length - 1;
			if (newSelection.x > cells - 1 && !horizontal) newSelection.x = cells - 1;
			else if (newSelection.y > cells - 1 && horizontal) newSelection.y = cells - 1;
			
			if (selection != null) {
				for each(var otherRow:Array in buttons) {
					for each(var otherButton:Button in otherRow)
							otherButton.deactivateOverlayItem();
				}
			}
			selection = newSelection;
			buttons[selection.y][selection.x].activateOverlayItem();
		}
		
	}

}