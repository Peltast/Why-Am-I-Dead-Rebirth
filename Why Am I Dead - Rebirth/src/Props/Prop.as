package Props 
{
	import Characters.Animation;
	import Characters.Character;
	import Characters.CharacterManager;
	import Cinematics.Trigger;
	import Core.Game;
	import Dialogue.*;
	import flash.display.*
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import Interface.GUIManager;
	import Maps.Map;
	import Maps.MapObject;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Prop extends MapObject
	{
		protected var propTag:String;
		protected var propLoader:Loader;
		
		protected var genericSuccess:Dialogue; // generic success dialogue used when there isn't a character specific one
		protected var genericFail:Dialogue; // generic fail dialogue used when there isn't a character specific one
		protected var successDialogues:Dictionary; // dialogues for when a character is permitted to use prop
		protected var failDialogues:Dictionary;  // dialogues for when a character cannot use prop eg "this door is locked"
		
		protected var fadeInPace:Number;
		protected var permissions:Vector.<String>; // vector of characters that are allowed to use prop effect
		protected var active:Boolean;
		protected var staticProp:Boolean;
		
		public function Prop(propImg:Bitmap, propTag:String, collidable:Boolean = true, xCoord:Number = 0, yCoord:Number = 0,
			bounds:Rectangle = null, permissions:Vector.<String> = null, sucDia:Dialogue = null, failDia:Dialogue = null) 
		{
			if (bounds == null && propImg == null)
				bounds = new Rectangle(0, 0, 32, 32);
			else if (bounds == null)
				bounds = new Rectangle(0, 0, propImg.width, propImg.height);
			
			super(this, propImg, collidable, bounds, xCoord, yCoord);
			
			createActionBounds();
			createWideBounds();
			
			this.propTag = propTag;
			this.permissions = permissions;
			this.genericSuccess = sucDia;
			this.genericFail = failDia;
			this.successDialogues = new Dictionary();
			this.failDialogues = new Dictionary();
			this.active = true;
			this.staticProp = true;
			
			if (permissions == null){
				this.permissions = new Vector.<String>();
				this.permissions.push
					("Ghost", "Cricket", "Randy", "Lucille", "Ted", "Morgan", "Iblis", "Rose", "Orval");
			}
			
		}
		override protected function createActionBounds():void 
		{
			actionBounds = new Rectangle(
				currentBounds.x - 10, currentBounds.y - 15,
				currentBounds.width + 20, currentBounds.height + 30);
		}
		override protected function createWideBounds():void 
		{
			wideBounds = new Rectangle(
				currentBounds.x - 15, currentBounds.y - 15,
				currentBounds.width + 30, currentBounds.height + 30);
		}
		
		public function updateProp():void {
			if (this.alpha < 1)
				this.alpha += fadeInPace;
			if (this.alpha >= 1) {
				this.alpha = 1;
				fadeInPace = 0;
			}
			this.updateSpectralMask();
		}
		
		public function isCharacterPermitted(charName:String):Boolean {
			if (!active) return false;
			
			for (var i:int = 0; i < permissions.length; i++) {
				if (permissions[i] == charName) return true;
			}
			if (charName.indexOf("Ghost") >= 0) {
				var charNameMinusGhost:String = charName.replace("Ghost", "");
				return isCharacterPermitted(charNameMinusGhost);
			}
			return false;
		}
		protected function removeCharPermission(charName:String):void {
			for (var i:int = 0; i < permissions.length; i++) {
				if (permissions[i] == charName) permissions.slice(i, 1);
			}
		}
		protected function addCharPermission(charName:String):void {
			permissions.push(charName);
		}
		
		public function setPermissions(permissions:Vector.<String>):void {
			this.permissions = permissions;
		}
		
		public function hasEffect():Boolean {
			return false;
		}
		public function hasDialogue(charName:String):Boolean {
			if (successDialogues[charName] != null) return true;
			else if (failDialogues[charName] != null) return true;
			else if (genericSuccess != null) return true;
			else if (genericFail != null) return true;
			return false;
		}
		public function setSuccessDialogue(dialogue:Dialogue):void {
			this.genericSuccess = dialogue;
		}
		public function setFailDialogue(dialogue:Dialogue):void {
			this.genericFail = dialogue;
		}
		public function setCharDialogue(charName:String, success:Boolean, dialogue:Dialogue):void {
			if (success)
				successDialogues[charName] = dialogue;
			else
				failDialogues[charName] = dialogue;
		}
		protected function getDialogue(charName:String):Dialogue {
			if (isCharacterPermitted(charName)) {
				if (successDialogues[charName] != null) 
					return successDialogues[charName];
				else return genericSuccess;
			}
			else {
				if (failDialogues[charName] != null) return failDialogues[charName];
				else return genericFail;
			}
			
			return null;
		}
		public function isActive():Boolean { return active; }
		public function setStatic(b:Boolean):void { staticProp = b; }
		public function isStatic():Boolean { return staticProp; }
		public function getPropTag():String { return propTag; }
		public function getPropCoords():Point {
			var tileSize:int = Game.getTileSize();
			return new Point(this.x / tileSize, this.y / tileSize);
		}
		
		override public function intersectsObject(mapObject:MapObject, checkCollidable:Boolean):Boolean 
		{
			if (mapObject.isCollidable() && checkCollidable) return true;
			else if (!checkCollidable) return true;
			return false;
		}
		
		public function effect(character:Character, isPlayer:Boolean = true, charName:String = ""):void {
			if (charName == "") charName = character.getName();
			
			var dialogue:Dialogue = this.getDialogue(charName);
			if (dialogue == null) return;
			
			GUIManager.getSingleton().startDialogue(dialogue);
			character.setUp(false);
			character.setDown(false);
			character.setLeft(false);
			character.setRight(false);
		}
		public function fadeInProp(fadePace:Number):void {
			fadeInPace = fadePace;
			this.alpha = 0;
		}
		
		public function listenToTrigger(parsedRequirement:Array):Boolean {
			
			return false;
		}
		
		public function performTriggerEffect(parsedEffect:Array):void {
			
			if (parsedEffect[0] == "changePermission") {
				var charName:String = parsedEffect[2];
				var boolean:Boolean; 
				if (parsedEffect[3] == "true") boolean = true;
				else boolean = false;
				
				if (charName != null) {
					if (boolean)
						permissions.push(charName);
					else
						removeCharPermission(charName);
				}
			}
			
		}
		
		public function saveProp(propTag:String, saveFile:SaveFile):void {
			if (genericSuccess != null) {
				var sucDiaTitle:String = genericSuccess.getTitle();
				saveFile.saveData(propTag + " successdialogue", sucDiaTitle);
			}
			if (genericFail != null) {
				var failDiaTitle:String = genericFail.getTitle();
				saveFile.saveData(propTag + " faildialogue", failDiaTitle);
			}
			
			var successDialogueStrings:Vector.<Object> = new Vector.<Object>();
			for (var key:String in successDialogues) {
				successDialogueStrings.push(key);
				var charDialogue:Dialogue = successDialogues[key] as Dialogue;
				if (charDialogue == null) continue;
				saveFile.saveData(propTag + " successKey" + key, charDialogue.getTitle());
			}
			saveFile.saveData(propTag + " successDialogueStrings", successDialogueStrings);
			
			var failDialogueStrings:Vector.<String> = new Vector.<String>();
			for (key in failDialogues) {
				failDialogueStrings.push(key);
				charDialogue = failDialogues[key] as Dialogue;
				if (charDialogue == null) continue;
				saveFile.saveData(propTag + " failKey" + key, charDialogue.getTitle());
			}
			saveFile.saveData(propTag + " failDialogueStrings", failDialogueStrings);
			
			var permissionClone:Vector.<String> = new Vector.<String>();
			for each(var perm:String in permissions)
				permissionClone.push(perm);
			saveFile.saveData(propTag + " permissions", permissionClone);
			
		}
		public function loadProp(propTag:String, saveFile:SaveFile):void {
			if (saveFile.loadData(propTag + " successdialogue") != null)
				genericSuccess = DialogueLibrary.getSingleton().retrieveDialogue
					("" + saveFile.loadData(propTag + " successdialogue"));
			if (saveFile.loadData(propTag + " faildialogue") != null)
				genericFail = DialogueLibrary.getSingleton().retrieveDialogue
					("" + saveFile.loadData(propTag + " faildialogue"));
			
			
			var successDialogueStrings:Vector.<Object> = saveFile.loadData(propTag + " successDialogueStrings") as Vector.<Object>;
			
			for each(var dialogueString:String in successDialogueStrings) {
				if (saveFile.loadData(propTag + " successKey" + dialogueString) == null) continue;
				successDialogues[dialogueString] = DialogueLibrary.getSingleton().retrieveDialogue
													("" + saveFile.loadData(propTag + " successKey" + dialogueString));
			}
			
			var failDialogueStrings:Vector.<String> = saveFile.loadData(propTag + " failDialogueStrings") as Vector.<String>;
			
			for each(dialogueString in failDialogueStrings) {
				if (saveFile.loadData(propTag + " failKey" + dialogueString) == null) continue;
				failDialogues[dialogueString] = DialogueLibrary.getSingleton().retrieveDialogue
													("" + saveFile.loadData(propTag + " failKey" + dialogueString));
			}
			
			var permissionStrings:Vector.<String> = saveFile.loadData(propTag + " permissions") as Vector.<String>;
			if (permissionStrings != null) {
				
				permissions = new Vector.<String>();
				for each(var permissionString:String in permissionStrings)
					permissions.push(permissionString);
			}
		}
		
	}

}