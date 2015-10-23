package Interface.MenuSystem 
{
	import Core.Game;
	import flash.events.KeyboardEvent;
	import flash.text.AntiAliasType;
	import Interface.OverlayItem;
	import Main;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import Setup.ControlsManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Button extends OverlayItem
	{
		protected var effectList:Array;
		private var text:String;
		protected var margins:Rectangle;
		protected var bounds:Rectangle;
		private var fontColors:Array;
		private var bgColors:Array;
		private var hasBorder:Boolean;
		protected var border:Shape;
		private var borderColor:uint;
		protected var buttonShape:Shape;
		protected var buttonText:TextField;
		private var toggleable:Boolean;
		private var hitTimer:int;
		
		protected var isHovered:Boolean;
		protected var isClicked:Boolean;
		protected var isToggled:Boolean;
		private var borderAlphaSwitch:Boolean;
		
		public function Button(text:String, fontSize:int, margins:Rectangle, fontColors:Array,
								bgColors:Array = null, toggleable:Boolean = false, buttonEffects:Array = null, 
								hasBorder:Boolean = false, borderColor:uint = 0 ) 
		{
			super(this, false);
			this.effectList = buttonEffects
			this.text = text;
			this.margins = margins;
			this.fontColors = fillRemainingColors(fontColors);
			this.bgColors = fillRemainingColors(bgColors);
			this.toggleable = toggleable;
			this.hasBorder = hasBorder;
			this.borderColor = borderColor;
			
			var tempFormat:TextFormat = new TextFormat("AppleKid", fontSize);
			buttonText = new TextField();
			buttonText.defaultTextFormat = tempFormat;
			buttonText.antiAliasType = AntiAliasType.NORMAL;
			buttonText.embedFonts = true;
			buttonText.selectable = false;
			buttonText.textColor = fontColors[0];
			buttonText.text = text;
			buttonText.height = buttonText.textHeight + 5;
			buttonText.width = buttonText.textWidth + 5;
			this.bounds = new Rectangle(buttonText.x, buttonText.y, buttonText.textWidth, buttonText.textHeight);
			
			buttonShape = new Shape();
			if (bgColors != null)
				buttonShape = drawShape(bgColors[0]);
			else 
				buttonShape = drawShape(0x000000, 0);
			
			border = new Shape();
			border.graphics.lineStyle(1, borderColor);
			border.graphics.drawRoundRect(bounds.x - margins.x, bounds.y - margins.y,
				bounds.width + margins.width + margins.x, bounds.height + margins.height + margins.y, 30, 30);
			
			this.addChild(buttonShape);
			this.addChild(buttonText);
			
			isHovered = false;
			isClicked = false;
			isToggled = false;
			
			this.addEventListener(Event.ENTER_FRAME, updateBorder);
		}
		private function fillRemainingColors(colorArray:Array):Array {
			if (colorArray == null) return colorArray;
			if (colorArray.length < 4) {
				var colorCopy:uint = colorArray[0];
				for (var i:int = colorArray.length - 1; i <= 4 - (colorArray.length - 1); i++) {
					colorArray.push(colorCopy);
				}
			}
			return colorArray;
		}
		
		override public function activateOverlayItem():void 
		{
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, checkKeyboardSelect);
			this.addEventListener(MouseEvent.MOUSE_DOWN, checkMouseClick);
			this.addEventListener(MouseEvent.MOUSE_UP, checkMouseUp);
			Game.getSingleton().stage.addEventListener(MouseEvent.MOUSE_MOVE, checkMouseHover);
			buttonHover();
			super.activateOverlayItem();
		}
		override public function deactivateOverlayItem():void 
		{
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, checkKeyboardSelect);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, checkMouseClick);
			this.removeEventListener(MouseEvent.MOUSE_UP, checkMouseUp);
			Game.getSingleton().stage.removeEventListener(MouseEvent.MOUSE_MOVE, checkMouseHover);
			buttonUnhover();
			super.deactivateOverlayItem();
		}
		override public function resetOverlayItem():void 
		{
			deactivateOverlayItem();
		}
		
		public function getButtonText():String {
			return buttonText.text;
		}
		public function changeButtonText(newText:String):void {
			buttonText.text = newText;
			this.addChild(buttonText);
		}
		public function addButtonEffect(buttonEffect:ButtonEffect):void {
			effectList.push(buttonEffect);
		}
		
		protected function checkKeyboardSelect(keyboard:KeyboardEvent):void {
			if (checkKeyInput("Enter Key", keyboard.keyCode) || checkKeyInput("Alt Enter Key", keyboard.keyCode)) {
				//buttonHit();
			}
		}
		private function checkKeyInput(keyName:String, keyCode:uint):Boolean {
			if (ControlsManager.getSingleton().getKey(keyName) == keyCode)
				return true;
			return false;
		}
		
		protected function hitAnimation(event:Event):void {
			if (hitTimer == 3)
				changeColor(3, 3);
			if (hitTimer <= 0) {
				if (isHovered) changeColor(1, 1);
				this.removeEventListener(Event.ENTER_FRAME, hitAnimation);
			}
			hitTimer--;
		}
		
		protected function buttonHover():void {
			isHovered = true;
			if (!isToggled) changeColor(1, 1);
			if (hasBorder) {
				border.visible = true;
				this.addChild(buttonShape);
				this.addChild(border);
				this.addChild(buttonText);
			}
		}
		protected function buttonUnhover():void {
			isHovered = false;
			if (!isToggled) changeColor(0, 0);
			else changeColor(3, 3);
			if (hasBorder && this.contains(border)) border.visible = false;
		}
		protected function buttonHit():void {
			
			if (!isToggled) {
				if (toggleable) { 
					isToggled = true;
					changeColor(3, 3);
				}
				else {
					hitTimer = 3;
					this.addEventListener(Event.ENTER_FRAME, hitAnimation);
				}
				if (effectList != null) {
					for each(var effect:ButtonEffect in effectList)
						effect.performEffect();
				}
			}
			else {
				isToggled = false;
				changeColor(0, 0);
				if (effectList != null) {
					for each(effect in effectList)
						effect.reverseEffect();
				}
			}
			
		}
		
		protected function checkMouseHover(mouse:MouseEvent):void {
			if (!isClicked) {
				if (buttonShape.hitTestPoint(mouse.stageX, mouse.stageY))
					buttonHover();
				else if(isHovered)
					buttonUnhover();
			}
			else {
				if (buttonShape.hitTestPoint(mouse.stageX, mouse.stageY)) 
					return;
				else
					buttonUnhover();
			}
		}
		
		protected function checkMouseClick(mouse:MouseEvent):void {
			if (isHovered) {
				if (mouse.buttonDown && buttonShape.hitTestPoint(mouse.stageX, mouse.stageY)){
					isClicked = true;
					changeColor(2, 2);
				}
				else{
					isClicked = false;
					if (isToggled) changeColor(2, 2);
				}
			}
		}
		
		protected function checkMouseUp(mouse:MouseEvent):void {
			if (isClicked) {
				if (!mouse.buttonDown && buttonShape.hitTestPoint(mouse.stageX, mouse.stageY)){
					isClicked = false;
					isHovered = true;
					
					buttonHit();
				}
			}
		}
		
		protected function updateBorder(event:Event):void {
			if (borderAlphaSwitch) border.alpha -= .03;
			else border.alpha += .03;
			
			if (border.alpha >= 1) borderAlphaSwitch = true;
			else if (border.alpha <= .4) borderAlphaSwitch = false;
		}
		
		private function changeColor(fontColorIndex:int, bgColorIndex:int):void {
			changeFontColor(fontColors[fontColorIndex]);
			if (bgColors != null)
				changeShapeColor(bgColors[bgColorIndex]);
		}
		
		private function changeFontColor(newColor:uint):void {
			if (this.contains(buttonText)) {
				this.removeChild(buttonText);
				buttonText.textColor = newColor;
				this.addChild(buttonText);
			}
		}
		private function changeShapeColor(newColor:uint):void {
			if (bgColors == null) return;
			if (this.contains(buttonShape)) { 
				this.removeChild(buttonShape);
				buttonShape = drawShape(newColor);
				this.addChild(buttonShape);
				this.addChild(border);
				this.addChild(buttonText);
			}
		}
		private function drawShape(color:uint, alpha:Number = 1):Shape {
			var tempShape:Shape = new Shape;
			tempShape.graphics.beginFill(color, alpha);
			tempShape.graphics.drawRoundRect
				(bounds.x - margins.x, bounds.y - margins.y,
				bounds.width + margins.width + margins.x, bounds.height + margins.height + margins.y, 30, 30);
			tempShape.graphics.endFill();
			return tempShape;
		}
		
		public function getHoverState():Boolean { return isHovered; }
		public function getClickState():Boolean { return isClicked; }
		public function getToggleState():Boolean { return isToggled; }
		
		public function containsPoint(point:Point):Boolean {
			return buttonShape.hitTestPoint(point.x, point.y);
		}
		public function setOnOff(b:Boolean):void {
			isToggled = b;
			if (b)
				changeColor(3, 3);
			else 
				changeColor(0, 0);
		}
		
	}

}