package Dialogue 
{
	import Characters.Animation;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import Characters.Character;
	import Main;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	
	public class Dialogue {
		
		protected var firstAction:String; // the title of the root action for the dialogue
		protected var actions:Dictionary; // the dictionary containing all possible actions in the dialgogue
		protected var visitedActions:Dictionary;
		protected var title:String;
		 
		public function Dialogue(title:String, firstAction:String, actions:Dictionary){
			this.firstAction = firstAction;
			this.title = title;
			this.actions = actions;
			
			visitedActions = new Dictionary();
			for (var actionTitle:Object in actions) {
				visitedActions[actionTitle + ""] = 0;
			}
		}
		
		public function changeRootAction(newRoot:String):void {
			if (actions[newRoot] != null)
				firstAction = newRoot;
		}
		
		public function getTitle():String { return title; }
		public function getRootAction():DialogueAction { return actions[firstAction]; }
		public function getAction(title:String):DialogueAction { 
			return actions[title];
		}
		public function addAction(title:String, action:DialogueAction):void {
			if (actions[title] != null)
				throw new Error("Dialogue error: Duplicate actions are being added to a dialogue.");
			else
				actions[title] = action;
		}
		
		public function setActionVisited(title:String):void {
			visitedActions[title] = 1;
		}
		public function checkActionVisited(title:String):Boolean {
			if (visitedActions[title] == null) return false;
			else if (visitedActions[title] == 1) return true;
			else return false;
		}
		
		public function isDialogueExhausted():Boolean {
			return checkActionExhausted(firstAction, firstAction);
		}
		
		public function checkActionExhausted(title:String, origin:String):Boolean {
			var checkedActions:Dictionary = new Dictionary();
			checkedActions[origin] = 1;
			checkedActions[title] = 1;
			return checkActionVisitedRecursive(title, checkedActions);
		}
		private function checkActionVisitedRecursive(title:String, checkedActions:Dictionary):Boolean {
			var childAction:String;
			
			if (actions[title] is Statement) {
				var currentStatement:Statement;
				currentStatement = actions[title] as Statement;
				childAction = currentStatement.getNextAction();
				
				if (checkedActions[childAction] == null)
					checkedActions[childAction] = 1;
				else
					return checkActionVisited(title);
				
				// If we've reached a dead end, return whether this current statement was visited.
				if (actions[childAction] == null)
					return checkActionVisited(title);
				// If we haven't reached the end, recurse through the next action.
				else
					return checkActionVisitedRecursive(childAction, checkedActions);
			}
			else if (actions[title] is Response) {
				var currentResponse:Response;
				currentResponse = actions[title] as Response;
				
				var exhausted:Boolean = true;
				// We have to go through all response options and see if they've all been exhausted.
				for (var i:int = 0; i < currentResponse.getResponses().length; i++) {
					childAction = currentResponse.getChild(i);
					
					var childActionStr:String = currentResponse.getResponse(i);
					if (!currentResponse.isResponseTriggered(childActionStr))
						continue;
					else if (childActionStr.indexOf("null") && !checkActionVisited(title))
						exhausted = false;
					
					if (checkedActions[childAction] == null)
						checkedActions[childAction] = 1;
					else
						continue;
					
					// If even one option has not been visited recursively, we have not exhausted this response.
					if (!checkActionVisitedRecursive(childAction, checkedActions))
						exhausted = false;
				}
				// If all response options have been recursively exhausted, this response is exhausted.
				if (exhausted) {
					return true;
				}
				else
					return false;
			}
			return true;
		}
		
		public function saveDialogue(saveFile:SaveFile):void {
			saveFile.saveData(title + " rootAction", firstAction);
			saveFile.saveData(title + "visitedActions", visitedActions);
		}
		public function loadDialogue(saveFile:SaveFile):void {
			if (saveFile.loadData(title + " rootAction") != null)
				firstAction = saveFile.loadData(title + " rootAction") + "";
			if (saveFile.loadData(title + "visitedActions") != null)
				visitedActions = saveFile.loadData(title + "visitedActions") as Dictionary;
		}
	 
	 }

}