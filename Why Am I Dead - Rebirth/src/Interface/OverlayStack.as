package Interface 
{
	import Characters.CharacterManager;
	import Core.Game;
	import Dialogue.DialogueLibrary;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import Maps.MapManager;
	import Misc.Stack;
	import Props.PropManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class OverlayStack extends Sprite
	{
		private var pauseOverlay:Overlay;
		
		private var pauseBG:Shape;
		private var resumeText:TextField;
		private var mainmenuText:TextField;
		
		private var overlayStack:Stack;
		
		public function OverlayStack() 
		{
			overlayStack = new Stack();
			
			
			pauseOverlay = new Overlay();
			
			pauseBG = new Shape();
			pauseBG.graphics.beginFill(0x000000, 1);
			pauseBG.graphics.drawRect( -10, -10, Main.getSingleton().getStageWidth() + 20,
										Main.getSingleton().getStageHeight() + 20);
			pauseBG.alpha = 0.7;
			pauseBG.graphics.endFill();
			
			var textFormat:TextFormat = new TextFormat("AppleKid");
			textFormat.size = 64;
			textFormat.color = 0xffffff;
			textFormat.bold = true;
			var textFormat2:TextFormat = new TextFormat("AppleKid");
			textFormat2.size = 24;
			textFormat2.color = 0xffffff;
			var pauseTextSmall:TextField = new TextField();
			pauseTextSmall.embedFonts = true;
			pauseTextSmall.defaultTextFormat = textFormat;
			pauseTextSmall.selectable = false;
			pauseTextSmall.text = "PAUSED";
			pauseTextSmall.width = pauseTextSmall.textWidth;
			
			var textFormat3:TextFormat = new TextFormat("AppleKid");
			textFormat3.size = 24;
			textFormat3.color = 0xffffff;
			var controlText:TextField = new TextField();
			controlText.embedFonts = true;
			controlText.defaultTextFormat = textFormat3;
			controlText.selectable = false;
			controlText.text = "Controls: \n WASD or arrow keys to move \n E or X to talk and open doors \n Space or C to possess \n P to pause / unpause";
			controlText.width = controlText.textWidth;
			
			resumeText = new TextField();
			resumeText.embedFonts = true;
			resumeText.defaultTextFormat = textFormat2;
			resumeText.selectable = false;
			resumeText.text = "RESUME GAME";
			resumeText.width = resumeText.textWidth + 5;
			resumeText.height = resumeText.textHeight + 5;
			resumeText.borderColor = 0xffffff;
			
			mainmenuText = new TextField();
			mainmenuText.embedFonts = true;
			mainmenuText.defaultTextFormat = textFormat2;
			mainmenuText.selectable = false;
			mainmenuText.text = "RETURN TO MAIN MENU";
			mainmenuText.width = mainmenuText.textWidth + 5;
			mainmenuText.height = mainmenuText.textHeight + 5;
			mainmenuText.borderColor = 0xffffff;
		}
		public function deactivateStack():void {
			if (getTopOverlay() != null)
				getTopOverlay().deactivateOverlay();
		}
		public function activateStack():void {
			if (getTopOverlay() != null)
				getTopOverlay().activateOverlay();
		}
		
		public function isEmpty():Boolean { return overlayStack.isEmpty(); }
		
		public function pushOverlay(overlay:Overlay):void {
			if (getTopOverlay() != null)
				getTopOverlay().deactivateOverlay();
			
			overlayStack.push(overlay);
			overlay.addOverlayToClient(this);
			
			getTopOverlay().activateOverlay();
		}
		public function peekStack():Overlay {
			return overlayStack.peek() as Overlay;
		}
		public function popStack():Overlay {
			var topOverlay:Overlay = getTopOverlay();
			if (topOverlay == null) return null;
			
			topOverlay.deactivateOverlay();
			topOverlay.removeOverlayFromClient(this);
			overlayStack.pop() as Overlay;
			
			if (getTopOverlay() != null)
				getTopOverlay().activateOverlay();
				
			Main.getSingleton().stage.focus = this;
			return topOverlay;
		}
		public function numOfOverlays():int {
			return overlayStack.getLength();
		}
		
		private function getTopOverlay():Overlay {
			if (overlayStack.first == null) return null;
			return overlayStack.peek() as Overlay;
		}
		
	}

}