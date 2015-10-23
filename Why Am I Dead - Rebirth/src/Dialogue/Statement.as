package Dialogue 
{
	import Characters.Character;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	 public class Statement extends DialogueAction 
	 {
		
		private var speakers:Array; // List of the speaker for each respective text
		private var texts:Array;
		private var nextAction:String;
	 
		public function Statement(title:String) {
			super(title);
			speakers = [];
			texts = [];
		}
		
		public function addText(speaker:String, text:String):void {
			speakers.push(speaker);
			texts.push(text);
		}
		
		public function setNextAction(title:String):void { nextAction = title; }
		public function getNextAction():String { return nextAction; }
		public function getSpeaker(index:int):String { 
			if (index >= 0 && index < speakers.length) 
				return speakers[index]; 
			return null;
		}
		public function getSpeech(index:int):String { 
			if (index >= 0 && index < texts.length) 
				return texts[index];
			return null;
		}
		public function getSpeechLength():int { return texts.length; }
	 
	}

}