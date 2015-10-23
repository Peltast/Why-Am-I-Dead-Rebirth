package AI 
{
	import Characters.Character;
	import Core.Game;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Maps.Map;
	import Maps.Tile;
	import Misc.Tuple;
	import Props.Prop;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class RandomBehavior extends Behavior
	{
		private var horizontalBound:int;
		private var verticalBound:int;
		private var startPoint:Point;
		
		public function RandomBehavior
			(host:Character, origin:Tuple, frequency:int, horizontalBound:int, verticalBound:int) 
		{
			super(this, host, origin, frequency);
			this.horizontalBound = horizontalBound;
			this.verticalBound = verticalBound;
			this.startPoint = origin.former as Point;
			
			if (this.origin == null) {
				
				origin = new Tuple(host.getNearestTilePoint(), host.getCurrentMap());
			}
			
		}
		
		override public function updateBehavior():void 
		{
			super.updateBehavior();
			if (charAI == null) return;
			
			if (horizontalBound == 0 && verticalBound == 0) return;
			
			if (timer > frequency) {
				// If the timer is set off, create a new command that has the character walk one tile in a random direction.
				timer = 0;
				
				var currentPoint:Point = host.getNearestTilePoint();
				var nextPoint:Point;
				var tries:int = 0;
				
				if (origin != null) {
					var originPt:Point = origin.former as Point;
					var originMap:Map = origin.latter as Map;
					
					if (currentPoint.x > originPt.x + horizontalBound || currentPoint.x < originPt.x - horizontalBound ||
						currentPoint.y > originPt.y + verticalBound || currentPoint.y < originPt.y - verticalBound ||
						host.getCurrentMap() != origin.latter) {
							
							currentCommand = new CharacterCommand(host, originPt, originMap, false);
							charAI.setCommand(currentCommand);
							return;
					}
				}
				
				while (true) {
					tries++;
					if (tries > 10) {
						timer = -frequency;
						return;
					}
					
					var dice:int = Math.ceil(Math.random() * 4);
					var nextTile:Tile;
					
					if (dice == 1) {
						nextPoint = new Point(currentPoint.x, currentPoint.y - 1);
						nextTile = host.getCurrentMap().getTile(currentPoint.x, currentPoint.y - 1);
					}
					else if (dice == 2) {
						nextPoint = new Point(currentPoint.x + 1, currentPoint.y);
						nextTile = host.getCurrentMap().getTile(currentPoint.x + 1, currentPoint.y);
					}
					else if (dice == 3) {
						nextPoint = new Point(currentPoint.x, currentPoint.y + 1);
						nextTile = host.getCurrentMap().getTile(currentPoint.x, currentPoint.y + 1);
					}
					else if (dice == 4) {
						nextPoint = new Point(currentPoint.x - 1, currentPoint.y);
						nextTile = host.getCurrentMap().getTile(currentPoint.x - 1, currentPoint.y);
					}
					
					if (nextTile == null) continue;
					
					var tS:int = Game.getTileSize();
					var proxyObj:Prop = new Prop(null, "", true, nextTile.x * tS, nextTile.y * tS, new Rectangle(0, 0, tS, tS));
					if (host.getCurrentMap().checkNormalCollision(proxyObj, true).length > 0 
						|| nextTile.getTileType() != 5)
							continue;
					if (Math.abs(startPoint.x - nextPoint.x) > horizontalBound) continue;
					if (Math.abs(startPoint.y - nextPoint.y) > verticalBound) continue;
					
					currentCommand = new CharacterCommand(host, nextTile.getTileCoords(), null, false);
					charAI.setCommand(currentCommand);
					break;
				}
			}
			
			if (currentCommand == null)
				timer++;
			else if (!currentCommand.commandRunning())
				// If there is no command running, add to the timer.
				timer++;
		}
		
		override public function saveBehavior(saveFile:SaveFile, charName:String):void 
		{
			super.saveBehavior(saveFile, charName);
			
			saveFile.saveData(charName + " behaviorType", "Random");
			saveFile.saveData(charName + " randomHorBound", horizontalBound);
			saveFile.saveData(charName + " randomVerBound", verticalBound);
		}
		
	}

}