package Setup 
{
	import flash.automation.KeyboardAutomationAction;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Peltast
	 */
	public class ControlsManager 
	{
		private static var singleton:ControlsManager;
		
		private var keyNames:Array;
		
		private var defaultKeyDictionary:Dictionary;
		private var keyDictionary:Dictionary;
		
		public static function getSingleton():ControlsManager {
			if (singleton == null)
				singleton = new ControlsManager();
			return singleton;
		}
		
		public function ControlsManager() 
		{
			defaultKeyDictionary = new Dictionary();
			keyDictionary = new Dictionary();
			keyNames = [];
			
			keyNames.push("Action Key");
			keyNames.push("Possession Key");
			keyNames.push("Pause Key");
			keyNames.push("Left Key");
			keyNames.push("Right Key");
			keyNames.push("Up Key");
			keyNames.push("Down Key");
			
			keyNames.push("Alt Action Key");
			keyNames.push("Alt Possession Key");
			keyNames.push("Alt Pause Key");
			keyNames.push("Alt Left Key");
			keyNames.push("Alt Right Key");
			keyNames.push("Alt Up Key");
			keyNames.push("Alt Down Key");
			
			//var gameConfig:SaveFile = SaveManager.getSingleton().getGameConfig();
			//if (gameConfig.loadData("keysInit") == null)
			initiateKeys();
			//else
			//	loadKeys();
		}
		
		public function getKey(keyName:String):uint {
 			return keyDictionary[keyName];
		}
		public function getKeyStrings():Array {
			return keyNames;
		}
		public function getValueStrings():Array {
			var returnArray:Array = [];
			for each(var key:String in keyNames) {
				var value:int = keyDictionary[key];
				returnArray.push(getCharCodeString(value));
			}
			return returnArray;
		}
		private function getCharCodeString(charCode:int):String {
			var charCodeStr:String = String.fromCharCode(charCode);
			
			if (charCode == 32) return "Space";
			
			if (charCode == 37) return "Left arrow";
			if (charCode == 39) return "Right arrow";
			if (charCode == 38) return "Up arrow";
			if (charCode == 40) return "Down arrow";
			
			if (charCode == 8) return "Backspace";
			if (charCode == 9) return "Tab";
			if (charCode == 13) return "Enter";
			if (charCode == 16) return "Shift";
			if (charCode == 17) return "Control";
			if (charCode == 20) return "Caps lock";
			if (charCode == 27) return "Esc";
			
			if (charCode == 35) return "End";
			if (charCode == 36) return "Home";
			if (charCode == 45) return "Insert";
			if (charCode == 46) return "Delete";
			
			return charCodeStr;
		}
		public function setKey(keyName:String, alt:Boolean, newInput:uint):Boolean {
			if (alt) keyName = "Alt " + keyName;
			
			if (keyDictionary[keyName] == null) return false;
			for (var keyStr:String in keyDictionary) {
				if (keyDictionary[keyStr] == newInput) {
					
					var oldInput:uint = keyDictionary[keyName];
					keyDictionary[keyStr] = oldInput;
					keyDictionary[keyName] = newInput;
					return true;
				}
			}
			
			keyDictionary[keyName] = newInput;
			return true;
		}
		
		public function setToDefault():void {
			for (var key:String in keyDictionary)
				keyDictionary[key] = defaultKeyDictionary[key];
		}
		public function saveKeys():void {
			var gameConfig:SaveFile = SaveManager.getSingleton().getGameConfig();
			for each(var name:String in keyNames) {
				gameConfig.saveData(name, keyDictionary[name]);
			}
			gameConfig.saveData("keysInit", 1);
		}
		
		private function initiateKeys():void {
			
			keyDictionary["Enter Key"] = 32;
			
			keyDictionary["Action Key"] = 74;
			keyDictionary["Possession Key"] = 32;
			keyDictionary["Pause Key"] = 80;
			keyDictionary["Left Key"] = 65;
			keyDictionary["Right Key"] = 68;
			keyDictionary["Up Key"] = 87;
			keyDictionary["Down Key"] = 83;
			
			keyDictionary["Alt Action Key"] = 90;
			keyDictionary["Alt Possession Key"] = 88;
			keyDictionary["Alt Pause Key"] = 80;
			keyDictionary["Alt Left Key"] = 37;
			keyDictionary["Alt Right Key"] = 39;
			keyDictionary["Alt Up Key"] = 38;
			keyDictionary["Alt Down Key"] = 40;
			
			for (var key:String in keyDictionary)
				defaultKeyDictionary[key] = keyDictionary[key];
		}
		private function loadKeys():void {
			var gameConfig:SaveFile = SaveManager.getSingleton().getGameConfig();
			for each(var name:String in keyNames) {
				keyDictionary[name] = gameConfig.loadData(name);
			}
		}
		
	}

}