package AI 
{
	import Characters.Character;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import Maps.MapManager;
	import Misc.Tuple;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author ...
	 */
	public class CharacterAI 
	{
		private var host:Character;
		// key = trigger name ;  value = path destination
		private var pathDict:Dictionary;
		
		private var currentCommand:CharacterCommand;
		private var currentBehavior:Behavior;
		
		
		public function CharacterAI(host:Character) 
		{
			this.host = host;
		}
		
		public function updateCharAI():void {
			if (currentBehavior != null)
				if(!currentBehavior.isPaused())
					currentBehavior.updateBehavior();
			
			if (currentCommand != null)
				if (currentCommand.commandRunning())
					currentCommand.updateCommand();
		}
		
		public function setRandomBehavior(frequency:int, origin:Tuple = null, horizontalBound:int = 1, verticalBound:int = 1):void {
			origin = initiateBehavior(origin);
			currentBehavior = new RandomBehavior(host, origin, frequency, horizontalBound, verticalBound);
			currentBehavior.initiateBehavior(this);
		}
		public function setPacingBehavior(frequency:int, horizontal:Boolean, length:int, origin:Tuple = null):void {
			origin = initiateBehavior(origin);
			currentBehavior = new PacingBehavior(host, origin, frequency, horizontal, length);
			currentBehavior.initiateBehavior(this);
		}
		public function setRoutineBehavior(destinations:Array, destinationMaps:Array,
											frequency:Array, loop:Boolean, origin:Tuple = null):void {
			origin = initiateBehavior(origin);
			currentBehavior = new RoutineBehavior(host, origin, frequency, destinations, destinationMaps, loop, 60);
			currentBehavior.initiateBehavior(this);
		}
		public function setBehavior(behavior:Behavior):void {
			clearBehavior();
			currentBehavior = behavior;
			currentBehavior.initiateBehavior(this);
		}
		
		private function initiateBehavior(origin:Tuple = null):Tuple {
			clearBehavior();
			if (origin == null) origin = new Tuple(host.getNearestTilePoint(), host.getCurrentMap());
			return origin;
		}
		
		public function clearBehavior():void {
			if (currentBehavior != null){
				currentBehavior.stopBehavior();
				currentBehavior = null;
			}
		}
		public function pauseBehavior():void {
			if (currentBehavior != null)
				currentBehavior.stopBehavior();
		}
		public function resumeBehavior():void {
			if (currentBehavior != null)
				currentBehavior.resumeBehavior();
		}
		
		public function setCommand(command:CharacterCommand):void { 
			if (currentCommand != null) currentCommand.stopCommand();
			currentCommand = command;
			currentCommand.startCommand();
		}
		public function clearCommand():void {
			if (currentCommand != null) currentCommand.stopCommand();
			currentCommand = null;
		}
		public function hasCommand():Boolean {
			if (currentCommand != null)
				if(currentCommand.commandRunning())
					return true;
			return false;
		}
		
		public function commandIncomplete():Boolean {
			if (currentCommand != null)
				return currentCommand.commmandIncomplete();
			return false;
		}
		public function commandRunning():Boolean {
			if (currentCommand != null)
				return currentCommand.commandRunning();
			return false;
		}
		
		public function pauseCommand():void {
			if (currentCommand != null) currentCommand.stopCommand();
		}
		public function resumeCommand():void {
			if (currentCommand != null) currentCommand.startCommand();
		}
		
		public function saveCharAI(saveFile:SaveFile):void {
			if (currentBehavior != null) {
				saveFile.saveData(host.getName() + "AInull", false);
				currentBehavior.saveBehavior(saveFile, host.getName());
			}
			else
				saveFile.saveData(host.getName() + "AInull", true);
		}
		public function loadCharAI(saveFile:SaveFile, mapManager:MapManager):void {
			if (saveFile.loadData(host.getName() + "AInull")) {
				currentBehavior = null;
				return;
			}
			
			currentBehavior = constructBehavior(saveFile, mapManager);
			if (currentBehavior != null) {
				currentBehavior.initiateBehavior(this);
				currentBehavior.resumeBehavior();
			}
			
			if (saveFile.loadData(host.getName() + " behaviorStatus") == "paused")
				currentBehavior.stopBehavior();
		}
		
		private function constructBehavior(saveFile:SaveFile, mapManager:MapManager):Behavior {
			var origin:Tuple = new Tuple(0, 0);
			var originPt:Object = saveFile.loadData(host.getName() + " behaviorOriginPoint");
			
			origin.former = new Point(originPt.x, originPt.y);
			origin.latter = mapManager.getMap(saveFile.loadData(host.getName() + " behaviorOriginMap") + "");
			var frequency:int = saveFile.loadData(host.getName() + " behaviorFreq") as int;
			
			if (saveFile.loadData(host.getName() + " behaviorType") == "Random")
				return constructRandomBehavior(saveFile, origin, frequency);
			else if (saveFile.loadData(host.getName() + " behaviorType") == "Pacing")
				return constructPacingBehavior(saveFile, origin, frequency);
			else if (saveFile.loadData(host.getName() + " behaviorType") == "Routine")
				return constructRoutineBehavior(saveFile, origin, frequency, mapManager);
			
			return null;
		}
		private function constructRandomBehavior(saveFile:SaveFile, origin:Tuple, frequency:int):RandomBehavior {
			var horizontalBound:int = saveFile.loadData(host.getName() + " randomHorBound") as int;
			var verticalBound:int = saveFile.loadData(host.getName() + " randomVerBound") as int;
			
			return new RandomBehavior(host, origin, frequency, horizontalBound, verticalBound);
		}
		private function constructPacingBehavior(saveFile:SaveFile, origin:Tuple, frequency:int):PacingBehavior {
			var horizontalStr:String = saveFile.loadData(host.getName() + " pacingHorizontal") as String;
			var firstLength:int = saveFile.loadData(host.getName() + " pacingLength") as int;
			
			var horizontal:Boolean;
			if (horizontalStr == "true") horizontal = true;
			else horizontal = false;
			
			return new PacingBehavior(host, origin, frequency, horizontal, firstLength);
		}
		private function constructRoutineBehavior(saveFile:SaveFile, origin:Tuple, frequency:int, mapManager:MapManager):RoutineBehavior {
			var destinations:Vector.<Object> = saveFile.loadData(host.getName() + " routineDestinations") as Vector.<Object>;
			var destinationMapStrs:Array = saveFile.loadData(host.getName() + " routineDestMaps") as Array;
			var freqArray:Array = saveFile.loadData(host.getName() + " routineFrequencies") as Array;
			var loopStr:String = saveFile.loadData(host.getName() + " routineLoop") as String;
			var waitTime:int = saveFile.loadData(host.getName() + " routineWaitTime") as int;
			
			var loop:Boolean;
			if (loopStr == "true") loop = true;
			else loop = false;
			
			var destinationList:Array = [];
			for each(var point:Object in destinations) {
				var tempPoint:Point = new Point(point.x, point.y);
				destinationList.push(tempPoint);
			}
			
			var destinationMaps:Array = [];
			for each(var mapName:String in destinationMapStrs)
				destinationMaps.push(mapManager.getMap(mapName));
			
			return new RoutineBehavior(host, origin, freqArray, destinationList, destinationMaps, loop, waitTime);
		}
		
	}

}