package Characters 
{
	import adobe.utils.CustomActions;
	import AI.BehaviorLibrary;
	import AI.CharacterCommand;
	import AI.PacingBehavior;
	import Cinematics.Trigger;
	import Core.Game;
	import Dialogue.Dialogue;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import Interface.GameScreen;
	import Main;
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	import Maps.Map;
	import Maps.MapManager;
	import Props.SpectralImageProp;
	import Setup.GameLoader;
	import Setup.SaveFile;
	import SpectralGraphics.SpectralImage;
	import SpectralGraphics.SpectralManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class CharacterManager 
	{
		private var characterList:Dictionary;
		private var charBehaviorLibrary:BehaviorLibrary;
		
		public function CharacterManager(mapManager:MapManager, gameScreen:GameScreen) 
		{	// Shouldn't be called directly!;
			
			
			var root:String = Main.getSingleton().rootURL;
			
			var walkRow:Array = new Array(new Point(0, 0), new Point(1, 0), new Point(2, 0), new Point(3, 0),
											new Point(4, 0), new Point(5, 0));
			var ghostRow:Array = new Array(new Point(0, 0), new Point(1, 0), new Point(2, 0), new Point(3, 0),
											new Point(4, 0), new Point(5, 0), new Point(6, 0), new Point(7, 0));
			var idleRow:Array = new Array(new Point(0, 0));
			
			var ghostIdle:Animation = new Animation("Ghost Idle", 3, new Point(0, 0), 44, 64, ghostRow);
			var ghostDown:Animation = new Animation("Ghost Down", 3, new Point(0, 0), 44, 64, ghostRow);
			var ghostUp:Animation = new Animation("Ghost Up", 3, new Point(0, 64), 44, 64, ghostRow);
			var ghostLeft:Animation = new Animation("Ghost Left", 3, new Point(0, 192), 44, 64, ghostRow);
			var ghostRight:Animation = new Animation("Ghost Right", 3, new Point(0, 128), 44, 64, ghostRow);
			
			var frontWalk:Animation = new Animation("Front Walk", 3, new Point(36, 0), 36, 64, walkRow);
			var backWalk:Animation = new Animation("Back Walk", 3, new Point(36, 64), 36, 64, walkRow);
			var leftWalk:Animation = new Animation("Left Walk", 3, new Point(36, 128), 36, 64, walkRow);
			var rightWalk:Animation = new Animation("Right Walk", 3, new Point(36, 192), 36, 64, walkRow);
			
			var iblisFrontWalk:Animation = new Animation("Front Walk", 3, new Point(40, 0), 40, 64, walkRow);
			var iblisBackWalk:Animation = new Animation("Back Walk", 3, new Point(40, 64), 40, 64, walkRow);
			var iblisLeftWalk:Animation = new Animation("Left Walk", 3, new Point(40, 128), 40, 64, walkRow);
			var iblisRightWalk:Animation = new Animation("Right Walk", 3, new Point(40, 192), 40, 64, walkRow);
			
			var frontIdle:Animation = new Animation("Front Idle", -1, new Point(0, 0), 36, 64, idleRow);
			var backIdle:Animation = new Animation("Back Idle", -1, new Point(0, 64), 36, 64, idleRow);
			var leftIdle:Animation = new Animation("Left Idle", -1, new Point(0, 128), 36, 64, idleRow);
			var rightIdle:Animation = new Animation("Right Idle", -1, new Point(0, 192), 36, 64, idleRow);
			
			var iblisFrontIdle:Animation = new Animation("Front Idle", -1, new Point(0, 0), 40, 64, idleRow);
			var iblisBackIdle:Animation = new Animation("Back Idle", -1, new Point(0, 64), 40, 64, idleRow);
			var iblisLeftIdle:Animation = new Animation("Left Idle", -1, new Point(0, 128), 40, 64, idleRow);
			var iblisRightIdle:Animation = new Animation("Right Idle", -1, new Point(0, 192), 40, 64, idleRow);
			
			var doorIdle:Animation = new Animation("Front Idle", -1, new Point(0, 0), 32, 64, idleRow);
			var dollIdle:Animation = new Animation("Front Idle", -1, new Point(0, 0), 32, 32, idleRow);
			
			var cricketAnimations:Dictionary = new Dictionary();
			cricketAnimations[frontWalk.getName()] = frontWalk;
			cricketAnimations[backWalk.getName()] = backWalk;
			cricketAnimations[leftWalk.getName()] = leftWalk;
			cricketAnimations[rightWalk.getName()] = rightWalk;
			cricketAnimations[frontIdle.getName()] = frontIdle;
			cricketAnimations[backIdle.getName()] = backIdle;
			cricketAnimations[leftIdle.getName()] = leftIdle;
			cricketAnimations[rightIdle.getName()] = rightIdle;
			
			var randyAnimations:Dictionary = new Dictionary();
			var morganAnimations:Dictionary = new Dictionary();
			var lucilleAnimations:Dictionary = new Dictionary();
			var tedAnimations:Dictionary = new Dictionary();
			var roseAnimations:Dictionary = new Dictionary();
			var orvalAnimations:Dictionary = new Dictionary();
			
			for (var key:Object in cricketAnimations) {
				var tempAnimation:Animation = cricketAnimations[key] as Animation;
				randyAnimations[key] = tempAnimation.getClone();
				morganAnimations[key] = tempAnimation.getClone(5);
				lucilleAnimations[key] = tempAnimation.getClone(4);
				tedAnimations[key] = tempAnimation.getClone(4);
				roseAnimations[key] = tempAnimation.getClone(5);
				orvalAnimations[key] = tempAnimation.getClone(4);
			}
			
			cricketAnimations["Evil"] = new Animation("Evil", 0, new Point(0, 256), 40, 64, [new Point()]);
			cricketAnimations["Defeated"] = new Animation("Defeated", 0, new Point(40, 256), 52, 64, [new Point()]);
			cricketAnimations["Shot"] = new Animation("Shot", 0, new Point(92, 256), 72, 64, [new Point()]);
			lucilleAnimations["FBI"] = new Animation("FBI", 0, new Point(0, 256), 40, 64, [new Point()]);
			
			var iblisAnimations:Dictionary = new Dictionary();
			iblisAnimations[frontWalk.getName()] = iblisFrontWalk;
			iblisAnimations[backWalk.getName()] = iblisBackWalk;
			iblisAnimations[leftWalk.getName()] = iblisLeftWalk;
			iblisAnimations[rightWalk.getName()] = iblisRightWalk;
			iblisAnimations[frontIdle.getName()] = iblisFrontIdle;
			iblisAnimations[backIdle.getName()] = iblisBackIdle;
			iblisAnimations[leftIdle.getName()] = iblisLeftIdle;
			iblisAnimations[rightIdle.getName()] = iblisRightIdle;
			
			var doorAnimations:Dictionary = new Dictionary();
			doorAnimations[doorIdle.getName()] = doorIdle;
			var dollAnimations:Dictionary = new Dictionary();
			dollAnimations[dollIdle.getName()] = dollIdle;
			
			var tS:int = Game.getTileSize();
			
			var cricket:Character = new Character(new GameLoader.Cricket() as Bitmap, "Cricket", cricketAnimations,
				9 * tS, 3 * tS, new Rectangle(6, 45, 26, 18), true, 5, 1, 1, 3, 1);
			var randy:Character = new Character(new GameLoader.Randy() as Bitmap, "Randy", randyAnimations,
				14 * tS, 12 * tS, new Rectangle(6, 45, 26, 18), true, 5, 1, 1, 3, 0, "Slow Footstep");
			var ted:Character = new Character(new GameLoader.Ted() as Bitmap, "Ted", tedAnimations,
				12 * tS, 7 * tS, new Rectangle(6, 45, 26, 18), true, 5, 1, 1, 3, 1);
			var lucille:Character = new Character(new GameLoader.Lucille() as Bitmap, "Lucille", lucilleAnimations,
				7 * tS, 3 * tS, new Rectangle(6, 45, 26, 18), true, 5, 1, 1, 3, 1);
			var morgan:Character = new Character(new GameLoader.Morgan() as Bitmap, "Morgan", morganAnimations,
				3 * tS, 5 * tS, new Rectangle(6, 45, 26, 18), true, 5, 1, 1, 3, 1);
			var iblis:Character = new Character(new GameLoader.Iblis() as Bitmap, "Iblis", iblisAnimations,
				18 * tS, 4 * tS, new Rectangle(6, 45, 26, 18), true, 5, 1, 1, 3, 1, "Light Footstep");
			var rose:Character = new Character(new GameLoader.Rose() as Bitmap, "Rose", roseAnimations,
				5 * tS, 4 * tS, new Rectangle(6, 45, 26, 18), true, 5, 1, 1, 3, 1);
			var orval:Character = new Character(new GameLoader.Orval() as Bitmap, "Orval", orvalAnimations,
				5 * tS, 2 * tS, new Rectangle(6, 45, 26, 18), true, 5, 1, 1, 3, 1);
			
			var pooper:Character = new Character(new GameLoader.Door() as Bitmap, "Pooper", doorAnimations,
				3 * tS, 2 * tS, new Rectangle(0, 0, 32, 64));
			
			var sarah:Character = new Character(new GameLoader.Doll() as Bitmap, "Sarah", dollAnimations,
				8.2 * tS, 5.8 * tS, new Rectangle(10, 16, 22, 16), true, 0, 0, 0, 0, 1);
			
			var ghostAnimations:Dictionary = new Dictionary();
			ghostAnimations[frontWalk.getName()] = ghostDown;
			ghostAnimations[backWalk.getName()] = ghostUp;
			ghostAnimations[leftWalk.getName()] = ghostLeft;
			ghostAnimations[rightWalk.getName()] = ghostRight;
			ghostAnimations[frontIdle.getName()] = ghostIdle;
			ghostAnimations[backIdle.getName()] = ghostIdle;
			ghostAnimations[leftIdle.getName()] = ghostIdle;
			ghostAnimations[rightIdle.getName()] = ghostIdle;
			
			var ghost:Character = new Character(new GameLoader.Ghost() as Bitmap, "Ghost", ghostAnimations,
				9 * tS, 11 * tS, new Rectangle(10, 50, 26, 18), false, 10, 0.5, 0.5, 4, 0, "");
			ghost.alpha = 0.5;
			
			
			cricket.addShadow(new GameLoader.Shadow1() as Bitmap, new Point(-3, 50));
			randy.addShadow(new GameLoader.Shadow2() as Bitmap, new Point(-4, 50));
			ted.addShadow(new GameLoader.Shadow2() as Bitmap, new Point(-3, 50));
			lucille.addShadow(new GameLoader.Shadow1() as Bitmap, new Point(-3, 50));
			morgan.addShadow(new GameLoader.Shadow2() as Bitmap, new Point(-3, 50));
			iblis.addShadow(new GameLoader.Shadow2() as Bitmap, new Point(-3, 48));
			rose.addShadow(new GameLoader.Shadow2() as Bitmap, new Point(-3, 50));
			orval.addShadow(new GameLoader.Shadow1() as Bitmap, new Point(-3, 50));
			
			characterList = new Dictionary();
			characterList[ghost.getName()] = ghost;
			characterList[cricket.getName()] = cricket;
			characterList[randy.getName()] = randy;
			characterList[ted.getName()] = ted;
			characterList[lucille.getName()] = lucille;
			characterList[morgan.getName()] = morgan;
			characterList[iblis.getName()] = iblis;
			characterList[rose.getName()] = rose;
			characterList[orval.getName()] = orval;
			characterList[pooper.getName()] = pooper;
			characterList[sarah.getName()] = sarah;
			
			mapManager.getMap("Owner's Room").addCharacter(ghost);
			mapManager.getMap("Owner's Room").addCharacter(cricket);
			mapManager.getMap("Owner's Room").addCharacter(randy);
			mapManager.getMap("Lucille's Room").addCharacter(lucille);
			mapManager.getMap("Lobby").addCharacter(ted);
			mapManager.getMap("Morgan's Room").addCharacter(morgan);
			mapManager.getMap("Hallway").addCharacter(iblis);
			mapManager.getMap("Rose's Room").addCharacter(rose);
			mapManager.getMap("Orval's Room").addCharacter(orval);
			mapManager.getMap("Bathroom").addCharacter(pooper);
			mapManager.getMap("Morgan's Room").addCharacter(sarah);
			
			
			charBehaviorLibrary = new BehaviorLibrary(mapManager, this);
		}
		public function initiateCharacters(saveFile:SaveFile, mapManager:MapManager):void {
			if (saveFile == null) {
				
				characterList["Ted"].setRandomBehavior(60, 5, 3);
				characterList["Lucille"].setRandomBehavior(120, 2, 2);
				characterList["Morgan"].setRandomBehavior(120, 4, 4);
				characterList["Rose"].setRandomBehavior(120, 4, 4);
				
				charBehaviorLibrary.activateBehavior("IblisPath");
				charBehaviorLibrary.activateBehavior("OrvalPath");
				
			}
			else {
				var loadedChars:Dictionary = new Dictionary();
				
				for each(var char:Character in characterList) {
					
					if (loadedChars[char.getName()] == null)
						char.loadCharacter(saveFile, mapManager, this, characterList);
					loadedChars[char.getName()] = char;
				}
			}
		}
		
		
		public function getCharacter(charName:String):Character {
			
			if (characterList[charName] != null)
				return characterList[charName];
			return null;
		}
		
		private function makeCharacterFollower(host:Character, leader:Character):void {
			if (host is Follower) {
				makeFollowerCharacter(host as Follower);
				makeCharacterFollower(characterList[host.getName()], leader);
			}
			else {
				var follower:Follower = host.createFollower(leader);
				host.getCurrentMap().addCharacter(follower);
				host.getCurrentMap().removeCharacter(host);
				characterList[host.getName() + "Follower"] = follower;
			}
			
		}
		private function makeFollowerCharacter(follower:Follower):void {
			var followerHost:Character = follower.getHost();
			followerHost.x = follower.x;
			followerHost.y = follower.y;
			
			follower.getCurrentMap().addCharacter(followerHost);
			follower.getCurrentMap().removeCharacter(follower);
			followerHost.removeFollowerCopy();
			
			delete(characterList[follower.getName() + "Follower"]);
		}
		
		public function drawGhostEffect(host:Character, hostImage:SpectralImage):void {
			for each(var character:Character in characterList) {
				if (character.getName() == "Ghost")
					continue;
				if (character.getCurrentMap() != host.getCurrentMap())
					continue;
					
				drawCharacterOverlay(character, hostImage);
			}
		}
		public function updateGhostEffect(host:Character, hostImage:SpectralImage):void {
			for each(var character:Character in characterList) {
				if (character.getName() == "Ghost") continue;
				
				if (character.getCurrentMap() != host.getCurrentMap() && character.imageContainsSpectralOverlay(hostImage))
					character.removeSpectralOverlay(hostImage);
				else if (character.getCurrentMap() == host.getCurrentMap() && !character.imageContainsSpectralOverlay(hostImage))
					drawCharacterOverlay(character, hostImage);
			}
		}
		private function drawCharacterOverlay(character:Character, hostImage:SpectralImage):void {
			if (character.getPossessStatus() >= 2)
				character.setSpectralMask(
					SpectralManager.getSingleton().getSpecGraphic("CanFullPossess").getClone() as SpectralImage,
					hostImage, 0, 0);
			else if (character.getPossessStatus() >= 1)
				character.setSpectralMask(
					SpectralManager.getSingleton().getSpecGraphic("CanPossess").getClone() as SpectralImage,
					hostImage, 0, 0xff00cc00);
			else
				character.setSpectralMask
					(SpectralManager.getSingleton().getSpecGraphic("CannotPossess").getClone() as SpectralImage, 
					hostImage, 0, 0xffcc0000);
		}
		
		public function undrawGhostEffect(hostImage:SpectralImage):void {
			for each(var character:Character in characterList) {
				if (character.getName() == "Ghost")
					continue;
				character.removeSpectralOverlay(hostImage);
			}
		}
		
		private function drawCharGhostEffect(character:Character):void {
			if(character.getPossessStatus() == 1){
				character.setPersonalMask
					(SpectralManager.getSingleton().getSpecGraphic("UnlockCharacter").getClone() as SpectralImage, 0, 0xffcc0000);
			}
			else if (character.getPossessStatus() == 2) {
				character.setPersonalMask
					(SpectralManager.getSingleton().getSpecGraphic("UnlockFullCharacter").getClone() as SpectralImage, 0, 0xffcc0000);
			}
		}
		private function removeCharGhostEffect(character:Character):void {
			character.removePersonalOverlay();
		}
		
		public function listenToTrigger(parsedRequirement:Array):Boolean {
			
			if (parsedRequirement[0] == "isOnTile") {
				// Returns if the given character is on a given tile on a given map
				var character:Character = characterList[parsedRequirement[1]];
				var mapName:String = parsedRequirement[2];
				var coordinates:Array = parsedRequirement[3].split(',');
				var tileSize:int = Game.getTileSize();
				
				var tileBounds:Rectangle = new Rectangle
					(coordinates[0] * tileSize, coordinates[1] * tileSize, tileSize, tileSize);
				if (character.getCurrentMap().getMapName() == mapName && character.getObjectBounds().intersects(tileBounds))
					return true;
			}
			else if (parsedRequirement[0] == "isPastPoint") {
				character = characterList[parsedRequirement[1]];
				mapName = parsedRequirement[2];
				var direction:String = parsedRequirement[3] + "";
				var point:int = parseInt(parsedRequirement[4]);
				
				if (character.getCurrentMap().getMapName() != mapName) return false;
				
				if (direction == "Left"){
					if (character.x < point) return true;
				}
				else if (direction == "Right"){
					if (character.x >= point) return true;
				}
				else if (direction == "Up"){
					if (character.y < point) return true;
				}
				else if (direction == "Down"){
					if (character.y >= point) return true;
				}
				return false;
			}
			else if (parsedRequirement[0] == "isInMap") {
				character = characterList[parsedRequirement[1]];
				mapName = parsedRequirement[2];
				
				if (character.getCurrentMap().getMapName() == mapName) 
					return true;
			}
			
			return false;
		}
		
		public function performTriggerEffect(parsedEffect:Array):void {
			
			if (parsedEffect[0] == "followChar") {
				var host:Character = this.getCharacter(parsedEffect[1] + "");
				var leader:Character = this.getCharacter(parsedEffect[2] + "");
				this.makeCharacterFollower(host, leader);
			}
			else if (parsedEffect[0] == "unfollowChar") {
				var follower:Follower = this.getCharacter(parsedEffect[1] + "Follower") as Follower;
				if (follower == null) 
					throw new Error("Trigger Error: UnfollowChar in CharacterManager given invalid follower name.");
				this.makeFollowerCharacter(follower);
			}
			
			else if (parsedEffect[0] == "animate") {
				// Effect for giving a given character a given animation
				
				var character:Character = this.getCharacter(parsedEffect[1] + "");
				var animation:String = parsedEffect[2];
				
				character.setAnimation(animation);
				character.freezeWalkAnimation();
			}
			else if (parsedEffect[0] == "unanimate") {
				character = this.getCharacter(parsedEffect[1] + "");
				character.resumeWalkAnimation();
			}
			else if (parsedEffect[0] == "forceChar") {
				character = this.getCharacter(parsedEffect[1] + "");
				if ((parsedEffect[2] + "") == "up") character.setUp(true);
				if ((parsedEffect[2] + "") == "down") character.setDown(true);
				if ((parsedEffect[2] + "") == "left") character.setLeft(true);
				if ((parsedEffect[2] + "") == "right") character.setRight(true);
			}
			else if (parsedEffect[0] == "stopChar") {
				character = this.getCharacter(parsedEffect[1] + "");
				character.stopCharacter();
			}
			
			else if (parsedEffect[0] == "pauseCommand") {
				character = this.getCharacter(parsedEffect[1] + "");
				character.pauseCommand();
			}
			else if (parsedEffect[0] == "resumeCommand") {
				character = this.getCharacter(parsedEffect[1] + "");
				character.resumeCommand();
			}
			
			else if (parsedEffect[0] == "pauseBehavior") {
				character = this.getCharacter(parsedEffect[1] + "");
				character.pauseBehavior();
			}
			else if (parsedEffect[0] == "eraseBehavior") {
				character = this.getCharacter(parsedEffect[1] + "");
				character.clearBehavior();
			}
			else if (parsedEffect[0] == "resumeBehavior") {
				character = this.getCharacter(parsedEffect[1] + "");
				character.resumeBehavior();
			}
			else if (parsedEffect[0] == "setBehavior") {
				var behaviorName:String = parsedEffect[1] + "";
				
				charBehaviorLibrary.activateBehavior(behaviorName);
			}
			
			else if (parsedEffect[0] == "setPossessable") {
				character = this.getCharacter(parsedEffect[1] +"");
				var possessStatus:int = parsedEffect[2];
				if (possessStatus < 0 || possessStatus > 2) 
					throw new Error("Cinematics Error: Invalid possession status given to setPossessable.");
				
				character.setPossessStatus(this, possessStatus);
			}
			
			else if (parsedEffect[0] == "drawCharGhostEffect") {
				character = this.getCharacter(parsedEffect[1] + "");
				drawCharGhostEffect(character);
			}
			else if (parsedEffect[0] == "removeCharGhostEffect") {
				character = this.getCharacter(parsedEffect[1] + "");
				removeCharGhostEffect(character);
			}
			
		}
		
		
		public function saveCharacterManager(saveFile:SaveFile):void {
			for each(var char:Character in characterList) {
				char.saveCharacter(saveFile);
				
				if (char.getPlayerControlled())
					saveFile.saveData("possessedCharacter", char.getName());
			}
		}
		
	}
	
}