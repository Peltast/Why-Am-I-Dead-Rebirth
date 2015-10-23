package Core 
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import Interface.Overlay;
	import Setup.ControlsManager;
	import SpectralGraphics.SpectralImage;
	import SpectralGraphics.SpectralManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SpectralState extends State
	{
		private var keyEscape:Boolean;
		private var pauseOverlay:Overlay;
		
		private var duration:int;
		private var timer:int;
		
		public function SpectralState(spectralGraphicName:String, keyEscape:Boolean, duration:int = -1) 
		{
			super(this);
			
			var specImg:SpectralImage = SpectralManager.getSingleton().getSpecGraphic(spectralGraphicName);
			specImg.beginImage();
			this.keyEscape = keyEscape;
			this.duration = duration;
			this.timer = 0;
			this.addChild(specImg);
			this.addChild(overlayStack);
			
			
			if (keyEscape) {
				Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, checkCancelUp);
			}
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, checkPause);
			Game.getSingleton().stage.addEventListener(Event.DEACTIVATE, checkUnfocus);
			Game.getSingleton().stage.addEventListener(Event.ENTER_FRAME, updateSpectralState);
			
		}
		override public function activateState():void 
		{
			super.activateState();
			Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, checkPause);
			Game.getSingleton().stage.addEventListener(Event.DEACTIVATE, checkUnfocus);
			Main.getSingleton().stage.focus = this;
		}
		override public function deactivateState():void 
		{
			super.deactivateState();
			Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, checkPause);
			Game.getSingleton().stage.removeEventListener(Event.DEACTIVATE, checkUnfocus);
		}
		
		private function updateSpectralState(event:Event):void {
			if(!overlayStack.isEmpty())
				if (overlayStack.peekStack() == pauseOverlay) return;
			
			if (timer >= duration && duration >= 0) {
				Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, checkPause);
				Game.getSingleton().stage.removeEventListener(Event.DEACTIVATE, checkUnfocus);
				Game.getSingleton().stage.removeEventListener(Event.ENTER_FRAME, updateSpectralState);
				Game.popState();
			}
			timer++;
		}
		
		private function checkUnfocus(event:Event):void {
			if (!overlayStack.isEmpty()) {
				if (overlayStack.peekStack() != pauseOverlay)
					overlayStack.pushOverlay(pauseOverlay);
			}
			else
				overlayStack.pushOverlay(pauseOverlay);
		}
		private function checkPause(key:KeyboardEvent):void {
			if (checkKeyInput("Pause Key", key.keyCode) || checkKeyInput("Alt Pause Key", key.keyCode)) {
				if (!overlayStack.isEmpty()) {
					if (overlayStack.peekStack() == pauseOverlay)
						overlayStack.popStack();
					else
						overlayStack.pushOverlay(pauseOverlay);
				}
				else
					overlayStack.pushOverlay(pauseOverlay);
			}
		}
		
		private function checkCancelUp(key:KeyboardEvent):void {
			if (((checkKeyInput("Cancel Key", key.keyCode) || checkKeyInput("Alt Cancel Key", key.keyCode))			
				|| checkKeyInput("Special Key", key.keyCode) || checkKeyInput("Alt Special Key", key.keyCode))
				&& Game.getState() is SpectralState) {
				Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, checkCancelUp);
				Game.popState();
			}
		}
		private function checkKeyInput(keyName:String, keyCode:uint):Boolean {
			if (ControlsManager.getSingleton().getKey(keyName) == keyCode)
				return true;
			return false;
		}
	}

}