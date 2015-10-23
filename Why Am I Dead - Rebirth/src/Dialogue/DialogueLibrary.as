package Dialogue 
{
	import adobe.utils.CustomActions;
	import Characters.Character;
	import Characters.CharacterManager;
	import Cinematics.CinematicManager;
	import Cinematics.Trigger;
	import Core.GameState;
	import Interface.GUIManager;
	import Main;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import Setup.GameLoader;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author Patrick McGrath
	 */

	public class DialogueLibrary {
		 
		 private static var singleton:DialogueLibrary;
		 
		 private var dialogues:Dictionary;	// keys - dialogue title eg: "Bob-Billy-init"
		 private var triggerList:Dictionary;
		 
		 public static function getSingleton():DialogueLibrary {
			 if (singleton == null)
				singleton = new DialogueLibrary();
			return singleton;
		 }
		 
		 public function DialogueLibrary() {
			// Shouldn't be called directly!
			dialogues = new Dictionary();
			triggerList = new Dictionary();
			
			loadAllDialogues();
		}
		 
		 public function resetTriggers():void {
			 for (var key:Object in triggerList) {
				 var tempTrig:Trigger = triggerList[key];
				 tempTrig.deactivateTrigger();
				 // TODO: Obviously when I implement game saves this function will not be necessary.
			 }
		 }
		 
		public function reloadAllDialogues():void {
			dialogues = new Dictionary();
			triggerList = new Dictionary();
			loadAllDialogues();
		}
		
		public function loadAllDialogues():void {
			
			loadDialogue(new GameLoader.CricketDialogues() as ByteArray);
			loadDialogue(new GameLoader.RandyDialogues() as ByteArray);
			loadDialogue(new GameLoader.LucilleDialogues() as ByteArray);
			loadDialogue(new GameLoader.TedDialogues() as ByteArray);
			loadDialogue(new GameLoader.MorganDialogues() as ByteArray);
			loadDialogue(new GameLoader.IblisDialogues() as ByteArray);
			loadDialogue(new GameLoader.RoseDialogues() as ByteArray);
			loadDialogue(new GameLoader.OrvalDialogues() as ByteArray);
			loadDialogue(new GameLoader.SarahDialogues() as ByteArray);
			
			loadDialogue(new GameLoader.PropDialogues() as ByteArray);
			
			loadDialogue(new GameLoader.Ending2Dialogues() as ByteArray);
			loadDialogue(new GameLoader.Ending3Dialogues() as ByteArray);
			loadDialogue(new GameLoader.Ending4Dialogues() as ByteArray);
		}
		
		 public function retrieveDialogue(title:String):Dialogue {
			
			for (var key:String in triggerList) { // iterate through all known triggers
				if (dialogues[title + key] != null && triggerList[key].isOn())
					// If there is a dialogue that contains a trigger that is on, return that one.
					return dialogues[title + key];
			}
			// Otherwise, just return the default dialogue.
			return dialogues[title];
		}
	 
		 private function loadDialogue(file:ByteArray):void {
			var fileStr:String = file.toString();
			var fileArray:Array = fileStr.split(/\n/);
			
			var dialogueTitle:String;
			
			for (var i:int = 0; i < fileArray.length; i++) {
				// go through all the lines of the script file.
				
				if (fileArray[i].indexOf("dialogue start") >= 0) {
					dialogueTitle = fileArray[i + 1];
					dialogueTitle = dialogueTitle.replace("\n", "");
					dialogueTitle = dialogueTitle.replace("\r", "");
					
					var newDialogue:Dialogue = parseDialogue(fileArray, i, dialogueTitle);
					if (newDialogue != null)
						dialogues[dialogueTitle] = newDialogue;
				}
			}
			
			
		}
		
		private function parseDialogue(fileArray:Array, index:int, title:String):Dialogue {
			
			var dialogueTitle:String = title;
			var onResponse:Boolean = false;
			var tempResponse:Response;
			var onStatement:Boolean = false;
			var tempStatement:Statement;
			var actions:Dictionary = new Dictionary();
			var firstAction:String = "root";
			
			for (var i:int = index; i < fileArray.length; i++) {
				
				if (fileArray[i].indexOf("dialogue end") >= 0) {
					// We've gone through the whole dialogue.
					
					if (dialogues[dialogueTitle] == null)
						// If this is a new dialogue, construct it.
						return new Dialogue(dialogueTitle, firstAction, actions);
					else {
						// If this is an old dialogue, go through the new actions and add them all.
						var oldDialogue:Dialogue = dialogues[dialogueTitle];
						for (var key:Object in actions) {
							var dialogueAction:DialogueAction = actions[key] as DialogueAction;
							oldDialogue.addAction(key + "", dialogueAction);
						}
						return null;
					}
				}
				
				if (fileArray[i].indexOf("action end") >= 0) {
					// Exit out of the current DialogueAction.
					// But add the constructed action to the actions dictionary first!
					if (onResponse) {
						actions[tempResponse.getTitle()] = tempResponse;
						onResponse = false;
						tempResponse = null;
					}
					else if (onStatement) {
						actions[tempStatement.getTitle()] = tempStatement;
						onStatement = false;
						tempStatement = null;
					}
				}
				
				if (fileArray[i].indexOf(":") >= 0) {
					// A colon is always used to either initiate a DialogueAction or add new information to one.
					var parsedLine:Array = fileArray[i].split(':');
					
					if (parsedLine[0] == "action") {
						// We're starting a new DialogueAction.
						if (onResponse == true || onStatement == true)
							throw new Error("Script Error: Two actions have been written next to each other without one being closed!");
						
						else if (parsedLine[1] == "response") {
							onResponse = true;
							var respTitle:String = parsedLine[2];
							var speaker:String = fileArray[i + 1];
							respTitle = respTitle.replace("\n", "");
							respTitle = respTitle.replace("\r", "");
							speaker = speaker.replace("\n", "");
							speaker = speaker.replace("\r", "");
							tempResponse = new Response(respTitle, speaker);
						}
						else if (parsedLine[1] == "statement") {
							onStatement = true;
							var stateTitle:String = parsedLine[2];
							stateTitle = stateTitle.replace("\n", "");
							stateTitle = stateTitle.replace("\r", "");
							tempStatement = new Statement(stateTitle);
						}
						
					}
					
					else if (onResponse) {
						// We're adding new information to a Response action.
						tempResponse = parseResponse(parsedLine, tempResponse);
					}
					
					else if (onStatement) {
						// We're adding new information to a Statement action.
						parsedLine = fileArray[i].split(':');
						
						if (parsedLine[0] == "next") {
							// Keyword designating what DialogueAction will follow this statement
							title = parsedLine[1];
							title = title.replace("\n", "");
							title = title.replace("\r", "");
							tempStatement.setNextAction(title);
						}
						else {
							// Otherwise we're adding a line of text
							tempStatement = parseStatement(parsedLine, tempStatement);
						}
						
					}
				}
				
			}
			
			throw new Error("Script error: Dialogue is not given an end!");
		}
		
		private function parseStatement(parsedLine:Array, tempStatement:Dialogue.Statement):Statement {
			
			var speaker:String = parsedLine[0];
			var text:String = parsedLine[1];
			text = text.replace("\n", "");
			text = text.replace("\r", "");
			
			tempStatement.addText(speaker, text);
			return tempStatement;
		}
		
		private function parseResponse(parsedLine:Array, tempResponse:Response):Response {
			
			var title:String = parsedLine[0];
			var parsedTitle:Array = parsedLine[0].split('-');
			var response:String = parsedLine[1];
			response = response.replace("\n", "");
			response = response.replace("\r", "");
			
			// Check to see if there is a trigger in this response's title, 
			// 		and if there is, add it to the composed exchange.
			for (var t:int = 0; t < parsedTitle.length; t++) {
				if (parsedTitle[t].indexOf(".") > 0) {
					// . is the notation for a trigger.
					var parsedTrigger:Array = parsedTitle[t].split('.');
					if (parsedTrigger[0] == "trigger") {
						// If this trigger doesn't yet exist, create an empty one and add it to CinematicsManager.
						if (CinematicManager.getSingleton().getTrigger(parsedTrigger[1]) == null){
							var trigger:Trigger = new Trigger(parsedTrigger[1], 0, null);
							CinematicManager.getSingleton().addTrigger(trigger);
						}
						else
							trigger = CinematicManager.getSingleton().getTrigger(parsedTrigger[1]);
							
						if (triggerList[parsedTrigger[1]] == null)
							triggerList[parsedTrigger[1]] = trigger;
						tempResponse.addTrigger(response, trigger);
					}
				}
			}
			
			// If parsedLine has a third component, there may be a trigger 
			//		designated to turn on if this response is selected.
			if (parsedLine.length >= 3) {
				if (parsedLine[2].indexOf(".") > 0) {
					var parsedSwitch:Array = parsedLine[2].split('.'); // Check to see if it is formatted correctly
					if (parsedSwitch[0] == "trigger") {
						
						var trigSwitch:String = parsedSwitch[1];
						trigSwitch = trigSwitch.replace("\n", "");
						trigSwitch = trigSwitch.replace("\r", "");
						var command:String = parsedSwitch[2];
						command = command.replace("\n", "");
						command = command.replace("\r", "");
						
						if (CinematicManager.getSingleton().getTrigger(trigSwitch) == null){
							trigger = new Trigger(trigSwitch, 0, null);
							CinematicManager.getSingleton().addTrigger(trigger);
						}
						else
							trigger = CinematicManager.getSingleton().getTrigger(trigSwitch);
							
						if (triggerList[trigSwitch] == null)
							triggerList[trigSwitch] = trigger;
						
						tempResponse.addTriggerSwitch(response, triggerList[trigSwitch], command);
					}
				}
			}
			
			tempResponse.addResponse(title, response);
			return tempResponse;
		}
		
		
		public function isTriggerOn(name:String):Boolean {
			if (triggerList[name] != null)
				return triggerList[name].isOn();
			else return false;
		}
		
		
		
		public function resetDialogues():void {
			singleton = null;
		}
		
		
		public function listenToTrigger(parsedRequirement:Array):Boolean {
			return false;
		}
		
		public function performTriggerEffect(parsedEffect:Array):void {
			
			if (parsedEffect[0] == "changeDialogueRoot") {
				var dialogueName:String = parsedEffect[1];
				var newRoot:String = parsedEffect[2];
				
				var dialogue:Dialogue = dialogues[dialogueName];
				if (dialogue != null)
					dialogue.changeRootAction(newRoot);
			}
			
		}
		
		public function saveDialogueLibrary(saveFile:SaveFile):void {
			for (var key:Object in dialogues) {
				var tempDialogue:Dialogue = dialogues[key] as Dialogue;
				tempDialogue.saveDialogue(saveFile);
			}
		}
		public function initiateDialogueLibrary(saveFile:SaveFile):void {
			if (saveFile == null) return;
			
			for (var key:Object in dialogues) {
				var tempDialogue:Dialogue = dialogues[key] as Dialogue;
				tempDialogue.loadDialogue(saveFile);
			}
		}
		
		
	 }
}