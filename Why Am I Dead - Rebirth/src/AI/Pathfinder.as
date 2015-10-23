package AI 
{
	import adobe.utils.CustomActions;
	import Characters.Character;
	import Characters.Follower;
	import Core.Game;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import Maps.Map;
	import Maps.MapManager;
	import Maps.MapObject;
	import Maps.MapTransition;
	import Maps.Tile;
	import Misc.LinkedList;
	import Misc.Stack;
	import Misc.Tuple;
	import Props.AnimatedProp;
	import Props.DoorProp;
	import Props.Prop;
	import Props.PropManager;
	import Props.ProxyProp;
	import Props.StairsDown;
	import Props.StairsUp;
	/**
	 * ...
	 * @author ...
	 */
	public class Pathfinder extends MovieClip
	{
		
		private var searchInProgress:Boolean;
		private var mapPath:Array;
		private var tilePath:Array;
		private var path:Tuple;
		
		private var host:Character;
		
		
		// DFS variables
		
		private var linkStack:Stack;
		private var examinedLinks:Array;
		
		
		// A* variables
		
		// Set of examined nodes, can just be an array.
		private var closedSet:Array;
		private var closedSetSnapshot:Array;
		
		// Set of unexamined tentative nodes.  It's a LinkedList of tuples, the former of which is
		// a priority number and the latter of which is an array of point tuples.
		private var openSet:LinkedList;
		private var openSetSnapshot:LinkedList;
		
		// A combination of closedSet and openSet, simply contains all nodes that have already been or will be looked at
		// to prevent redundancy.  Stored in a dictionary for easy look-up.
		private var checkedSet:Dictionary;
		private var checkedSetSnapshot:Dictionary;
		
		private var aStarBeginningTime:int;
		private var aStarParams:Array;
		
		// Empty prop object used to test collision detection as proxy, since we don't have/need scope to characters.
		private var proxyObj:ProxyProp;
		private var tileBound:Rectangle;
		private var newTileBound:Rectangle;
		
		
		public function Pathfinder() 
		{
			proxyObj = new ProxyProp(null, "", true, 0, 0, new Rectangle());
			tileBound = new Rectangle();
			closedSetSnapshot = [];
			checkedSetSnapshot = new Dictionary();
			openSetSnapshot = new LinkedList();
		}
		
		public function constructPath(startMap:Map, startPoint:Point, endMap:Map, endPoint:Point, host:Character):int {
			
			if (searchInProgress) return 0;
			
			this.host = host;
			
			findMapPath(startMap, startPoint, endMap, endPoint, host);
			var tilePathConstructionStatus:int = findTilePath(startMap, startPoint, endMap, endPoint, host);
			
			return (tilePathConstructionStatus);
		}
		
		public function checkPathStatus():int {
			var unfinished:Boolean;
			for (var i:int = 0; i < tilePath.length; i++)
				if (tilePath[i] == null)
					unfinished = true;
			if (unfinished) return 0;
			else return 1;
		}
		
		public function retrievePath():Tuple {
			return new Tuple(mapPath, tilePath);
		}
		
		private function findMapPath(startMap:Map, startPoint:Point, endMap:Map, endPoint:Point, host:Character):void {
			// The first array is a collection of tuples showing the path of maps 
			// eg ( (map1, null), (map2, map1), (map3, map2) )
			mapPath = dfsPath(startMap, endMap, host);
		}
		
		private function findTilePath(startMap:Map, startPoint:Point, endMap:Map, endPoint:Point, host:Character):int {
			
			// The second array is a collection of arrays of tuples, showing the path that must be
			// taken in each individual map to proceed to the next.
			tilePath = new Array(mapPath.length);
			var collidable:Boolean;
			if (host is Follower) collidable = false;
			else collidable = true;
			
			openSetSnapshot = new LinkedList();
			checkedSet = new Dictionary();
			checkedSetSnapshot = new Dictionary();
			
			var aStarStatus:int
			var incomplete:Boolean;
			var unfinished:Boolean;
			searchInProgress = false;
			
			for (var i:int = 0; i < mapPath.length; i++) {
				var tempLink:Array = mapPath[i] as Array;
				var currentMap:Map = tempLink[0] as Map;
				var previousMap:Map = tempLink[1] as Map;
				var nextLink:Array = mapPath[i + 1] as Array;
				if (nextLink != null) var nextMap:Map = nextLink[0] as Map;
				else nextMap = null;
				
				var origin:Point;
				var originMap:Map;
				var destination:Point;
				var destinationMap:Map;
				
				if (previousMap == null && currentMap == endMap) {
					// This is the beginning and end of the map path; the character does not have to go to any other map.
					
					originMap = currentMap;
					destinationMap = nextMap;
					origin = startPoint;
					destination = endPoint;
				}
				else if (previousMap == null) {
					// This is the beginning of the map path, we don't need to figure out the origin map, since we're there.
					// The destination will be where the transition to the next map begins.
					
					originMap = currentMap;
					destinationMap = nextMap;
					origin = startPoint;
					if (nextLink[2]){
						destination = currentMap.getDoor(nextMap).getPropCoords();
						destination = new Point(Math.ceil(destination.x), Math.ceil(destination.y));
						destination.y += 2;
					}
					else
						destination = currentMap.findTransition(nextMap).getStartTile().getTileCoords();
					
				}
				else if (currentMap == endMap) {
					// This is the end of the map path, we don't need to figure out the destination map, since we're there.
					// The origin will be where the previous transition to get to this map left off.
					
					originMap = endMap;
					destinationMap = nextMap;
					if (tempLink[2])
						origin = previousMap.getDoor(currentMap).getEndCoord();
					else
						origin = previousMap.findTransition(currentMap).getEndTile().getTileCoords();
					destination = endPoint;
					
					origin.y += 1;
				}
				else {
					nextLink = mapPath[i + 1];
					
					// Put them both together
					
					originMap = currentMap;
					destinationMap = nextMap;
					if (tempLink[2])
						origin = previousMap.getDoor(currentMap).getEndCoord();
					else
						origin = previousMap.findTransition(currentMap).getEndTile().getTileCoords();
					if (nextLink[2]){
						destination = currentMap.getDoor(nextMap).getPropCoords();
						destination.y += 2;
					}
					else
						destination = currentMap.findTransition(nextMap).getStartTile().getTileCoords();
					
					origin.y += 1;
				}
				
				// Finally, run the A* algorithm.
				aStarStatus = startAStar(originMap, destinationMap, origin, destination, collidable, i);
				
				if (aStarStatus == 0)
					unfinished = true;
				else if (aStarStatus == -1)
					incomplete = true;
				
			}
			if (incomplete) return -1;
			else if (unfinished) return 0;
			else return 1;
		}
		
		
		
		
		
		// Uses DFS to find quickest path through map branch
		// This is admittedly not the best way to find a path, but the amount of links between maps will ALWAYS be
		// a trivial amount.
		private function dfsPath(currentMap:Map, destinationMap:Map, host:Character):Array {
			
			linkStack = new Stack();
			examinedLinks = [];
			
			linkStack.push(new Array(currentMap, null, false));
			
			while (!linkStack.isEmpty()) {
				
				examinedLinks.push(linkStack.peek());
				var currentLink:Array = linkStack.pop() as Array;
				var currentMap:Map = currentLink[0] as Map;
				
				if (currentMap == destinationMap) 
					return constructMapPath(currentLink, new Array(currentLink));
				
				var tempList:Vector.<MapObject> = currentMap.getTransitions();
				for (var i:int = 0; i < tempList.length; i++) {
					var tempTransition:MapTransition = tempList[i] as MapTransition;
					if (!tempTransition.isAICompatible()) 
						continue;
					var newLink:Array = new Array(tempTransition.getEndMap(), currentMap, false);
					
					addToLinkStack(newLink);
				}
				
				var doorArray:Array = currentMap.getDoorList();
				for (var j:int = 0; j < doorArray.length; j++) {
					var tempDoor:DoorProp = doorArray[j] as DoorProp;
					if (!tempDoor.isCharacterPermitted(host.getName())) continue;
					newLink = new Array(tempDoor.getEndMap(), currentMap, true);
					
					addToLinkStack(newLink);
				}
			}
			return [];
		}
		private function addToLinkStack(newLink:Array):void {
			// Check if we've examined a similar link before; if we have, break.  If not, push to link stack.
			for (var j:int = 0; j < examinedLinks.length; j++) {
				var tempLink:Array = examinedLinks[j];
				if (newLink[0] == tempLink[0] && newLink[1] == tempLink[1])
					return;
			}
			linkStack.push(newLink);
		}
		
		private function constructMapPath(link:Array, array:Array):Array {
			
			if (link[1] == null) return array;
			
			for (var i:int = 0; i < examinedLinks.length; i++) {
				var tempLink:Array = examinedLinks[i] as Array;
				if (tempLink[0] == link[1]) {
					var tempArray:Array = new Array(tempLink);
					tempArray = tempArray.concat(array);
					return constructMapPath(tempLink, tempArray);
				}
			}
			return null;
		}
		
		private function startAStar(map:Map, nextMap:Map, origin:Point, destination:Point, collidable:Boolean, index:int):int {
			
			closedSet = [];
			checkedSet = new Dictionary();
			openSet = new LinkedList();
			
			addToOpenSet(new Tuple(0, new Tuple(new Point(origin.x, origin.y), null)));
			
			// If the destination is not viable, stop right here and return null.
			var destinationTile:Tile = map.getTile(destination.x, destination.y);
			if (host.getName() == "Donovan")
				var fuck:int = 2;
			if (!checkTileViable(1, 0, map, nextMap, destinationTile, collidable, origin, destination, true)) {
				var alternateDestination:Point = searchAlternateDestination(map, nextMap, origin, destination, collidable);
				if (alternateDestination == null)
					return -1;
				else return aStarPath(closedSet, openSet, checkedSet, map, nextMap, origin, alternateDestination, true, index);
			}
			
			return aStarPath(closedSet, openSet, checkedSet, map, nextMap, origin, destination, collidable, index);
		}
		private function searchAlternateDestination(map:Map, nextMap:Map, origin:Point, destination:Point, collidable:Boolean):Point {
			
			for (var y:int = -1; y < 2; y++) {
				for (var x:int = -1; x < 2; x++) {
					var newDestination:Point = new Point(destination.x + x, destination.y + y);
					var destinationTile:Tile = map.getTile(newDestination.x, newDestination.y);
					if (checkTileViable(1, 0, map, nextMap, destinationTile, collidable, origin, newDestination, true))
						return newDestination;
				}
			}
			return null;
		}
		
		
		// Uses A* to find quickest path through a map
		private function aStarPath(closedSet:Array, openSet:LinkedList, checkedSet:Dictionary, 
									map:Map, nextMap:Map, origin:Point, destination:Point, collidable:Boolean, index:int):int {
			
			aStarBeginningTime = getTimer();
			
			while (!openSet.isEmpty()) {
				
				
				
/*				if (checkOverTime(aStarBeginningTime) && !searchInProgress) {
					
					closedSetSnapshot = closedSetSnapshot.concat(closedSet);
					openSetSnapshot = openSet.clone();
					for (var key:Object in checkedSet)
						checkedSetSnapshot[key] = checkedSet[key];
						
					aStarParams = new Array(map, nextMap, origin, destination, collidable, index);
					if (!this.hasEventListener(Event.ENTER_FRAME))
						this.addEventListener(Event.ENTER_FRAME, waitUntilNextFrame);
					searchInProgress = true;
					return 0;
				}*/
				
				
				
				// The next node is removed during getNextOpenNode, so we don't have to worry about
				// removing it from openSet here.
				var currentNode:Tuple = getNextOpenNode();
				if (openSet.isEmpty()) continue;  // It's possible for openSet to empty out during getNextOpenNode.
				// In this case, continue back to the while condition, which will fail and end the function.
				
				var pastHVal:int = currentNode.former as int;
				var currentPoint:Point = currentNode.former as Point;
				
				// We've found the destination!  Now we need to string together the tuples that got us there.
				if (currentPoint.x == destination.x && currentPoint.y == destination.y) {
					
					tilePath[index] = constructTilePath(currentNode as Tuple, new Array(currentNode));
					return 1;
				}
				
				else {
					
					closedSet.push(currentNode);
					
					for (var y:int = -1; y < 2; y++) {
						for (var x:int = -1; x < 2; x++) {
							var tempPoint:Point = new Point(currentPoint.x + x, currentPoint.y + y);
							var tempTile:Tile = map.getTile(tempPoint.x, tempPoint.y);
							
							if (!checkTileViable(x, y, map, nextMap, tempTile, collidable, currentPoint, tempPoint)) 
								continue;
							
							var dist1:int = Math.sqrt(y * y + x * x);
							var dist2:int = Math.abs(tempPoint.x - destination.x) + Math.abs(tempPoint.y - destination.y);
							var hVal:int = pastHVal + dist1 + dist2;
							
							addToOpenSet(new Tuple(hVal, new Tuple(
								new Point(tempPoint.x, tempPoint.y), 
								new Point(currentPoint.x, currentPoint.y))));
						}
					}
				}
				
			}
			// Failed to find a path!
			return -1;
		}
		
		private function checkOverTime(aStarBeginTime:int):Boolean {
			
			var currentTime:int = getTimer()
			var executedTime:int = currentTime - aStarBeginningTime;
			var frameTime:Number = 1000 / Main.getSingleton().getFrameRate();
			
			if (executedTime > frameTime / 3)
				return true;
			else return false;
		}
		private function waitUntilNextFrame(event:Event):void {
			this.removeEventListener(Event.ENTER_FRAME, waitUntilNextFrame);
			searchInProgress = true;
			
			this.closedSet = closedSetSnapshot;
			this.openSet = openSetSnapshot;
			this.checkedSet = checkedSetSnapshot;
			
			aStarPath(closedSet, openSet, checkedSet, 
				aStarParams[0], aStarParams[1], aStarParams[2], aStarParams[3], aStarParams[4], aStarParams[5]);
		}
		
		
		private function checkTileViable(xDelta:int, yDelta:int, map:Map, nextMap:Map, tile:Tile, collidable:Boolean,
											currentPoint:Point, nextPoint:Point, isDestination:Boolean = false):Boolean {
			// There are numerous reasons to discard a tile in our search.
			
			if (xDelta != 0 && yDelta != 0) return false; // no diagonals!
			if (xDelta == 0 && yDelta == 0) return false; // If x and y are zero we aren't moving anywhere
			if (tile == null) return false; // If it's beyond the bounds of the map
			if (tile.getTileType() != 5) return false; // If the tile isn't passable
			
			newTileBound = map.getTile(nextPoint.x, nextPoint.y).getTileBounds();
			tileBound.x = newTileBound.x + 1;
			tileBound.y = newTileBound.y + 1;
			tileBound.width = newTileBound.width - 2;
			tileBound.height = newTileBound.height - 2;
			
			proxyObj.resetBounds(tileBound);
			
 			var collisionList:Array = map.checkNormalCollision(proxyObj, true);
			if (collisionList.length > 0) {
				if (collidable == false) 
					return handleTransitions(map, nextMap, currentPoint, nextPoint);
				else if (collisionList.length == 1 && collisionList[0] == host)
					return true;
				else if (collisionList.length == 1 && (collisionList[0] is StairsUp || collisionList[0] is StairsDown)) {
					if (isDestination) return true;
					if (handleStairs(collisionList, currentPoint, nextPoint, map, nextMap))
						return handleTransitions(map, nextMap, currentPoint, nextPoint);
				}
				return false;
			}
			
			
			return handleTransitions(map, nextMap, currentPoint, nextPoint);
		}
		private function handleStairs(collisionList:Array, currentPoint:Point, stairPoint:Point, map:Map, nextMap:Map):Boolean {
			if (collisionList[0] is StairsUp) {
				
				if (stairPoint.x > currentPoint.x && stairPoint.y == currentPoint.y) {
					if (map == nextMap || nextMap == null)
						return false;
					else if (nextMap.getMapName() != "Pilothouse" && nextMap.getMapName() != "Floor One" &&
						nextMap.getMapName() != "Basement One")
							return false;
					return true;
				}
				else
					return false;
			}
			else if (collisionList[0] is StairsDown) {
				if (stairPoint.x < currentPoint.x && stairPoint.y == currentPoint.y) {
					if (map == nextMap || nextMap == null)
						return false;
					else if (nextMap.getMapName() != "Basement Two" && nextMap.getMapName() != "Basement One" &&
						nextMap.getMapName() != "Floor One")
							return false;
					return true;
				}
				else
					return false;
			}
			return false;
		}
		private function handleTransitions(map:Map, nextMap:Map, currentPoint:Point, nextPoint:Point):Boolean {
			var mapTransitions:Vector.<MapObject> = map.getTransitions();
			for each(var tempTrans:MapTransition in mapTransitions) {
				if (tempTrans.getStartTile().getTileCoords().x == nextPoint.x
					&& tempTrans.getStartTile().getTileCoords().y == nextPoint.y
					&& tempTrans.getEndMap() != nextMap)
						return false;
			}
			return true;
		}
		
		
		private function constructTilePath(tuple:Tuple, array:Array):Array {
			
			if (tuple.latter == null)
				return array;
			
			for (var i:int = 0; i < closedSet.length; i++) {
				var tempTuple:Tuple = closedSet[i];
				if (tempTuple.former.x == tuple.latter.x && tempTuple.former.y == tuple.latter.y) {
					var tempArray:Array = new Array(tempTuple);
					tempArray = tempArray.concat(array);
					
					return constructTilePath(tempTuple, tempArray);
				}
			}
			return null;
		}
		
		private function getNextOpenNode():Tuple {
			while(!openSet.isEmpty()){
				openSet.setCurrentNodeEnd();
				openSet.setBackward();
				var tempTuple:Tuple = openSet.getCurrent() as Tuple;
				var tempStack:Stack = tempTuple.latter as Stack;
				if (tempStack.isEmpty()) {
					openSet.removeCurrentNode();
					continue;
				}
				else
					return tempStack.pop() as Tuple;
			}
			// Failed to find open node
			return null;
		}
		
		private function addToOpenSet(node:Tuple):void {
			var hVal:int = node.former as int;
			var points:Tuple = node.latter as Tuple;
			var newPoint:Point = points.former as Point;
			
			if (checkedSet[node.latter.former + " " + node.latter.latter] != null) {
				// If the checked set contains this point, don't add it.
				return;
			}
			var closedPoint:Point = new Point();
			for (var i:int = 0; i < closedSet.length; i++) { 
				// If the closed set already contains this point, don't add it.
				closedPoint = closedSet[i].former as Point;
				if (closedPoint.x == newPoint.x && closedPoint.y == newPoint.y) 
				return;
			}
			checkedSet[node.latter.former + " " + node.latter.latter] = 1;
			
			if (openSet.isEmpty()) {
				// If the open set is empty, don't worry about where to put this tuple!
				var newStack:Stack = new Stack();
				newStack.push(points);
				var newTuple:Tuple = new Tuple(hVal, newStack);
				openSet.insertBeforeCurrent(newTuple);
				return;
			}
			
			openSet.setCurrentNodeEnd();
			var startNode:Object = openSet.getCurrent();
			var count:int = 0;
			
			var tempVal:int = openSet.getCurrent().former;
			var tempStack:Stack = openSet.getCurrent().latter;
			
			// Loop through open set in order to insert new point into proper place according to its hValue.
			while (startNode != openSet.getCurrent() || count == 0)
			{
				
				tempVal = openSet.getCurrent().former;
				tempStack = openSet.getCurrent().latter;
				
				// If the new node has lower priority than the current node, put it before current node
				if (hVal > tempVal) {
					newStack = new Stack();
					newStack.push(points);
					openSet.insertBeforeCurrent(new Tuple(hVal, newStack));
					return;
				}
				// If they have the same priority, just push 
				else if (hVal == tempVal) {
					openSet.getCurrent().latter.push(points);
					return;
				}
				
				count++; 
				// If openset only has one element, it will be impossible to know if we've made a full loop or not
				// without the help of some sort of external count.
				openSet.setForward();
				
				// If we've reached the beginning, add new node to the end.
				if (openSet.getElementIndex(openSet.getCurrent()) == 0 && count > 0) {
					openSet.setBackward();
					newStack = new Stack();
					newStack.push(points);
					openSet.insertAfterCurrent(new Tuple(hVal, newStack));
					return;
				}
				
			}
			return;
		}
		
	}

}