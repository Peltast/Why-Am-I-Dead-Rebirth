package AI 
{
	import Characters.Character;
	import Core.Game;
	import flash.display.GraphicsPathCommand;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import Maps.Map;
	import Maps.MapManager;
	import Maps.MapObject;
	import Misc.Tuple;
	import Props.AnimatedProp;
	import Props.DoorProp;
	import Props.Prop;
	import Props.StairsDown;
	import Props.StairsUp;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author ...
	 */
	public class CharacterCommand extends MovieClip
	{
		private var pathFinder:Pathfinder;
		private var currentPathQuery:PathQuerier;
		
		private var character:Character;
		private var destination:Point;
		private var destinationMap:Map;
		private var relative:Boolean;
		
		private var mapPathList:Array;
		private var tileTupleList:Array;
		
		private var mapProgression:int;
		private var tileProgression:int;
		
		private var isRunning:Boolean;
		private var commandIncomplete:Boolean;
		
		private var positionSnapshot:Point;
		private var snapshotCounter:int;
		
		public function CharacterCommand(character:Character, destination:Point, destinationMap:Map = null, relative:Boolean = true) 
		{
			this.character = character;
			this.destination = destination;
			if (destinationMap == null)
				this.destinationMap = character.getCurrentMap();
			else
				this.destinationMap = destinationMap;
			this.relative = relative;
			this.isRunning = false;
			this.commandIncomplete = false;
			
			this.pathFinder = new Pathfinder();
			
			if (relative) {
				var charPt:Point = character.getNearestTilePoint();
				var absoluteDest:Point = new Point(charPt.x + destination.x, charPt.y + destination.y);
				currentPathQuery = new PathQuerier
					(character.getCurrentMap(), charPt, character.getCurrentMap(), absoluteDest, character);
				
				queryPathFinder();
			}
			else {
				currentPathQuery = new PathQuerier
					(character.getCurrentMap(), character.getNearestTilePoint(), this.destinationMap, destination, character);
				
				queryPathFinder();
			}
			
			
			mapProgression = 0;
			tileProgression = 0;
			positionSnapshot = new Point();
			snapshotCounter = 0;
		}
		
		private function queryPathFinder():void {
			var pathFinderStatus:int = currentPathQuery.queryPath(pathFinder);
			
			if (pathFinderStatus == 1) {
				createPath();
			}
			else if (pathFinderStatus == 0) {
				if (!this.hasEventListener(Event.ENTER_FRAME))
					this.addEventListener(Event.ENTER_FRAME, queryAgain);
			}
			else if (pathFinderStatus == -1) {				
				stopCommand();
				character.stopCharacter();
				commandIncomplete = true;
				return;
			}
		}
		private function queryAgain(event:Event):void {
			
			var status:int = pathFinder.checkPathStatus();
			if (status == 1) {
				this.removeEventListener(Event.ENTER_FRAME, queryAgain);
				createPath();
			}
			else if (status == -1) {
				this.removeEventListener(Event.ENTER_FRAME, queryAgain);
				stopCommand();
				character.stopCharacter();
				commandIncomplete = true;
				return;
			}
			
		}
		
		private function createPath():void {
			var path:Tuple = pathFinder.retrievePath();
			mapPathList = path.former as Array;
			tileTupleList = path.latter as Array;
		}
		
		public function commandRunning():Boolean { return isRunning; }
		public function startCommand():void {
			if (isRunning) return;
			
			isRunning = true;
		}
		public function stopCommand():void {
			if (!isRunning) return;
			
			isRunning = false;
		}
		
		public function commmandIncomplete():Boolean { return commandIncomplete };
		
		public function updateCommand():void {
			
			if (mapPathList == null || tileTupleList == null) {
				stopCommand();
				character.stopCharacter();
				commandIncomplete = true;
				return;
			}
			else if (mapPathList[mapProgression] == null || tileTupleList[mapProgression] == null){
				// The path is incomplete, and so this command cannot be completed.  This is most likely because of an
				// obstacle such as another character that was in the way.
				// We should have this information accessible so that this command can be thrown away and another attempt
				// at finding the path can be made.
				
				stopCommand();
				character.stopCharacter();
				commandIncomplete = true;
				return;
			}
			
			if (mapProgression < mapPathList.length ) {
				// If we haven't exhausted the mapTupleList, that is to say, the character hasn't reached
				// their final destination...
				
				if (mapPathList.length == 1) // If the map list only has one element, we don't transition between maps.
					var currentMapDestination:Map = destinationMap;
				else {
					currentMapDestination = mapPathList[mapProgression][0];
					
					// If the character has arrived next to a door leading to the next map in their path, have them use it.
					var propArray:Array = character.getCurrentMap().checkActionCollision(character, false);
					for (var i:int = 0; i < propArray.length; i++) {
						if (propArray[i] is DoorProp && character.getName() == "Donovan")
							var poo:int = 0;
						if (propArray[i] is DoorProp && mapPathList.length >= mapProgression + 2) {
							var tempDoor:DoorProp = propArray[i] as DoorProp;
							if (tempDoor.getEndMap() == mapPathList[mapProgression + 1][0])
								tempDoor.effect(character, false);
						}
					}
				}
				 
				// If the map the character is on is the current map destination, navigate through the map
				if (character.getCurrentMap() == currentMapDestination) {
					var currentTilePath:Array = tileTupleList[mapProgression];
					
					innerMapNav(currentTilePath, mapProgression);
					
					if (tileTupleList.length > mapProgression) {
						if (tileProgression + 1 >= tileTupleList[mapProgression].length 
							&& mapProgression + 1 >= mapPathList.length)
								finishCommand();
					}
				}
				
				// Otherwise, progress to the next map in the map path list, and reset tile progression.
				else {
					mapProgression++;
					tileProgression = 0;
				}
			}
		}
		private function finishCommand():void {
			stopCommand();
			character.stopCharacter();
			commandIncomplete = false;
		}
		
		private function innerMapNav(currentTilePath:Array, mapProgression:int):void {
			
			// If we aren't on the last tile in the tile path...
			if (tileProgression < currentTilePath.length - 1) {
				
				snapshotCounter ++;
				var currentTile:Point = character.getNearestTilePoint(); //currentTilePath[tileProgression].former;
				var nextTile:Point = currentTilePath[tileProgression + 1].former;
				var nearestTile:Point = character.getNearestTilePoint();
				var tileSize:int = Game.getTileSize();
				
				
				if (snapshotCounter < 0) return;
				
				var nextTileBound:Rectangle = character.getCurrentMap().getTile(nextTile.x, nextTile.y).getTileBounds();
				nextTileBound = new Rectangle(nextTileBound.x + 1, nextTileBound.y + 1, nextTileBound.width - 2, nextTileBound.height - 2);
				var nextTileProxy:MapObject = new Prop(null, "", true, 0, 0, nextTileBound);
				var nextTileCollisions:Array = character.getCurrentMap().checkNormalCollision(nextTileProxy, true);
				
				for (var i:int = 0; i < nextTileCollisions.length; i++) {
					if (nextTileCollisions[i] == this.character) {
						nextTileCollisions.splice(i, 1);
						i--;
					}
					else if (nextTileCollisions[i] is StairsUp || nextTileCollisions[i] is StairsDown) {
						nextTileCollisions.splice(i, 1);
						i--;
					}
				}
				if (nextTileCollisions.length >= 1) {
					// If the next tile has become occupied since we originally ran the A*, we'll have to run it again
					// to find a path around this obstacle.					
					currentPathQuery = new PathQuerier
						(character.getCurrentMap(), currentTile, destinationMap, destination, character);
					queryPathFinder();
					character.setAnimation("Front Idle");
					character.stopXSpeed();
					character.stopYSpeed();
					character.stopCharacter();
					snapshotCounter = -100;
					return;
				}
				
				// If the character has finished moving to the next tile, move tile progression.
				if (tileProgression < currentTilePath.length - 2 && nearestTile.x == nextTile.x && nearestTile.y == nextTile.y ) {
					tileProgression++;
					character.stopCharacter();
				}
				// If it's the last tile, we make sure they are completely within the tile before moving on.
				else if (tileProgression < currentTilePath.length - 1 && character.tileContainsObject(nextTile)) {
					tileProgression++;
					character.stopCharacter();
				}
				
				else if (snapshotCounter > 3) {
					if (character.x == positionSnapshot.x && character.y == positionSnapshot.y) {
						// If the character hasn't moved at all, it must have hit an obstacle
						// that we failed to notice.  Correct to the nearest tile.
						var tileBounds:Rectangle = new Rectangle(currentTile.x * tileSize, 
						currentTile.y * tileSize, tileSize, tileSize);
						var charBounds:Rectangle = character.getObjectBounds();
						character.stopCharacter();
							
						if (charBounds.x <= tileBounds.x) 
							character.setRight(true);
						else if (charBounds.x + charBounds.width >= tileBounds.x + tileBounds.width) 
							character.setLeft(true);
						if (charBounds.y <= tileBounds.y) 
							character.setDown(true);
						else if (charBounds.y + charBounds.height >= tileBounds.y + tileBounds.height) 
							character.setUp(true);
						return;
					}
					positionSnapshot = new Point(character.x, character.y);
					snapshotCounter = 0;
				}				
				
				// The meat of moving the character along to the next tile!
				if (tileProgression < currentTilePath.length - 1)
					nextTile = currentTilePath[tileProgression + 1].former;
				
					tileBounds = new Rectangle(nextTile.x * tileSize, nextTile.y * tileSize, tileSize, tileSize);
					charBounds = character.getObjectBounds();
					character.stopCharacter();
					
					if (charBounds.x < tileBounds.x) 
						character.setRight(true);
					else if (charBounds.x + charBounds.width > tileBounds.x + tileBounds.width) 
						character.setLeft(true);
					if (charBounds.y < tileBounds.y) 
						character.setDown(true);
					else if (charBounds.y + charBounds.height > tileBounds.y + tileBounds.height) 
						character.setUp(true);
				
			}
			
		}
		
		
	}
}