package Interface.DialogueSystem 
{
	import Core.Game;
	import Dialogue.Dialogue;
	import Dialogue.Statement;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.text.TextFormat;
	import Setup.ControlsManager;
	/**
	 * ...
	 * @author Peltast
	 */
	public class StatementInterface extends Sprite
	{
		protected var textFormat:TextFormat;
		
		public function StatementInterface(selfRef:StatementInterface) 
		{
			if (this != selfRef)
				throw new Error("StatementInterface is meant to be used as an abstract class!");
		}
		
		public function drawStatement(currentStatement:Statement):void { }
		public function undrawStatement():void { }
		
		public function updateStatement():void { }
		
		public function checkStatementKey(key:KeyboardEvent, enterKeyDown:Boolean, currentDialogue:Dialogue):Boolean 
			{ return false; }
		
		
		protected function replaceGeneralTerm(dialogue:String):String 
		{
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
		
		
		protected function checkKeyInput(keyName:String, keyCode:uint):Boolean {
			if (ControlsManager.getSingleton().getKey(keyName) == keyCode)
				return true;
			return false;
		}
	}

}