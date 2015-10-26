package Interface.DialogueSystem 
{
	import Dialogue.Dialogue;
	import Dialogue.DialogueLibrary;
	import Dialogue.Response;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import Misc.Tuple;
	import Setup.ControlsManager;
	import Setup.GameLoader;
	import Interface.MenuSystem.*;
	/**
	 * ...
	 * @author Peltast
	 */
	public class RegularResponse extends ResponseInterface
	{
		private var optionBox:MenuBox;
		private var nameBox:MenuBox;
		private var charName:TextField;
		private var clickPrompt:TextField;
		private var clickAlphaSwitch:Boolean;
		
		private var responseNumberImgs:Array;
		private var responseImages:Array;
		private var responseBorders:Array;
		private var responseBullets:Array;
		
		private var selection:int;
		private var responseHeight:int;
		private var visitedFormat:TextFormat;
		
		public function RegularResponse(textFormat:TextFormat, responseHeight:int) 
		{
			super(this);
			
			this.textFormat = textFormat;
			this.responseHeight = responseHeight;
			
			optionBox = new MenuBox(new Rectangle(0, 0, 460, responseHeight), new GameLoader.MenuSkin() as Bitmap);
			optionBox.x = 40;
			optionBox.y = 5;
			
			clickPrompt = new TextField();
			clickPrompt.embedFonts = true;
			clickPrompt.defaultTextFormat = textFormat;
			clickPrompt.selectable = false;
			clickPrompt.text = "Select response";
			clickPrompt.x = 340;
			clickPrompt.y = responseHeight;
			clickPrompt.width = clickPrompt.textWidth + 10;
			clickAlphaSwitch = false;
			
			nameBox = new MenuBox(new Rectangle(0, 0, 100, 50), new GameLoader.MenuSkin() as Bitmap);
			nameBox.x = 340;
			nameBox.y = responseHeight - 5;			
			
			charName = new TextField();
			charName.embedFonts = true;
			charName.defaultTextFormat = textFormat;
			charName.selectable = false;
			
			visitedFormat = new TextFormat("AppleKid");
			visitedFormat.color = 0x999999;
			visitedFormat.size = 16;
		}
		
		override public function updateResponse(event:Event, mouse:Point):void 
		{
			if (responseImages != null) {
				// The current responses have been shown but nothing has been clicked yet.  At this point,
				// update the clickPrompt to flash.
				
				if (this.contains(clickPrompt)) {
					if (clickAlphaSwitch) {
						clickPrompt.alpha -= .025;
						if (responseBorders[selection] == null) return;
						responseBorders[selection].alpha -= .05;
						if (responseBorders[selection].alpha < .5) responseBorders[selection].alpha = .5;
					}
					else { 
						clickPrompt.alpha += .025;
						if (responseBorders[selection] == null) return;
						responseBorders[selection].alpha += .05;
						if (responseBorders[selection].alpha > 1) responseBorders[selection].alpha = 1;
					}
					
					if (clickPrompt.alpha >= 1) clickAlphaSwitch = true;
					if (clickPrompt.alpha <= .5) clickAlphaSwitch = false;
				}
			}
			
			for (var i:int = 0; i < responseBullets.length;i++ ) {
				if (responseBullets[i] is AnimatedItem) {
					var animatedBullet:AnimatedItem = responseBullets[i] as AnimatedItem;
					animatedBullet.updateItem();
				}
			}
		}
		
		override public function undrawResponse():void 
		{
			this.removeChild(optionBox);
			this.removeChild(nameBox);
			this.removeChild(charName);
			
			for (var j:int = 0; j < responseImages.length; j++){
				this.removeChild(responseImages[j]);
				this.removeChild(responseNumberImgs[j]);
				this.removeChild(responseBullets[j]);
			}
			if (responseBorders.length > 0)
				if(this.contains(responseBorders[selection])) this.removeChild(responseBorders[selection]);
			
			responseImages = null;
			responseList = null;
		}
		override public function drawResponse(currentResponse:Response, currentDialogue:Dialogue):void 
		{
			this.addChild(optionBox);
			this.addChild(nameBox);
			
			var previousResponseHeight:int = 10;
			responseNumberImgs = new Array();
			responseImages = new Array();
			responseBorders = new Array();
			responseBullets = new Array();
			responseList = currentResponse.getResponses();
			triggerList = currentResponse.getTriggers();
			var i:int = 0;
			selection = 0;
			
			for (var k:int = 0; k < currentResponse.getResponses().length; k++ ) {
				
				var response:String = currentResponse.getResponses()[k];
				response = replaceGeneralTerm(response);
				
				// Check if the response requires a trigger.  If it does, check if that trigger is on.
				//		If the trigger is off, skip this response so that it doesn't show.
				if (triggerList[response] != null)
					if (!triggerList[response].isOn()) continue;
				
				// Textfield for the number of the response.  Kept separate from responseImg
				//		to keep responseImg's text purely the response text
				var responseNumber:TextField = new TextField();
				responseNumber.embedFonts = true;
				responseNumber.defaultTextFormat = textFormat;
				responseNumber.selectable = false;
				responseNumber.text = " ";
				responseNumber.x = 35 + optionBox.x;
				responseNumber.y = getBounds(optionBox).y + 15 + previousResponseHeight;
				
				// Bullet for aesthetics.
				var responseBullet:Sprite = new Sprite();
				responseBullet.addChild(new GameLoader.DialogueOption() as Bitmap);
				responseBullet.x = 30 + optionBox.x;
				responseBullet.y = getBounds(optionBox).y + 15 + previousResponseHeight;
				
				// Textfield for response text
				
				var visited:Boolean = currentDialogue.checkActionExhausted(currentResponse.getChild(k), currentResponse.getTitle());
				
				var responseImg:TextField = new TextField();
				responseImg.wordWrap = true;
				responseImg.embedFonts = true;
				if(visited)
					responseImg.defaultTextFormat = visitedFormat;
				else
					responseImg.defaultTextFormat = textFormat;
				responseImg.autoSize = "left";
				responseImg.selectable = false;
				responseImg.border = false;
				responseImg.borderColor = 0xffffff;
				responseImg.text = response;
				responseImg.width = getBounds(optionBox).width - optionBox.x -  50;
				responseImg.height = responseImg.textHeight + 5;
				responseImg.x = Math.ceil(50 + optionBox.x);
				responseImg.y = Math.ceil(getBounds(optionBox).y + 15 + previousResponseHeight);
				
				// Flashing border around selected response
				var responseBorder:Shape = new Shape();
				responseBorder.graphics.lineStyle(2, 0xffffff);
				responseBorder.graphics.drawRoundRect
					(26 + optionBox.x,  getBounds(optionBox).y + 10 + previousResponseHeight,
						getBounds(optionBox).width - 52, responseImg.textHeight + 15, 20, 10);
				
				previousResponseHeight = responseImg.textHeight + responseImg.y;
				
				responseNumberImgs.push(responseNumber);
				responseImages.push(responseImg);
				responseBorders.push(responseBorder);
				responseBullets.push(responseBullet);
				this.addChild(responseImages[i]);
				this.addChild(responseNumberImgs[i]);
				this.addChild(responseBullets[i]);
				if (i == 0) {
					this.addChild(responseBorders[selection]);
					animateBullet(selection);
				}
				
				i++;
			}
			
			// If the last response goes past the original optionBox's height, expand it.
			// If it doesn't, revert back to the original height.
			if (previousResponseHeight >= 90)
				responseHeight = previousResponseHeight + 15;
			else
				responseHeight = 105;
				
			clickPrompt.y = responseHeight;
			
			this.removeChild(optionBox);
			optionBox = new MenuBox(new Rectangle(0, 0, 460, responseHeight + 25), new GameLoader.MenuSkin() as Bitmap);
			optionBox.x = 40;
			optionBox.y = 5;
			this.addChild(optionBox);
			
			drawNamebox(currentResponse.getSpeaker());
			this.addChild(nameBox);
			this.addChild(charName);
			this.setChildIndex(optionBox, 0);
			this.addChild(clickPrompt);
		}
		private function drawNamebox(speaker:String):void {
			charName.text = speaker;
			charName.text = replaceGeneralTerm(charName.text);
			
			this.removeChild(nameBox);
			nameBox = new MenuBox(new Rectangle(0, 0, charName.textWidth + 60, 50), new GameLoader.MenuSkinLight() as Bitmap);
			nameBox.x = 100;
			nameBox.y = responseHeight - 5;
			this.addChild(nameBox);
			
			charName.x = Math.ceil(nameBox.x + (nameBox.width / 2) - (charName.textWidth / 2));
			charName.y = Math.ceil(nameBox.y + 15);
			this.addChild(charName);
		}
		
		override public function checkResponseKey(key:KeyboardEvent, enterKeyDown:Boolean):int
		{
			if (responseList == null || responseImages == null) return -1;
			
			// Move the response selection up or down based on keypresses
			if (checkKeyInput("Up Key", key.keyCode) || checkKeyInput("Alt Up Key",key.keyCode)) {
				selection--;
				if (selection < 0) selection = 0;
				else{
					this.addChild(responseBorders[selection]);
					animateBullet(selection);
					deanimateBullet(selection + 1);
					if (responseImages.length > selection + 1) this.removeChild(responseBorders[selection + 1]);
				}
			}
			else if (checkKeyInput("Down Key", key.keyCode) || checkKeyInput("Alt Down Key",key.keyCode)) { // DOWN
				selection++;
				if (selection > responseImages.length - 1) selection = responseImages.length - 1;
				else{
					this.addChild(responseBorders[selection]);
					animateBullet(selection);
					deanimateBullet(selection - 1);
					if (selection > 0) this.removeChild(responseBorders[selection - 1]);
				}
			}
			// Select the given response
			else if ((checkKeyInput("Action Key", key.keyCode) || checkKeyInput("Alt Action Key", key.keyCode)) 
						&& !enterKeyDown) {
				
				if (this.contains(clickPrompt))
					this.removeChild(clickPrompt);
				
				return selection;
				
			}
			
			return -1;
		}
		
		private function animateBullet(index:int):void {
			if (index < 0 || index > responseBullets.length)
				return;
			
			this.removeChild(responseBullets[index]);
			
			var frames:Array = new Array(new Point(), new Point(1), new Point(2), new Point(3),
											new Point(4), new Point(5), new Point(6));
			var bullet:AnimatedItem = new AnimatedItem(new GameLoader.DialogueOptionAnim() as Bitmap, frames, 3, 20, 20);
			
			bullet.x = responseBullets[index].x;
			bullet.y = responseBullets[index].y;
			responseBullets[index] = bullet;
			
			this.addChild(bullet);
		}
		private function deanimateBullet(index:int):void {
			if (index < 0 || index > responseBullets.length)
				return;
			
			this.removeChild(responseBullets[index]);
			
			var bullet:Sprite = new Sprite();
			bullet.addChild(new GameLoader.DialogueOption() as Bitmap);
			bullet.x = responseBullets[index].x;
			bullet.y = responseBullets[index].y;
			responseBullets[index] = bullet;
			
			this.addChild(responseBullets[index]);
		}
		
		
		private function checkKeyInput(keyName:String, keyCode:uint):Boolean {
			if (ControlsManager.getSingleton().getKey(keyName) == keyCode)
				return true;
			return false;
		}
		
	}

}