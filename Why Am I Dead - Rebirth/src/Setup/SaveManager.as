package Setup 
{
	import Characters.CharacterManager;
	import Cinematics.CinematicManager;
	import Dialogue.DialogueLibrary;
	import flash.net.SharedObject;
	import Maps.MapManager;
	import Props.PropManager;
	import Props.SaveProp;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SaveManager 
	{
		private static var singleton:SaveManager;
		
		private var mapManager:MapManager;
		private var propManager:PropManager;
		private var characterManager:CharacterManager;
		
		public static function getSingleton():SaveManager {
			if (singleton == null)
				singleton = new SaveManager();
			return singleton;
		}
		
		private var gameConfig:SaveFile;
		private var saveFiles:Vector.<SaveFile>;
		private var chapterFiles:Vector.<SaveFile>;
		private var currentSave:int;
		
		public function SaveManager()
		{
			currentSave = -1;
			saveFiles = new Vector.<SaveFile>();
			chapterFiles = new Vector.<SaveFile>();
			
			//gameConfig = new SaveFile("GameConfig", true);
			
			for (var i:int = 0; i < 1; i++) {
				saveFiles.push(new SaveFile("SaveFile" + (i + 1), true));
			}
		}
		
		
		public function setMapManager(mapManager:MapManager):void { 
			this.mapManager = mapManager;
		}
		public function setPropManager(propManager:PropManager):void {
			this.propManager = propManager;
		}
		public function setCharacterManager(characterManager:CharacterManager):void { 
			this.characterManager = characterManager; 
		}
		
		public function getGameConfig():SaveFile { return gameConfig; }
		public function getSaveFile(index:int):SaveFile {
			if (index >= 0 && index < saveFiles.length)
				return saveFiles[index];
			return null;
		}
		public function getChapterFile(index:int):SaveFile {
			if (index >= 0 && chapterFiles.length)
				return chapterFiles[index];
			return null;
		}
		public function setCurrentSave(index:int):void { currentSave = index; }
		
		public function saveGameConfig():void {
			
		}
		public function saveGame():void {
			if (currentSave < 0 ) throw new Error("Attempt to save a game when the save slot was not instantiated.");
			
			var saveFile:SaveFile = saveFiles[currentSave];
			
			saveFile.beginSave();
			
			characterManager.saveCharacterManager(saveFile);
			mapManager.saveMapManager(saveFile);
			propManager.savePropManager(saveFile);
			CinematicManager.getSingleton().saveCinematicManager(saveFile);
			DialogueLibrary.getSingleton().saveDialogueLibrary(saveFile);
			saveSaveInformation(saveFile);
			
			saveFile.saveData("init", 1);
			
			saveFile.finishSave();
		}
		
		private function saveSaveInformation(saveFile:SaveFile):void {
			
			var saveDate:String = "";
			var saveTime:String = "";
			var currentChapter:String = "";
			
			// Find actual values
			var currentTime:Date = new Date();
			saveDate = currentTime.getDate() +" / " + (currentTime.getMonth() + 1) + " / " + currentTime.getFullYear();
			
			var hours:int = currentTime.getHours();
			var minutes:String = currentTime.getMinutes() +"";
			if (minutes.length < 2) 
				minutes = "0" + minutes;
			if (hours > 12) {
				hours -= 12;
				minutes += "  PM";
			}
			else minutes += "  AM";
			
			saveTime = hours + ":" + minutes;
			
			currentChapter = "";
			
			// If actual values haven't been retrieved, create default values.
			if (saveDate == "") saveDate = "1 / 1 / 2001";
			if (saveTime == "") saveTime = "12:00 AM";
			if (currentChapter == "") currentChapter = "Chapter ?";
			
			saveFile.saveData("saveDate", saveDate);
			saveFile.saveData("saveTime", saveTime);
			saveFile.saveData("currentChapter", currentChapter);
			
		}
		
	}

}