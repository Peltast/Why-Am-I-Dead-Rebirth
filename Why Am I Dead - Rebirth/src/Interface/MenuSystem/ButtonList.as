package Interface.MenuSystem 
{
	import Core.Game;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import Interface.OverlayItem;
	/**
	 * ...
	 * @author Peltast
	 */
	public class ButtonList extends OverlayItem
	{
		private var buttonContainer:Sprite;
		private var buttons:Array;
		private var margins:Rectangle;
		private var horizontal:Boolean;
		private var maxToggled:int;
		private var title:String;
		private var titleField:TextField;
		private var selection:int;
		
		private var listWidth:int;
		private var listHeight:int;
		
		public function ButtonList(buttons:Array, margins:Rectangle, horizontal:Boolean, maxToggled:int, title:String = "",
									titleSize:int = 0, titleColor:uint = 0, exclusiveActivity:Boolean = false) 
		{
			super(this, exclusiveActivity);
			buttonContainer = new Sprite();
			this.margins = margins;
			this.horizontal = horizontal;
			this.maxToggled = maxToggled;
			this.title = title;
			titleField = new TextField();
			this.buttons = [];
			
			listWidth = 0;
			listHeight = 0;
			for (var i:int = 0; i < buttons.length; i++) {
				var tempButton:Button = buttons[i] as Button;
				
				addButton(tempButton);
			}
			
			this.addChild(buttonContainer);
			
			if (title != "") {
				var titleFormat:TextFormat 	= new TextFormat("AppleKid", titleSize, titleColor);
				titleField.defaultTextFormat = titleFormat;
				titleField.embedFonts = true;
				titleField.text = title;
				titleField.selectable = false;
				titleField.width = titleField.textWidth + 5;
				titleField.height = titleField.textHeight + 5;
				
				if (horizontal) {
					titleField.x = listWidth / 2 - titleField.width / 2 - margins.x;
					buttonContainer.y = titleField.y + titleField.height + margins.y;
				}
				else {
					titleField.y = listHeight / 2 - titleField.height / 2;
					buttonContainer.x = titleField	.x + titleField.width + margins.y;
				}
				this.addChild(titleField);
			}
		}
		public function addButton(button:Button):void {
			if (horizontal) {
				button.x = listWidth + margins.x;
				listWidth = button.x + button.width;
			}
			else {
				button.y = listHeight + margins.y;
				listHeight = button.y + button.height;
			}
			buttonContainer.addChild(button);
			buttons.push(button);
			
			if (horizontal) {
				titleField.x = listWidth / 2 - titleField.width / 2 - margins.x;
				buttonContainer.y = titleField.y + titleField.height + margins.y;
			}
			else {
				titleField.y = listHeight / 2 - titleField.height / 2;
				buttonContainer.x = titleField.x + titleField.width + margins.y;
			}
		}
		
		override public function resetOverlayItem():void 
		{
			super.resetOverlayItem();
			selection = 0;
			for each(var button:Button in buttons)
				if (button.isActive())
					button.deactivateOverlayItem();
		}
		override public function activateOverlayItem():void 
		{
			super.activateOverlayItem();
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, keyboardSelection);
			Game.getSingleton().stage..addEventListener(MouseEvent.MOUSE_MOVE, mouseSelection);
			if (buttons.length > 0){
				buttons[0].activateOverlayItem();
				selection = 0;
			}
		}
		override public function deactivateOverlayItem():void 
		{
			super.deactivateOverlayItem();
			selection = -1;
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, keyboardSelection);
			Game.getSingleton().stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseSelection);
			for each(var button:Button in buttons)
				if (button.isActive())
					button.deactivateOverlayItem();
		}
		
		private function keyboardSelection(keyboard:KeyboardEvent):void {
			changeSelection(selection + keyboardInputDirection(keyboard));
		}
		private function keyboardInputDirection(keyboard:KeyboardEvent):int {
			if (horizontal) {
				if (keyboard.keyCode == 65 || keyboard.keyCode == 37)
					return -1;
				else if (keyboard.keyCode == 68 || keyboard.keyCode == 39)
					return 1;
			}
			else {
				if (keyboard.keyCode == 87 || keyboard.keyCode == 38)
					return -1;
				else if (keyboard.keyCode == 83 || keyboard.keyCode == 40)
					return 1;
			}
			return 0;
		}
		private function mouseSelection(mouse:MouseEvent):void {
			var i:int = 0;
			for each(var button:Button in buttons) {
				
				if (button.hitTestPoint(mouse.stageX, mouse.stageY)) {
					if (selection == i) return;
					
					changeSelection(i);
					for each(var otherButton:Button in buttons) {
						if (otherButton != button)
							otherButton.deactivateOverlayItem();
					}
					return;
				}
				i++;
				
			}
		}
		
		private function changeSelection(newSelection:int):void {
			if (buttons.length == 0) return;
			if (newSelection == selection) return;
			
			if (newSelection < 0) newSelection = 0;
			if (newSelection > buttons.length - 1) newSelection = buttons.length - 1;
			
			if (selection != -1) {
				if (buttons[selection].isActive())
					buttons[selection].deactivateOverlayItem();
			}
			selection = newSelection;
			buttons[selection].activateOverlayItem();
		}
	}

}