package AI 
{
	import Characters.Character;
	import flash.geom.Point;
	import Maps.Map;
	import Misc.Tuple;
	/**
	 * ...
	 * @author Peltast
	 */
	public class PathQuerier
	{
		private var startMap:Map;
		private var startPoint:Point;
		private var endMap:Map;
		private var endPoint:Point;
		private var host:Character;
		
		public function PathQuerier(startMap:Map, startPoint:Point, endMap:Map, endPoint:Point, host:Character):void 
		{
			this.startMap = startMap;
			this.startPoint = startPoint;
			this.endMap = endMap;
			this.endPoint = endPoint;
			this.host = host;
		}
		
		public function queryPath(pathFinder:Pathfinder):int {
			return pathFinder.constructPath(startMap, startPoint, endMap, endPoint, host);
		}
		
	}

}