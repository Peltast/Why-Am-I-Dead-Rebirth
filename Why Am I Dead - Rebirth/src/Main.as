package 
{
	import flash.display.*;
	import flash.events.Event;
	import Core.*;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import Sound.SoundManager;
	
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	
	[Frame(factoryClass="Preloader")]
	public class Main extends MovieClip
	{
		[Embed(source = "../lib/04B_03__.ttf", fontName = "AppleKid",
			mimeType = "application/x-font", 
			fontWeight="normal", 
			fontStyle="normal", 
			unicodeRange="U+0020-U+007E", 
			advancedAntiAliasing="false", 
			embedAsCFF = "false")]
		public var applekidstring:String;
		
		[Embed(source = "../lib/Pixel-Noir Skinny Caps.ttf", fontName = "SkinnyNoir",
			mimeType = "application/x-font", 
			fontWeight="normal", 
			fontStyle="normal", 
			unicodeRange="U+0020-U+007E", 
			advancedAntiAliasing="false", 
			embedAsCFF = "false")]
		public var skinnynoirstring:String;
		
		public var rootURL:String;
		
		private static var mainSingleton:Main;
		private static var game:Core.Game;
		
		private var stageWidth:int;
		private var stageHeight:int;
		private var frameRate:Number;
		
		public function Main():void 
		{
			applekidstring = "AppleKid";
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function init(e:Event = null):void 
		{
			rootURL = "../";
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.stage.stageFocusRect = false;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.frameRate = stage.frameRate;
			
			//stage.displayState = StageDisplayState.FULL_SCREEN;
			
			stageWidth = 540;
			stageHeight = 400;
			this.scaleX = 1;
			this.scaleY = 1;
			
			trace(stage.stageHeight * this.scaleY);
			stage.fullScreenSourceRect = new Rectangle(0, 0, stageWidth * this.scaleX, stageHeight * this.scaleY);
			stage.showDefaultContextMenu = false;
			
			stage.quality = StageQuality.LOW;
			mainSingleton = this;
			
			var blackBG:Shape = new Shape();
			blackBG.graphics.beginFill(0, 1);
			blackBG.graphics.drawRect(0, 0, 540, 400);
			blackBG.graphics.endFill();
			
			this.addChild(blackBG);
			this.addChild(Game.getSingleton());
			var menuState:MenuState = new MenuState();
			var splashState:SplashState = new SplashState();
			Game.pushState(splashState);
			
			this.stage.addEventListener(Event.RESIZE, resizeGameMask);
		}
		
		public static function getSingleton():Main {
			if (mainSingleton == null)
				mainSingleton = new Main();
			return mainSingleton;
		}
		
		public function getStage():Stage {
			if (this.stage != null) return this.stage;
			return null;
		}
		
		public function getStageWidth():int {
			return stageWidth;
		}
		public function getStageHeight():int {
			return stageHeight;
		}
		public function getFrameRate():Number {
			return frameRate;
		}
		
		public function resizeGameMask(event:Event):void {
			Game.getSingleton().resizeMask(event);
			stage.fullScreenSourceRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}
		
		public function onConnectError(status:String):void {
			// handle error here...
		}
		
		
	}
	
}