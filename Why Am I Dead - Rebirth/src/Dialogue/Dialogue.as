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
		protected var title:String;
		 
		public function Dialogue(title:String, firstAction:String, actions:Dictionary){
			this.firstAction = firstAction;
			this.title = title;
			this.actions = actions;
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
		
		public function saveDialogue(saveFile:SaveFile):void {
			saveFile.saveData(title + " rootAction", firstAction);
		}
		public function loadDialogue(saveFile:SaveFile):void {
			if (saveFile.loadData(title + " rootAction") != null)
				firstAction = saveFile.loadData(title + " rootAction") + "";
		}
	 
	 }

}