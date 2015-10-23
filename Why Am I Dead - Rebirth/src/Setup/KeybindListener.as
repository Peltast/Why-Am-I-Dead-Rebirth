package Setup 
{
	import flash.display.Shape;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import Interface.MenuSystem.Button;
	import Interface.OverlayItem;
	import Interface.OverlayStack;
	/**
	 * ...
	 * @author Peltast
	 */
	public class KeybindListener extends OverlayItem
	{
		private var buttonKey:String;
		private var alt:Boolean;
		private var bindList:KeybindList;
		private var overlayStack:OverlayStack
		
		public function KeybindListener(buttonKey:String, alt:Boolean, bindList:KeybindList, overlayStack:OverlayStack) 
		{
			super(this, true);
			this.buttonKey = buttonKey;
			this.alt = alt;
			this.bindList = bindList;
			this.overlayStack = overlayStack;
			
			var backgroundRect:Shape = new Shape();
			backgroundRect.graphics.beginFill(0x000000, .4);
			backgroundRect.graphics.drawRect(0, 0, 540, 400);
			backgroundRect.graphics.endFill();
			
			this.addChild(backgroundRect);
			
			var textFormat:TextFormat = new TextFormat("AppleKid", 24);
			var prompt:TextField = new TextField();
			prompt.defaultTextFormat = textFormat;
			prompt.embedFonts = true;
			prompt.selectable = false;
			prompt.textColor = 0xFFFFFF;
			prompt.text = "PRESS THE KEY YOU WOULD LIKE \n TO BIND TO THIS ACTION";
			prompt.height = prompt.textHeight + 5;
			prompt.width = prompt.textWidth + 5;
			prompt.y = 150;
			prompt.x = 270 - (prompt.width / 2);
			
			this.addChild(prompt);
		}
		
		override public function activateOverlayItem():void 
		{
			super.activateOverlayItem();
			
			Main.getSingleton().addEventListener(KeyboardEvent.KEY_UP, bindKey);
			Main.getSingleton().stage.focus = this;
		}
		override public function deactivateOverlayItem():void 
		{
			super.deactivateOverlayItem();
			
			Main.getSingleton().removeEventListener(KeyboardEvent.KEY_UP, bindKey);
		}
		
		private function bindKey(event:KeyboardEvent):void {
			
			var keyCode:int = event.keyCode;
			ControlsManager.getSingleton().setKey(buttonKey + "Key", alt, keyCode);
			
			bindList.resetBindList();
			
			Main.getSingleton().removeEventListener(KeyboardEvent.KEY_UP, bindKey);
			overlayStack.popStack();
		}
		
	}

}