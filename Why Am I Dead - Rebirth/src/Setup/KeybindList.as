package Setup 
{
	import flash.geom.Rectangle;
	import Interface.MenuSystem.Button;
	import Interface.MenuSystem.ButtonEffect;
	import Interface.MenuSystem.ButtonGrid;
	import Interface.MenuSystem.Menu;
	import Interface.Overlay;
	import Interface.OverlayItem;
	import Interface.OverlayStack;
	/**
	 * ...
	 * @author Peltast
	 */
	public class KeybindList extends Menu
	{
		
		private var keyButtons:Array = [];
		private var valueButtons:Array = [];
		private var altKeyButtons:Array = [];
		private var altValueButtons:Array = [];
		
		private var allButtons:Array = [];
		
		private var fontColors:Array;
		private var bgColors:Array;
		private var bgColors2:Array;
		
		private var overlayStack:OverlayStack;
		
		public function KeybindList(hostMenu:Menu, overlayStack:OverlayStack) 
		{
			super(false, new Rectangle());
			this.overlayStack = overlayStack;
			
			fontColors = new Array(0xfffffff, 0xffffff);
			bgColors = new Array(0x312121, 0x312121);
			bgColors2 = new Array(0x312121, 0x635353);
			
			this.addMenuItem(generateDefaultButton());
			this.addMenuItem(generateBindList());
		}
		public function resetBindList():void {
			valueButtons = [];
			altValueButtons = [];
			keyButtons = [];
			allButtons = [];
			
			this.emptyMenu();
			this.addMenuItem(generateDefaultButton());
			this.addMenuItem(generateBindList());
		}
		
		private function generateDefaultButton():Button {
			
			var defaultEffect:Array = [new ButtonEffect("DefaultControls", []), new ButtonEffect("UpdateControls", [this])];
			var defaultButton:Button = new Button
				("Default", 16, new Rectangle(2, 2, 2, 2), fontColors, bgColors2, false, defaultEffect);
			
			return defaultButton;
		}
		
		private function generateBindList():ButtonGrid {
			
			var keyNames:Array = ControlsManager.getSingleton().getKeyStrings();
			var keyValues:Array = ControlsManager.getSingleton().getValueStrings();
			
			generateKeyBindButtons(keyNames, keyValues);
			setAllButtonArray();
			
			var bindList:ButtonGrid = new ButtonGrid
				(allButtons, new Rectangle(5, 5, 5, 5), false, 3, 140, "Key Bindings", 16, 0xffffff, true);
			bindList.activateOverlayItem();
			bindList.y = 20;
			
			return bindList;
		}
		
		private function generateKeyBindButtons(keyNames:Array, keyValues:Array):void {
			
			for (var k:int = 0; k < keyNames.length; k++ ) {
				
				var key:String = keyNames[k].replace("Key", "");
				var value:String = keyValues[k];
				
				if (key.indexOf("Alt ") == -1) {
					valueButtons.push(generateValueButton(value, new Rectangle(5, 2, 10, 2), fontColors, bgColors2));
					keyButtons.push(new Button(key, 16, new Rectangle(2, 2, 2, 2), fontColors, bgColors));
				}
				else
					altValueButtons.push(generateValueButton(value, new Rectangle(5, 2, 10, 2), fontColors, bgColors2));
			}
			
			addBindEffects(valueButtons, false);
			addBindEffects(altValueButtons, true);
		}
		private function generateValueButton(value:String, margins:Rectangle, fontColors:Array, bgColors2:Array):Button {
			
			var valueButton:Button = new Button(value, 16, margins, fontColors, bgColors2, false, []);
			return valueButton;
		}
		private function addBindEffects(buttonArray:Array, alt:Boolean):void {
			for (var k:int = 0; k < buttonArray.length; k++) {
				var tempValButton:Button = buttonArray[k] as Button;
				var value:String = tempValButton.getButtonText();
				
				tempValButton.addButtonEffect(
					new ButtonEffect("AddOverlay", [generateBindOverlay(getValueKey(value), alt), overlayStack]));
			}
		}
		private function generateBindOverlay(buttonKey:String, alt:Boolean):Overlay {
			
			var bindOverlay:Overlay = new Overlay();
			bindOverlay.addToOverlay(new KeybindListener(buttonKey, alt, this, overlayStack));
			
			return bindOverlay;
		}
		private function getValueKey(value:String):String {
			
			for (var k:int = 0; k < valueButtons.length; k++) {
				
				var tempValButton:Button = valueButtons[k];
				var tempAltValButton:Button = altValueButtons[k];
				if (tempValButton.getButtonText() == value || tempAltValButton.getButtonText() == value)
					break;
				
				if (k == valueButtons.length - 1) return "";
			}
			
			var keyButton:Button = keyButtons[k];
			return keyButton.getButtonText();
		}
		
		private function setAllButtonArray():void {
			
			for (var i:int = 0; i < keyButtons.length; i++) {
				allButtons.push(keyButtons[i]);
				allButtons.push(valueButtons[i]);
				allButtons.push(altValueButtons[i]);
			}
		}
		
		
	}

}