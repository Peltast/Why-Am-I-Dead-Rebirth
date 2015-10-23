package AI 
{
	import adobe.utils.CustomActions;
	import Characters.Character;
	import flash.events.Event;
	import flash.geom.Point;
	import Maps.Map;
	import Misc.Tuple;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class RoutineBehavior extends Behavior
	{
		
		private var destinationList:Vector.<Destination>;
		// index of current waypoint
		private var currentWaypoint:int;
		
		// If loop is true, will go from the last waypoint directly back to the first.  If false, will go back through
		// the waypoints in reverse order.
		private var loop:Boolean;
		private var delta:int;
		private var waitTime:int;
		private var waitTimer:int;
		
		public function RoutineBehavior(host:Character, origin:Tuple, freq:Array,
				destinations:Array, destinationMaps:Array, loop:Boolean, waitTime:int) 
		{
			super(this, host, origin, -1);
			destinationList = new Vector.<Destination>();
			constructDestinationList(destinations, destinationMaps, freq);
			
			this.loop = loop;
			this.waitTime = waitTime;
			waitTimer = 0;
			
			currentWaypoint = -1;
			delta = 1;
		}
		
		override public function updateBehavior():void 
		{
			super.updateBehavior();
			if (charAI == null) return;
			
			if (currentWaypoint < 0) proceedToWaypoint();
			else {
				
				// If the previous attempt to move forward failed
				if (charAI.commandIncomplete() || !charAI.commandRunning()) {
					
					if (waitTime == -1) stopBehavior(); // and waitTime is less than zero, stop the behavior altogether
					
					else {	// otherwise wait for a specified amount of time
						waitTimer++;
						if (waitTimer > waitTime) {
							
							// And then try again.
							waitTimer = 0;
							currentWaypoint -= delta;
							proceedToWaypoint();
						}
					}
				}
				
				if (timer > destinationList[currentWaypoint].frequency) {
					timer = 0;
					proceedToWaypoint();
				}
				
				if (host.getNearestTilePoint().x == destinationList[currentWaypoint].point.x && 
					host.getNearestTilePoint().y == destinationList[currentWaypoint].point.y)
						timer++;
			}
			
		}
		
		private function proceedToWaypoint():void {
			
			if (currentWaypoint < 0 || (delta < 0 && currentWaypoint == 0))
				delta = 1;
			currentWaypoint += delta;
			
			if (currentWaypoint > destinationList.length - 1) {
				if (loop) currentWaypoint = 0;
				else {
					delta = -1;
					currentWaypoint += delta;
				}
			}
			currentCommand = new CharacterCommand
				(host, destinationList[currentWaypoint].point, destinationList[currentWaypoint].map, false);
			charAI.setCommand(currentCommand);
			
		}
		
		private function constructDestinationList(destinations:Array, destinationMaps:Array, frequencies:Array):void {
			if (destinations.length != destinationMaps.length || destinationMaps.length != frequencies.length)
				throw new Error("AI Error: RoutineBehavior is given incomplete destination information.");
			
			for (var i:int = 0; i < destinations.length; i++) {
				addNewDestination(i, destinations[i], destinationMaps[i], frequencies[i]);
			}
		}
		
		public function addNewDestination(index:int, destination:Point, destinationMap:Map, frequency:int):void {
			var newDestination:Destination = new Destination(index, destination, destinationMap, frequency);
			
			for (var i:int = 0; i < destinationList.length; i++) {
				var tempDestination:Destination = destinationList[i];
				if (newDestination.index == tempDestination.index) 
					throw new Error("AI Error: RoutineBehavior has two destinations at the same time.");
				
				if (newDestination.index < tempDestination.index) {
					destinationList.splice(i, 0, newDestination);
					return;
				}
			}
			destinationList.push(newDestination);
		}
		
		public function setLoop(b:Boolean):void { loop = b; }
		public function setWaitTime(timer:int):void { waitTime = timer; }
		public function setHost(host:Character):void { this.host = host; } 
		
		override public function resumeBehavior():void 
		{
			super.resumeBehavior();
			currentWaypoint = -1;
			timer = 0;
		}
		
		override public function saveBehavior(saveFile:SaveFile, charName:String):void 
		{
			super.saveBehavior(saveFile, charName);
			
			var loopString:String;
			if (loop) loopString = "true";
			else loopString = "false";
			
			var points:Vector.<Object> = new Vector.<Object>();
			var mapStrings:Array = [];
			var frequencies:Array = [];
			for each(var destination:Destination in destinationList) {
				points.push(destination.point);
				mapStrings.push(destination.map.getMapName());
				frequencies.push(destination.frequency);
			}
			
			saveFile.saveData(charName + " behaviorType", "Routine");
			saveFile.saveData(charName + " routineDestinations", points);
			saveFile.saveData(charName + " routineDestMaps", mapStrings);
			saveFile.saveData(charName + " routineFrequencies", frequencies);
			saveFile.saveData(charName + " routineLoop", loopString);
			saveFile.saveData(charName + " routineWaitTime", waitTime);
		}
		
	}
	
}
import flash.geom.Point;
import Maps.Map;

class Destination {
	
	public var index:int;
	public var point:Point;
	public var map:Map;
	public var frequency:int;
	
	public function Destination(index:int, point:Point, map:Map, frequency:int) {
		this.index = index;
		this.point = point;
		this.map = map;
		this.frequency = frequency;
	}
	
}