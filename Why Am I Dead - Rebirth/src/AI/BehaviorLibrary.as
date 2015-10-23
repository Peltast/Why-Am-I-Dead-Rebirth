package AI 
{
	import Characters.Character;
	import Characters.CharacterManager;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import Maps.Map;
	import Maps.MapManager;
	import Misc.Tuple;
	/**
	 * ...
	 * @author Peltast
	 */
	public class BehaviorLibrary 
	{
		private var HOST_CHARACTER_NAME:int = 0;
		private var BEHAVIOR_ORIGIN:int = 2;
		private var BEHAVIOR_FREQUENCY:int = 3;
		
		private var behaviorInfoList:Dictionary;
		
		public function BehaviorLibrary(mapManager:MapManager, characterManager:CharacterManager) 
		{
			behaviorInfoList = new Dictionary();
			
			var mapEmbedFiles:Dictionary = mapManager.getMapFiles();
			
			for (var mapString:String in mapEmbedFiles) {
				var mapFile:Class = mapEmbedFiles[mapString];
				parseMapBehaviors(mapManager, characterManager, mapString, mapFile); 
			}
			
		}
		
		public function activateBehavior(behaviorName:String):void {
			if (behaviorInfoList[behaviorName] == null) return;
			
			var behavior:Behavior = behaviorInfoList[behaviorName] as Behavior;
			var character:Character = behavior.getHost();
			
			character.setBehavior(behavior);
		}
		
		private function parseMapBehaviors(mapManager:MapManager, charManager:CharacterManager, mapString:String, mapFile:Class):void {
			
			var fileBytes:ByteArray = new mapFile() as ByteArray;
			var fileInfo:String = fileBytes.toString();
			var fileArray:Array = fileInfo.split(/\n/);
			var parsingBehavior:Boolean = false;
			
			for (var i:int = 0; i < fileArray.length; i++) {
				if (fileArray[i].indexOf("objectgroup name=\"AI\"") >= 0)
					parsingBehavior = true;
				if (parsingBehavior && fileArray[i].indexOf("</objectgroup>") >= 0)
					return;
				
				if (parsingBehavior && fileArray[i].indexOf("object name") >= 0) {
					
					var behaviorParameters:Dictionary = parseBehavior(mapManager, mapString, fileArray, fileArray[i], i);
					
					// construct behavior with parameters
					if (behaviorParameters["Type"] == "Pacing")
						constructPacingBehavior(charManager, behaviorParameters);
					else if (behaviorParameters["Type"] == "Random")
						constructRandomBehavior(charManager, behaviorParameters);
					else if (behaviorParameters["Type"] == "Routine")
						constructRoutineBehavior(charManager, mapManager, behaviorParameters, mapString);
				}
			}
			
		}
		private function parseBehavior
		(mapManager:MapManager, mapString:String, fileArray:Array, behaviorLine:String, propLineIndex:int):Dictionary {
			var behaviorParameters:Dictionary = new Dictionary();
			behaviorParameters["CharDialogue"] = new Array();
			
			var parsedBehavior:Array = cleanPropertyLine(behaviorLine);
			
			for (var i:int = 0; i < parsedBehavior.length; i++) {
				if (parsedBehavior[i].indexOf('=') >= 0) {
					
					var property:Array = parsedBehavior[i].split('=');
					behaviorParameters[property[0]] = property[1];
					
					if (property[0] == "x") behaviorParameters[property[0]] = property[1] / 32;
					if (property[0] == "y") behaviorParameters[property[0]] = property[1] / 32 - 1;
				}
			}
			behaviorParameters["Origin"] = new Tuple
				(new Point(behaviorParameters["x"], behaviorParameters["y"]), mapManager.getMap(mapString));
			behaviorParameters = parseProperties(fileArray, propLineIndex + 1, behaviorParameters);
			
			return behaviorParameters;
		}
		private function parseProperties(fileArray:Array, startLine:int, parameters:Dictionary):Dictionary {
			if (fileArray[startLine].indexOf("<properties>") < 0) return parameters;
			
			for (var i:int = startLine + 1; i < fileArray.length; i++) {
				if (fileArray[i].indexOf("</properties>") >= 0) return parameters;
				
				var property:Array = cleanPropertyLine(fileArray[i]);
				for (var j:int = 0; j < property.length; j++) {
					var name:String;
					var value:Object;
					
					if (property[j].indexOf('=') >= 0) {
						var parsedProperty:Array = property[j].split('=');
						if (parsedProperty[0] == "name")
							name = parsedProperty[1];
						else if (parsedProperty[0] == "value")
							value = parsedProperty[1];
					}
				}
				
				if (name == "Horizontal") {
					if (value == "true") parameters[name] = true;
					else if (value == "false") parameters[name] = false;
				}
				else parameters[name] = value;
				
			}
			
			return parameters;
		}
		
		private function cleanPropertyLine(line:String):Array {
			line = line.replace('<', '');
			line = line.replace('>', '');
			line = line.replace('/', '');
			line = line.split('"').join('');
			var parsedProp:Array = line.split(' ');
			return parsedProp;
		}
		
		private function constructPacingBehavior(charManager:CharacterManager, parameters:Dictionary):void {
			var host:Character = charManager.getCharacter(parameters["Character"]);
			
			var newPacingBehavior:PacingBehavior = new PacingBehavior(host, parameters["Origin"],
													parameters["Frequency"], parameters["Horizontal"], parameters["Length"]);
			behaviorInfoList[parameters["name"]] = newPacingBehavior;
		}
		private function constructRandomBehavior(charManager:CharacterManager, parameters:Dictionary):void {
			var host:Character = charManager.getCharacter(parameters["Character"]);
			
			var newRandomBehavior:RandomBehavior = new RandomBehavior(host, parameters["Origin"], parameters["Frequency"],
													parameters["HorizontalBound"], parameters["VerticalBound"]);
			behaviorInfoList[parameters["name"]] = newRandomBehavior;
		}
		private function constructRoutineBehavior(charManager:CharacterManager, mapManager:MapManager, parameters:Dictionary, mapString:String):void {
			
			if (behaviorInfoList[parameters["name"]] == null) {
				
				var host:Character = charManager.getCharacter(parameters["Character"]);
				
				var newRoutineBehavior:RoutineBehavior = new RoutineBehavior(host, parameters["Origin"], [], [], [],
														parameters["Loop"], parameters["WaitTime"]);
				behaviorInfoList[parameters["name"]] = newRoutineBehavior;
			}
			
			var destination:Point = new Point(parameters["x"], parameters["y"]);
			var destinationMap:Map = mapManager.getMap(mapString);
			var frequency:int = parameters["Frequency"];
			
			var routine:RoutineBehavior = behaviorInfoList[parameters["name"]] as RoutineBehavior;
			if (routine != null) {
				routine.addNewDestination(parameters["Index"], destination, destinationMap, frequency);
			}
			if (parameters["Loop"] != null)
				routine.setLoop(parameters["Loop"]);
			if (parameters["WaitTime"] != null)
				routine.setWaitTime(parameters["WaitTime"]);
			if (parameters["Character"] != null)
				routine.setHost(charManager.getCharacter(parameters["Character"]));
		}
		
		
	}

}