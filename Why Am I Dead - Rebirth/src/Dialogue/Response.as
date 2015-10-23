package Dialogue 
{
	import Cinematics.Trigger;
	import flash.utils.Dictionary;
	import Misc.Tuple;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Response extends DialogueAction
	{
		private var speaker:String;
		private var children:Array;	// List of DialogueAction titles
		private var responseList:Array;  	// List of response strings.
		
		// Dictionary of triggers corresponding to each response, regarding trigger required to access the response.
		private var triggerDict:Dictionary; 
		// Dictionary of triggers corresponding to each response, regarding trigger 
		// 		that is switched on when statement is selected.
		private var switchTrigDict:Dictionary;
		
		public function Response(title:String, speaker:String) 
		{
			super(title);
			
			this.speaker = speaker;
			children = [];
			responseList = [];
			triggerDict = new Dictionary();
			switchTrigDict = new Dictionary();
		}
		
		
		public function addResponse(title:String, newResp:String):void {
			responseList.push(newResp);
			children.push(title);
		}
		public function addTrigger(responseTitle:String, trigger:Trigger):void {
			triggerDict[responseTitle] = trigger;
		}
		public function addTriggerSwitch(responseTitle:String, trigger:Trigger, command:String):void {
			switchTrigDict[responseTitle] = new Tuple(trigger, command);
		}
		
		public function getSpeaker():String { return speaker; }
		public function getResponse(index:int):String { return responseList[index]; }
		public function getResponses():Array { return responseList; }
		public function getTriggers():Dictionary { return triggerDict; }
		public function getSwitches():Dictionary { return switchTrigDict; }
		public function getChild(index:int):String { return children[index]; }
		
		public function getResponseSwitch(response:String):Tuple {
			return switchTrigDict[response];
		}
		
		public function getResponseTitle(response:String):String {
			for (var i:int = 0; i < responseList.length; i++) {
				if (responseList[i].getResponse() == response)
					return responseList[i].getTitle();
			}
			return null;
		 }
		 
		public function hasResponses():Boolean {
			if (responseList.length > 0) return true;
			else return false;
		}
		
	}

}