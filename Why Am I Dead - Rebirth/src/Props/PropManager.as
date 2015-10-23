package Props 
{
	import adobe.utils.CustomActions;
	import Characters.Character;
	import Characters.CharacterManager;
	import Cinematics.Trigger;
	import Core.Game;
	import Dialogue.Dialogue;
	import Dialogue.DialogueLibrary;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import Interface.GameScreen;
	import Main;
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	import Maps.Map;
	import Maps.MapManager;
	import Setup.GameLoader;
	import Setup.SaveFile;
	import SpectralGraphics.SpectralBitmap;
	import SpectralGraphics.SpectralImage;
	import SpectralGraphics.SpectralManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class PropManager 
	{
		private var propList:Dictionary;
		private var allPermission:Vector.<String>;
		
		public function PropManager(mapManager:MapManager, gameScreen:GameScreen)
		{
			propList = new Dictionary();
			
			// Special Props
			
			//var saveProp:Prop = new Prop(new GameLoader.SaveProp() as Bitmap, "SaveProp",
			//	true, 11 * 32, 6 * 32, null, null, DialogueLibrary.getSingleton().retrieveDialogue("SaveConfirmation"));
			//mapManager.getMap("Paulo's Room").addProp(saveProp);
			//propList[saveProp.getPropTag()] = saveProp;
			
			allPermission = new Vector.<String>();
			allPermission.push("Ghost", "Cricket", "Randy", "Lucille", "Ted", "Morgan", "Iblis", "Rose", "Orval")
			
			var saveProp:Prop = new Prop(new GameLoader.Clipboard() as Bitmap, "SaveProp",
				false, 13 * 32, 6 * 32, new Rectangle(0, 5, 32, 37), allPermission,
				DialogueLibrary.getSingleton().retrieveDialogue("SaveConfirmation"));
			mapManager.getMap("Lobby").addProp(saveProp);
			propList[saveProp.getPropTag()] = saveProp;
			
			
			var tutorial1:SpectralImageProp = new SpectralImageProp
				(SpectralManager.getSingleton().getSpecGraphic("Tutorial1"), "Tutorial1", false, 5 * 32, 11 * 32);
			var tutorial2:SpectralImageProp = new SpectralImageProp
				(SpectralManager.getSingleton().getSpecGraphic("Tutorial2"), "Tutorial2", false, 11 * 32, 5 * 32);
			var tutorial3:SpectralImageProp = new SpectralImageProp
				(SpectralManager.getSingleton().getSpecGraphic("Tutorial3"), "Tutorial3", false, 17 * 32, 10 * 32);
			var tutorial4:SpectralImageProp = new SpectralImageProp
				(SpectralManager.getSingleton().getSpecGraphic("Tutorial4"), "Tutorial4", false, 9 * 32, 5 * 32);
			propList[tutorial1.getPropTag()] = tutorial1;
			propList[tutorial2.getPropTag()] = tutorial2;
			propList[tutorial3.getPropTag()] = tutorial3;
			propList[tutorial4.getPropTag()] = tutorial4;
			
			
			createProp(false, mapManager, "Owner's Room", new GameLoader.HiddenDoor() as Bitmap, "HiddenDoor", false, 5, 0,
					new Rectangle(0, 0, 42, 105), null);
			propList["HiddenDoor"].setCharDialogue
				("Morgan", true, DialogueLibrary.getSingleton().retrieveDialogue("HiddenDoor"));
			propList["HiddenDoor"].setCharDialogue
				("Lucille", true, DialogueLibrary.getSingleton().retrieveDialogue("LucilleHiddenDoor"));
			
			
			createDoorProp(true, mapManager, "Lobby", new GameLoader.Door() as Bitmap, "OwnersDoor",
				true, 4, 3, "Owner's Room", 14, 13, allPermission);
			createDoorProp(true, mapManager, "Lobby", new GameLoader.Door() as Bitmap, "RandysDoor",
				true, 16, 3, "Randy's Room", 6, 6, allPermission);
			createDoorProp(true, mapManager, "Hallway", new GameLoader.Door() as Bitmap, "RosesDoor",
				true, 10, 2, "Rose's Room", 5, 6, allPermission);
			createDoorProp(true, mapManager, "Hallway", new GameLoader.Door() as Bitmap, "MorgansDoor",
				true, 15, 2, "Morgan's Room", 5, 7, allPermission);
			createDoorProp(true, mapManager, "Hallway", new GameLoader.Door() as Bitmap, "CricketsDoor",
				true, 20, 2, "Cricket's Room", 4, 6, allPermission);
			createDoorProp(true, mapManager, "Hallway", new GameLoader.Door() as Bitmap, "Bathroom",
				true, 24, 2, "Bathroom", 6, 6, allPermission);
			createDoorProp(true, mapManager, "Hallway", new GameLoader.Door() as Bitmap, "LucillesDoor",
				true, 29, 2, "Lucille's Room", 7, 6, allPermission);
			createDoorProp(true, mapManager, "Hallway", new GameLoader.Door() as Bitmap, "TedsDoor",
				true, 34, 2, "Ted's Room", 6, 6, allPermission);
			createDoorProp(true, mapManager, "Hallway", new GameLoader.Door() as Bitmap, "OrvalsDoor",
				true, 39, 2, "Orval's Room", 6, 6, allPermission);
			
			
			parseMapProps(mapManager, "Owner's Room", GameLoader.OwnersRoom);
			parseMapProps(mapManager, "Lobby", GameLoader.Lobby);
			parseMapProps(mapManager, "Randy's Room", GameLoader.RandysRoom);
			createAnimatedProp(true, mapManager, "Randy's Room", new GameLoader.Television, "RandysTV", true, 5, .8,
				3, 64, 96, false, new Array(new Point(), new Point(1, 0), new Point(2, 0)), null, new Rectangle(0, 0, 64, 96),
				allPermission, DialogueLibrary.getSingleton().retrieveDialogue("RandysTV"));
			parseMapProps(mapManager, "Hallway", GameLoader.Hallway);
			
			parseMapProps(mapManager, "Bathroom", GameLoader.Bathroom);
			parseMapProps(mapManager, "Rose's Room", GameLoader.RosesRoom);
			parseMapProps(mapManager, "Morgan's Room", GameLoader.MorgansRoom);
			parseMapProps(mapManager, "Cricket's Room", GameLoader.CricketsRoom);
			parseMapProps(mapManager, "Lucille's Room", GameLoader.LucillesRoom);
			parseMapProps(mapManager, "Ted's Room", GameLoader.TedsRoom);
			parseMapProps(mapManager, "Orval's Room", GameLoader.OrvalsRoom);
			
			parseMapProps(mapManager, "Dark Hallway", GameLoader.DarkHallway);
			parseMapProps(mapManager, "Black Room", GameLoader.BlackRoom);
		}
		
		private function parseMapProps(mapManager:MapManager, mapString:String, mapFile:Class):void {
			
			var fileBytes:ByteArray = new mapFile() as ByteArray;
			var fileInfo:String = fileBytes.toString();
			var fileArray:Array = fileInfo.split(/\n/);
			var parsingProps:Boolean = false;
			
			for (var i:int = 0; i < fileArray.length; i++) {
				if (fileArray[i].indexOf("objectgroup name=\"Props\"") >= 0)
					parsingProps = true;
				if (parsingProps && fileArray[i].indexOf("</objectgroup>") >= 0)
					return;
				
				if (parsingProps && fileArray[i].indexOf("object name") >= 0) {
					var propParameters:Dictionary = parseProp(fileArray, fileArray[i], i);
					
					createProp(true, mapManager, mapString, 
						GameLoader.getSpriteByName(propParameters["Sprite"]), propParameters["name"],
						propParameters["Collidable"], propParameters["x"] / 32, propParameters["y"] / 32 - 1,
						propParameters["Bounds"], propParameters["Permissions"],
						propParameters["SuccessDialogue"], propParameters["FailDialogue"]);
					addCharacterSpecificDialogues(propParameters, propList[propParameters["name"]]);
					addPropElevation(propParameters, propList[propParameters["name"]]);
					setPropStatic(propParameters, propList[propParameters["name"]]);
				}
			}
			
		}
		private function parseProp(fileArray:Array, propLine:String, propLineIndex:int):Dictionary {
			var propParameters:Dictionary = new Dictionary();
			propParameters["CharDialogue"] = new Array();
			
			var parsedProp:Array = cleanPropertyLine(propLine);
			
			for (var i:int = 0; i < parsedProp.length; i++) {
				if (parsedProp[i].indexOf('=') >= 0) {
					
					var property:Array = parsedProp[i].split('=');
					propParameters[property[0]] = property[1];
					
				}
			}
			propParameters = parseProperties(fileArray, propLineIndex + 1, propParameters);
			
			return propParameters;
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
				
				if (name == "Collidable") {
					if (value == "true") parameters[name] = true;
					else if (value == "false") parameters[name] = false;
				}
				else if (name == "SuccessDialogue" || name == "FailDialogue") {
					value = DialogueLibrary.getSingleton().retrieveDialogue(value + "");
					parameters[name] = value;
				}
				else if (name.indexOf("CharDialogue") >= 0) {
					var parseValue:Array = value.split('-');
					if (parseValue.length != 3) throw new Error("Prop error: Invalid CharDialogue property formatting.");
					if (parseValue[1] == "true") parseValue[1] = true;
					else if (parseValue[1] == "false") parseValue[1] = false;
					parameters["CharDialogue"].push(parseValue);
				}
				else if (name == "Permissions") {
					if (value == "All") {
						value = allPermission;
					}
					else {
						var parsedValue:Array = value.split(',');
						value = new Vector.<String>();
						for each(var char:String in parsedValue)
							value.push(char);
					}
					parameters[name] = value;
				}
				else if (name == "Bounds") {
					parsedValue = value.split(',');
					value = new Rectangle(parsedValue[0], parsedValue[1], parsedValue[2], parsedValue[3]);
					parameters[name] = value;
				}
				else if (name == "Static") {
					if (value == "true") 
						parameters[name] = true;
					else if (value == "false") 
						parameters[name] = false;
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
		
		private function addCharacterSpecificDialogues(propParameters:Dictionary, prop:Prop):void {
			var charDialogues:Array = propParameters["CharDialogue"];
			
			for each(var dialogue:Array in charDialogues) {
				prop.setCharDialogue(dialogue[0], dialogue[1], DialogueLibrary.getSingleton().retrieveDialogue(dialogue[2]));
			}
		}
		private function addPropElevation(propParameters:Dictionary, prop:Prop):void {
			var elevation:int = propParameters["Elevation"];
			if (elevation > 0)
				prop.setElevation(elevation);
		}
		private function setPropStatic(propParameters:Dictionary, prop:Prop):void {
			var staticBool:Boolean = propParameters["Static"];
			prop.setStatic(!staticBool);
		}
		
		private function createProp(addMap:Boolean, mapManager:MapManager, homeMap:String, propBmp:Bitmap, propName:String, 
									isCollidable:Boolean, xCoord:Number, yCoord:Number, bounds:Rectangle = null,
									permissions:Vector.<String> = null, sucDia:Dialogue = null, failDia:Dialogue = null):void {
			
			var tS:int = Game.getTileSize();
			var newProp:Prop = new Prop(propBmp, propName, isCollidable, xCoord * tS, yCoord * tS, 
										bounds, permissions, sucDia, failDia);
			
			if (addMap)
				mapManager.getMap(homeMap).addProp(newProp);
			this.propList[propName] = newProp;
		}
		private function createStaticProp(addMap:Boolean, mapManager:MapManager, homeMap:String, propBmp:Bitmap, propName:String, 
									isCollidable:Boolean, xCoord:Number, yCoord:Number, bounds:Rectangle = null,
									permissions:Vector.<String> = null, sucDia:Dialogue = null, failDia:Dialogue = null):void {
			
			var tS:int = Game.getTileSize();
			var newProp:Prop = new Prop(propBmp, propName, isCollidable, xCoord * tS, yCoord * tS, 
										bounds, permissions, sucDia, failDia);
			
			if (addMap)
				mapManager.getMap(homeMap).addStaticProp(newProp);
			this.propList[propName] = newProp;
		}
		private function createParallaxProp(addMap:Boolean, mapManager:MapManager, homeMap:String, propName:String, 
											xCoord:Number, yCoord:Number, props:Vector.<Prop>, propDistances:Vector.<int>,
											gameScreen:GameScreen, isStatic:Boolean):void {
			var tS:int = Game.getTileSize();
			var newProp:ParallaxProp = new ParallaxProp(propName, false, xCoord * tS, yCoord * tS, props, propDistances, gameScreen);
			newProp.setStatic(isStatic);
			
			if (addMap)
				mapManager.getMap(homeMap).addParallaxProp(newProp);
			this.propList[propName] = newProp;
		}
		private function createDoorProp(addMap:Boolean, mapManager:MapManager, homeMap:String, propBmp:Bitmap, propName:String, 
									isCollidable:Boolean, xCoord:Number, yCoord:Number, endMapName:String, endX:int, endY:int,
									permissions:Vector.<String> = null, sucDia:Dialogue = null, failDia:Dialogue = null,
									checkGhostVisited:Boolean = true):void {
			
			if (permissions == null) {
				permissions = new Vector.<String>();
				permissions.push("Ghost", "Cricket", "Randy", "Lucille", "Ted", "Morgan", "Iblis", "Rose", "Orval");
			}
			var tS:int = Game.getTileSize();
			var endMap:Map = mapManager.getMap(endMapName);
			var newProp:DoorProp = new DoorProp(mapManager, propBmp, propName, isCollidable, xCoord * tS, yCoord * tS, 
									endMap, endX, endY, permissions, sucDia, failDia, checkGhostVisited);
			
			if (addMap)
				mapManager.getMap(homeMap).addProp(newProp);
			this.propList[propName] = newProp;
		}
		private function createStairUpProp(addMap:Boolean, mapManager:MapManager, homeMap:String, propBmp:Bitmap, 
									propName:String, isCollidable:Boolean, xCoord:Number, yCoord:Number):void {
			
			var tS:int = Game.getTileSize();
			var map:Map = mapManager.getMap(homeMap);
			var newProp:StairsUp = new StairsUp(propBmp, propName, isCollidable, map, xCoord * tS, yCoord * tS);
			
			if (addMap)
				mapManager.getMap(homeMap).addStaticProp(newProp);
			this.propList[propName] = newProp;
		}
		private function createStairDownProp(addMap:Boolean, mapManager:MapManager, homeMap:String, propBmp:Bitmap, 
									propName:String, isCollidable:Boolean, xCoord:Number, yCoord:Number):void {
			
			var tS:int = Game.getTileSize();
			var map:Map = mapManager.getMap(homeMap);
			var newProp:StairsDown = new StairsDown(propBmp, propName, isCollidable, map, xCoord * tS, yCoord * tS);
			
			if (addMap)
				mapManager.getMap(homeMap).addStaticProp(newProp);
			this.propList[propName] = newProp;
		}
		private function createAnimatedProp(addMap:Boolean, mapManager:MapManager, homeMap:String, propBmp:Bitmap, 
									propName:String, isCollidable:Boolean, xCoord:Number, yCoord:Number, animationSpd:int,
									propWidth:int, propHeight:int, oneOff:Boolean, frames:Array, oneOffFrames:Array = null,
									bounds:Rectangle = null, permissions:Vector.<String> = null, 
									sucDia:Dialogue = null, failDia:Dialogue = null):void {
			var tS:int = Game.getTileSize();
			var map:Map = mapManager.getMap(homeMap);
			var newProp:AnimatedProp = new AnimatedProp
				(propBmp, propName, isCollidable, xCoord * tS, yCoord * tS, animationSpd, propWidth, propHeight,
				oneOff, frames, oneOffFrames, bounds, permissions, sucDia, failDia);
			
			if (addMap)
				mapManager.getMap(homeMap).addProp(newProp);
			this.propList[propName] = newProp;
		}
		
		private function createSpecImgProp(addMap:Boolean, mapManager:MapManager, homeMap:String, specImg:SpectralImage,
									propName:String, isCollidable:Boolean, xCoord:Number, yCoord:Number, propWidth:int,
									propHeight:int, bounds:Rectangle = null, permissions:Vector.<String> = null,
									sucDia:Dialogue = null, failDia:Dialogue = null):void {
			var tS:int = Game.getTileSize();
			var map:Map = mapManager.getMap(homeMap);
			var newProp:SpectralImageProp = new SpectralImageProp(specImg, propName, isCollidable, xCoord * tS, yCoord * tS,
				bounds, permissions, sucDia, failDia);
			
			if (addMap)
				mapManager.getMap(homeMap).addProp(newProp);
			this.propList[propName] = newProp;
		}
		
		
		public function initiateProps(saveFile:SaveFile):void {
			if (saveFile != null) {
				for (var key:String in propList) {
					var tempProp:Prop = propList[key];
					tempProp.loadProp(key, saveFile);
				}
			}
			else {
				
				
			}
		}
		
		public function getProp(tag:String):Prop {
			return propList[tag];
		}
		
		public function listenToTrigger(parsedRequirement:Array):Boolean {
			
			return false;
		}
		
		public function performTriggerEffect(parsedEffect:Array):void {
			
			if (parsedEffect[0] == "changePermission") {
				var prop:Prop = propList[parsedEffect[1]];
				if (prop != null)
					prop.performTriggerEffect(parsedEffect);
			}
			else if (parsedEffect[0] == "changeAllPermission") {
				prop = propList[parsedEffect[1]];
				var bool:Boolean;
				if (parsedEffect[2] == "true") bool = true;
				else bool = false;
				
				if (prop != null) {
					if (bool)
						prop.setPermissions(allPermission);
					else
						prop.setPermissions(new Vector.<String>());
				}
			}
			else if (parsedEffect[0] == "changePropDialogue") {
				prop = propList[parsedEffect[1]];
				var character:String = parsedEffect[2];
				var dialogue:String = parsedEffect[3];
				var success:Boolean; 
				if (parsedEffect[4] == "true") success = true;
				else success = false;
				
				if (prop != null)
					prop.setCharDialogue(character, success, DialogueLibrary.getSingleton().retrieveDialogue(dialogue));
			}
			
		}
		
		public function savePropManager(saveFile:SaveFile):void {
			
			for (var key:Object in propList) {
				var tempProp:Prop = propList[key] as Prop;
				tempProp.saveProp(key as String, saveFile);
			}
		}
	}

}