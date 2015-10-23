package Characters 
{
	import Cinematics.Trigger;
	import Core.Game;
	import Core.GameState;
	import Core.State;
	import Dialogue.*;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import Interface.*;
	import Main;
	import Interface.GUIManager;
	import Maps.Map;
	import Maps.MapManager;
	import Maps.MapObject;
	import Maps.MapTransition;
	import Props.DoorProp;
	import Props.Prop;
	import Setup.ControlsManager;
	import Setup.SaveFile;
	import Sound.SoundManager;
	import SpectralGraphics.SpectralImage;
	import SpectralGraphics.SpectralManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Player
	{
		private var host:Character;
		private var ghostForm:Character;
		private var playerLoader:Loader;
		protected var findAction:Boolean;
		protected var isGhost:Boolean;
		protected var fullPossession:Boolean;
		protected var possessCount:int;
		
		protected var homeMap:Map;
		
		private var lockedScreen:Boolean;
		private var cameraPan:Boolean;
		private var cameraMove:Boolean;
		private var cameraRelative:Boolean;
		private var cameraDestination:Point;
		private var cameraSpeed:Number;
		
		private var lockedPlayer:Boolean;
		
		public function Player() 
		{
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, movePlayer);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, stopPlayer);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, checkAction);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, beginPossession);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, stopActionSearch);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, possession);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, specialDown);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, specialUp);
			
			possessCount = -1;
			fullPossession = false;
			lockedScreen = false;
			lockedPlayer = false;
			
		}
		public function initiatePlayer(saveFile:SaveFile, charManager:CharacterManager):void {
			
			this.ghostForm = charManager.getCharacter("Ghost");
			
			if (saveFile != null) {
				var possessedChar:String = saveFile.loadData("possessedCharacter") + "";
				this.host = charManager.getCharacter(possessedChar);
				
				if (host == null) {
					isGhost = true;
					ghostForm = charManager.getCharacter("Ghost");
					host = ghostForm;
				}
				else if (this.host.getName() == "Ghost") isGhost = true;
			}
			else {
				isGhost = true;
				ghostForm = charManager.getCharacter("Ghost");
				host = ghostForm;
			}
			
			host.setControlled(this, true);
		}
		
		public function updatePlayer(currentMap:Map, gameScreen:GameScreen):void {
			// Update a couple of Player variables needed in other functions.
			homeMap = currentMap;
			if (!homeMap.hasPlayerVisited())
				homeMap.setVisited(true);
			
			// If the possession button has been hit, add to the counter that determines how long it was held down.
			if (possessCount >= 0) possessCount++;
			if (possessCount == 10) SoundManager.getSingleton().playSound("FullPossessBegin", 1, false);
			if (possessCount == 60) SoundManager.getSingleton().playSound("FullPossessDone", 1, false);
			
			// Handle map scrolling.
			var screenHeight:int = Main.getSingleton().getStageHeight();
			var screenWidth:int = Main.getSingleton().getStageWidth();
			
			if (cameraMove) {
				centerScreenOnPoint(gameScreen, cameraDestination);
				cameraMove = false;
			}
			else if (cameraPan) {
				
				var currentPos:Point = new Point(screenWidth / 2 - gameScreen.x, screenHeight / 2 - gameScreen.y);
				var distance:Number = Math.abs(currentPos.x - cameraDestination.x) + Math.abs(currentPos.y - cameraDestination.y);
				var speed:Number = cameraSpeed;
				
				if (cameraRelative) {
					cameraDestination.x = cameraDestination.x + currentPos.x;
					cameraDestination.y = cameraDestination.y + currentPos.y;
					cameraRelative = false;
				}
				
				if (distance < cameraSpeed)
					speed = distance;
				
				var tempDestination:Point = new Point();
				var xDifference:int = currentPos.x - cameraDestination.x;
				var yDifference:int = currentPos.y - cameraDestination.y;
				var theta:Number = Math.atan(yDifference / xDifference);
				var degreeTheta:Number = theta * (360 / Math.PI);
				var xDelta:Number = speed * Math.cos(theta);
				var yDelta:Number = speed * Math.sin(theta);
				
				if (xDifference < 0)
					xDelta = -Math.abs(xDelta);
				else
					xDelta = Math.abs(xDelta);
				if (yDifference < 0)
					yDelta = -Math.abs(yDelta);
				else
					yDelta = Math.abs(yDelta);
				tempDestination.x = currentPos.x - xDelta;
				tempDestination.y = currentPos.y - yDelta;
				
				centerScreenOnPoint(gameScreen, tempDestination);
				
				currentPos = new Point(screenWidth / 2 - gameScreen.x, screenHeight / 2 - gameScreen.y);
				if (Math.abs(currentPos.x - cameraDestination.x) < 3 && Math.abs(currentPos.y - cameraDestination.y) < 3)
					cameraPan = false;
			}
			else if (!lockedScreen && !GUIManager.getSingleton().inDialogue()) {
				centerScreenOnPlayer(currentMap, gameScreen);
			}
			
		}
		private function centerScreenOnPlayer(currentMap:Map, gameScreen:GameScreen):void {
			var screenHeight:int = Main.getSingleton().getStageHeight();
			var screenWidth:int = Main.getSingleton().getStageWidth();
			
			if (currentMap.getArrayWidth() * 32 < screenWidth)
				gameScreen.x = screenWidth / 2 - (currentMap.getArrayWidth() * 32) / 2;
			else if (host.x - screenWidth / 2 > gameScreen.x 
				&& host.x + screenWidth / 2 < currentMap.getArrayWidth() * 32 )
					gameScreen.x = -(host.x) + screenWidth / 2;
			else if (host.x + screenWidth / 2 > currentMap.getArrayWidth() * 32)
				gameScreen.x = (-currentMap.getArrayWidth() * 32) + screenWidth;
			
			if (currentMap.getArrayHeight() * 32 < screenHeight)
				gameScreen.y = screenHeight / 2 - (currentMap.getArrayHeight() * 32) / 2;
			else if (host.y - screenHeight / 2 > gameScreen.y
				&& host.y + screenHeight / 2 < currentMap.getArrayHeight() * 32)
					gameScreen.y = -(host.y) + screenHeight / 2;	
			else if (host.y + screenHeight / 2 > currentMap.getArrayHeight() * 32)
				gameScreen.y = ( -currentMap.getArrayHeight() * 32) + screenHeight;
		}
		private function centerScreenOnPoint(gameScreen:GameScreen, point:Point):void {
			var screenHeight:int = Main.getSingleton().getStageHeight();
			var screenWidth:int = Main.getSingleton().getStageWidth();
			
			gameScreen.x = screenWidth / 2 - point.x;
			gameScreen.y = screenHeight / 2 - point.y;
		}
		
		private function beginPossession(keyEvent:KeyboardEvent):void {
			if ((checkKeyInput("Possession Key", keyEvent.keyCode) || checkKeyInput("Alt Possession Key", keyEvent.keyCode))
					&& GUIManager.getSingleton().inDialogue() == false && isGhost && possessCount < 0) {
				possessCount = 0;
			}
		}
		
		private function possession(keyEvent:KeyboardEvent):void {
			if (lockedPlayer) return;
			if (host.getCurrentMap() != homeMap)
				return;
			
			if ((checkKeyInput("Possession Key", keyEvent.keyCode) || checkKeyInput("Alt Possession Key", keyEvent.keyCode))
					&& GUIManager.getSingleton().inDialogue() == false) {
				
				if (!isGhost)
					depossess();
				
				else {
					// If in ghost form when 'z' is pressed, we look to see if there are any nearby characters to possess.
					
					var charArray:Array = homeMap.checkCharacterCollisions(host, host.getActionBounds(), false);
					var closestCharacter:Character = findClosestObject(charArray) as Character;
					
					if (closestCharacter != null && closestCharacter.isCollidable())
						handlePossessAttempt(closestCharacter);
					
				}
				// reset possession counter
				if (possessCount >= 60) 
					SoundManager.getSingleton().playSound("FullPossessEnd", 1, false);
				
				possessCount = -1;
			}
		}
		
		private function handlePossessAttempt(closestCharacter:Character):void {
			
			// Fails if the character trying to be possessed is unpossessable.
			if (closestCharacter.getPossessStatus() == 0) {
				//SoundManager.getSingleton().playSound("PossessFail", 1);
				possessCount = -1;
				return;
			}
			
			// Fails if the player is trying to 'fully' possess a character that is only half-possessable.
			if (possessCount >= 60) {
				possessCount = -1;
				if (closestCharacter.getPossessStatus() != 2) {
					//SoundManager.getSingleton().playSound("FullPossessEnd", 1, false);
					return;
				}
				fullPossession = true;
			}
			
			handleSuccessfulPossession(closestCharacter);
			
		}
		private function handleSuccessfulPossession(closestCharacter:Character):void {
			var ghostEffect:GhostEffect = ghostForm.getCharEffect() as GhostEffect;
			if (ghostEffect != null) ghostEffect.silenceGhostEffect();
			
			homeMap.removeCharacter(ghostForm);
			host.stopCharacter()
			host.setControlled(this, false);
			SoundManager.getSingleton().playSound("Possess", 1);
			
			handleMusicChange(closestCharacter);
			
			host = closestCharacter;
			host.pauseBehavior();
			host.clearCommand();
			host.stopCharacter();
			host.setControlled(this, true);
			isGhost = false;
		}
		
		private function depossess():void {
			if (!isGhost) {
				// If 'z' is pressed while in material form, the ghostForm character is added to the map and displayList.
				// We also halt the previous host, set the ghost to the same position as the previous host,
				//  and make the host the ghost.
				
				host.setControlled(this, false);
				host.stopCharacter();
				host.resumeBehavior();
				SoundManager.getSingleton().playSound("Unpossess", 1);
				
				handleMusicChange(ghostForm);
				
				ghostForm.x = host.getObjectBounds().x - (ghostForm.getObjectBounds().x - ghostForm.x);
				ghostForm.y = host.getObjectBounds().y - (ghostForm.getObjectBounds().y - ghostForm.y);
				ghostForm.setZPosition(host.getZPosition());
				host = ghostForm;
				host.setControlled(this, true);
				homeMap.addCharacter(ghostForm);
				ghostForm.handleTransition(null);
				isGhost = true;
				fullPossession = false;
			}
		}
		
		private function handleMusicChange(newChar:Character):void {
			var newTheme:String = newChar.getTheme();
			var oldTheme:String = host.getTheme();
			
			// If neither the new character nor the old character have theme music, there's nothing to do here.
			if (newTheme == null && oldTheme == null) return;
			
			if (oldTheme != null)
				SoundManager.getSingleton().stopSound(oldTheme);
			else
				host.getCurrentMap().stopMapSounds(null, .05);
			
			if (newTheme != null && !SoundManager.getSingleton().isPlayingSound(newTheme))
				SoundManager.getSingleton().playSound(newTheme, 1, true);
			else
				host.getCurrentMap().playMapSounds(true, .05);
		}
		
		
		public function checkAction(keyEvent:KeyboardEvent):void {
			if (lockedPlayer || homeMap == null) return;
			
			// If 'e' is pressed, check to see if there are other characters nearby.
			if ((checkKeyInput("Action Key", keyEvent.keyCode) || checkKeyInput("Alt Action Key", keyEvent.keyCode))) {
				
				if (!GUIManager.getSingleton().inDialogue() && !findAction) {
					
					var actionArray:Array = homeMap.checkActionCollision(host, false);
					
					var closestObj:MapObject = findClosestObject(actionArray);
					var objDistance:int;
					
					if (closestObj == null) objDistance = int.MAX_VALUE;
					else objDistance = Math.abs(host.x - closestObj.x) + Math.abs(host.y - closestObj.y);
					
					if (closestObj is Prop && !findAction) {
						var closestProp:Prop = closestObj as Prop;
						if (fullPossession) var charName:String = "Ghost" + host.getName();
						else charName = host.getName();
						
						possessCount = -1;
						closestProp.effect(this.host, true, charName);
						findAction = true;
						return;
						
					}
					else if (closestObj is Character) {
						
						var closestChar:Character = closestObj as Character;
						closestChar.faceCharacter(host);
						
						if(host.getName() == "Ghost" && closestChar.getName() != "Paulo") return;
						var prefix:String = host.getName();
						var suffix:String = closestChar.getName();
						
						if (fullPossession)
							var dialogue:Dialogue = getGhostDialogue(prefix, suffix);
						else
							dialogue = DialogueLibrary.getSingleton().retrieveDialogue(prefix + "-" + suffix);
						
						if (dialogue != null) {
							
							host.stopCharacter();
							host.stopXSpeed();
							host.stopYSpeed();
							possessCount = -1;
							GUIManager.getSingleton().startDialogue(dialogue, closestChar);
						}
					}
				}
				
				findAction = true;
			}
		}
		private function getGhostDialogue(prefix:String, suffix:String):Dialogue {
			
			var dialogue:Dialogue = DialogueLibrary.getSingleton().retrieveDialogue("Ghost" + host.getName() + "-" + suffix);
			
			if (dialogue == null)
				return DialogueLibrary.getSingleton().retrieveDialogue("Ghost-" + suffix);
			else
				return dialogue;
		}
		
		private function findClosestObject(actionArray:Array):MapObject{
			var closestDistance:int = int.MAX_VALUE;
			var closestObject:MapObject;
			var hostCenter:Point = new Point(host.getActionBounds().x + host.getObjectBounds().width / 2,
											host.getActionBounds().y + host.getObjectBounds().height / 2);
			
			for (var i:int = 0; i < actionArray.length; i++) {
				
				// All the reasons a map object might be disqualified from player interaction:
				if (!(actionArray[i] is MapObject)) continue; // It isn't actually a mapobject at all.
				if (actionArray[i] is Follower) continue; // Followers can't be interacted with.
				if (actionArray[i] is Prop) {			// If it's a prop and has no dialogues or effects whatsoever.
					var tempProp:Prop = actionArray[i] as Prop;
					if (!tempProp.hasEffect() && !tempProp.hasDialogue(host.getName())) continue;
				}
				
				var mapObject:MapObject = actionArray[i] as MapObject;
				var mapObjectCenter:Point = new Point(mapObject.getActionBounds().x + mapObject.getObjectBounds().width / 2,
												mapObject.getActionBounds().y + mapObject.getObjectBounds().height / 2);
				if (!isFacingObject(mapObject, hostCenter, mapObjectCenter) && host.getName() != "Sarah") 
					continue; // If the player isn't facing it.
				
				var distance:int = Math.abs(hostCenter.x - mapObjectCenter.x) + Math.abs(hostCenter.y - mapObjectCenter.y);
				
				if (distance < closestDistance && mapObject != this.host) {
					closestDistance = distance;
					closestObject = mapObject;
				}
			}
			return closestObject;
		}
		private function isFacingObject(mapObject:MapObject, hostCenter:Point, mapObjectCenter:Point):Boolean {
			if (host.getName() == "Ghost") return true;
			
			var direction:String = directionOfObject(mapObject, hostCenter, mapObjectCenter);
			if (direction == host.getAlignment()) 
				return true;
			else
				return false;
		}
		private function directionOfObject(mapObject:MapObject, hostCenter:Point, mapObjectCenter:Point):String {
			
			var xDifference:int = hostCenter.x - mapObjectCenter.x;
			var yDifference:int = hostCenter.y - mapObjectCenter.y;
			
			if (xDifference > 0 && Math.abs(xDifference) >= Math.abs(yDifference)) return "Left";
			else if (xDifference < 0 && Math.abs(xDifference) >= Math.abs(yDifference)) return "Right";
			
			else if (yDifference > 0 && Math.abs(yDifference) >= Math.abs(xDifference)) return "Back";
			else if (yDifference < 0 && Math.abs(yDifference) >= Math.abs(xDifference)) return "Front";
			
			return "";
		}
		
		public function stopActionSearch(keyEvent:KeyboardEvent):void {
			if (keyEvent.keyCode == ControlsManager.getSingleton().getKey("Action Key") 
					|| keyEvent.keyCode == ControlsManager.getSingleton().getKey("Alt Action Key"))
				findAction = false;
		}
		
		private function movePlayer(moveEvent:KeyboardEvent):void {	
			if (homeMap == null) return;
			
			if(!lockedPlayer){
				if (checkKeyInput("Up Key", moveEvent.keyCode) || checkKeyInput("Alt Up Key", moveEvent.keyCode))
					host.setUp(true);
				if (checkKeyInput("Down Key", moveEvent.keyCode) || checkKeyInput("Alt Down Key", moveEvent.keyCode))
					host.setDown(true);
				if (checkKeyInput("Left Key", moveEvent.keyCode) || checkKeyInput("Alt Left Key", moveEvent.keyCode))
					host.setLeft(true);
				if (checkKeyInput("Right Key", moveEvent.keyCode) || checkKeyInput("Alt Right Key", moveEvent.keyCode))
					host.setRight(true);
			}
			
			if (GUIManager.getSingleton().inDialogue() || lockedPlayer) {
				host.setUp(false);
				host.setDown(false);
				host.setLeft(false);
				host.setRight(false);
			}
		}	
		
		private function stopPlayer(moveEvent:KeyboardEvent):void {
			if (checkKeyInput("Up Key", moveEvent.keyCode) || checkKeyInput("Alt Up Key", moveEvent.keyCode))
				host.setUp(false);
			if (checkKeyInput("Down Key", moveEvent.keyCode) || checkKeyInput("Alt Down Key", moveEvent.keyCode))
				host.setDown(false);
			if (checkKeyInput("Left Key", moveEvent.keyCode) || checkKeyInput("Alt Left Key", moveEvent.keyCode))
				host.setLeft(false);
			if (checkKeyInput("Right Key", moveEvent.keyCode) || checkKeyInput("Alt Right Key", moveEvent.keyCode))
				host.setRight(false);
		}
		
		private function specialDown(key:KeyboardEvent):void {
			if (host.getCharEffect() == null) return;
			if (GUIManager.getSingleton().inDialogue()) return;
			if (lockedPlayer) return;
			
			if (checkKeyInput("Special Key", key.keyCode) || checkKeyInput("Alt Special Key", key.keyCode))
				host.getCharEffect().effectPress(host);
		}
		private function specialUp(key:KeyboardEvent):void {
			if (host.getCharEffect() == null) return;
			if (GUIManager.getSingleton().inDialogue()) return;
			
			if (checkKeyInput("Special Key", key.keyCode) || checkKeyInput("Alt Special Key", key.keyCode))
				host.getCharEffect().effectRelease(host);
		}
		
		private function checkKeyInput(keyName:String, keyCode:uint):Boolean {
			if (ControlsManager.getSingleton().getKey(keyName) == keyCode)
				return true;
			return false;
		}
		
		public function getHost():Character { return host; }
		
		public function removePlayerListeners():void {
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_DOWN, movePlayer);
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, stopPlayer);
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkAction);
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, stopActionSearch);
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, possession);
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_DOWN, specialDown);
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, specialUp);
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_DOWN, beginPossession);
		}
		public function addPlayerListeners():void {
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, movePlayer);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, stopPlayer);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, checkAction);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, stopActionSearch);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, possession);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, specialDown);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, specialUp);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_DOWN, beginPossession);
		}
		
		public function listenToTrigger(parsedRequirement:Array):Boolean {
			
			if (parsedRequirement[0] == "isCharacter") {
				var charName:String = parsedRequirement[1];
				if (host.getName() == charName) return true;
			}
			else if (parsedRequirement[0] == "isFullyPossessedCharacter") {
				charName = parsedRequirement[1];
				if (host.getName() == charName && fullPossession) return true;
			}
			else if (parsedRequirement[0] == "isInMap") {
				var map:String = parsedRequirement[1];
				if (host.getCurrentMap().getMapName() == map) return true;
			}
			return false;
		}
		
		public function performTriggerEffect(parsedEffect:Array):void {
			
			if (parsedEffect[0] == "lockPlayer") {
				if (parsedEffect[1] == "true") {
					host.stopXSpeed();
					host.stopYSpeed();
					host.stopCharacter();
					lockedPlayer = true;
				}
				else if (parsedEffect[1] == "false")
					lockedPlayer = false;
			}
			
			else if (parsedEffect[0] == "depossess")
				this.depossess();
			
			else if (parsedEffect[0] == "cameraPan") {
				cameraPan = true;
				cameraDestination = getEffectPosition(parsedEffect, 2);
				cameraSpeed = parsedEffect[1];
			}
			else if (parsedEffect[0] == "cameraPanRelative") {
				cameraPan = true;
				cameraRelative = true;
				cameraDestination = getEffectPosition(parsedEffect, 2);
				cameraSpeed = parsedEffect[1];
			}
			else if (parsedEffect[0] == "panToPlayer") {
				cameraPan = true;
				cameraDestination = new Point(host.getObjectBounds().x, host.getObjectBounds().y);
				cameraSpeed = parsedEffect[1];
			}
			else if (parsedEffect[0] == "cameraMove") {
				cameraMove = true;
				cameraDestination = getEffectPosition(parsedEffect, 1);
			}
			else if (parsedEffect[0] == "moveToPlayer") {
				cameraMove = true;
				cameraDestination = new Point(host.getObjectBounds().x, host.getObjectBounds().y);
			}
			else if (parsedEffect[0] == "cameraLock") {
				if (parsedEffect[1] == "true")
					lockedScreen = true;
				else if (parsedEffect[1] == "false")
					lockedScreen = false;
			}
			
		}
		private function getEffectPosition(parsedEffect:Array, index:int):Point {
			var effectPosition:Point = new Point();
			var positionValues:Array = parsedEffect[index].split(',');
			if (positionValues.length != 2) 
				throw new Error("Cinematic Error: Effect requiring two-point coordinate received wrong number of coordinates!");
			
			var positionVal:String = positionValues[0];
			if (positionVal.indexOf("<neg>") >= 0)
				effectPosition.x = -1 * parseInt(positionVal.split('>')[1]);
			else
				effectPosition.x = parseInt(positionVal);
				
			positionVal = positionValues[1];
			if (positionVal.indexOf("<neg>") >= 0)
				effectPosition.y = -1 * parseInt(positionVal.split('>')[1]);
			else
				effectPosition.y = parseInt(positionVal);
				
			return effectPosition;
		}
		
		public function panCameraToCharacter(parsedEffect:Array, character:Character):void {
			cameraPan = true;
			cameraDestination = new Point(character.getObjectBounds().x, character.getObjectBounds().y);
			cameraSpeed = parsedEffect[2];
		}
		
	}

}