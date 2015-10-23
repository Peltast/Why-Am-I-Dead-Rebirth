package Cinematics 
{
	import Characters.CharacterManager;
	import Characters.Player;
	import Core.Game;
	import Dialogue.DialogueLibrary;
	import flash.events.Event;
	import flash.net.SharedObject;
	import Interface.GUIManager;
	import Maps.MapManager;
	import Misc.Tuple;
	import Props.PropManager;
	import Setup.SaveFile;
	import Sound.SoundManager;
	import SpectralGraphics.SpectralManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Trigger 
	{
		private var triggerName:String;
		
		// Triggers have three states:
		//   -1 : Trigger is asleep.  It is not doing anything nor is it eligible to be activated.
		//    0 : Trigger is deactivated.  It is not doing anything but can be activated if some conditions are met.
		//    1 : Trigger is activated.  It is doing something.
		private var status:int;
		private var triggerTime:int;
		private var triggerCount:int;
		
		private var blockList:Vector.<TriggerBlock>;
		
		public function Trigger(name:String, status:int, blocks:Vector.<Tuple>) 
		{
			this.triggerName = name;
			this.status = status;
			
			var blockTuple:Tuple;
			var blockStatus:int;
			var newTriggerBlock:TriggerBlock;
			
			this.blockList = new Vector.<TriggerBlock>();
			if (blocks != null) {
				for (var i:int = 0; i < blocks.length; i++) {
					blockTuple = blocks[i];
					if (i == 0) blockStatus = 0;
					else blockStatus = -1;
					newTriggerBlock = new TriggerBlock(blockStatus, blockTuple.former as Array, blockTuple.latter as Array);
					blockList.push(newTriggerBlock);
					blockStatus = -1;
				}
			}
			
			if (name == "AltonXuCinematic2")
				var j:int = 0;
		}
		
		public function getTriggerName():String { return triggerName; }
		public function isOn():Boolean { return (status > 0); }
		public function isAwake():Boolean { return (status == 0); }
		public function isAsleep():Boolean { return (status < 0); }
		
		public function sleepTrigger():void {
			if (status >= 0) {
				status = -1;
				triggerCount = -1;
			}
		}
		public function wakeUpTrigger():void {
			if (status < 0) {
				status = 0;
				triggerCount = triggerTime;
			}
		}
		public function activateTrigger():void { 
			if (status == 0) status = 1;
		}
		public function deactivateTrigger():void {
			if (status == 1) {
				status = 0;
				triggerCount = -1;
			}
		}
		
		public function listenTrigger(cinematicManager:CinematicManager, player:Player, mapManager:MapManager,
									characterManager:CharacterManager, guiManager:GUIManager, propManager:PropManager):void {
			if (status == 1) {
				takeEffect(0, cinematicManager, player, mapManager, characterManager, guiManager, propManager);
				return;
			}
			if (blockList.length == 0) return;
			if (blockList[0].getReqLength() == 0) return;
			
			var blockIndex:int = -1;
			for (var b:int = 0; b < blockList.length; b++) {
				// Go through all trigger blocks and see which one is awake.
				if (blockList[b].isAwake()) {
					blockIndex = b;
					break;
				}
			}
			if (blockIndex < 0) return;
			
			for (var i:int = 0; i < blockList[blockIndex].getReqLength(); i++) {
				// Go through requirements and see if they are all fulfilled.
				var parsedReq:Array = blockList[blockIndex].getReqAt(i).split('.');
				var parsedReqParams:String = parsedReq[1];
				var listenerParsedReq:Array = parsedReqParams.split('-');
				for (var j:int = 0; j < listenerParsedReq.length; j++)
					listenerParsedReq[j] = listenerParsedReq[j].replace("<hyphen>", "\-");
				
				// Check every type of requirement.  If at any point something returns false, stop looking.
				if (parsedReq[0] == "self") {
					if (!this.listenToTrigger(listenerParsedReq))
						return;
				}
				else if (parsedReq[0] == "map") {
					if (!mapManager.listenToTrigger(listenerParsedReq))
						return;
				}
				else if (parsedReq[0] == "prop") {
					if (!propManager.listenToTrigger(listenerParsedReq))
						return;
				}
				else if (parsedReq[0] == "trigger") {
					if (!CinematicManager.getSingleton().listenToTrigger(listenerParsedReq))
						return;
				}
				else if (parsedReq[0] == "character") {
					if (!characterManager.listenToTrigger(listenerParsedReq))
						return;
				}
				else if (parsedReq[0] == "player") {
					if (!player.listenToTrigger(listenerParsedReq))
						return;
				}
				else if (parsedReq[0] == "dialogue") {
					if (!DialogueLibrary.getSingleton().listenToTrigger(listenerParsedReq))
						return;
				}
				else if (parsedReq[0] == "spectral") {
					if (!SpectralManager.getSingleton().listenToTrigger(listenerParsedReq))
						return;
				}
				else if (parsedReq[0] == "sound") {
					if (!SoundManager.getSingleton().listenToTrigger(listenerParsedReq))
						return;
				}
				else if (parsedReq[0] == "gui") {
					if (!guiManager.listenToTrigger(listenerParsedReq))
						return;
				}
				else throw new Error("Cinematic Error: Invalid requirement type!");
			}
			// If the entire for-loop has completed, all of the requirements must be fulfilled.
			
			if (blockList.length == 1)
				activateTrigger();
			takeEffect(blockIndex, cinematicManager, player, mapManager, characterManager, guiManager, propManager);
			
		}
		
		private function takeEffect(blockIndex:int, cinematicManager:CinematicManager, player:Player, mapManager:MapManager,
									characterManager:CharacterManager, guiManager:GUIManager, propManager:PropManager):void {
			// Tell all relevant Managers that this trigger block has now activated so that they can
			//		carry out its effects.
			if (blockList.length == 0) return;
			
			for (var i:int = 0; i < blockList[blockIndex].getEffectLength(); i++) {
				var parsedEffect:Array = blockList[blockIndex].getEffectAt(i).split('.');
				var parsedEffectParams:String = parsedEffect[1];
				var listenerParsedEffect:Array = parsedEffectParams.split('-');
				for (var j:int = 0; j < listenerParsedEffect.length; j++)
					listenerParsedEffect[j] = listenerParsedEffect[j].replace("<hyphen>", "\-");
				for (var k:int = 0; k < listenerParsedEffect.length; k++)
					listenerParsedEffect[k] = listenerParsedEffect[k].replace("<dot>", ".");
				
				if (parsedEffect[0] == "self")
					this.performTriggerEffect(listenerParsedEffect);
					
				else if (parsedEffect[0] == "map")
					mapManager.performTriggerEffect(listenerParsedEffect);
				else if (parsedEffect[0] == "trigger")
					cinematicManager.performTriggerEffect
						(listenerParsedEffect, player, characterManager, mapManager, guiManager, propManager);
				else if (parsedEffect[0] == "character")
					characterManager.performTriggerEffect(listenerParsedEffect);
				else if (parsedEffect[0] == "player" && player != null)
					player.performTriggerEffect(listenerParsedEffect);
				else if (parsedEffect[0] == "dialogue")
					DialogueLibrary.getSingleton().performTriggerEffect(listenerParsedEffect);
				else if (parsedEffect[0] == "spectral")
					SpectralManager.getSingleton().performTriggerEffect(listenerParsedEffect);
				else if (parsedEffect[0] == "sound")
					SoundManager.getSingleton().performTriggerEffect(listenerParsedEffect);
				else if (parsedEffect[0] == "gui")
					guiManager.performTriggerEffect(listenerParsedEffect);
				else if (parsedEffect[0] == "prop")
					propManager.performTriggerEffect(listenerParsedEffect);
					
				else if (parsedEffect[0] == "cinematic")
					cinematicManager.performTriggerEffect
						(listenerParsedEffect, player, characterManager, mapManager, guiManager, propManager);
				else throw new Error("Cinematic Error: Invalid effect type!");
			}
			
			// We also need to take the necessary actions on other trigger blocks.
			if (blockIndex < blockList.length - 1) { 
				// If it isn't the last block, awaken the next block and put this one to sleep.
				blockList[blockIndex + 1].wakeUpBlock();
				blockList[blockIndex].sleepBlock();
			}
			else {
				// If it is the last block, put this one to sleep and awaken the very first block (restarting the trigger).
				blockList[blockIndex].sleepBlock();
				blockList[0].wakeUpBlock();
			}
			
		}
		
		private function listenToTrigger(parsedRequirement:Array):Boolean {
			var activeBlockIndex:int = -1;
			for (var i:int = 0; i < blockList.length; i++) {
				if (blockList[i].isAwake()) {
					activeBlockIndex = i;
					break;
				}
			}
			if (activeBlockIndex < 0) 
				return false;
			else
				return blockList[i].listenToBlock(parsedRequirement);
			
			return false;
		}
		private function performTriggerEffect(parsedEffect:Array):void {
			
			if (parsedEffect[0] == "setStatus") {
				var newStatus:String = parsedEffect[1];
				if (newStatus == "on") this.activateTrigger();
				else if (newStatus == "awake" && status == 0) this.wakeUpTrigger();
				else if (newStatus == "awake" && status == 1) this.deactivateTrigger();
				else if (newStatus == "asleep") this.sleepTrigger();
				else throw new Error("What are you doing with self.setTriggerStatus?!?!?!");
			}
		}
		
		public function saveTrigger(saveFile:SaveFile):void {
			saveFile.saveData(triggerName + "status", status);
		}
		public function loadTrigger(saveFile:SaveFile):void {
			if (saveFile.loadData(triggerName + "status") == null) return;
			
			status = parseInt(saveFile.loadData(triggerName + "status") + "");
		}
		
	}

}