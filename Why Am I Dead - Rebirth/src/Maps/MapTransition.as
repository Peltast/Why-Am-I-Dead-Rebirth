package Maps 
{
	import Characters.Character;
	import Core.Game;
	import flash.geom.Rectangle;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	
	public class MapTransition extends MapObject {
	
		private var startMap:Map;
		private var startTile:Tile;
		private var endMap:Map;
		private var endTile:Tile;
		private var reqHeight:int;
		private var endHeight:int;
		private var needsCollidable:Boolean; // If true, only characters that can collide with other characters (ie not the 'ghost' char)
												// can use this transition.
		private var status:int;
		private var specialPermissions:Vector.<String>;
		private var aiCompatible:Boolean;
	
		public function MapTransition
			(sM:Map, sT:Tile, eM:Map, eT:Tile, needsCollidable:Boolean = false, reqHeight:int = 0, endHeight:int = 0,
				aiCompatible:Boolean = true) {
			
			startMap = sM;
			startTile = sT;
			endMap = eM;
			endTile = eT;
			status = 1;
			this.reqHeight = reqHeight;
			this.endHeight = endHeight;
			this.needsCollidable = needsCollidable;
			this.aiCompatible = aiCompatible;
			this.specialPermissions = null;
			
			super(this, null, false, new Rectangle(0, -5, Game.getTileSize(), Game.getTileSize() + 10), startTile.x, startTile.y);
			
		}
		
		override public function intersectsObject(mapObject:MapObject, checkCollidable:Boolean):Boolean 
		{
			
			if (getObjectBounds().intersects(mapObject.getObjectBounds())) {
				
				if (reqHeight <= 0 && (mapObject.getZPosition() <= reqHeight || mapObject.getElevation() <= reqHeight))
					return true;
				else if(reqHeight > 0 && (mapObject.getZPosition() >= reqHeight || mapObject.getElevation() >= reqHeight))
					return true;
			}
			return false;
		}
		public function isPermitted(character:Character):Boolean {
			if (needsCollidable && !character.isCollidable()) return false;
			if (status == -1 && !getPermitted(character.getName())) return false;
			
			return true;
		}
		
		public function getStartMap():Map { return startMap; }
		public function getStartTile():Tile { return startTile; }
		public function getEndMap():Map { return endMap; }
		public function getEndTile():Tile { return endTile; }
		private function getPermitted(charName:String):Boolean {
			for each(var char:String in specialPermissions)
				if (char == charName) return true;
			return false;
		}
		public function needsCollidableChar():Boolean { return needsCollidable; }
		public function getReqHeight():int { return reqHeight; }
		public function getEndHeight():int { return endHeight; }
		public function isAICompatible():Boolean { return aiCompatible; }
		
		public function addSpecialPermission(char:String):void {
			if (specialPermissions == null) specialPermissions = new Vector.<String>();
			specialPermissions.push(char);
		}
		public function removeSpecialPermission(char:String):void {
			for (var i:int = 0; i < specialPermissions.length; i++) {
				if (specialPermissions[i] == char)
					specialPermissions = specialPermissions.splice(i, 1);
			}
		}
		public function deactivateTransition():void { status = -1; }
		public function activateTransition():void { status = 1; }
		
		public function saveTransition(saveFile:SaveFile, mapName:String):void {
			saveFile.saveData
				(mapName + " transition:" + startTile.getTileCoords().x + "," + startTile.getTileCoords().y, status);
			saveFile.saveData(mapName + " transition:" + startTile.getTileCoords().x + "," 
								+ startTile.getTileCoords().y + "permissions", specialPermissions)
		}
		public function loadTransition(saveFile:SaveFile, mapName:String):void {
			var loadedStatus:int = saveFile.loadData
				(mapName + " transition:" + startTile.getTileCoords().x + "," + startTile.getTileCoords().y) as int;
			this.status = loadedStatus;
			
			var loadedPermissions:Vector.<String> = saveFile.loadData
				(mapName + " transition:" + startTile.getTileCoords().x 
				+ "," + startTile.getTileCoords().y + "permissions") as Vector.<String>;
			if (loadedPermissions != null)
				this.specialPermissions = loadedPermissions;
		}
	
}

}