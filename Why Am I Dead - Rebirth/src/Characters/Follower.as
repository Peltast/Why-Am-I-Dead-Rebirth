package Characters 
{
	import AI.CharacterCommand;
	import Core.Game;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import Maps.Map;
	import Maps.MapManager;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author Peltast
	 */
	public class Follower extends Character
	{
		private var host:Character;
		private var leader:Character;
		private var leaderCurrentPos:Point;
		private var leaderPrevPos:Point;
		
		private var lastPosition:Point;
		private var stuckCounter:int;
		
		public function Follower(characterImg:Bitmap, name:String, animations:Dictionary, xCoord:int, yCoord:int,
			charBounds:Rectangle, maxSpeed:int, animationSpeed:int, host:Character, leader:Character) 
		{
			super(new Bitmap(characterImg.bitmapData), host.getName(), animations, xCoord, yCoord, charBounds,
					false, maxSpeed, 1, 1, animationSpeed);
			
			Game.getSingleton().addEventListener(Event.ENTER_FRAME, updateSpeed);
			
			this.host = host;
			this.leader = leader;
			leaderCurrentPos = new Point(leader.getObjectBounds().x, leader.getObjectBounds().y);
			leaderPrevPos = null;
			lastPosition = new Point();
			
			this.removeChild(objectBmp);
			currentAnimation = animations["Front Idle"];
			objectBmp = new Bitmap(new BitmapData(currentAnimation.getWidth(), currentAnimation.getHeight()));
			objectBmp.bitmapData.copyPixels(characterSheet.bitmapData, currentAnimation.getRectangle(), new Point(0, 0));
			this.addChild(objectBmp);
		}
		
		override protected function updateSpeed(event:Event):void 
		{
			if (leaderPrevPos == null) {
				stopXSpeed();
				stopYSpeed();
				stopCharacter();
				if (currentAnimation.getName() == "Back Walk") currentAnimation = animations["Back Idle"];
				if (currentAnimation.getName() == "Left Walk") currentAnimation = animations["Left Idle"];
				if (currentAnimation.getName() == "Front Walk") currentAnimation = animations["Front Idle"];
				if (currentAnimation.getName() == "Right Walk") currentAnimation = animations["Right Idle"];
				return;
			}
			if (charAI.hasCommand()) {
				super.updateSpeed(event);
				return;
			}
			
			var tileSize:int = Game.getTileSize();
			
			var charBounds:Rectangle = this.getObjectBounds();
			
			if (charBounds.x - leaderPrevPos.x <= -5) {
				currentAnimation = animations["Right Walk"];
				this.xSpeed = maxSpeed;
			}
			else if (xSpeed > 0) {
				currentAnimation = animations["Right Idle"];
				this.xSpeed = 0;
			}
			
			if (charBounds.x + charBounds.width > leaderPrevPos.x + leader.getObjectBounds().width) {
				currentAnimation = animations["Left Walk"];
				this.xSpeed = -maxSpeed;
			}
			else if (xSpeed < 0) {
				currentAnimation = animations["Left Idle"];
				this.xSpeed = 0;
			}
			
			if (charBounds.y - leaderPrevPos.y <= -5) {
				currentAnimation = animations["Front Walk"];
				this.ySpeed = maxSpeed;
			}
			else if (ySpeed > 0) {
				currentAnimation = animations["Front Idle"];
				this.ySpeed = 0;
			}
			
			if (charBounds.y > leaderPrevPos.y) {
				currentAnimation = animations["Back Walk"];
				this.ySpeed = -maxSpeed;
			}
			else if (ySpeed < 0) {
				currentAnimation = animations["Back Idle"];
				this.ySpeed = 0;
			}
			
			if (ySpeed == 0 && xSpeed == 0) {
				leaderPrevPos = null;
			}
		}
		
		override public function updateCharacter(currentMap:Map):void 
		{
			super.updateCharacter(currentMap);
			
			if (leader.getCurrentMap() != this.currentMap) {
				this.currentMap.removeCharacter(this);
				leader.getCurrentMap().addCharacter(this);
				this.x = leader.x;
				this.y = leader.y + 2;
				this.elevation = 0;
				this.zPosition = 0;
				leaderPrevPos = null;
				leaderCurrentPos = new Point(leader.getObjectBounds().x, leader.getObjectBounds().y);
			}
			
			if (leaderPrevPos != null && this.x == lastPosition.x && this.y == lastPosition.y)
				stuckCounter++;
			else
				stuckCounter = 0;
			if (stuckCounter >= 10) {
					
				if (!charAI.hasCommand() && leaderPrevPos != null) {
					var newCommand:CharacterCommand = new CharacterCommand(this, leader.getNearestTilePoint(), this.currentMap, false);
					charAI.setCommand(newCommand);
					stuckCounter = 0;
				}
				else if (charAI.hasCommand()){
					charAI.clearCommand();
					stuckCounter = 0;
				}
				
			}
			
			var leaderPt:Point = new Point(leader.getObjectBounds().x, leader.getObjectBounds().y);
			if (Math.abs(leaderPt.x - leaderCurrentPos.x) + Math.abs(leaderPt.y - leaderCurrentPos.y) > 25) {
				leaderPrevPos = leaderCurrentPos;
				leaderCurrentPos = leaderPt;
			}
			
			lastPosition = new Point(this.x, this.y);
		}
		
		public function getHost():Character { return host; }
		
		public function saveFollower(saveFile:SaveFile):void 
		{
			var charX:int = this.x;
			var charY:int = this.y;
			var zPos:int = zPosition;
			var mapName:String = currentMap.getMapName();
			saveFile.saveData(host.getName() + "followerX", charX);
			saveFile.saveData(host.getName() + "followerY", charY);
			saveFile.saveData(host.getName() + "followerZ", zPos);
			saveFile.saveData(host.getName() + "followerMap", mapName);
			saveFile.saveData(host.getName() + "followerLeader", leader.getName()); 
		}
		
	}

}