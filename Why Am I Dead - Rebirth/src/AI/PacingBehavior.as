package AI 
{
	import Characters.Character;
	import Core.Game;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Maps.Map;
	import Misc.Tuple;
	import Props.Prop;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class PacingBehavior extends Behavior
	{
		private var firstLength:int;
		private var lengthA:int;
		private var lengthB:int;
		private var horizontal:Boolean;
		private var firstTime:Boolean;
		private var direction:int;
		
		public function PacingBehavior(host:Character, origin:Tuple, frequency:int, horizontal:Boolean, length:int) 
		{
			super(this, host, origin, frequency);
			this.firstLength = length;
			this.horizontal = horizontal;
			this.firstTime = true;
			this.direction = -1;
			
			// Some math is needed to make sure that the character's pacing makes sense given the amount of space they
			// have around them.
			
			var openSpaceA:int;
			var openSpaceB:int;
			var currentTile:Point = host.getNearestTilePoint();
			var tempTile:Point = currentTile;
			
			// We first use two for-loops to figure out how much free space (either to the left and right, or up and down)
			// there is around the character.
			
			for (var i:int = 0; i < length; i++) {
				if (horizontal) tempTile.x--;
				else tempTile.y--;
				
				var tS:int = Game.getTileSize();
				var proxyObj:Prop = new Prop(null, "", true, tempTile.x * tS, tempTile.y * tS, new Rectangle(0, 0, tS, tS));
				if (host.getCurrentMap().checkNormalCollision(proxyObj, true))
						openSpaceA++;
				else break;
			}
			
			tempTile = currentTile;
			
			for (var j:int = 0; j < length; j++) {
				if (horizontal) tempTile.x++;
				else tempTile.y++;
				
				proxyObj = new Prop(null, "", true, tempTile.x * tS, tempTile.y * tS, new Rectangle(0, 0, tS, tS));
				if (host.getCurrentMap().checkNormalCollision(proxyObj, true))
						openSpaceB++;
				else break;
			}
			
			// Then based on that, we give the behavior two int values, one for each direction.
			
			if (length % 2 == 0 && openSpaceA == length && openSpaceB == length) {
				lengthA = length / 2;
				lengthB = length / 2;
			}
			else if (openSpaceA == length && openSpaceB == length) {
				lengthA = Math.ceil(length / 2);
				lengthB = Math.floor(length / 2);
			}
			else if (openSpaceA == length) {
				lengthB = openSpaceB;
				lengthA = length - lengthB;
			}
			else if (openSpaceB == length) {
				lengthA = openSpaceA;
				lengthB = length - lengthA;
			}
			else {
				lengthA = openSpaceA;
				lengthB = openSpaceB;
			}
			
			if (this.origin == null || origin.latter == null) {
				
				this.origin = new Tuple(host.getNearestTilePoint(), host.getCurrentMap());
			}
		}
		
		override public function updateBehavior():void 
		{
			super.updateBehavior();
			if (charAI == null) return;
			
			if (timer > frequency) {
				
				timer = 0;
				var currentTile:Point = host.getNearestTilePoint();
				var destination:Point = currentTile;
				
				if (origin != null) {
					var originPt:Point = origin.former as Point;
					var originMap:Map = origin.latter as Map;
					
					if ((horizontal && (currentTile.x > originPt.x + lengthB + lengthA || currentTile.x < originPt.x - lengthB - lengthA)) ||
						(!horizontal && (currentTile.y > originPt.y + lengthB + lengthA || currentTile.y < originPt.y - lengthB - lengthA)) ||
						host.getCurrentMap() != originMap) {
							
							currentCommand = new CharacterCommand(host, originPt, originMap, false);
							charAI.setCommand(currentCommand);
							return;
					}
				}
				
				if (direction < 0) {
					if (firstTime){
						var delta:int = lengthA;
						firstTime = false;
					}
					else delta = lengthA + lengthB;
					
					if (horizontal) destination.x -= delta;
					else destination.y -= delta;
					
					currentCommand = new CharacterCommand(host, destination, null, false);
					charAI.setCommand(currentCommand);
					direction = -direction;
				}
				else if (direction > 0) {
					if (firstTime){
						delta = lengthB;
						firstTime = false;
					}
					else delta = lengthA + lengthB;
					
					if (horizontal) destination.x += delta;
					else destination.y += delta;
					
					currentCommand = new CharacterCommand(host, destination, null, false);
					charAI.setCommand(currentCommand);
					direction = -direction;
				}
			}
			
			if (currentCommand == null)
				timer++;
			else if (!currentCommand.commandRunning())
				timer++;
		}
		
		public function isHorizontal():Boolean { return horizontal; }
		public function getLength():int { return firstLength; }
		
		override public function saveBehavior(saveFile:SaveFile, charName:String):void 
		{
			super.saveBehavior(saveFile, charName);
			
			var horizontalString:String;
			if (horizontal) horizontalString = "true";
			else horizontalString = "false";
			
			saveFile.saveData(charName + " behaviorType", "Pacing");
			saveFile.saveData(charName + " pacingHorizontal", horizontalString);
			saveFile.saveData(charName + " pacingLength", firstLength);
		}
		
	}

}