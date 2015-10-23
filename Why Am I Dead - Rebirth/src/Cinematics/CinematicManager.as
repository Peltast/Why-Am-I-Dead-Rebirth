package Cinematics 
{
	import AI.CharacterCommand;
	import Characters.Character;
	import Characters.CharacterManager;
	import Characters.Player;
	import Core.EndingState;
	import Core.Game;
	import Dialogue.*;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import Interface.GUIManager;
	import Maps.Map;
	import Maps.MapManager;
	import Misc.Tuple;
	import Props.AnimatedProp;
	import Props.Prop;
	import Props.PropManager;
	import Setup.GameLoader;
	import Setup.SaveFile;
	import Setup.SaveManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class CinematicManager 
	{
		
		private static var singleton:CinematicManager;
		private var triggerList:Dictionary;
		private var cinematicList:Dictionary;
		
		public static function getSingleton():CinematicManager {
			if (singleton == null)
				singleton = new CinematicManager();
			return singleton;
		}
		
		public function CinematicManager() 
		{
			triggerList = new Dictionary();
			cinematicList = new Dictionary();
			
			loadTriggers(new GameLoader.CoreTriggers() as ByteArray);
			loadTriggers(new GameLoader.PlotTriggers() as ByteArray);
			loadTriggers(new GameLoader.PlotTriggers2() as ByteArray);
			loadTriggers(new GameLoader.PlotTriggers3() as ByteArray);
			loadTriggers(new GameLoader.PlotTriggers4() as ByteArray);
		}
		public function resetTriggers():void {
			singleton = new CinematicManager();
		}
		public function initiateTriggers(saveFile:SaveFile):void {
			if (saveFile != null) {
				for each(var trigger:Trigger in triggerList)
					trigger.loadTrigger(saveFile);
			}
			var j:int = 0;
		}
		
		private function loadTriggers(file:ByteArray):void {
			var fileArray:Array = file.toString().split(/\n/);
			
			var onTrigger:Boolean = false;
			var onReq:Boolean = false;
			var onEffect:Boolean = false;
			var triggerTitle:String = "";
			var triggerStat:int = -2;
			var blockList:Vector.<Tuple> = new Vector.<Tuple>();
			var triggerBlock:Tuple;
			var triggerReq:Array = [];
			var triggerEffect:Array = [];
			
			for (var i:int = 0; i < fileArray.length; i++) {
				
				if (fileArray[i].indexOf("trigger start") >= 0) {
					if (onTrigger) 
						throw new Error("Cinematics Error: New trigger introduced before old one was finished parsing.");
					var tempStr:String = fileArray[i + 1];
					tempStr = tempStr.replace("\n", "");
					tempStr = tempStr.replace("\r", "");
					triggerStat = parseInt(tempStr.split(',')[1]);
					triggerTitle = tempStr.split(',')[0];
					onTrigger = true;
				}
				else if (fileArray[i].indexOf("trigger end") >= 0) {
					if (onTrigger == false || triggerTitle == "" || triggerStat == -2) 
						throw new Error("Cinematics Error: Trigger given invalid information.");
					triggerBlock = new Tuple(triggerReq, triggerEffect);
					blockList.push(triggerBlock);
					
					triggerList[triggerTitle] = new Trigger(triggerTitle, triggerStat, blockList);
					triggerTitle = "";
					triggerStat = -2;
					blockList = new Vector.<Tuple>();
					triggerReq = [];
					triggerEffect = [];
					onTrigger = false;
					onReq = false;
					onEffect = false;
				}
				else if (fileArray[i].indexOf("requirements") >= 0) {
					if (onReq) throw new Error("Cinematics Error: Two trigger blocks started in a row.");
					if (onEffect) {
						triggerBlock = new Tuple(triggerReq, triggerEffect);
						blockList.push(triggerBlock);
						triggerReq = [];
						triggerEffect = [];
					}
					onReq = true;
					onEffect = false;
				}
				else if (fileArray[i].indexOf("effects") >= 0) {
					if (onEffect) throw new Error("Cinematics Error: Two effect blocks started in a row.");
					onEffect = true;
					onReq = false;
				}
				
				else if (fileArray[i].indexOf('.') >= 0 && onReq) {
					// Process trigger requirement
					var requirement:String = fileArray[i];
					requirement = requirement.replace("\n", "");
					requirement = requirement.replace("\r", "");
					requirement = requirement.replace("\t", "");
					
					if (requirement == ".null") {
						triggerReq = null;
						continue;
					}
					triggerReq.push(requirement);
				}
				else if (fileArray[i].indexOf('.') >= 0 && onEffect) {
					// Process trigger effect
					var effect:String = fileArray[i];
					
					effect = effect.replace("\n", "");
					effect = effect.replace("\r", "");
					effect = effect.replace("\t", "");
					triggerEffect.push(effect);
				}
			}
		}
		
		
		public function updateCinematicManager
				(player:Player, mapManager:MapManager, characterManager:CharacterManager, 
				guiManager:GUIManager, propManager:PropManager):void {
			
			for each(var trigger:Trigger in triggerList) {
				
				if (trigger.isAwake() || trigger.isOn()) {
					trigger.listenTrigger(this, player, mapManager, characterManager, guiManager, propManager);
				}
			}
			
			for each(var cinematic:Cinematic in cinematicList) {
				cinematic.updateCinematic();
			}
		}
		
		public function getTrigger(name:String):Trigger {
			return triggerList[name];
		}
		public function addTrigger(trig:Trigger):void {
			triggerList[trig.getTriggerName()] = trig;
		}
		public function switchTriggerOn(name:String):void {
			if (triggerList[name] != null)
				triggerList[name].activateTrigger();
		}
		public function switchTriggerOff(name:String):void {
			if (triggerList[name] != null)
				triggerList[name].deactivateTrigger();
		}
		
		public function listenToTrigger(parsedRequirement:Array):Boolean {
			
			if (parsedRequirement[0] == "triggerIsStatus") {
				var trigger:String = parsedRequirement[1] as String;
				var status:String = parsedRequirement[2] as String;
				
				if (triggerList[trigger] != null) {
					var tempTrigger:Trigger = triggerList[trigger] as Trigger;
					if (status == "awake" && (tempTrigger.isAwake() || tempTrigger.isOn())) 
						return true;
					else if (status == "on" && tempTrigger.isOn()) 
						return true;
					else if (status == "asleep" && tempTrigger.isAsleep()) 
						return true
					else 
						return false;
				}
			}
			
			return false;
		}
		
		public function performTriggerEffect(parsedEffect:Array, player:Player, characterManager:CharacterManager,
												mapManager:MapManager, guiManager:GUIManager, propManager:PropManager):void {
			
			if (parsedEffect[0] == "saveGame") {
				SaveManager.getSingleton().saveGame();
			}
			
			else if (parsedEffect[0] == "endGame") {
				
				var endStatus:int = parseInt(parsedEffect[1]);
				
				mapManager.removeFade();
				Game.popState();
				Game.pushState(new EndingState(endStatus));
			}
			
			else if (parsedEffect[0] == "triggerStatus") {
				
				var triggerName:String = parsedEffect[1] + "";
				var newStatus:String = parsedEffect[2];
				if (triggerList[triggerName] != null) {
					var tempTrigger:Trigger = triggerList[triggerName] as Trigger;
					
					if (newStatus == "on") tempTrigger.activateTrigger();
					else if (newStatus == "awake" && tempTrigger.isOn()) tempTrigger.deactivateTrigger();
					else if (newStatus == "awake" && tempTrigger.isAsleep()) tempTrigger.wakeUpTrigger();
					else if (newStatus == "asleep") tempTrigger.sleepTrigger();
				}
			}
			else if (parsedEffect[0] == "cinematicStatus") {
				var cinematicName:String = parsedEffect[1] + "";
				newStatus = parsedEffect[2];
				if (cinematicList[cinematicName] != null) {
					var tempCinematic:Cinematic = cinematicList[cinematicName] as Cinematic;
					
					if (newStatus == "on") tempCinematic.activateCinematic();
					else if (newStatus == "awake" && tempCinematic.isOn()) tempCinematic.deactivateCinematic();
					else if (newStatus == "awake" && tempCinematic.isAsleep()) tempCinematic.wakeUpCinematic();
					else if (newStatus == "asleep") tempTrigger.sleepTrigger();
				}
			}
			
			else if (parsedEffect[0] == "moveChar" || parsedEffect[0] == "walkChar") {
			// Effects for moving a given character to a given position at a given map.
				if (parsedEffect.length < 4) throw new Error("Trigger error: Effect was scripted incorrectly.");
				
				var character:Character = characterManager.getCharacter(parsedEffect[1] + "");
				var oldMap:Map = character.getCurrentMap();
				var destinationMap:Map = mapManager.getMap(parsedEffect[2]);
				var coords:Array = parsedEffect[3].split(',');
				
				if (parsedEffect[0] == "moveChar") { // Simply teleport the character there
					if (oldMap != null) oldMap.removeCharacter(character);
					destinationMap.addCharacter(character);
					character.x = Game.getTileSize() * coords[0];
					character.y = Game.getTileSize() * coords[1];
				}
				else if (parsedEffect[0] == "walkChar") { // Have the character walk there
					character.clearBehavior();
					character.clearCommand();
					character.setCommand(
						new CharacterCommand(character, new Point(coords[0], coords[1]), destinationMap, false));
				}
			}
			else if (parsedEffect[0] == "removeChar") {
				character = characterManager.getCharacter(parsedEffect[1]);
				oldMap = character.getCurrentMap();
				if (oldMap != null)
					oldMap.removeCharacter(character);
			}
			
			else if (parsedEffect[0] == "removeProp") {
				var map:Map = mapManager.getMap(parsedEffect[1]);
				var prop:Prop = propManager.getProp(parsedEffect[2]);
				if (map == null) throw new Error("Trigger Error: RemoveProp given invalid map name.");
				if (prop == null) throw new Error("Trigger Error: RemoveProp given invalid prop name.");
				
				map.removeProp(prop);
			}
			else if (parsedEffect[0] == "addProp") {
				map = mapManager.getMap(parsedEffect[1]);
				prop = propManager.getProp(parsedEffect[2]);
				if (map == null) throw new Error("Trigger Error: RemoveProp given invalid map name.");
				if (prop == null) throw new Error("Trigger Error: RemoveProp given invalid prop name.");
				
				map.addProp(prop);
			}
			else if (parsedEffect[0] == "addStaticProp") {
				map = mapManager.getMap(parsedEffect[1]);
				prop = propManager.getProp(parsedEffect[2]);
				if (map == null) throw new Error("Trigger Error: RemoveProp given invalid map name.");
				if (prop == null) throw new Error("Trigger Error: RemoveProp given invalid prop name.");
				
				map.addStaticProp(prop);
			}
			else if (parsedEffect[0] == "addParallaxProp") {
				map = mapManager.getMap(parsedEffect[1]);
				prop = propManager.getProp(parsedEffect[2]);
				if (map == null) throw new Error("Trigger Error: RemoveProp given invalid map name.");
				if (prop == null) throw new Error("Trigger Error: RemoveProp given invalid prop name.");
				
				map.addParallaxProp(prop);
			}
			else if (parsedEffect[0] == "fadeInProp") {
				map = mapManager.getMap(parsedEffect[1]);
				prop = propManager.getProp(parsedEffect[2]);
				var fadeInPace:Number = parseFloat(parsedEffect[3]);
				
				map.addProp(prop);
				prop.fadeInProp(fadeInPace);
			}
			
			else if (parsedEffect[0] == "panCameraToCharacter") {
				character = characterManager.getCharacter(parsedEffect[1]);
				
				if (character.getCurrentMap() != player.getHost().getCurrentMap()) return;
				else player.panCameraToCharacter(parsedEffect, character);
			}
			
			else if (parsedEffect[0] == "changeMapMusic") {
				map = mapManager.getMap(parsedEffect[1]);
				var sound:String = parsedEffect[2];
				var volume:Number = parsedEffect[3];
				
				if (map != null) {
					map.removeSounds();
					map.addSound(sound, volume);
				}
			}
			
			else if (parsedEffect[0] == "addCharDialogue") {
				prop = propManager.getProp(parsedEffect[1]);
				character = characterManager.getCharacter(parsedEffect[2]);
				var dialogue:Dialogue = DialogueLibrary.getSingleton().retrieveDialogue(parsedEffect[3]);
				
				prop.setCharDialogue(character.getName(), true, dialogue);
			}
			
		}
		
		
		public function saveCinematicManager(saveFile:SaveFile):void {
			for each(var trigger:Trigger in triggerList) {
				trigger.saveTrigger(saveFile);
			}
		}
		
	}

}