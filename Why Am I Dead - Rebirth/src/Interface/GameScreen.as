package Interface 
{
	import Characters.Player;
	import Core.GameState;
	import flash.display.Sprite;
	import Maps.MapManager;
	/**
	 * ...
	 * @author Peltast
	 */
	public class GameScreen extends OverlayItem
	{
		private var gameState:GameState;
		private var player:Player;
		private var mapManager:MapManager;
		private var guiManager:GUIManager;
		
		public function GameScreen()
		{
			super(this, true);
			
		}
		public function initiateGameScreen(gameState:GameState, player:Player, mapManager:MapManager, guiManager:GUIManager):void {
			
			this.gameState = gameState;
			this.player = player;
			this.mapManager = mapManager;
			this.guiManager = guiManager;
			guiManager.setHost(this);
		}
		
		override public function activateOverlayItem():void 
		{
			super.activateOverlayItem();
			
			this.repaintGUI();
			guiManager.resumeDialogue();
			player.addPlayerListeners();
			if (mapManager.getCurrentMap() != null)
				mapManager.getCurrentMap().resumeMapSounds();
		}
		
		override public function deactivateOverlayItem():void 
		{
			super.deactivateOverlayItem();
			
			this.hideGUI();
			
			// Stop player movement and input
			player.removePlayerListeners();
			player.getHost().setDown(false);
			player.getHost().setUp(false);
			player.getHost().setLeft(false);
			player.getHost().setRight(false);
			
			// pause any music/sound that's playing
			mapManager.getCurrentMap().pauseMapSounds();
		}
		
		private function hideGUI():void {
			if (this.contains(guiManager)) this.removeChild(guiManager);
		}
		
		private function repaintGUI():void {
			if (this.contains(guiManager)) this.removeChild(guiManager);
			this.addChild(guiManager);
		}
		private function removeGUI():void {
			if (this.contains(guiManager)) this.removeChild(guiManager);
			guiManager.resetGUIManager();
		}
	}

}