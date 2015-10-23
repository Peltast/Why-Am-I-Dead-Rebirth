package Core 
{
	import flash.display.Sprite;
	import Interface.OverlayStack;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class State extends Sprite
	{
		private var stateName:String;
		protected var overlayStack:OverlayStack;
		
		public function State(state:State) 
		{
			if(state != this)
				throw new Error("This class is meant to be treated as Abstract.");
			overlayStack = new OverlayStack();
			this.addChild(overlayStack);
		}
		
		public function deactivateState():void {
			overlayStack.deactivateStack();
		}
		public function activateState():void {
			overlayStack.activateStack();
		}
		
		public function drawState():void {
			
		}
		
	}

}