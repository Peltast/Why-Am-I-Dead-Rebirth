package Characters 
{
	import AI.Behavior;
	import AI.CharacterAI;
	import AI.CharacterCommand;
	import Cinematics.CinematicManager;
	import Core.*;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import Interface.GUIManager;
	import Main;
	import flash.utils.Dictionary;
	import Maps.*;
	import Dialogue.*;
	import Props.AnimatedProp;
	import Props.Prop;
	import Setup.GameLoader;
	import Setup.SaveFile;
	import Sound.SoundManager;
	import SpectralGraphics.EffectTypes.ChangeHueEffect;
	import SpectralGraphics.SpectralImage;
	import SpectralGraphics.SpectralManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Character extends MapObject
	{
		private var characterLoader:Loader;
		protected var characterSheet:Bitmap;
		protected var alternateBounds:Dictionary;
		protected var animations:Dictionary; // Dictionary of Animation objects
		protected var currentAnimation:Animation;
		protected var lockWalkAnimations:Boolean;
		protected var alignment:String;
		protected var action:String;
		private var animationSpeed:int;
		protected var characterEffect:CharacterEffect;
		protected var shadow:Sprite;
		protected var shadowOffset:Point;
		
		protected var playerControlled:Boolean;
		protected var goUp:Boolean;
		protected var goDown:Boolean;
		protected var goLeft:Boolean;
		protected var goRight:Boolean;
		protected var characterIsStuck:Boolean;
		protected var fadeInCharacter:Boolean;
		protected var characterFadeAlpha:Number;
		protected var followerCopy:Follower;
		protected var currentMap:Map;
		
		protected var maxSpeed:int;
		protected var acceleration:Number;
		protected var deceleration:Number;
		protected var xSpeed:Number;
		protected var ySpeed:Number;
		protected var footstepFrequency:int;
		protected var footstepCounter:int;
		protected var footstepType:String;
		private var charName:String;
		
		private var speechBubble:SpeechBubble;
		protected var themeMusic:String;
		protected var charAI:CharacterAI;
		private var possessionStatus:int; // 0 = not possessable, 1 = half possessable, 2 = full possessable
		
		public function Character(characterImg:Bitmap, name:String, animations:Dictionary, xCoord:int, yCoord:int,
			bounds:Rectangle = null, collision:Boolean = true, maxSpeed:int = 6, acceleration:Number = 1, 
			deceleration:Number = 1, animationSpeed:int = 3, possessStat:int = 0, footstepType:String = "Footstep",
			charEffect:CharacterEffect = null, altBounds:Dictionary = null) 
		{
			this.animations = animations;
			currentAnimation = animations["Front Idle"];
			lockWalkAnimations = false;
			alignment = "";
			action = "Idle";
			objectBmp = new Bitmap(new BitmapData(currentAnimation.getWidth(), currentAnimation.getHeight()));
			
			super(this, objectBmp, collision, bounds, xCoord, yCoord);
			
			this.alternateBounds = altBounds;
			
			charName = name;
			this.playerControlled = false;
			this.animationSpeed = animationSpeed;
			this.maxSpeed = maxSpeed;
			this.acceleration = acceleration;
			this.deceleration = deceleration;
			this.possessionStatus = possessStat;
			this.characterEffect = charEffect;
			this.footstepFrequency = 6;
			this.footstepType = footstepType;
			xSpeed = 0;
			ySpeed = 0;
			footstepCounter = 0;
			
			charAI = new CharacterAI(this);
			
			characterSheet = characterImg;
			createActionBounds();
			createWideBounds();
			
			Game.getSingleton().addEventListener(Event.ENTER_FRAME, updateSpeed);
			
		}
		override protected function createActionBounds():void 
		{
			actionBounds = new Rectangle(
				currentBounds.x - 10, currentBounds.y - 25,
				currentBounds.width + 20, currentBounds.height + 50);
			if (charName == "Sarah") {
				actionBounds = new Rectangle(
					currentBounds.x - 20, currentBounds.y - 25,
					currentBounds.width + 40, currentBounds.height + 50);
			}
		}
		override protected function createWideBounds():void 
		{
			wideBounds = new Rectangle(
				currentBounds.x - 15, currentBounds.y - 15,
				currentBounds.width + 30, currentBounds.height + 30);
		}
		override public function intersectsObject(mapObject:MapObject, checkCollidable:Boolean):Boolean 
		{
			if (mapObject is Character) {
				var mapChar:Character = mapObject as Character;
				if (mapChar.isStuck() || this.isStuck()) return true;
			}
			else if (this.isStuck()) return false;
			
			if (mapObject.isCollidable() && checkCollidable) return true;
			else if (!checkCollidable) return true;
			return false;
		}
		
		public function addShadow(shadowBmp:Bitmap, offset:Point):void {
			this.shadow = new Sprite();
			shadowBmp.alpha = .2;
			shadow.addChild(shadowBmp);
			shadowOffset = offset;
			this.addChild(shadow);
		}
		public function addShadowSprite(shadowSprite:Sprite, shadowOffset:Point):void {
			this.shadow = shadowSprite;
			this.shadowOffset = shadowOffset;
			this.addChild(shadowSprite);
		}
		
		protected function updateSpeed(event:Event):void {
			
			var currentAcc:Point;
			var currentDec:Point;
			
			currentAcc = new Point(acceleration, acceleration);
			currentDec = new Point(deceleration, deceleration);
			
			if (goUp) { 
				ySpeed -= currentAcc.y;
				alignment = "Back";
				action = "Walk";
			}
			else if (!goUp && ySpeed < 0) { 
				ySpeed += currentDec.y;
				if (!playerControlled) ySpeed = 0;
				alignment = "Back";
				action = "Idle";
			}
			
			if (goDown && !goUp) {
				ySpeed += currentAcc.y;
				alignment = "Front";
				action = "Walk";
			}
			else if (!goDown && ySpeed > 0) { 
				ySpeed -= currentDec.y;
				if (!playerControlled) ySpeed = 0;
				alignment = "Front";
				action = "Idle";
			}
			
			if (goLeft) {
				xSpeed -= currentAcc.x;
				alignment = "Left";
				action = "Walk";
			}
			else if (!goLeft && xSpeed < 0){
				xSpeed += currentDec.x;
				if (!playerControlled) xSpeed = 0;
				alignment = "Left";
				action = "Idle";
			}
			
			if (goRight && !goLeft) {
				xSpeed += currentAcc.x;
				alignment = "Right";
				action = "Walk";
			}
			else if (!goRight && xSpeed > 0) { 
				xSpeed -= currentDec.x;
				if (!playerControlled) xSpeed = 0;
				alignment = "Right";
				action = "Idle";
			}
			
			var maxSpd:int;
			if (!playerControlled && maxSpeed > 4) maxSpd = 4;
			if (this is Follower) maxSpd = 6;
			else maxSpd = maxSpeed;
			
			if (xSpeed < -maxSpd) xSpeed = -maxSpd;
			if (xSpeed > maxSpd) xSpeed = maxSpd;
			if (ySpeed < -maxSpd) ySpeed = -maxSpd;
			if (ySpeed > maxSpd) ySpeed = maxSpd;
			
			if (!goUp && !goDown && ySpeed > 0) ySpeed -= deceleration;
			else if (!goUp && !goDown && ySpeed < 0) ySpeed += deceleration;
			else if (!goUp && !goDown) ySpeed = 0;
			
			if (!goLeft && !goRight && xSpeed > 0) xSpeed -= deceleration;
			else if (!goLeft && !goRight && xSpeed < 0) xSpeed += deceleration;
			else if (!goLeft && !goRight) xSpeed = 0;
			
			if (xSpeed == 0 && currentAnimation == animations["Left Walk"])
				action = "Idle";
			if (xSpeed == 0 && currentAnimation == animations["Right Walk"])
				action = "Idle";
			if (ySpeed == 0 && currentAnimation == animations["Back Walk"])
				action = "Idle";
			if (ySpeed == 0 && currentAnimation == animations["Front Walk"])
				action = "Idle";
			
			setWalkAnimation();
		}
		
		private function setWalkAnimation():void {
			if (lockWalkAnimations) return;
			
			var tempAction:String = action;
			if (characterEffect != null)
				if (characterEffect.getAnimationAction() != "")
					tempAction = characterEffect.getAnimationAction();
			
			var walkAnimation:String = alignment + " " + tempAction;
			if (walkAnimation == currentAnimation.getName()) return;
			
			if (animations[walkAnimation] != null)
				this.setAnimation(walkAnimation);
		}
		
		
		public function setCommand(command:CharacterCommand):void { charAI.setCommand(command); }
		public function pauseCommand():void { charAI.pauseCommand(); }
		public function resumeCommand():void { charAI.resumeCommand(); }
		public function clearCommand():void { charAI.clearCommand(); }
		
		public function setRandomBehavior(frequency:int, horizontalBound:int = 1, verticalBound:int = 1):void { 
			charAI.setRandomBehavior(frequency, null, horizontalBound, verticalBound); 
		}
		public function setPacingBehavior(frequency:int, horizontal:Boolean, length:int):void 
		{ 
			charAI.setPacingBehavior(frequency, horizontal, length); 
		}
		public function setRoutineBehavior(destinations:Array, destinationMaps:Array, freq:Array, loop:Boolean):void {
			charAI.setRoutineBehavior(destinations, destinationMaps, freq, loop);
		}
		public function setBehavior(behavior:Behavior):void { 
			charAI.setBehavior(behavior); 
			if (playerControlled) charAI.pauseBehavior();
		}
		public function clearBehavior():void { charAI.clearBehavior(); }
		public function pauseBehavior():void { charAI.pauseBehavior(); }
		public function resumeBehavior():void { charAI.resumeBehavior(); }		
		
		public function updateCharacter(currentMap:Map):void {
			if (currentAnimation == null) return;
			
			if (characterIsStuck) {
				if (currentMap.checkCharacterCollisions(this, getObjectBounds(), true).length < 1)
					characterIsStuck = false;
			}
			if (fadeInCharacter) {
				fadeCharacter();
				return;
			}
			
			if (this.playerControlled && footstepType != "") {
				footstepCounter++;
				
				if (footstepCounter > footstepFrequency
					&& (currentAnimation.getFrameIndex() == 2 || currentAnimation.getFrameIndex() == 5)) {
						footstepCounter = 0;
						SoundManager.getSingleton().playSound(footstepType, .5);
				}
			}
			
			updateCharacterSprite();
			updateShadowSprite();
			updateSpeechBubble();
			
			if (spectralOverlay != null)
				if (this.contains(spectralOverlay)) this.addChild(spectralOverlay);
			
			if (alternateBounds != null) {
				if (alternateBounds[currentAnimation.getName()] != null)
					currentBounds = alternateBounds[currentAnimation.getName()] as Rectangle;
				else
					currentBounds = regularBounds;
			}
			
			if (xSpeed == 0 && ySpeed == 0) {
				updateSpectralMask();
				return;
			}
			
			
			if (currentMap != null && numChildren > 0) {
				
				var child:DisplayObject = objectBmp;
				var bounds:Rectangle = getObjectBounds();
				
				var tempXSpeed:Number = xSpeed;
				var tempYSpeed:Number = ySpeed;
				this.x += xSpeed;
				this.y += ySpeed;
				
				var wideCollisions:Array = currentMap.checkWideCollision(this, false);
				var collisionArray:Array = currentMap.checkCollisionsFromList(this, wideCollisions);
				if (characterIsStuck) {
					for (var i:int = 0; i < collisionArray.length; i++) {
						if (collisionArray[i] is Character) {
							collisionArray.splice(i, 1);
							i--;
						}
					}
				}
				var closestDistances:Point = collisionDistance(collisionArray, xSpeed < 0, ySpeed < 0);
				
				if ((ySpeed > 0 && closestDistances.y <= ySpeed) || (ySpeed < 0 && closestDistances.y >= ySpeed))
					var closestY:Boolean = true;
				if ((xSpeed > 0 && closestDistances.x <= xSpeed) || (xSpeed < 0 && closestDistances.x >= xSpeed))
					var closestX:Boolean = true;
				
					
				if (collisionArray.length > 0 && closestY >= closestX) {
					this.y -= tempYSpeed;
					if (closestY) this.y += closestDistances.y;
					this.ySpeed = 0;
					collisionArray = currentMap.checkCollisionsFromList(this, wideCollisions);
					
					if (collisionArray.length > 0) {
						if(closestY) this.y -= closestDistances.y;
						
						this.x -= tempXSpeed;
						if (closestX) 
							this.x += closestDistances.x;
						collisionArray = currentMap.checkCollisionsFromList(this, wideCollisions);
						
						if (collisionArray.length > 0) {
							if (closestX) this.x -= closestDistances.x;
						}
					}
				}
				if (collisionArray.length > 0 && closestY < closestX) {
					this.x -= tempXSpeed;
					if (closestX) 
						this.x += closestDistances.x;
					this.xSpeed = 0;
					collisionArray = currentMap.checkCollisionsFromList(this, wideCollisions);
					
					if (collisionArray.length > 0) {
						if(closestX) this.x -= closestDistances.x;
						
						this.y -= tempYSpeed;
						if(closestY) this.y += closestDistances.y;
						collisionArray = currentMap.checkCollisionsFromList(this, wideCollisions);
						
						if (collisionArray.length > 0) {
							if (closestY) this.y -= closestDistances.y;
						}
					}
				}
				
			}
			
			this.updateSpectralMask();
		}
		
		private function updateSpeechBubble():void {
			if (speechBubble != null) {
				speechBubble.x = this.width / 2;
				speechBubble.y = -this.getZPosition() - this.getElevation() - 10;
				speechBubble.updateSpeechBubble();
				this.addChild(speechBubble);
			}
		}
		
		override public function setZPosition(newZ:int):void 
		{
			super.setZPosition(newZ);
			updateSpectralMask();
			updateShadowSprite();
		}
		
		private function updateShadowSprite():void {
			if (shadow != null) {
				shadow.x = shadowOffset.x;
				shadow.y = shadowOffset.y - this.getZPosition();
			}
		}
		private function updateCharacterSprite():void {
			charAI.updateCharAI();
			if (characterEffect != null)
				characterEffect.updateEffect(currentMap);
			
			currentAnimation.updateAnimation();
			
			if (objectBmp.width != currentAnimation.getWidth() || objectBmp.height != currentAnimation.getHeight()) {
				this.removeChild(objectBmp);
				objectBmp = new Bitmap(new BitmapData(currentAnimation.getWidth(), currentAnimation.getHeight()));
			}
			objectBmp.bitmapData.copyPixels(characterSheet.bitmapData, currentAnimation.getRectangle(), new Point(0, 0));
			objectBmp.y = -zPosition - elevation;
			this.addChild(objectBmp);
		}
		
		private function collisionDistance(collisionArray:Array, headingLeft:Boolean, headingUp:Boolean):Point {
			// This function is admittedly quite muddled, but it's more efficient than the previous form of
			// collision detection 'smoothing'.
			
			// ClosestX and ClosestY will determine the amount of leniency we can give the collision;
			//   that is to say, if a character is moving at a speed of 6 but is only 3 away from an object,
			//   we want them to then move those 3 first, rather than immediately come to a full stop.
			//   ClosestX or Y would hold that value of 3.
			if (!headingLeft) var closestX:int = int.MAX_VALUE;
			else closestX = -int.MAX_VALUE;
			
			if (!headingUp) var closestY:int = int.MAX_VALUE;
			else closestY = -int.MAX_VALUE;
			
			for (var i:int = 0; i < collisionArray.length; i++) {
				// Find the boundary rectangle of the collided object.
				var tempBounds:Rectangle;
				if (collisionArray[i] is Tile) {
					var tempTile:Tile = collisionArray[i] as Tile;
					// Diagonal tiles cannot be handled with this kind of approach, so we just return a non-smoothed value.
					if (tempTile.getTileType() != 5 && tempTile.getTileType() != 0)
						return new Point(0, 0);
					tempBounds = tempTile.getTileBounds();
				}
				else if (collisionArray[i] is Prop) {
					var tempProp:Prop = collisionArray[i] as Prop;
					tempBounds = tempProp.getObjectBounds();
				}
				else if (collisionArray[i] is Character) {
					var tempChar:Character = collisionArray[i] as Character;
					tempBounds = tempChar.getObjectBounds();
				}
				
				var currentX:int;
				var currentY:int;
				var currentCharBounds:Rectangle = getObjectBounds();
				
				currentCharBounds.x -= xSpeed;
				if (!currentCharBounds.intersects(tempBounds)) {
					
					// If we are to the left of the object, currentX is calculated differently than if we are to the right.
					// If we are at the same x position, there is obviously no leniency.
					if (currentCharBounds.x < tempBounds.x)
						currentX = tempBounds.x - (currentCharBounds.x + currentCharBounds.width);
					else if (currentCharBounds.x > tempBounds.x)
						currentX = (tempBounds.x + tempBounds.width) - currentCharBounds.x;
					else currentX = 0;
					
					if (!headingLeft && currentX < closestX) closestX = currentX;
					else if (headingLeft && currentX > closestX) closestX = currentX;
					
				}
				currentCharBounds.x += xSpeed;
				
				currentCharBounds.y -= ySpeed;
				if (!currentCharBounds.intersects(tempBounds)) {
					
					if (currentCharBounds.y < tempBounds.y)
						currentY = tempBounds.y - (currentCharBounds.y + currentCharBounds.height);
					else if (currentCharBounds.y > tempBounds.y)
						currentY = (tempBounds.y + tempBounds.height) - currentCharBounds.y;
					else currentY = 0;
					
					if (!headingUp && currentY < closestY) closestY = currentY;
					else if (headingUp && currentY > closestY) closestY = currentY;
					
				}
				currentCharBounds.y += ySpeed;
				
			}
			return new Point(closestX, closestY);
		}
		
		public function addSpeechBubble():void {
			this.speechBubble = new SpeechBubble();
			this.addChild(speechBubble);
		}
		public function removeSpeechBubble():void {
			if (speechBubble == null) return;
			
			if (this.contains(speechBubble))
				this.removeChild(speechBubble);
			speechBubble = null;
		}
		
		public function handleTransition(transition:MapTransition):void {
			updateShadowSprite();
			checkTransitionAfterCollision();
			if (characterEffect != null)
				characterEffect.handleTransition(this, transition);
			if (!playerControlled) {
				characterFadeAlpha = 0;
				fadeInCharacter = true;
				action = "Idle";
				setWalkAnimation();
				updateCharacterSprite();
			}
		}
		private function checkTransitionAfterCollision():void {
			var transCollision:Array = currentMap.checkCharacterCollisions(this, getObjectBounds(), true);
			if (transCollision.length >= 1) {
				for each(var character:Character in transCollision)
					character.setCharacterStuck(true);
				characterIsStuck = true;
			}
			else
				characterIsStuck = false;
		}
		public function setCharacterStuck(b:Boolean):void {
			characterIsStuck = b;
		}
		
		private function fadeCharacter():void {
			characterFadeAlpha += .05;
			objectBmp.alpha = characterFadeAlpha;
			this.removeChild(objectBmp);
			this.addChild(objectBmp);
			if (characterFadeAlpha >= 1)
				fadeInCharacter = false;
		}
		
		
		public function faceCharacter(character:Character):void {
			var xDif:int = this.x - character.x;
			var yDif:int = this.y - character.y;
			
			if (xDif > 0 && Math.abs(xDif) >= Math.abs(yDif)) this.setAnimation("Left Idle");
			else if (xDif < 0 && Math.abs(xDif) >= Math.abs(yDif)) this.setAnimation("Right Idle");
			
			else if (yDif > 0 && Math.abs(yDif) >= Math.abs(xDif)) this.setAnimation("Back Idle");
			else if (yDif < 0 && Math.abs(yDif) >= Math.abs(xDif)) this.setAnimation("Front Idle");
			
			this.xSpeed = 0;
			this.ySpeed = 0;
		}
		
		public function freezeWalkAnimation():void {
			lockWalkAnimations = true;
		}
		public function resumeWalkAnimation():void {
			lockWalkAnimations = false;
		}
		public function setAnimation(animName:String):void {
			if (animName.indexOf("Left") >= 0) this.alignment = "Left";
			else if (animName.indexOf("Right") >= 0) this.alignment = "Right";
			else if (animName.indexOf("Front") >= 0) this.alignment = "Front";
			else if (animName.indexOf("Back") >= 0) this.alignment = "Back";
			
			if (animations[animName] != null) {
				if (animations[animName] is OneOffAnimation)
					animations[animName].resetAnimation();
				currentAnimation = animations[animName];
			}
		}
		public function removeAnimation():void {
			currentAnimation = null;
		}
		public function setImage(newBmp:Bitmap):void {
			this.removeChild(objectBmp);
			this.addChild(newBmp);
		}
		public function resetEffect():void {
			if (characterEffect != null)
				characterEffect.resetEffect();
		}
		
		public function mindRead():SpectralState {
			if (this.charName != "Ghost") return null;
			
			var mindReadArray:Array = currentMap.checkCharacterCollisions(this, getActionBounds(), false);
			var closestChar:Character = this.findClosestCharacter(mindReadArray);
			
			var mindreadTheme:String = SpectralManager.getSingleton().getMindReadTheme(closestChar);
			if (mindreadTheme != null && mindreadTheme != "") {
				SoundManager.getSingleton().stopAllSounds();
				SoundManager.getSingleton().fadeInSound
					(SpectralManager.getSingleton().getMindReadTheme(closestChar), 0, 1, .01, true);
			}
			
			if (closestChar == null) return null;
			if (SpectralManager.getSingleton().getSpecGraphic(closestChar.getName() + " Mindread") != null) {
				return new SpectralState(closestChar.getName() + " Mindread", true)
			}
			return null;
		}
		public function endMindRead():void {
			SoundManager.getSingleton().fadeOutAllSounds(.01);
			var mapSounds:Dictionary = currentMap.getMapSounds();
			for (var key:String in mapSounds)
				if (!SoundManager.getSingleton().isPlayingSound(key) && key != "")
					SoundManager.getSingleton().fadeInSound(key, 0, 1, .01, true);
		}
		private function findClosestCharacter(charArray:Array):Character {
			var closestDistance:int = int.MAX_VALUE;
			var closestCharacter:Character;
			for (var i:int = 0; i < charArray.length; i++) {
				var tempChar:Character = charArray[i] as Character;
				var distance:int = Math.abs(this.x - tempChar.x) + Math.abs(this.y - tempChar.y);
				
				if (distance < closestDistance && tempChar != this) {
					closestDistance = distance;
					closestCharacter = tempChar;
				}
			}
			return closestCharacter;
		}
		
		public function setThemeTrack(themeTitle:String):void { themeMusic = themeTitle; }
		public function getTheme():String { return themeMusic; }
		
		public function setCurrentMap(map:Map):void { currentMap = map; }
		public function getCurrentMap():Map { return currentMap; }
		
		public function setControlled(player:Player, bool:Boolean):void { playerControlled = bool; }
		public function setPossessStatus(charMan:CharacterManager, newPS:int):void { possessionStatus = newPS; }
		
		public function getPlayerControlled():Boolean { return playerControlled; }
		public function getName():String { return charName; }
		public function getXSpeed():int { return xSpeed; }
		public function getYSpeed():int { return ySpeed; }
		public function stopXSpeed():void { xSpeed = 0; }
		public function stopYSpeed():void { ySpeed = 0; }
		public function getAlignment():String { return alignment; }
		public function getPossessStatus():int { return possessionStatus; }
		public function getCharEffect():CharacterEffect { return characterEffect; }
		public function isStuck():Boolean { return characterIsStuck; }
		
		public function stopCharacter():void {
			setUp(false);
			setDown(false);
			setLeft(false);
			setRight(false);
		}
		public function setUp(b:Boolean):void { goUp = b;}
		public function setDown(b:Boolean):void { goDown = b;}
		public function setLeft(b:Boolean):void { goLeft = b;}
		public function setRight(b:Boolean):void { goRight = b; }
		
		public function removeFollowerCopy():void {
			followerCopy = null;
			this.addChild(shadow);
		}
		public function createFollower(leader:Character):Follower {
			if (followerCopy != null) return null;
			
			followerCopy = new Follower(characterSheet, this.charName + "Follower", this.animations, this.x, this.y,
				this.currentBounds, this.maxSpeed, this.animationSpeed, this, leader);
			if (this.shadow != null)
				followerCopy.addShadowSprite(shadow, shadowOffset);
			return followerCopy;
		}
		
		
		public function saveCharacter(saveFile:SaveFile):void {
			if (this is Follower) 
				return;
			if (this.currentMap == null)
				return;
			
			var charX:int = this.x;
			var charY:int = this.y;
			var zPos:int = zPosition;
			var mapName:String = currentMap.getMapName();
			var possStat:int = possessionStatus;
			saveFile.saveData(charName + "x", charX);
			saveFile.saveData(charName + "y", charY);
			saveFile.saveData(charName + "z", zPos);
			saveFile.saveData(charName + "posStatus", possStat);
			saveFile.saveData(charName + "alignment", alignment);
			if(currentMap.hasCharacter(this))
				saveFile.saveData(charName + "map", mapName);
			else
				saveFile.saveData(charName + "map", null);
			
			if (this.playerControlled) 
				saveFile.saveData(charName + "controlled", 1);
			else
				saveFile.saveData(charName + "controlled", null);
			
			if (followerCopy != null) {
				saveFile.saveData(charName + "follower", "true");
				followerCopy.saveFollower(saveFile);
			}
			else saveFile.saveData(charName + "follower", "false");
			charAI.saveCharAI(saveFile);
		}
		public function loadCharacter(saveFile:SaveFile, mapManager:MapManager, 
										characterManager:CharacterManager, charList:Dictionary):void {
			if (this is Follower)
				return;
				
			if (saveFile.loadData(charName + "follower") == "true") {
				followerCopy = constructFollower(saveFile, mapManager, characterManager);
				charList[charName + "Follower"] = followerCopy;
				this.currentMap.removeCharacter(this);
				return;
			}
			x = parseInt(saveFile.loadData(charName + "x") + "");
			y = parseInt(saveFile.loadData(charName + "y") + "");
			zPosition = parseInt(saveFile.loadData(charName + "z") + "");
			alignment = saveFile.loadData(charName + "alignment") + "";
			
			currentMap = mapManager.getMap(saveFile.loadData(charName + "map") + "");
			if (currentMap != null)
				currentMap.addCharacter(this);
			possessionStatus = parseInt(saveFile.loadData(charName + "posStatus") + "");
			
			if (saveFile.loadData(charName + "controlled") != null)
				playerControlled = true;
			else 
				playerControlled = false;
			
			charAI.loadCharAI(saveFile, mapManager);
		}
		
		private function constructFollower(saveFile:SaveFile, mapManager:MapManager, characterManager:CharacterManager):Follower {
			var followerX:int = parseInt(saveFile.loadData(charName + "followerX") + "");
			var followerY:int = parseInt(saveFile.loadData(charName + "followerY") + "");
			var followerZ:int = parseInt(saveFile.loadData(charName + "followerZ") + "");
			var followerMap:Map = mapManager.getMap(saveFile.loadData(charName + "followerMap") + "");
			var followerLeader:Character = characterManager.getCharacter(saveFile.loadData(charName + "followerLeader") + ""); 
			
			if (saveFile.loadData(followerLeader.getName() + "follower") == "true") {
				
				var leader:Character = characterManager.getCharacter(followerLeader.getName() + "Follower");
				if (leader == null)
					leader = characterManager.getCharacter(followerLeader.getName());
				followerLeader = leader;
			}
			
			var tempFollower:Follower = new Follower(characterSheet, charName, animations, followerX, followerY,
													currentBounds, maxSpeed, animationSpeed, this, followerLeader)
			tempFollower.addShadowSprite(shadow, shadowOffset);
			followerMap.addCharacter(tempFollower);
			return tempFollower;
		}
		
	}

}