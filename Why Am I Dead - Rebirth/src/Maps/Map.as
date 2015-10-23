package Maps 
{
	import Characters.*;
	import Misc.Tuple;
	import SpectralGraphics.*;
	import Props.*;
	import Setup.*;
	import Core.Game;
	import Interface.GUIManager;
	import Main;
	import Dialogue.Dialogue;
	import Sound.SoundManager
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	 
	public class Map
	{
		private var mapReader:URLLoader;
		private var mapName:String;
		
		private var mapTileArray:Array;
		private var mapObjectList:Vector.<MapObject>;
		private var characterList:Vector.<MapObject>;
		private var propList:Vector.<MapObject>;
		private var transitionList:Vector.<MapObject>;
		private var spectralImageList:Vector.<SpectralImage>;
		private var soundList:Dictionary;
		private var playerVisited:Boolean;
		
		private var mapHeight:int;
		private var mapWidth:int;
		private var mapNo:int;
		
		private var mapSprite:Sprite;
		private var mapParallaxContainer:Sprite;
		private var mapBackgroundContainer:Sprite;
		private var mapMiddlegroundContainer:Sprite;
		private var mapForegroundContainer:Sprite;
		
		public function Map(mapFile:Class, tileSet:Bitmap, tilePermissions:Array, name:String, mapNo:int = 1)
		{
			mapSprite = new Sprite();
			mapParallaxContainer = new Sprite();
			mapBackgroundContainer = new Sprite();
			mapMiddlegroundContainer = new Sprite();
			mapForegroundContainer = new Sprite();
			
			mapSprite.addChild(mapParallaxContainer);
			mapSprite.addChild(mapBackgroundContainer);
			mapSprite.addChild(mapMiddlegroundContainer);
			mapSprite.addChild(mapForegroundContainer);
			
			this.mapNo = mapNo;
			mapName = name;
			playerVisited = false;
			
			mapTileArray = [];
			mapObjectList = new Vector.<MapObject>();
			characterList = new Vector.<MapObject>();
			propList = new Vector.<MapObject>();
			transitionList = new Vector.<MapObject>();
			soundList = new Dictionary();
			spectralImageList = new Vector.<SpectralImage>();
			
			var fileBytes:ByteArray = new mapFile() as ByteArray;
			var fileInfo:String = fileBytes.toString();
			var fileArray:Array = fileInfo.split(/\n/);
			
			// Parse height and width information out of file
			for (var f:int = 0; f < fileArray.length; f++) {
				if (fileArray[f].indexOf("layer name") >= 0) break;
			}
			
			var sizeLine:Array = fileArray[f].split(' ');
			for (var i:int = 0; i < sizeLine.length; i++) {
				if(String(sizeLine[i]).indexOf("width") >= 0){
					var parsedWidth:Array = sizeLine[i].split('"');
					mapWidth = int(parsedWidth[1]);
				}
				else if (String(sizeLine[i]).indexOf("height") >= 0){
					var parsedHeight:Array = sizeLine[i].split('"');
					mapHeight = int(parsedHeight[1]);
				}
			}
			
			// Iterate through all of the tile information
			var yCounter:int = 0;
			var xCounter:int = 0;
			var tempArray:Array = new Array();
			
			for (var j:int = 7; j < fileArray.length; j++) {
				if (String(fileArray[j]).indexOf('tile gid="') < 0) 
					continue;
				
				var parsedTileLine:Array = fileArray[j].split('"');
				var tilePassable:int = tilePermissions[parsedTileLine[1] - 1];
				tempArray.push(new Tile(parsedTileLine[1], tileSet, xCounter, yCounter, tilePassable));
				
				xCounter += 1;
				if (xCounter >= mapWidth) {
					xCounter = 0;
					yCounter += 1;
					
					mapTileArray.push(tempArray);
					tempArray = new Array();
				}
			}
			
			// Add everything to the map
			for (var r:int = 0; r < mapTileArray.length; r++) {
				tempArray = mapTileArray[r] as Array;
				for (var q:int = 0; q < tempArray.length; q++) {
					
					var tempTile:Tile = Tile(tempArray[q]);
					tempTile.x = q * Game.getTileSize();
					tempTile.y = r * Game.getTileSize();
					
					if (!tempTile.isTileForeground())
						mapBackgroundContainer.addChild(tempTile);
					else
						mapForegroundContainer.addChild(tempTile);
				}
			}
			
		}
		public function addMapToClient(client:Sprite):void {
			client.addChild(mapSprite);
		}
		public function removeMapFromClient(client:Sprite):void {
			if (client.contains(mapSprite)) client.removeChild(mapSprite);
		}
		
		public function updateMap(mapManager:MapManager):void {
			
			for (var p:int = 0; p < propList.length; p++) {
				var currentProp:Prop = propList[p] as Prop;
				
				currentProp.updateProp();
			}
			
			for (var i:int = 0; i < characterList.length; i++) {
				
				var currentChar:Character = characterList[i] as Character;
				
				// Update characters
				currentChar.updateCharacter(this);
				
				var tempTransition:MapTransition = this.checkTransitions(currentChar)[0];
				if (tempTransition != null) {
					
					if (tempTransition.isPermitted(currentChar))
						mapManager.executeTransition
							(tempTransition, currentChar, currentChar.getPlayerControlled());
				}
			}
				
			var tempTuple:Tuple = checkMapObjectsAndListThem();
			var isSorted:Boolean = tempTuple.former;
			var insertSortList:Vector.<MapObject> = tempTuple.latter as Vector.<MapObject>;
			
			if (!isSorted)
				insertSortList = insertionSort(insertSortList);
				
			for each(var mapObj:MapObject in insertSortList)
				mapMiddlegroundContainer.addChild(mapObj);
			
		}
		
		private function getObjectYPos(mapObject:MapObject):int {
			return(mapObject.getObjectBounds().y + mapObject.getObjectBounds().height + mapObject.getElevation());
		}
		private function checkMapObjectsAndListThem():Tuple {
			var listToSort:Vector.<MapObject> = new Vector.<MapObject>();
			var isSorted:Boolean = true;
			var currentObj:MapObject;
			var previousObj:MapObject;
			for (var i:int = 0; i < mapMiddlegroundContainer.numChildren; i++) {
				currentObj = mapMiddlegroundContainer.getChildAt(i) as MapObject;
				listToSort.push(currentObj);
				
				if (previousObj != null) {
					if (getObjectYPos(currentObj) < getObjectYPos(previousObj))
						isSorted = false;
				}
				previousObj = mapMiddlegroundContainer.getChildAt(i) as MapObject;
				mapMiddlegroundContainer.removeChildAt(i);
				i--;
			}
			return new Tuple(isSorted, listToSort);
		}
		private function insertionSort(mapObjects:Vector.<MapObject>):Vector.<MapObject> {
			
			for (var i:int = 1; i < mapObjects.length; i++) {
				
				if (getObjectYPos(mapObjects[i]) < getObjectYPos(mapObjects[i - 1])) {
					
					for (var j:int = i - 1; j >= -1; j--) {
						if (j < 0) {
							var tempObject:MapObject = mapObjects[i];
							var tempVector:Vector.<MapObject> = new Vector.<MapObject>();
							tempVector.push(tempObject);
							mapObjects.splice(i, 1);
							mapObjects = tempVector.concat(mapObjects);
							break;
						}
						if (getObjectYPos(mapObjects[i]) >= getObjectYPos(mapObjects[j])) {
							tempObject = mapObjects[i];
							mapObjects.splice(i, 1);
							tempVector = new Vector.<MapObject>();
							tempVector.push(tempObject);
							mapObjects = mapObjects.slice(0, j + 1).concat(tempVector).concat(mapObjects.slice(j + 1));
							break;
						}
					}
				}
			}
			return mapObjects;
		}
		
		
		
		public function checkNormalCollision(mapObject:MapObject, onlyCollidableObjs:Boolean):Array {
			return checkCollision(mapObject, mapObject.getObjectBounds(), onlyCollidableObjs);
		}
		public function checkWideCollision(mapObject:MapObject, onlyCollidableObjs:Boolean):Array {
			return checkCollision(mapObject, mapObject.getWideBounds(), onlyCollidableObjs, true);
		}
		public function checkActionCollision(mapObject:MapObject, onlyCollidableObjs:Boolean):Array {
			return checkCollision(mapObject, mapObject.getActionBounds(), onlyCollidableObjs);
		}
		
		public function checkTransitions(mapObject:MapObject):Array {
			return checkMapListCollisions
				(mapObject, mapObject.getObjectBounds(), transitionList as Vector.<MapObject>, false);
		}
		
		public function checkCharacterCollisions(mapObject:MapObject, objBounds:Rectangle, onlyCollidableObjs:Boolean):Array {
			return checkMapListCollisions
				(mapObject, objBounds, characterList, onlyCollidableObjs);
		}
		
		
		private var returnArray:Array = [];
		private var collisionList:Array = [];
		
		public function checkCollisionsFromList(mapObject:MapObject, objects:Array):Array {
			returnArray = [];
			
			for (var i:int = 0; i < objects.length; i++) {
				if (objects[i] is Tile) {
					var tempTile:Tile = objects[i];
					if (checkObjectAndTile(mapObject, mapObject.getObjectBounds(), tempTile))
						returnArray.push(tempTile);
				}
				else if (checkMapObjects(mapObject, mapObject.getObjectBounds(), objects[i], true))
				returnArray.push(objects[i]);
			}
			return returnArray;
		}
		
		private function checkCollision(mapObject:MapObject, objBounds:Rectangle, checkCollidable:Boolean, isWide:Boolean = false):Array {
			returnArray = [];
			
			returnArray = returnArray.concat(checkMapTiles(mapObject, objBounds, isWide));
			returnArray = returnArray.concat(checkMapListCollisions
				(mapObject, objBounds, characterList, checkCollidable));
			returnArray = returnArray.concat(checkMapListCollisions
				(mapObject, objBounds, propList, checkCollidable));
			
			return returnArray;
		}
		private function checkMapListCollisions(mapObject:MapObject, objBounds:Rectangle,
												list:Vector.<MapObject>, checkCollidable:Boolean):Array {
			
			collisionList = [];
			for (var i:int = 0; i < list.length; i++) {
				
				if (checkMapObjects(mapObject, objBounds, list[i], checkCollidable))
					collisionList = collisionList.concat(list[i]);
				
			}
			return collisionList;
		}
		private function checkMapObjects(objectOne:MapObject, objBounds:Rectangle,
										objectTwo:MapObject, checkCollidable:Boolean):Boolean {
			if (objectOne == objectTwo)
				return false;
			if (!objectTwo.isCollidable() && checkCollidable)
				return false;
			
			if (objBounds.intersects(objectTwo.getObjectBounds()) && objectTwo.intersectsObject(objectOne, checkCollidable))
				return true;
			else
				return false;
		}
		private function checkObjectAndTile(objectOne:MapObject, objBounds:Rectangle, mapTile:Tile):Boolean {
			if (objBounds.intersects(mapTile.getTileBounds()) && mapTile.collidesWithTile(objBounds))
				return true;
			return false;
		}
		
		// returns an array of tiles that the character is currently colliding with
		private function checkMapTiles(mapObject:MapObject, objBounds:Rectangle, isWide:Boolean = false):Array {
			
			// Determine a rough area of tiles to search.
			var innerBoundX:int = objBounds.x / 1.2;
			var outerBoundX:int = (objBounds.x + objBounds.width) / .8;
			var innerBoundY:int = objBounds.y / 1.2;
			var outerBoundY:int = (objBounds.y + objBounds.height) / .8;
			
			innerBoundX = Math.floor(innerBoundX / Game.getTileSize());
			outerBoundX = Math.ceil(outerBoundX / Game.getTileSize());
			innerBoundY = Math.floor(innerBoundY / Game.getTileSize());
			outerBoundY = Math.ceil(outerBoundY / Game.getTileSize());
			
			if (innerBoundX < 0) innerBoundX = 0;
			else if (innerBoundX > mapWidth ) innerBoundX = mapWidth;
			if (outerBoundX < 0) outerBoundX = 0;
			else if (outerBoundX > mapWidth) outerBoundX = mapWidth;
			
			if (innerBoundY < 0) innerBoundY = 0;
			else if (innerBoundY > mapHeight) innerBoundY = mapHeight;
			if (outerBoundX < 0) outerBoundX = 0;
			else if (outerBoundY > mapHeight) outerBoundY = mapHeight;
			
			
			var collidingArray:Array = new Array();
			for (var i:int = innerBoundY; i < outerBoundY; i++) {
				for (var j:int = innerBoundX; j < outerBoundX; j++) {
					
					var tempTile:Tile = mapTileArray[i][j];
					if (isWide && objBounds.intersects(tempTile.getTileBounds())) {
						collidingArray.push(tempTile);
						continue;
					}
					else if(checkObjectAndTile(mapObject, objBounds, tempTile))
						collidingArray.push(tempTile);
				}
			}
			
			return collidingArray;
		}
		
		
		
		
		public function getTransitions():Vector.<MapObject> {
			return transitionList;
		}
		public function findTransition(endMap:Map):MapTransition {
			for each(var transition:MapTransition in transitionList) {
				if (transition.getEndMap().getMapName() == endMap.getMapName())
					return transition;
			}
			return null;
		}
		
		public function addTransition(newTransition:MapTransition):void {
			mapObjectList.push(newTransition);
			transitionList.push(newTransition);
		}
		
		public function hasCharacter(character:Character):Boolean {
			return mapMiddlegroundContainer.contains(character);
		}
		public function addCharacter(newCharacter:Character):void { 
			mapObjectList.push(newCharacter);
			characterList.push(newCharacter);
			mapMiddlegroundContainer.addChild(newCharacter);
			newCharacter.setCurrentMap(this);
		}
		public function removeCharacter(oldCharacter:Character):void {
			if (mapMiddlegroundContainer.contains(oldCharacter))
				mapMiddlegroundContainer.removeChild(oldCharacter);
			mapObjectList.splice(mapObjectList.indexOf(oldCharacter), 1);
			characterList.splice(characterList.indexOf(oldCharacter), 1);
		}
		
		public function addProp(newProp:Prop):void {
			mapObjectList.push(newProp);
			propList.push(newProp);
			mapMiddlegroundContainer.addChild(newProp);
		}
		public function addStaticProp(newProp:Prop):void {
			mapObjectList.push(newProp);
			propList.push(newProp);
			mapBackgroundContainer.addChild(newProp);
		}
		public function addParallaxProp(newProp:Prop):void {
			mapObjectList.push(newProp);
			propList.push(newProp);
			mapParallaxContainer.addChild(newProp);
		}
		
		public function removeProp(oldProp:Prop):void {
			
			if (mapMiddlegroundContainer.contains(oldProp) || mapBackgroundContainer.contains(oldProp)) {
				
				mapObjectList.splice(mapObjectList.indexOf(oldProp), 1);
				propList.splice(propList.indexOf(oldProp), 1);
				
				if (oldProp is SpectralImageProp) {
					var oldSpectralProp:SpectralImageProp = oldProp as SpectralImageProp;
					oldSpectralProp.pauseSpectralImage();
				}
				
				if (mapMiddlegroundContainer.contains(oldProp))
					mapMiddlegroundContainer.removeChild(oldProp);
				else if(mapBackgroundContainer.contains(oldProp))
					mapBackgroundContainer.removeChild(oldProp);
				else if (mapParallaxContainer.contains(oldProp))
					mapBackgroundContainer.removeChild(oldProp);
			}
		}
		
		public function addSound(soundName:String, volume:Number = 1):void {
			soundList[soundName] = volume;
		}
		public function removeSounds():void {
			stopMapSounds();
			soundList = new Dictionary();
		}
		
		public function playMapSounds(checkCurrent:Boolean = true, fadeIn:Number = 1):void {
			for (var key:String in soundList) {
				if(!checkCurrent || (checkCurrent && !SoundManager.getSingleton().isPlayingSound(key)))
					SoundManager.getSingleton().fadeInSound(key, 0, soundList[key], fadeIn, true);
			}
		}
		public function stopMapSounds(exceptions:Dictionary = null, fadeOut:Number = 1):void {
			var skip:Boolean;
			for (var key:String in soundList) {
				skip = false;
				
				if (exceptions != null) {
					for (var exceptKey:String in exceptions)
						if (exceptKey == key && SoundManager.getSingleton().isPlayingSound(key)) 
							skip = true;
				}
				
				if (!skip)
					SoundManager.getSingleton().fadeOutSound(key, fadeOut);
			}
		}
		public function pauseMapSounds():void {
			for (var key:String in soundList) {
				SoundManager.getSingleton().pauseSound(key);
			}
		}
		public function resumeMapSounds():void {
			for (var key:String in soundList) {
				SoundManager.getSingleton().resumeSound(key);
			}
		}
		public function getMapSounds():Dictionary {
			return soundList;
		}
		
		public function hasPlayerVisited():Boolean {
			return playerVisited;
		}
		public function setVisited(b:Boolean):void { playerVisited = b; }
		
		public function drawGhostEffect(host:Character, hostImage:SpectralImage):void {
			for each(var prop:Prop in propList) {
				if (prop is DoorProp) {
					var tempDoor:DoorProp = prop as DoorProp;
					if(tempDoor.getEndMap().hasPlayerVisited())
						prop.setSpectralMask
							(SpectralManager.getSingleton().getSpecGraphic("CanEnter").getClone() as SpectralImage,
							hostImage, 0, 0xff00cc00, 0, .8);
					else
						prop.setSpectralMask
							(SpectralManager.getSingleton().getSpecGraphic("CannotEnter").getClone() as SpectralImage,
							hostImage, 0, 0xffcc0000, 0, 1);
				}
			}
		}
		public function undrawGhostEffect(hostImage:SpectralImage):void {
			for each(var prop:Prop in propList) {
				if (prop is DoorProp)
					prop.removeSpectralOverlay(hostImage);
			}
		}
		public function undrawSpectralEffect(hostImage:SpectralImage):void {
			for each(var prop:Prop in propList) {
				if (prop is DoorProp)
					prop.removeSpectralOverlay(hostImage);
				if (prop is SpectralImageProp) {
					var specImgProp:SpectralImageProp = prop as SpectralImageProp;
					specImgProp.pauseSpectralImage();
				}
			}
		}
		public function redrawSpectralEffect():void {
			for each(var prop:Prop in propList) {
				if (prop is SpectralImageProp) {
					var specImgProp:SpectralImageProp = prop as SpectralImageProp;
					specImgProp.resumeSpectralImage();
				}
			}
		}
		
		public function getDoor(endMap:Map):DoorProp {
			for (var i:int = 0; i < propList.length; i++) {
				if (propList[i] is DoorProp) {
					var tempDoor:DoorProp = propList[i] as DoorProp;
					if (tempDoor.getEndMap() == endMap)
						return tempDoor;
				}
			}
			return null;
		}
		public function getDoorList():Array {
			var doors:Array = [];
			for (var i:int = 0; i < propList.length; i++) {
				if (propList[i] is DoorProp) {
					doors.push(propList[i]);
				}
			}
			return doors;
		}
		public function getMapName():String { return mapName; }
		public function getArrayWidth():int { return mapWidth; }
		public function getArrayHeight():int { return mapHeight;}
		public function getTile(x:int, y:int):Tile { 
			if (mapTileArray == null)
				mapReader.addEventListener(Event.COMPLETE, getTile);
			if (y < 0 || x < 0 || y >= mapHeight || x >= mapWidth) return null;
			return mapTileArray[y][x];
		}
		public function getGhostPos():Point {
			for each(var character:Character in characterList) {
				if (!character.isCollidable())
					return new Point(character.x, character.y);
			}
			return null;
		}
		
		public function saveMap(saveFile:SaveFile):void {
			for each(var transition:MapTransition in transitionList) {
				transition.saveTransition(saveFile, mapName);
			}
			var charStringList:Vector.<Object> = new Vector.<Object>();
			for each(var char:Character in characterList)
				charStringList.push(char.getName());
			var propStringList:Vector.<Object> = new Vector.<Object>();
			for each(var prop:Prop in propList)
				propStringList.push(prop.getPropTag());
			
			saveFile.saveData(mapName + "characters", charStringList);
			saveFile.saveData(mapName + "props", propStringList);
			saveFile.saveData(mapName + "playerVisited", playerVisited);
			saveFile.saveData(mapName + "sounds", soundList);
		}
		public function loadMap(saveFile:SaveFile, propManager:PropManager):void {
			// The properties of individual characters and props will be loaded in CharacterManager and PropManager.
			// This decides which props belong in which map.
			for each(var transition:MapTransition in transitionList) {
				transition.loadTransition(saveFile, mapName);
			}
			
			var charStringList:Vector.<Object> = saveFile.loadData(mapName + "characters") as Vector.<Object>;
			for each(var char:Character in characterList) {
				if (charStringList.indexOf(char.getName()) == -1)
					removeCharacter(char);
			}
			characterList = new Vector.<MapObject>();
			
			var propStringList:Vector.<Object> = saveFile.loadData(mapName + "props") as Vector.<Object>;
			if (propStringList.length > 0) {
				for (var i:int = 0; i < propList.length; i++) {
					var tempProp:Prop = propList[i] as Prop;
					if (!tempProp.isStatic())
						removeProp(tempProp);
				}
			}
			
			for each(var propTag:String in propStringList) {
				var loadedProp:Prop = propManager.getProp(propTag);
				if (loadedProp == null) continue;
				
				if (!loadedProp.isStatic() && (loadedProp is StairsUp || loadedProp is StairsDown ))
					addStaticProp(loadedProp);
				else if (propTag == "BoatSunset" || propTag == "BoatSundown" || propTag == "BoatDaytime")
					addParallaxProp(loadedProp);
				else if (!loadedProp.isStatic())
					addProp(loadedProp);
			}
			
			if (saveFile.loadData(mapName + "sounds") is Dictionary)
				soundList = saveFile.loadData(mapName + "sounds") as Dictionary;
			
			playerVisited = saveFile.loadData(mapName + "playerVisited");
		}
		
	}

}