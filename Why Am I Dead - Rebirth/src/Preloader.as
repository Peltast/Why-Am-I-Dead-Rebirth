package 
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import Setup.GameLoader;
	
	
	public class Preloader extends MovieClip 
	{
		[Embed(source = "../lib/04B_03__.ttf", fontName = "AppleKid",
			mimeType = "application/x-font", 
			fontWeight="normal", 
			fontStyle="normal", 
			unicodeRange="U+0020-U+007E", 
			advancedAntiAliasing="false", 
			embedAsCFF = "false")]
		public var applekidstring:String;
		
		[Embed(source = "../lib/UI/Preloader1.png")]
		public static const Preloader1:Class;
		[Embed(source = "../lib/UI/Preloader2.png")]
		public static const Preloader2:Class;
		
		
		private var lastLoadPercent:Number;
		private var loadPercent:Number;
		private var screenBG:Shape;
		private var percentCount:TextField;
		private var playButton:TextField;
		
		private var preloadOwner:Bitmap;
		private var preloadGhost:Bitmap;
		private var ghostMask:Shape;
		
		public function Preloader() 
		{
			
			trace(stage.loaderInfo.url);
			
			var textFormat:TextFormat = new TextFormat("AppleKid");
			textFormat.color = 0x4287FF;
			textFormat.size = 36;
			
			screenBG = new Shape();
			screenBG.graphics.beginFill(0x000000);
			screenBG.graphics.drawRect(0, 0, 540, 400);
			screenBG.graphics.endFill();
			
			ghostMask = new Shape();
			ghostMask.graphics.beginFill(0xffffff, 1);
			ghostMask.graphics.drawRect(200, 312, 128, 0);
			ghostMask.graphics.endFill();
			
			preloadOwner = new Preloader1() as Bitmap;
			preloadOwner.x = 160;
			preloadOwner.y = 170;
			
			preloadGhost = new Preloader2() as Bitmap;
			preloadGhost.x = 200; 
			preloadGhost.y = 10;
			preloadGhost.alpha = .5;
			preloadGhost.mask = ghostMask;
			
			
			percentCount = new TextField();
			percentCount.embedFonts = true;
			percentCount.defaultTextFormat = textFormat;
			percentCount.x = 400;
			percentCount.y = 290;
			percentCount.selectable = false;
			percentCount.text = "0%";
			percentCount.height = percentCount.textHeight + 5;
			percentCount.width = percentCount.textWidth + 5;
			
			loadPercent = 0;
			
			playButton = new TextField();
			playButton.embedFonts = true;
			playButton.defaultTextFormat = textFormat;
			playButton.selectable = false;
			playButton.text = " PLAY ";
			playButton.borderColor = 0x7AFFFF;
			playButton.width = playButton.textWidth + 5;
			playButton.height = playButton.textHeight + 5;
			playButton.x = Math.ceil(270 - playButton.width/2);
			playButton.y = 340;
			
			this.addChild(screenBG);
			this.addChild(preloadOwner);
			this.addChild(preloadGhost);
			this.addChild(percentCount);
			
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);		
			
		}
		
		private function progress(e:ProgressEvent):void 
		{
		}
		
		private function checkFrame(e:Event):void 
		{
			var totalBytes:Number = loaderInfo.bytesTotal;
			var loadedBytes:Number = loaderInfo.bytesLoaded;
			
			loadPercent = Math.ceil((loadedBytes / totalBytes) * 100);
			
			if (loadPercent != lastLoadPercent) {
				var maskProgress:int = loadPercent * (252 / 100);
				
				ghostMask.graphics.beginFill(0xffffff, 1);
				ghostMask.graphics.drawRect(200, 262 - maskProgress, 128, maskProgress);
				ghostMask.graphics.endFill();
				preloadGhost.mask = ghostMask;
				
				percentCount.text = "-  " + loadPercent + "%";
				percentCount.height = percentCount.textHeight + 5;
				percentCount.width = percentCount.textWidth + 5;
				percentCount.y = 290 - maskProgress - (percentCount.height / 1.5);
			}
			
			if (loadPercent >= 100) 
				loadingFinished();
			
			lastLoadPercent = loadPercent;
		}
		
		private function loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			
			addChild(playButton);
			
			playButton.addEventListener(MouseEvent.MOUSE_OVER, checkHover);
			playButton.addEventListener(MouseEvent.MOUSE_OUT, checkOut);
			playButton.addEventListener(MouseEvent.MOUSE_UP, checkClick);
			
		}
		
		private function startup():void 
		{
			
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as MovieClip);
			
		}
		
		
		private function checkHover(mouse:MouseEvent):void {
			playButton.border = true;
		}
		private function checkOut(mouse:MouseEvent):void {
			playButton.border = false;
		}
		private function checkClick(mouse:MouseEvent):void {
			startup();
		}
		
		
	}
	
}