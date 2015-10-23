package AI 
{
	import Characters.Character;
	import Core.Game;
	import Core.GameState;
	import flash.events.Event;
	import flash.geom.Point;
	import Maps.Map;
	import Misc.Tuple;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author ...
	 */
	public class Behavior 
	{
		
		protected var currentCommand:CharacterCommand;
		protected var host:Character;
		protected var charAI:CharacterAI;
		
		protected var frequency:int;
		protected var origin:Tuple;
		protected var timer:int;
		protected var resumeTimer:int;
		
		protected var paused:Boolean;
		
		public function Behavior(behavior:Behavior, host:Character, origin:Tuple, frequency:int) 
		{
			if (behavior != this) throw new Error("Behavior is meant to be used only as an abstract class!");
			this.host = host;
			this.origin = origin;
			this.frequency = frequency;
			this.timer = 0;
			this.paused = false;
			this.resumeTimer = 120;
			
		}
		
		public function initiateBehavior(charAI:CharacterAI):void {
			this.charAI = charAI;
		}
		
		public function stopBehavior():void {
			if (currentCommand != null) {
				currentCommand.stopCommand();
				currentCommand = null;
			}
			Game.getSingleton().stage.removeEventListener(Event.ENTER_FRAME, waitToResume);
			paused = true;
		}
		public function resumeBehavior():void {
			if (paused) {
				Game.getSingleton().stage.addEventListener(Event.ENTER_FRAME, waitToResume);
			}
		}
		private function waitToResume(event:Event):void {
			if (resumeTimer <= 0) {
				Game.getSingleton().stage.removeEventListener(Event.ENTER_FRAME, waitToResume);
				paused = false;
				resumeTimer = 120;
			}
			else resumeTimer--;
		}
		
		public function updateBehavior():void {
			return;
		}
		
		public function isPaused():Boolean { return paused; }
		public function getHost():Character { return host; }
		public function getFrequency():int { return frequency; }
		public function getOrigin():Tuple { return origin; }
		
		
		public function saveBehavior(saveFile:SaveFile, charName:String):void {
			var originMap:Map = origin.latter as Map;
			saveFile.saveData(charName + " behaviorOriginMap", originMap.getMapName());
			saveFile.saveData(charName + " behaviorOriginPoint", origin.former);
			saveFile.saveData(charName + " behaviorFreq", frequency);
			if (paused)
				saveFile.saveData(charName + " behaviorStatus", "paused");
			else
				saveFile.saveData(charName + " behaviorStatus", "active");
		}
		
	}

}