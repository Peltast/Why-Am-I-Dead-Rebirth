package Props 
{
	import Characters.Animation;
	import Characters.Character;
	import flash.geom.Point;
	import Main;
	import Dialogue.*;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.NetStreamPlayTransitions;
	import flash.net.URLRequest;
	import Interface.GUIManager;
	import Maps.Map;
	import Maps.MapManager;
	import Maps.MapTransition;
	import Maps.Tile;
	import Setup.SaveFile;
	import Sound.SoundManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class DoorProp extends Prop
	{
		private var mapManager:MapManager;
		private var endMap:Map;
		private var endX:int;
		private var endY:int;
		private var checkGhostVisited:Boolean;
		
		public function DoorProp(mapManager:MapManager, propImg:Bitmap, propTag:String, collidable:Boolean = true,
									xCoord:Number = 0, yCoord:Number = 0, endMap:Map = null, endX:int = 0, endY:int = 0,
									permissions:Vector.<String> = null, sucDia:Dialogue = null, failDia:Dialogue = null,
									checkGhostVisited:Boolean = true) 
		{
			var bitMap:Bitmap = propImg;
			this.addChild(bitMap);
			
			super(propImg, propTag, collidable, xCoord, yCoord, null, permissions, sucDia, failDia);
				
			this.mapManager = mapManager;
			this.endX = endX;
			this.endY = endY;
			this.genericFail = null;
			this.endMap = endMap;
			this.checkGhostVisited = checkGhostVisited;
			
			failDialogues["Alton"] = DialogueLibrary.getSingleton().retrieveDialogue("DoorFail");
			failDialogues["Marcurio"] = DialogueLibrary.getSingleton().retrieveDialogue("DoorFail");
			failDialogues["Xu"] = DialogueLibrary.getSingleton().retrieveDialogue("DoorFail");
			failDialogues["Ferdinand"] = DialogueLibrary.getSingleton().retrieveDialogue("DoorFail");
			failDialogues["Donovan"] = DialogueLibrary.getSingleton().retrieveDialogue("DoorFail");
			failDialogues["Garv"] = DialogueLibrary.getSingleton().retrieveDialogue("DoorFail");
			failDialogues["Darryl"] = DialogueLibrary.getSingleton().retrieveDialogue("DoorFail");
			failDialogues["Quella"] = DialogueLibrary.getSingleton().retrieveDialogue("DoorFail");
			failDialogues["Gwen"] = DialogueLibrary.getSingleton().retrieveDialogue("DoorFail");
			failDialogues["Cat"] = DialogueLibrary.getSingleton().retrieveDialogue("DoorCatFail");
			
		}
		public function getEndMap():Map { return endMap; }
		public function getEndCoord():Point { return new Point(endX, endY); }
		override public function hasEffect():Boolean 
		{
			return true;
		}
		
		override public function effect(character:Character, isPlayer:Boolean = true, charName:String = ""):void 
		{
			if (charName == "") charName = character.getName();
			
			if (!isCharacterPermitted(charName)) {
				var dialogue:Dialogue = getDialogue(charName);
				if (dialogue != null) GUIManager.getSingleton().startDialogue(dialogue);
				if (charName != "Ghost")
					return;
			}
			
			if (endMap == null )
				return;
			
			var currentMap:Map = character.getCurrentMap();
			
			if (isPlayer && character.isCollidable())
				SoundManager.getSingleton().playSound("Door", 1);
				
			mapManager.executeTransition(new MapTransition
				(currentMap, currentMap.getTile(0, 0), endMap,
				endMap.getTile(endX,endY), false), character, isPlayer);
		}
		
		override public function saveProp(propTag:String, saveFile:SaveFile):void 
		{
			super.saveProp(propTag, saveFile);
		}
		override public function loadProp(propTag:String, saveFile:SaveFile):void 
		{
			super.loadProp(propTag, saveFile);
		}
		
	}

}