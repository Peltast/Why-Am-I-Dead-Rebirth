package Maps 
{
	import AI.BehaviorLibrary;
	import Characters.Animation;
	import Characters.Character;
	import Characters.CharacterManager;
	import Cinematics.Trigger;
	import Core.GameState;
	import flash.display.Sprite;
	import flash.net.SharedObject;
	import Interface.GameScreen;
	import Interface.Overlay;
	import Interface.OverlayItem;
	import Main;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import Interface.GUIManager;
	import Props.PropManager;
	import Setup.SaveFile;
	import Sound.SoundManager;
	import Setup.GameLoader;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class MapManager 
	{		
		private var fadeFill:Shape;
		private var fadeDelta:Number;
		
		private var startMap:Map;
		private var currentMap:Map;
		private var embedMapFileList:Dictionary;
		private var mapList:Dictionary;
		
		private var gameScreen:GameScreen;
		
		public function MapManager(gameScreen:GameScreen) 
		{
			this.gameScreen = gameScreen;
			
			fadeFill = new Shape();
			embedMapFileList = new Dictionary();
			
			embedMapFileList["Owner's Room"] = GameLoader.OwnersRoom;
			embedMapFileList["Lobby"] = GameLoader.Lobby;
			embedMapFileList["Randy's Room"] = GameLoader.RandysRoom;
			embedMapFileList["Hallway"] = GameLoader.Hallway;
			embedMapFileList["Bathroom"] = GameLoader.Bathroom;
			
			embedMapFileList["Rose's Room"] = GameLoader.RosesRoom;
			embedMapFileList["Morgan's Room"] = GameLoader.MorgansRoom;
			embedMapFileList["Cricket's Room"] = GameLoader.CricketsRoom;
			embedMapFileList["Lucille's Room"] = GameLoader.LucillesRoom;
			embedMapFileList["Ted's Room"] = GameLoader.TedsRoom;
			embedMapFileList["Orval's Room"] = GameLoader.OrvalsRoom;
			
			mapList = new Dictionary();
			var mapNo:int = 6;
			
			var mainTileSet:Bitmap = new GameLoader.MainTileSheet() as Bitmap;
			var mainPermissions:Array = new Array
				(5, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0,
				 0, 1, 0, 0, 0, 2, 0,
				 0, 3, 0, 0, 0, 4, 0,
				 0, 0, 0, 0, 0, 0, 0);
			var bathroomTileSet:Bitmap = new GameLoader.BathroomTileSheet() as Bitmap;
			var bathroomPermissions:Array = new Array
				(5, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0,
				 0, 1, 0, 0, 0, 2, 0,
				 0, 3, 0, 0, 0, 4, 0,
				 0, 0, 0, 0, 0, 0, 0);			
			var darkHallwayTileSet:Bitmap = new GameLoader.DarkHallwayTileSheet() as Bitmap;
			var darkHallwayPermissions:Array = new Array
				(5, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0,
				 0, 1, 0, 0, 0, 2, 0,
				 0, 3, 0, 0, 0, 4, 0,
				 0, 0, 0, 0, 0, 0, 0);
			
			
			var blackRoomTileSet:Bitmap = new GameLoader.BlackRoomTileSheet() as Bitmap;
			var blackRoomPermissions:Array = new Array
				(5, 0, 5, 5, 5, 0, 0,
				 5, 0, 1, 5, 2, 0, 0,
				 0, 0, 5, 5, 5, 0, 0,
				 0, 0, 5, 5, 5, 0, 0,
				 0, 0, 3, 5, 4, 0, 0,
				 0, 0, 5, 5, 5, 0, 0);
			
			
			var ownersRoom:Map = new Map(GameLoader.OwnersRoom, mainTileSet, mainPermissions, "Owner's Room");
			var lobby:Map = new Map(GameLoader.Lobby, mainTileSet, mainPermissions, "Lobby");
			var randysRoom:Map = new Map(GameLoader.RandysRoom, mainTileSet, mainPermissions, "Randy's Room");
			var hallway:Map = new Map(GameLoader.Hallway, mainTileSet, mainPermissions, "Hallway");
			var bathroom:Map = new Map(GameLoader.Bathroom, bathroomTileSet, bathroomPermissions, "Bathroom");
			
			var rosesRoom:Map = new Map(GameLoader.RosesRoom, mainTileSet, mainPermissions, "Rose's Room");
			var morgansRoom:Map = new Map(GameLoader.MorgansRoom, mainTileSet, mainPermissions, "Morgan's Room");
			var cricketsRoom:Map = new Map(GameLoader.CricketsRoom, mainTileSet, mainPermissions, "Cricket's Room");
			var lucillesRoom:Map = new Map(GameLoader.LucillesRoom, mainTileSet, mainPermissions, "Lucille's Room");
			var tedsRoom:Map = new Map(GameLoader.TedsRoom, mainTileSet, mainPermissions, "Ted's Room");
			var orvalsRoom:Map = new Map(GameLoader.OrvalsRoom, mainTileSet, mainPermissions, "Orval's Room");
			
			var darkHallway:Map = new Map(GameLoader.DarkHallway, darkHallwayTileSet, darkHallwayPermissions, "Dark Hallway");
			var blackRoom:Map = new Map(GameLoader.BlackRoom, blackRoomTileSet, blackRoomPermissions, "Black Room");
			
			mapList[ownersRoom.getMapName()] = ownersRoom;
			mapList[lobby.getMapName()] = lobby;
			mapList[randysRoom.getMapName()] = randysRoom;
			mapList[hallway.getMapName()] = hallway;
			mapList[bathroom.getMapName()] = bathroom;
			
			mapList[rosesRoom.getMapName()] = rosesRoom;
			mapList[morgansRoom.getMapName()] = morgansRoom;
			mapList[cricketsRoom.getMapName()] = cricketsRoom;
			mapList[lucillesRoom.getMapName()] = lucillesRoom;
			mapList[tedsRoom.getMapName()] = tedsRoom;
			mapList[orvalsRoom.getMapName()] = orvalsRoom;
			
			mapList[darkHallway.getMapName()] = darkHallway;
			mapList[blackRoom.getMapName()] = blackRoom;
			
			
			ownersRoom.addTransition(
				new MapTransition(mapList["Owner's Room"], mapList["Owner's Room"].getTile(14, 15),
				mapList["Lobby"], mapList["Lobby"].getTile(4, 4), false));
			
			randysRoom.addTransition(
				new MapTransition(mapList["Randy's Room"], mapList["Randy's Room"].getTile(6, 8),
				mapList["Lobby"], mapList["Lobby"].getTile(16, 4), false));
			
			lobby.addTransition(
				new MapTransition(mapList["Lobby"], mapList["Lobby"].getTile(10, 1),
				mapList["Hallway"], mapList["Hallway"].getTile(24, 8), false));
			lobby.addTransition(
				new MapTransition(mapList["Lobby"], mapList["Lobby"].getTile(11, 1),
				mapList["Hallway"], mapList["Hallway"].getTile(25, 8), false));
			
			hallway.addTransition(
				new MapTransition(mapList["Hallway"], mapList["Hallway"].getTile(24, 10),
				mapList["Lobby"], mapList["Lobby"].getTile(10, 3), false));
			hallway.addTransition(
				new MapTransition(mapList["Hallway"], mapList["Hallway"].getTile(25, 10),
				mapList["Lobby"], mapList["Lobby"].getTile(11, 3), false));
			
			rosesRoom.addTransition(
				new MapTransition(mapList["Rose's Room"], mapList["Rose's Room"].getTile(5, 8),
				mapList["Hallway"], mapList["Hallway"].getTile(10, 3), false));
			morgansRoom.addTransition(
				new MapTransition(mapList["Morgan's Room"], mapList["Morgan's Room"].getTile(5, 9),
				mapList["Hallway"], mapList["Hallway"].getTile(15, 3), false));
			cricketsRoom.addTransition(
				new MapTransition(mapList["Cricket's Room"], mapList["Cricket's Room"].getTile(4, 8),
				mapList["Hallway"], mapList["Hallway"].getTile(20, 3), false));
			bathroom.addTransition(
				new MapTransition(mapList["Bathroom"], mapList["Bathroom"].getTile(6, 8),
				mapList["Hallway"], mapList["Hallway"].getTile(24, 3), false));
			lucillesRoom.addTransition(
				new MapTransition(mapList["Lucille's Room"], mapList["Lucille's Room"].getTile(7, 8),
				mapList["Hallway"], mapList["Hallway"].getTile(29, 3), false));
			tedsRoom.addTransition(
				new MapTransition(mapList["Ted's Room"], mapList["Ted's Room"].getTile(6, 8),
				mapList["Hallway"], mapList["Hallway"].getTile(34, 3), false));
			orvalsRoom.addTransition(
				new MapTransition(mapList["Orval's Room"], mapList["Orval's Room"].getTile(6, 8),
				mapList["Hallway"], mapList["Hallway"].getTile(39, 3), false));
			
			
			ownersRoom.addSound("Wind");
			lobby.addSound("Thunder");
			randysRoom.addSound("Static", .1);
			hallway.addSound("Thunder", .5);
			
			rosesRoom.addSound("Melody", .4);
			morgansRoom.addSound("Melody", .4);
			cricketsRoom.addSound("Melody", .4);
			lucillesRoom.addSound("Melody", .4);
			tedsRoom.addSound("Melody", .4);
			orvalsRoom.addSound("Melody", .4);
			
			darkHallway.addSound("Tunnel", .5);
			blackRoom.addSound("Tunnel", 1);
		}
		public function initiateMaps(saveFile:SaveFile, propManager:PropManager):void {
			
			if(saveFile == null)
				startMap = mapList["Owner's Room"];
			else {
				startMap = mapList[saveFile.loadData("currentMap") + ""];
				
				for each(var map:Map in mapList) {
					map.loadMap(saveFile, propManager);
				}
			}
		}
		
		public function startMapManager():void {
			if (startMap == null) return;
			
			setMap(startMap); 
			startMap.playMapSounds();
		}
		
		public function updateMaps(gameScreen:GameScreen):void {
			for (var key:String in mapList) {
				var tempMap:Map = mapList[key] as Map;
				tempMap.updateMap(this);
			}
			fadeFill.x = -gameScreen.x;
			fadeFill.y = -gameScreen.y;
		}
		
		public function getCurrentMap():Map {
			return currentMap;
		}
		
		public function setMap(newMap:Map):Boolean {
			
			this.removeMap();
			
			newMap.addMapToClient(gameScreen);
			newMap.redrawSpectralEffect();
			currentMap = newMap;
			return true;
		}
		
		
		private function removeMap():void {
			if (currentMap != null) {
				currentMap.removeMapFromClient(gameScreen);
			}
			currentMap = null;
		}
		public function getMap(mapName:String):Map {
			if (mapList[mapName] != null)
				return mapList[mapName];
			return null;
		}
		
		public function getMapFiles():Dictionary {
			return embedMapFileList;
		}
		
		private function fadeOutScreen(event:Event):void {
			if (fadeFill.alpha < 1) {
				fadeFill.alpha += fadeDelta;
			}
			if (fadeFill.alpha >= 1) {
				fadeFill.alpha = 1;
				gameScreen.removeEventListener(Event.ENTER_FRAME, fadeOutScreen);
			}
		}
		private function fadeInScreen(event:Event):void {
			if (fadeFill.alpha > 0) {
				fadeFill.alpha -= fadeDelta;
			}
			if (fadeFill.alpha <= 0) {
				fadeFill.alpha = 0;
				gameScreen.removeChild(fadeFill);
				gameScreen.removeEventListener(Event.ENTER_FRAME, fadeInScreen);
			}
		}
		
		
		public function executeTransition(transition:MapTransition, character:Character, isPlayer:Boolean = true):void {
			
			character.setZPosition(0);
			character.resetEffect();
			
			// If we are actually moving to another map, handle moving the character around.  This comes in handy
			// when we want the sound/visual effect of a transition, without the movement -- generally to leave the
			// impression that time has passed.
			if (transition.getEndMap() != transition.getStartMap()) {
				
				// Only if the character that's moving is the player do we change the map that's displayed.
				if (isPlayer) {
					this.handleSoundTransition(transition, character);
					
					setMap(transition.getEndMap());
					gameScreen.x = 0;
					gameScreen.y = 0;
				}
				
				transition.getStartMap().removeCharacter(character);
				transition.getEndMap().addCharacter(character);
				
				var endTile:Tile = transition.getEndTile();
				character.x = endTile.x + (character.x - character.getObjectBounds().x) / 2;
				character.y = (endTile.y + 32) - (character.getObjectBounds().y - character.y);
			}
			
			// Only if the character that's moving is the player do we have the screen go to black and then fade back in.
			if (isPlayer) {
				
				SoundManager.getSingleton().playSound("CinematicBoom");
				fadeFill = new Shape();
				fadeFill.graphics.beginFill(0x000000, 1);
				fadeFill.graphics.drawRect
					(-20, -20, Main.getSingleton().getStageWidth() + 40, Main.getSingleton().getStageHeight() + 40);
				fadeFill.alpha = 1;
				fadeFill.graphics.endFill();
				gameScreen.addChild(fadeFill);
				gameScreen.addEventListener(Event.ENTER_FRAME, fadeInMap);
			}
			
			character.handleTransition(transition);
		}
		private function fadeInMap(event:Event):void {
			if (fadeFill.alpha <= 0) { 
				if (gameScreen.contains(fadeFill))
					gameScreen.removeChild(fadeFill);
				gameScreen.removeEventListener(Event.ENTER_FRAME, fadeInMap);
			}
			else {
				fadeFill.x = -gameScreen.x;
				fadeFill.y = -gameScreen.y;
				fadeFill.alpha -= .1;
			}
		}
		public function removeFade():void {
			fadeFill.alpha = 0;
		}
		
		private function handleSoundTransition(transition:MapTransition, character:Character):void {
			
			var characterTheme:String = character.getTheme();
			if (characterTheme != null) return;
			
			transition.getStartMap().stopMapSounds(transition.getEndMap().getMapSounds(), .05);
			transition.getEndMap().playMapSounds(true, .05);
		}
		
		public function listenToTrigger(parsedRequirement:Array):Boolean {
			
			return false;
		}
		
		public function performTriggerEffect(parsedEffect:Array):void {
			
			if (parsedEffect[0] == "changeTransition") {
				var startMapName:String = parsedEffect[1];
				var endMapName:String = parsedEffect[2];
				var status:String = parsedEffect[3];
				
				if (mapList[startMapName] == null || mapList[endMapName] == null) {
					throw new Error("Cinematic Error: Incorrect map name given to transition effect.");
					return;
				}
				var startMap:Map = mapList[startMapName] as Map;
				var endMap:Map = mapList[endMapName] as Map;
				var transition:MapTransition = startMap.findTransition(endMap);
				if (transition != null)
					if (status == "on") transition.activateTransition();
					else if (status == "off") transition.deactivateTransition();
			}
			
			else if (parsedEffect[0] == "fadeOutMap") {
				fadeDelta = parseFloat(parsedEffect[1]);
				
				fadeFill = new Shape();
				fadeFill.graphics.beginFill(0x000000, 1);
				fadeFill.graphics.drawRect
					(-20, -20, Main.getSingleton().getStageWidth() + 40, Main.getSingleton().getStageHeight() + 40);
				fadeFill.alpha = 0;
				fadeFill.graphics.endFill();
				fadeFill.x = -gameScreen.x;
				fadeFill.y = -gameScreen.y;
				gameScreen.addChild(fadeFill);
				gameScreen.addEventListener(Event.ENTER_FRAME, fadeOutScreen);
			}
			else if (parsedEffect[0] == "fadeInMap") {
				fadeDelta = parseFloat(parsedEffect[1]);
				fadeFill.alpha = 1;
				fadeFill.x = -gameScreen.x;
				fadeFill.y = -gameScreen.y;
				gameScreen.addChild(fadeFill);
				gameScreen.addEventListener(Event.ENTER_FRAME, fadeInScreen);
			}
			
			else if (parsedEffect[0] == "changeMap") {
				var newMap:Map = this.getMap(parsedEffect[1]);
				setMap(newMap);
			}
			
			else if (parsedEffect[0] == "clearMapSound") {
				var map:Map = this.getMap(parsedEffect[1]);
				map.removeSounds();
			}
			else if (parsedEffect[0] == "addMapSound") {
				map = this.getMap(parsedEffect[1]);
				map.addSound(parsedEffect[2], parsedEffect[3]);
			}
		}
		
		
		public function saveMapManager(saveFile:SaveFile):void {
			for each(var map:Map in mapList)
				map.saveMap(saveFile);
			saveFile.saveData("currentMap", currentMap.getMapName());
			var j:int = 0;
		}
		
	}

}