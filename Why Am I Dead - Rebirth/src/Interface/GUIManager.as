package Interface 
{
	import Characters.Character;
	import Characters.Player;
	import Core.GameState;
	import flash.display.Shape;
	import flash.events.Event;
	import Interface.DialogueSystem.DialogueBox;
	import Main;
	import Dialogue.*;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import Setup.GameLoader;
	import Sound.SoundManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class GUIManager extends Sprite
	{
		private static var singleton:GUIManager;
		
		private var host:Sprite;
		private var dialogueBox:DialogueBox;
		private var muteButton:Sprite;
		private var soundOnBmp:Bitmap;
		private var soundOffBmp:Bitmap;
		
		private var saveFill:Shape;
		private var blackFill:Shape;
		private var fadeWait:int;
		private var fadeDelta:Number;
		
		public static function getSingleton():GUIManager {
			if (singleton == null)
				singleton = new GUIManager;
			return singleton;
		}
		
		public function GUIManager() 
		{
			Main.getSingleton().addChild(this);
			dialogueBox = new DialogueBox();
			this.addChild(dialogueBox);
			
			muteButton = new Sprite();
			muteButton.x = 510;
			muteButton.y = 10;
			
			soundOnBmp = new GameLoader.SoundOn() as Bitmap;
			soundOffBmp = new GameLoader.SoundOff() as Bitmap;
			muteButton.addChild(soundOnBmp);
			muteButton.addEventListener(MouseEvent.MOUSE_UP, checkMuteClick);
			this.addChild(muteButton);
			
			saveFill = new Shape();
			saveFill.graphics.beginFill(0x6DFFE4, 1);
			saveFill.graphics.drawRect
				(-20, -20, Main.getSingleton().getStageWidth() + 40, Main.getSingleton().getStageHeight() + 40);
			saveFill.alpha = 1;
			saveFill.graphics.endFill();
			
			blackFill = new Shape();
			blackFill.graphics.beginFill(0x000000, 1);
			blackFill.graphics.drawRect
				( -20, -20, Main.getSingleton().getStageWidth() + 40, Main.getSingleton().getStageHeight() + 40);
			blackFill.alpha = 1;
			blackFill.graphics.endFill();
			
		}
		
		public function resetGUIManager():void {
			dialogueBox.endDialogue();
			if (this.contains(muteButton)) removeChild(muteButton);
			singleton = null;
		}
		
		public function pauseDialogue():void {
			if (dialogueBox.getDialogueOn())
				dialogueBox.pauseDialogue();
		}
		public function resumeDialogue():void {
			if (dialogueBox.getDialogueOn())
				dialogueBox.resumeDialogue();
		}
		
		public function updateGUI():void {
			if (host == null) return;
			if (!host.contains(this)) return;
			
			while (host.getChildIndex(this) < host.numChildren - 1) {
				var currentIndex:int = host.getChildIndex(this);
				host.swapChildren(this, host.getChildAt(currentIndex + 1));
			}
			dialogueBox.x = -host.x;
			dialogueBox.y = -host.y;
			muteButton.x = -host.x + 510;
			muteButton.y = -host.y + 10;
			saveFill.x = -host.x;
			saveFill.y = -host.y;
			blackFill.x = -host.x;
			blackFill.y = -host.y;
		}
		
		public function checkMuteClick(mouse:MouseEvent):void {
			
			if (getBounds(muteButton.getChildAt(0)).containsPoint(new Point(mouse.localX, mouse.localY))) {
				
				if (muteButton.getChildAt(0) == soundOnBmp) {
					muteButton.removeChild(soundOnBmp);
					muteButton.addChild(soundOffBmp);
					SoundManager.getSingleton().muteSound();
				}
				else if (muteButton.getChildAt(0) == soundOffBmp) {
					muteButton.removeChild(soundOffBmp);
					muteButton.addChild(soundOnBmp);
					SoundManager.getSingleton().unMuteSound();
				}
				
			}
			
		}
		
		public function setHost(host:Sprite):void { this.host = host; }
		public function startDialogue(dialogue:Dialogue, subjectCharacter:Character = null, spectral:Boolean = false): void {
			
			if (dialogue != null) dialogueBox.startDialogue(dialogue, subjectCharacter, spectral); 
		}
		public function inDialogue():Boolean {
			if (dialogueBox.getDialogueOn()) return true;
			return false;
		}
		
		public function listenToTrigger(parsedRequirement:Array):Boolean {
			
			if (parsedRequirement[0] == "inDialogue") {
				if (inDialogue()) return true;
				else return false;
			}
			else if (parsedRequirement[0] == "outOfDialogue") {
				if (inDialogue()) return false;
				else return true;
			}
			else if (parsedRequirement[0] == "inSpecificDialogue") {
				var dialogueName:String = parsedRequirement[1];
				if (dialogueBox.getDialogueName() == dialogueName && inDialogue()) return true;
				else return false;
			}
			
			return false;
		}
		
		public function performTriggerEffect(parsedEffect:Array):void {
			
			if (parsedEffect[0] == "startDialogue") {
				// Initiate given dialogue at a given entry point.
				if (parsedEffect.length < 3) throw new Error("Trigger error: Effect was scripted incorrectly.");
				
				var dialogue:Dialogue = DialogueLibrary.getSingleton().retrieveDialogue(parsedEffect[1]);
				dialogue.changeRootAction(parsedEffect[2]);
				var spectralDialogue:Boolean = false;
				if (parsedEffect.length > 3) {
					if (parsedEffect[3] == "true") spectralDialogue = true;
					else if (parsedEffect[3] == "false") spectralDialogue = false;
				}
				
				this.startDialogue(dialogue, null, spectralDialogue);
			}
			else if (parsedEffect[0] == "flashEffect") {
				
				this.addChild(saveFill);
				Main.getSingleton().stage.addEventListener(Event.ENTER_FRAME, fadeInMap);
			}
			
			else if (parsedEffect[0] == "blackEffect") {
				
				fadeWait = parseInt(parsedEffect[1]);
				fadeDelta = parseFloat(parsedEffect[2]);
				
				this.addChild(blackFill);
				Main.getSingleton().stage.addEventListener(Event.ENTER_FRAME, fadeInMapBlack);
			}
			
		}
		
		private function fadeInMap(event:Event):void {
			if (saveFill.alpha <= 0) { 
				this.removeChild(saveFill);
				saveFill.alpha = 1;
				Main.getSingleton().stage.removeEventListener(Event.ENTER_FRAME, fadeInMap);
			}
			else {
				saveFill.alpha -= .1;
			}
		}
		
		private function fadeInMapBlack(event:Event):void {
			if (fadeWait > 0) {
				fadeWait--;
			}
			else if (saveFill.alpha <= 0) { 
				this.removeChild(blackFill);
				blackFill.alpha = 1;
				Main.getSingleton().stage.removeEventListener(Event.ENTER_FRAME, fadeInMapBlack);
			}
			else {
				blackFill.alpha -= fadeDelta;
			}
		}
		
	}

}