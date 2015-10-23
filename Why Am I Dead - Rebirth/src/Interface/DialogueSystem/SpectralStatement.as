package Interface.DialogueSystem 
{
	import Core.Game;
	import Dialogue.Dialogue;
	import Dialogue.Statement;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import SpectralGraphics.EffectTypes.SpectralEffect;
	import SpectralGraphics.SpectralImage;
	import SpectralGraphics.SpectralText;
	/**
	 * ...
	 * @author Peltast
	 */
	public class SpectralStatement extends StatementInterface
	{
		private var currentStatement:Statement;
		private var currentStatementText:String;
		
		private var textSize:int;
		private var textColor:uint;
		private var spectralImage:SpectralImage;
		private var spectralText:SpectralText;
		private var statementText:String;
		private var textEffects:Array;
		private var typeEffect:Boolean;
		
		private var pressEImage:SpectralImage;
		private var pressE:SpectralText;
		private var pressEalphaSwitch:Boolean;
		
		public function SpectralStatement(textSize:int, textColor:uint, textEffects:Array, typeEffect:Boolean) 
		{
			super(this);
			
			this.textSize = textSize;
			this.textColor = textColor;
			this.textEffects = textEffects;
			this.typeEffect = typeEffect;
			
			pressE = new SpectralText("Press J/Z", new GlowFilter(0x000000, 1, 2, 2, 10), textSize, textColor, .8);
			pressEImage = new SpectralImage(0, 540, 400);
			pressEImage.addObject(0, pressE, 1, 1);
			
			for (var i:int = 0; i < textEffects.length; i++) {
				if (!(textEffects[i] is SpectralEffect)) continue;
				pressEImage.addEffect(0, textEffects[i]);
			}
		}
		
		override public function updateStatement():void 
		{
			if (typeEffect) {
				var progress:int = spectralText.getTextLength();
				spectralText.appendText(currentStatementText.charAt(progress));
			}
			
			spectralText.x = (540 / 2) - spectralText.getTextWidth() / 2;
			spectralText.y = (400 / 2) - spectralText.getTextHeight() / 2;
			
			if (pressEalphaSwitch) pressE.alpha -= .05;
			else pressE.alpha += .05;
			if (pressE.alpha >= 1) pressEalphaSwitch = true;
			if (pressE.alpha <= .5) pressEalphaSwitch = false;
			
		}
		
		override public function drawStatement(currentStatement:Statement):void 
		{
			this.currentStatement = currentStatement;
			
			spectralImage = new SpectralImage(1, 540, 400);
			
			if (currentStatement.getSpeech(0) != null) {
				currentStatementText = currentStatement.getSpeech(0);
				currentStatementText = replaceGeneralTerm(currentStatementText);
			}
			
			if (typeEffect) statementText= "";
			else statementText = currentStatementText;
			
			spectralText = new SpectralText("", new GlowFilter(0x000000, 1, 2, 2, 10), textSize, textColor, .8);
			spectralText.setText(statementText);
			spectralImage.addObject(0, spectralText, 1, 1);
			spectralImage.addObject(0, pressE, 270 - spectralText.getTextWidth() / 2, spectralText.getTextHeight() + 200);
			
			for (var i:int = 0; i < textEffects.length; i++) {
				if (!(textEffects[i] is SpectralEffect)) continue;
				spectralImage.addEffect(0, textEffects[i] as SpectralEffect);
			}
			
			this.addChild(spectralImage);
			spectralImage.beginImage();
		}
		
		override public function undrawStatement():void 
		{
			spectralImage.clearImage();
			this.removeChild(spectralImage);
		}
		
		override public function checkStatementKey(event:KeyboardEvent, enterKeyDown:Boolean, currentDialogue:Dialogue):Boolean 
		{
			//if (OverlayManager.getSingleton().numOfOverlays() > 1) return;
			if (currentStatement == null || spectralImage == null) return false;
			if (enterKeyDown) return false;
			
			// If 'e' is hit when the NPC statement is still animating, finish the animation.
			// If 'e' is hit when it's done, this progresses the dialogue into the next statement or response.
			// If there is none, we end the dialogue.
			if ((checkKeyInput("Action Key", event.keyCode) || checkKeyInput("Alt Action Key", event.keyCode)) 
					&& !enterKeyDown) {
				enterKeyDown = true;
				
				if (currentStatementText.length - 1 > spectralText.getTextLength()) {
					// Finish animation.
					spectralText.setText(currentStatementText);
					
				}
				else {
					
					// Loop through statement list and find index of our current statement.
					for (var j:int = 0; j < currentStatement.getSpeechLength(); j++) {
						
						if (currentStatement.getSpeech(j) == currentStatementText) {
							if(j < currentStatement.getSpeechLength() - 1){
								// If we aren't on the last statement, move to the next statement.
								currentStatementText = currentStatement.getSpeech(j + 1);
								if (typeEffect) 
									spectralText.setText("");
								else
									spectralText.setText(currentStatementText);
								
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