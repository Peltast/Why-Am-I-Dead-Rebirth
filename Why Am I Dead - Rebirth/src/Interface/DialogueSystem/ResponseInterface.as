package Interface.DialogueSystem 
{
	import Core.Game;
	import Dialogue.Response;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Peltast
	 */
	public class ResponseInterface extends Sprite
	{
		
		protected var textFormat:TextFormat;
		protected var responseList:Array;
		protected var triggerList:Dictionary;
		
		public function ResponseInterface(selfRef:ResponseInterface) 
		{
			if (selfRef != this) throw new Error("ResponseInterface is meant to be used as an abstract class!");
			
		}
		
		public function drawResponse(currentResponse:Response):void { }
		public function undrawResponse():void { }
		
		public function updateResponse(event:Event, mouse:Point):void { }
		
		public function checkResponseKey(key:KeyboardEvent, enterKeyDown:Boolean):int { return -1; }
		public function checkResponseMouse(mouse:MouseEvent):int { return -1; }
		
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
		
	}

}