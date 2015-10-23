package Interface.DialogueSystem 
{
	import Dialogue.Dialogue;
	import Dialogue.Statement;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import Interface.MenuSystem.MenuBox;
	import Setup.GameLoader;
	import Sound.SoundManager;
	/**
	 * ...
	 * @author Peltast
	 */
	public class RegularStatement extends StatementInterface
	{
		private var currentStatement:Statement;
		private var statementImage:TextField;
		private var currentStatementTxt:String;
		private var tempStatementText:String;
		
		private var charName:TextField;
		private var pressE:TextField;
		private var pressEalphaSwitch:Boolean;
		private var optionBox:MenuBox;
		private var nameBox:MenuBox;
		
		
		public function RegularStatement(textFormat:TextFormat) 
		{
			super(this);
			
			optionBox = new MenuBox(new Rectangle(0, 0, 460, 125), new GameLoader.MenuSkin() as Bitmap);
			optionBox.x = 40;
			optionBox.y = 5;
			
			nameBox = new MenuBox(new Rectangle(0, 0, 100, 50), new GameLoader.MenuSkinLight() as Bitmap);
			
			textFormat = new TextFormat("AppleKid");
			textFormat.color = 0xffffff;
			textFormat.size = 16;
			
			charName = new TextField();
			charName.embedFonts = true;
			charName.defaultTextFormat = textFormat;
			charName.selectable = false;
			
			pressE = new TextField();
			pressE.embedFonts = true;
			pressE.defaultTextFormat = textFormat;
			pressE.selectable = false;
			pressE.text = "Press J/Z";
			pressE.x = 30 + optionBox.x;
			pressE.y = 100;
			pressEalphaSwitch = false;
			
			
			this.textFormat = textFormat;
		}
		
		override public function updateStatement():void 
		{
			var progress:int = statementImage.text.length;
			statementImage.appendText(currentStatementTxt.charAt(progress));
			statementImage.width = statementImage.textWidth + 5;
			statementImage.height = statementImage.textHeight + 5;
			statementImage.x = optionBox.x + 32;
			
			if (currentStatementTxt.length - 1 <= statementImage.text.length && !this.contains(pressE))
				this.addChild(pressE);
			
			else if (this.contains(pressE)) {
				if (pressEalphaSwitch) pressE.alpha -= .05;
				else pressE.alpha += .05;
				if (pressE.alpha >= 1) pressEalphaSwitch = true;
				if (pressE.alpha <= .5) pressEalphaSwitch = false;
			}
			else if (progress % 3 == 0 && this.contains(charName)) {
				if(SoundManager.getSingleton().hasSound(charName.text + " Text"))
					SoundManager.getSingleton().playSound(charName.text + " Text", .5);
				else
					SoundManager.getSingleton().playSound("Normal Text", .5);
			}
			
			if (statementImage.width > (optionBox.width) - statementImage.x) { 
				statementImage.width = optionBox.width - statementImage.x;
				statementImage.height += statementImage.textHeight + 5;
				statementImage.wordWrap = true;
			}
		}
		
		override public function drawStatement(currentStatement:Statement):void 
		{
			this.currentStatement = currentStatement;
			this.addChild(optionBox);
			this.addChild(nameBox);
			
			if(currentStatement.getSpeaker(0) != "null")
				drawNamebox(currentStatement.getSpeaker(0));
			else {
				this.removeChild(nameBox);
			}
			
			if (currentStatement.getSpeech(0) != null) {
				currentStatementTxt = currentStatement.getSpeech(0);
				tempStatementText = currentStatementTxt;
				currentStatementTxt = replaceGeneralTerm(currentStatementTxt);
			}
			
			statementImage = new TextField();
			statementImage.wordWrap = false;
			statementImage.embedFonts = true;
			statementImage.defaultTextFormat = textFormat;
			statementImage.text = "";
			statementImage.selectable = false;
			statementImage.width = statementImage.textWidth + 5;
			statementImage.y = 	  Math.ceil(optionBox.y + optionBox.height / 2 - 16) 
								- Math.ceil(calculateStatementTextHeight(currentStatement, 0) / 2);
			statementImage.x = Math.ceil(getBounds(optionBox).width / 2 - (statementImage.width / 2) + optionBox.x);
			
			this.addChild(statementImage);
		}
		private function drawNamebox(speaker:String):void {
			if (this.contains(charName))
				this.removeChild(charName);
			charName.text = speaker;
			charName.text = replaceGeneralTerm(charName.text);
			
			if (this.contains(nameBox)) this.removeChild(nameBox);
			nameBox = new MenuBox(new Rectangle(0, 0, charName.textWidth + 60, 50), new GameLoader.MenuSkinLight() as Bitmap);
			nameBox.x = 300;
			nameBox.y = 95;
			this.addChild(nameBox);
			
			charName.x = Math.ceil(nameBox.x + (nameBox.width / 2) - (charName.textWidth / 2));
			charName.y = Math.ceil(nameBox.y + 15);
			this.addChild(charName);
		}
		private function calculateStatementTextHeight(statement:Statement, speechIndex:int):int {
			var dummyImage:TextField = new TextField;
			dummyImage.defaultTextFormat = textFormat;
			dummyImage.text = statement.getSpeech(speechIndex);
			
			var numberOfLines:int = Math.ceil(dummyImage.textWidth / optionBox.width);
			return numberOfLines * (textFormat.size as int);
		}
		
		override public function undrawStatement():void 
		{
			if(this.contains(optionBox)) this.removeChild(optionBox);
			if(this.contains(charName)) this.removeChild(charName);
			if (this.contains(nameBox)) this.removeChild(nameBox);
			if (this.contains(pressE)) this.removeChild(pressE);
			
			if (this.contains(statementImage)) this.removeChild(statementImage);
			currentStatement = null;
		}
		
		override public function checkStatementKey(event:KeyboardEvent, enterKeyDown:Boolean, currentDialogue:Dialogue):Boolean
		{
			//if (OverlayManager.getSingleton().numOfOverlays() > 1) return;
			if (currentStatement == null || statementImage == null) return false;
			if (enterKeyDown) return false;
			
			// If 'e' is hit when the NPC statement is still animating, finish the animation.
			// If 'e' is hit when it's done, this progresses the dialogue into the next statement or response.
			// If there is none, we end the dialogue.
			if ((checkKeyInput("Action Key", event.keyCode) || checkKeyInput("Alt Action Key", event.keyCode)) 
					&& !enterKeyDown) {
				enterKeyDown = true;
				
				if (currentStatementTxt.length - 1 > statementImage.text.length) {
					// Finish animation.
					statementImage.text = currentStatementTxt;
					statementImage.width = statementImage.textWidth + 5;
					statementImage.x = Math.ceil(optionBox.width / 2 - (statementImage.width / 2) + optionBox.x);
					
					if (statementImage.width > optionBox.width - optionBox.x) { 
						statementImage.width = optionBox.width - statementImage.x;
						statementImage.wordWrap = true;
					}
				}
				else {
					
					if (this.contains(pressE))
						this.removeChild(pressE);
					
					// Loop through statement list and find index of our current statement.
					for (var j:int = 0; j < currentStatement.getSpeechLength(); j++) {
						
						if (currentStatement.getSpeech(j) == tempStatementText) {
							if(j < currentStatement.getSpeechLength() - 1){
								// If we aren't on the last statement, move to the next statement.
								currentStatementTxt = currentStatement.getSpeech(j + 1);
								tempStatementText = currentStatementTxt;
								statementImage.text = "";
								statementImage.wordWrap = false;
								statementImage.y = 	  Math.ceil(optionBox.y + optionBox.height / 2 - 16) 
													- Math.ceil(calculateStatementTextHeight(currentStatement, j + 1) / 2);
								
								if (currentStatement.getSpeaker(j + 1) != "null")
									drawNamebox(currentStatement.getSpeaker(j + 1));
								
								break;
							}
							else { // Otherwise we'll need to switch to the next exchange.
								return true;
							}
						}
					}
				}
			}
			return false;
		}
		
		
	}

}