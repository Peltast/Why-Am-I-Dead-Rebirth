package Core 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import Misc.Stack;
	import Setup.SaveManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Game extends Sprite
	{
		private static var stateStack:Stack;
		private static var singleton:Game;
		private static var tileSize:int;
		
		public static function getSingleton():Game {
			if (singleton == null)
				singleton = new Game();
			return singleton;
		}
		
		public function Game() 
		{
			stateStack = new Stack();			
			this.addEventListener(Event.ENTER_FRAME, playGame);
			tileSize = 32;
			SaveManager.getSingleton();
			
			var maskRectangle:Shape = new Shape();
			maskRectangle.graphics.beginFill(0xffffff);
			maskRectangle.graphics.drawRect
				(0, 0, Main.getSingleton().getStageWidth(), Main.getSingleton().getStageHeight());
			maskRectangle.graphics.endFill();
			this.mask = maskRectangle;
			
		}
		
		public function playGame(event:Event):void {
			
			if (!stateStack.isEmpty()) {
					
				if(stateStack.peek() is State){
					
					var currentState:State = State(stateStack.peek());
					currentState.drawState();
					
				}
				else {
					
					throw new Error("A non-state object was pushed into the game's state stack.");
					
				}
				
			}
			
		}
		
		public static function popState():void {
			if (stateStack.isEmpty()) return;
			
			singleton.removeChild(stateStack.peek() as DisplayObject);
			stateStack.peek().deactivateState();
			stateStack.pop();
			if (!stateStack.isEmpty()) {
				singleton.addChild(stateStack.peek() as DisplayObject);
				stateStack.peek().activateState();
			}
		}
		public static function pushState(state:State):void {
			if (!stateStack.isEmpty()) {
				var topState:State = stateStack.peek() as State;
				topState.deactivateState();
				singleton.removeChild(stateStack.peek() as DisplayObject);
			}
			singleton.addChild(state);
			stateStack.push(state);
			state.activateState();
			var j:int = 0;
		}
		public static function getState():State {
			return stateStack.peek() as State;
		}
		public static function getTileSize():int {
			return tileSize;
		}
		
		public function resizeMask(event:Event):void {
			var maskRectangle:Shape = new Shape();
			maskRectangle.graphics.beginFill(0xffffff);
			maskRectangle.graphics.drawRect
				(0, 0, Main.getSingleton().getStageWidth(), Main.getSingleton().getStageHeight());
			maskRectangle.graphics.endFill();
			this.mask = maskRectangle;
		}
		
		public function replaceGeneralTerm(term:String):String {
			if (stateStack.peek() is GameState) {
				return stateStack.peek().findGeneralTerm(term);
			}
			else return "";
		}
		
	}
}