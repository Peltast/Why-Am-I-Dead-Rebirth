package Interface.DialogueSystem 
{
	import Characters.Character;
	import Characters.Player;
	import Cinematics.CinematicManager;
	import Cinematics.Trigger;
	import Core.*;
	import Dialogue.*;
	import flash.display.Bitmap;
	import flash.display.Shader;
	import flash.display.Shape;
	import Main;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import Misc.Tuple;
	import Setup.ControlsManager;
	import Setup.GameLoader;
	import Sound.SoundManager;
	import SpectralGraphics.EffectTypes.FadeEffect;
	import SpectralGraphics.EffectTypes.SpinEffect;
	import SpectralGraphics.EffectTypes.WaveEffect;
	import Interface.MenuSystem.*;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class DialogueBox extends Sprite
	{
		private var textFormat:TextFormat;
		private var spectralFormat:TextFormat;
		private var effectsArray:Array;
		private var highlightFormat:TextFormat;
		private var highlightStart:int;
		
		private var dialogueOn:Boolean;
		private var optionBox:MenuBox;
		private var responseHeight:int;
		private var currentDialogue:Dialogue;
		private var enterKeyDown:Boolean;
		
		private var currentAction:DialogueAction;
		private var currentStatement:Statement;
		private var currentResponse:Response;
		
		private var responseInterface:ResponseInterface;
		private var statementInterface:StatementInterface;
		private var subjectChar:Character;
		
		public function DialogueBox() 
		{	
			dialogueOn = false;
			
			textFormat = new TextFormat("AppleKid");
			textFormat.color = 0xffffff;
			textFormat.size = 16;
			responseHeight = 100;
			
			spectralFormat = new TextFormat("AppleKid");
			spectralFormat.color = 0xaa00ff;
			spectralFormat.size = 32;
			
			optionBox = new MenuBox(new Rectangle(0, 0, 460, responseHeight + 25), new GameLoader.MenuSkin() as Bitmap);
			optionBox.x = 40;
			optionBox.y = 5;
			
			enterKeyDown = false;
			
			effectsArray = [];
			//effectsArray.push(new FadeEffect(0, 1, .01));
			effectsArray.push(new WaveEffect(true, .01, .01, 1, 55));
			effectsArray.push(new WaveEffect(false, .025, .025, 1, 15));
			effectsArray.push(new SpinEffect(.1, .025, .025, 2));
			
			responseInterface = new RegularResponse(textFormat, responseHeight);
			statementInterface = new RegularStatement(textFormat);
			this.addChild(responseInterface);
			this.addChild(statementInterface);
		}
		
		public function updateDialogue(event:Event):void {
			
			if (currentAction == null) { // Initiate dialogue display by getting the root exchange
				currentAction = currentDialogue.getRootAction();
				drawAction(currentAction);
			}
			
			else if (currentStatement == null && currentResponse != null) {
				// The current responses have been shown but nothing has been clicked yet.  At this point,
				// update the clickPrompt to flash.
				responseInterface.updateResponse(event, new Point(mouseX, mouseY));
				
			}
			else if (currentStatement != null) {
				// If the NPC statement has been started, we need to update it for a typing effect.
				
				statementInterface.updateStatement();
			}
			
		}
		
		private function drawAction(action:DialogueAction):void {
			
			if (action is Statement) {
				currentStatement = action as Statement;
				currentDialogue.setActionVisited(action.getTitle());
				drawStatement(currentStatement);
			}
			else if (action is Response) {
				currentResponse = action as Response;
				currentDialogue.setActionVisited(action.getTitle());
				drawResponse(currentResponse);
			}
			// If currentAction is null, then the dialogue is over.
			else if (action == null) {
				endDialogue();
				return;
			}
		}
		private function drawStatement(currentStatement:Statement):void {
			
			statementInterface.drawStatement(currentStatement);	
		}
		
		private function undrawStatement():void {
			
			statementInterface.undrawStatement();
			currentStatement = null;
		}
		
		private function drawResponse(currentResponse:Response):void {
			
			responseInterface.drawResponse(currentResponse, currentDialogue);
		}
		private function undrawResponse():void {
			
			responseInterface.undrawResponse();
			currentResponse = null;
			Main.getSingleton().stage.focus = Main.getSingleton().stage;
		}
		
		private function releaseEnterKey(key:KeyboardEvent):void {
			if (checkKeyInput("Action Key", key.keyCode) || checkKeyInput("Alt Action Key", key.keyCode))
				enterKeyDown = false;
		}
		
		
		public function checkResponseMouse(mouse:MouseEvent):void {
			checkResponse(mouse);
		}
		public function checkResponseKey(key:KeyboardEvent):void {
			checkResponse(key);
		}
		private function checkResponse(event:Event):void {
			if (currentResponse == null) return;
			
			if (event is KeyboardEvent) 
				var responseSelection:int = responseInterface.checkResponseKey(event as KeyboardEvent, enterKeyDown);
			else if (event is MouseEvent) 
				responseSelection = responseInterface.checkResponseMouse(event as MouseEvent);
			else throw new Error("DialogueBox: Why is a different kind of event being thrown to the response interface?");
				
			if (responseSelection >= 0) {
				
				if (responseInterface is RegularResponse) enterKeyDown = true;
				
				var i:int = -1;
				while (true) {
					if (i >= responseSelection) break;
					
					i++;
					if (currentResponse.getTriggers()[currentResponse.getResponses()[i]] == null)
						continue;
					else if (currentResponse.getTriggers()[currentResponse.getResponses()[i]].isOn())
						continue;
					else responseSelection++;
					
				}
				
				// If the response we just clicked has a switch attached to it, we need to find the trigger
				//		and do whatever the switch tells us to.
				var responseSwitch:Tuple = currentResponse.getResponseSwitch(currentResponse.getResponses()[responseSelection]);
				if (responseSwitch != null){
					if (responseSwitch.latter == "off")
						CinematicManager.getSingleton().switchTriggerOff(responseSwitch.former.getTriggerName());
					else if (responseSwitch.latter == "on")
						CinematicManager.getSingleton().switchTriggerOn(responseSwitch.former.getTriggerName());
				}
				
				currentAction = currentDialogue.getAction(currentResponse.getChild(responseSelection));
				undrawResponse();
				
				// Prepare next action
				drawAction(currentAction);
			}
		}
		
		public function checkStatement(event:KeyboardEvent):void {
			if (!(currentAction is Statement)) return;
			
			if (statementInterface.checkStatementKey(event, enterKeyDown, currentDialogue)) {
				
				currentAction = currentDialogue.getAction(currentStatement.getNextAction());
				
				// Prepare next action
				undrawStatement();
				drawAction(currentAction);
			}
			if (checkKeyInput("Action Key", event.keyCode) || checkKeyInput("Alt Action Key", event.keyCode)) 
				enterKeyDown = true;
		}
		
		private var skipButtonDown:Boolean;
		public function listenToSkipPress(key:KeyboardEvent):void {
			if (!dialogueOn) return;
			if (currentAction is Response) return;
			else skipButtonDown = true;
		}
		public function listenToSkipRelease(key:KeyboardEvent):void {
			if (!dialogueOn) return;
			
			if (checkKeyInput("Cancel Key", key.keyCode) || checkKeyInput("Alt Cancel Key", key.keyCode)) {
				if (currentAction is Response)
					skipButtonDown = false;
				else if(skipButtonDown) {
					skipToResponse();
					skipButtonDown = false;
				}
			}
		}
		
		private function skipToResponse():void {
			if (currentAction is Response)
				return;
			else if (currentAction is Statement) {
				var nextResponse:Response = findNextResponse(currentAction);
				if (nextResponse == null) {
					undrawStatement();
					endDialogue();
					return;
				}
				undrawStatement();
				currentAction = nextResponse;
				drawAction(nextResponse);
			}
		}
		private function findNextResponse(action:DialogueAction):Response {
			if (action is Response)
				return action as Response;
			else if (action is Statement) {
				var currentStatement:Statement = action as Statement;
				return findNextResponse(currentDialogue.getAction(currentStatement.getNextAction()));
			}
			return null;
		}
		
		
		private function checkKeyInput(keyName:String, keyCode:uint):Boolean {
			if (ControlsManager.getSingleton().getKey(keyName) == keyCode)
				return true;
			return false;
		}
		
		public function resumeDialogue():void {
			Main.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, checkStatement);
			Main.getSingleton().stage.addEventListener(Event.ENTER_FRAME, updateDialogue);
			Main.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, checkResponseKey);
			Main.getSingleton().stage.addEventListener(MouseEvent.MOUSE_DOWN, checkResponseMouse);
			Main.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, releaseEnterKey);
		}
		public function pauseDialogue():void {
			Main.getSingleton().stage.removeEventListener(Event.ENTER_FRAME, updateDialogue);
			Main.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkResponseKey);
			Main.getSingleton().stage.removeEventListener(MouseEvent.MOUSE_DOWN, checkResponseMouse);
			Main.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkStatement);
			Main.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, releaseEnterKey);
		}
		
		
		public function startDialogue(dialogue:Dialogue, character:Character = null, spectral:Boolean = false):void { 
			if (dialogueOn == false) {				
				dialogueOn = true;
				currentDialogue = dialogue;
				if (character != null) {
					subjectChar = character;
					subjectChar.stopCharacter();
					subjectChar.pauseBehavior();
				}
				
				if (currentDialogue == null) {
					dialogueOn = false;
					return;
				}
				
				this.removeChild(statementInterface);
				this.removeChild(responseInterface);
				if (spectral) {
					statementInterface = new SpectralStatement
						(spectralFormat.size as int, spectralFormat.color as uint, effectsArray, false);
					responseInterface = new SpectralResponse
						(spectralFormat.size as int, spectralFormat.color as uint, effectsArray, []);
				}
				else {
					statementInterface = new RegularStatement(textFormat);
					responseInterface = new RegularResponse(textFormat, responseHeight);
				}
				this.addChild(statementInterface);
				this.addChild(responseInterface);
				
				Main.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, checkStatement);
				Main.getSingleton().stage.addEventListener(Event.ENTER_FRAME, updateDialogue);
				Main.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, checkResponseKey);
				Main.getSingleton().stage.addEventListener(MouseEvent.MOUSE_DOWN, checkResponseMouse);
				Main.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, releaseEnterKey);
				Main.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, listenToSkipPress);
				Main.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, listenToSkipRelease);
			}
		}
		public function endDialogue():void {
			if (subjectChar != null)
				subjectChar.resumeBehavior();
			this.addEventListener(Event.ENTER_FRAME, delayDialogueEnd);
			if(this.contains(optionBox)) this.removeChild(optionBox);
			
			if (currentDialogue != null && subjectChar != null)
				if (currentDialogue.isDialogueExhausted())
					subjectChar.removeSpeechBubble();
			
			currentDialogue = null;
			currentAction = null;
			currentStatement = null;
			currentResponse = null;
			subjectChar = null;
			
			Main.getSingleton().stage.removeEventListener(Event.ENTER_FRAME, updateDialogue);
			Main.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkResponseKey);
			Main.getSingleton().stage.removeEventListener(MouseEvent.MOUSE_DOWN, checkResponseMouse);
			Main.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkStatement);
			Main.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, releaseEnterKey);
			Main.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_DOWN, listenToSkipPress);
			Main.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, listenToSkipRelease);
		}
		private var endCount:int;
		private function delayDialogueEnd(event:Event):void {
			if (endCount > 2) { 
				endCount = 0;
				dialogueOn = false;
				this.removeEventListener(Event.ENTER_FRAME, delayDialogueEnd);
			}
			endCount++;
		}
		
		public function getDialogueOn():Boolean { return dialogueOn; }
		public function getDialogueName():String {
			if (currentDialogue != null)
				return currentDialogue.getTitle();
			return "";
		}
		
		private function replaceGeneralTerm(dialogue:String):String {
			if (dialogue.indexOf("<") >= 0) {
				// < > is the marker for general terms.
				var start:int = dialogue.indexOf("<");
				var end:int = dialogue.indexOf(">");
				if (start >= 0 && end > 0 && end > start) {
					var generalTerm:String = dialogue.slice(start + 1, end);
					generalTerm = Game.getSingleton().replaceGeneralTerm(generalTerm);
					dialogue = dialogue.substr(0, start) + generalTerm + dialogue.substr(end + 1);
				}
			}
			return dialogue;
		}
		
	}

}