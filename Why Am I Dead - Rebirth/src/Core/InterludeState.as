package Core 
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import Interface.CinematicScreen;
	import Interface.Overlay;
	import Interface.PauseScreen;
	import Setup.ControlsManager;
	import SpectralGraphics.SpectralImage;
	import SpectralGraphics.SpectralManager;
	/**
	 * ...
	 * @author Peltast
	 */
	public class InterludeState extends State
	{
		private var cinematicScreen:CinematicScreen;
		private var spectralOverlay:Overlay;
		private var pauseOverlay:Overlay;
		private var interludeSpectralImage:SpectralImage;
		
		private var timer:int;
		
		public function InterludeState() 
		{
			super(this);
			
			this.addChild(overlayStack);
			spectralOverlay = new Overlay();
			pauseOverlay = new Overlay();
			cinematicScreen = new CinematicScreen();
			
			spectralOverlay.addToOverlay(cinematicScreen);
			pauseOverlay.addToOverlay(new PauseScreen(overlayStack));
			
			overlayStack.pushOverlay(spectralOverlay);
			
			interludeSpectralImage = SpectralManager.getSingleton().getSpecGraphic("Interlude");
			interludeSpectralImage.beginImage();
			cinematicScreen.addChild(interludeSpectralImage);
			
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, checkPause);
			Game.getSingleton().stage.addEventListener(Event.DEACTIVATE, checkUnfocus);
			Game.getSingleton().stage.addEventListener(Event.ENTER_FRAME, updateInterlude);
		}
		
		public function updateInterlude(event:Event):void {
			
			if (timer > 3000) {
				interludeSpectralImage.stopImage();
				Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, checkPause);
				Game.getSingleton().stage.removeEventListener(Event.DEACTIVATE, checkUnfocus);
				Game.getSingleton().stage.removeEventListener(Event.ENTER_FRAME, updateInterlude);
				Game.popState();
			}
			timer++;
		}
		
		
		override public function activateState():void 
		{
			super.activateState();
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, checkPause);
			Game.getSingleton().stage.addEventListener(Event.DEACTIVATE, checkUnfocus);
			Game.getSingleton().stage.addEventListener(Event.ENTER_FRAME, updateInterlude);
			Main.getSingleton().stage.focus = this;
			
		}
		override public function deactivateState():void 
		{
			super.deactivateState();
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, checkPause);
			Game.getSingleton().stage.removeEventListener(Event.DEACTIVATE, checkUnfocus);
			Game.getSingleton().stage.removeEventListener(Event.ENTER_FRAME, updateInterlude);
		}
		
		
		private function checkUnfocus(event:Event):void {
			if (!overlayStack.isEmpty()) {
				if (overlayStack.peekStack() != pauseOverlay) {
					overlayStack.pushOverlay(pauseOverlay);
				}
			}
			else {
				overlayStack.pushOverlay(pauseOverlay);
			}
		}
		private function checkPause(key:KeyboardEvent):void {
			if (checkKeyInput("Pause Key", key.keyCode) || checkKeyInput("Alt Pause Key", key.keyCode)) {
				if (!overlayStack.isEmpty()) {
					if (overlayStack.peekStack() == pauseOverlay) {
						overlayStack.popStack();
					}
					else {
						overlayStack.pushOverlay(pauseOverlay);
					}
				}
				else {
					overlayStack.pushOverlay(pauseOverlay);
				}
			}
		}
		
		
		private function checkKeyInput(keyName:String, keyCode:uint):Boolean {
			if (ControlsManager.getSingleton().getKey(keyName) == keyCode)
				return true;
			return false;
		}
	}

}