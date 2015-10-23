package Core 
{
	import AI.CharacterCommand;
	import Cinematics.CinematicManager;
	import flash.net.navigateToURL;
	import flash.net.SharedObject;
	import Interface.DialogueSystem.DialogueBox;
	import Setup.*;
	import Characters.*;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import Interface.*;
	import Dialogue.DialogueLibrary;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import Maps.*;
	import Props.PropManager;
	import Setup.GameLoader;
	import Sound.SoundManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class GameState extends State
	{	
		private var saveFile:SaveFile;
		private var launchedIntroduction:Boolean;
		
		private var mapManager:MapManager;
		private var characterManager:CharacterManager;
		private var dialogueLibrary:DialogueLibrary;
		private var guiManager:GUIManager;
		private var soundManager:SoundManager;
		private var cinematicManager:CinematicManager;
		private var propManager:PropManager;
		private var player:Player;
		
		private var gameOverlay:Overlay;
		private var gameScreen:GameScreen;
		private var pauseOverlay:Overlay;
		
		private var dialogueBox:DialogueBox;
		private var fadeInScreen:Shape;		
		
		public function GameState(saveFile:SaveFile) 
		{
			super(this);
			this.saveFile = saveFile;
			
			Game.getSingleton().stage.addEventListener(Event.DEACTIVATE, unFocus);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, pause);
			
			fadeInScreen = new Shape();
			fadeInScreen.graphics.beginFill(0);
			fadeInScreen.graphics.drawRect(0, 0, 540, 400);
			fadeInScreen.graphics.endFill();
			
			gameOverlay = new Overlay();
			this.overlayStack.pushOverlay(gameOverlay);
			gameScreen = new GameScreen();
			
			mapManager = new MapManager(gameScreen);
			characterManager = new CharacterManager(mapManager, gameScreen);
			
			GUIManager.getSingleton().resetGUIManager();
			guiManager = GUIManager.getSingleton();
			soundManager = SoundManager.getSingleton();
			
			CinematicManager.getSingleton().resetTriggers();
			cinematicManager = CinematicManager.getSingleton();
			player = new Player();
			
			DialogueLibrary.getSingleton().reloadAllDialogues();
			dialogueLibrary = DialogueLibrary.getSingleton();
			
			propManager = new PropManager(mapManager, gameScreen);
			gameScreen.initiateGameScreen(this, player, mapManager, guiManager);
			gameOverlay.addToOverlay(gameScreen);
			
			pauseOverlay = new PauseOverlay(overlayStack);
			
			propManager.initiateProps(saveFile);
			mapManager.initiateMaps(saveFile, propManager);
			characterManager.initiateCharacters(saveFile, mapManager);
			cinematicManager.initiateTriggers(saveFile);
			dialogueLibrary.initiateDialogueLibrary(saveFile);
			player.initiatePlayer(saveFile, characterManager);
			
			SaveManager.getSingleton().setCharacterManager(characterManager);
			SaveManager.getSingleton().setMapManager(mapManager);
			SaveManager.getSingleton().setPropManager(propManager);
			
			this.addChild(fadeInScreen);
		}
		override public function activateState():void 
		{
			super.activateState();
			Game.getSingleton().stage.addEventListener(Event.DEACTIVATE, unFocus);
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, pause);
			Main.getSingleton().stage.focus = this;
		}
		override public function deactivateState():void 
		{
			super.deactivateState();
			Game.getSingleton().stage.removeEventListener(Event.DEACTIVATE, unFocus);
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, pause);
		}
		
		private function unFocus(focusEvent:Event):void {
			if (mapManager.getCurrentMap() == null) return;
			if (overlayStack.peekStack() == gameOverlay) {
				guiManager.pauseDialogue();
				overlayStack.pushOverlay(pauseOverlay);
			}
			
		}
		private function pause(key:KeyboardEvent):void {
			if (checkKeyInput("Pause Key", key.keyCode) || checkKeyInput("Alt Pause Key",key.keyCode)) {
				
				if (overlayStack.peekStack() != gameOverlay) {
					
					overlayStack.popStack();
					guiManager.resumeDialogue();
				}
				else {
					
					overlayStack.pushOverlay(pauseOverlay);
					guiManager.pauseDialogue();
				}
			}
		}
		
		private function checkKeyInput(keyName:String, keyCode:uint):Boolean {
			if (ControlsManager.getSingleton().getKey(keyName) == keyCode)
				return true;
			return false;
		}
		
		public function findGeneralTerm(term:String):String {
			
			if (term == "player" && player != null && player.getHost() != null) {
				return player.getHost().getName();
			}
			return "";
			
		}
		
		public override function drawState():void {
			
			if (overlayStack.peekStack() != gameOverlay) 
				return;
			
			if(mapManager.getCurrentMap() != null){
				
				updateGame();
				
			}
			else mapManager.startMapManager();
		}
		
		private function updateGame():void {
			if (saveFile == null && !launchedIntroduction) {
				launchedIntroduction = true;
				//Game.pushState(new IntroState());
			}
			else if(saveFile != null){
				if (saveFile.loadData("init") == null && !launchedIntroduction) {
					launchedIntroduction = true;
					//Game.pushState(new IntroState());
				}
			}
			
			if (fadeInScreen.alpha > 0)
				fadeInScreen.alpha = fadeInScreen.alpha - .016;
			else if (fadeInScreen.alpha <= 0 && this.contains(fadeInScreen))
				this.removeChild(fadeInScreen);
			
			// Where the magic happens
			player.updatePlayer(mapManager.getCurrentMap(), gameScreen);
			guiManager.updateGUI();
			mapManager.updateMaps(gameScreen);
			cinematicManager.updateCinematicManager(player, mapManager, characterManager, guiManager, propManager);
		}
		
	}

}