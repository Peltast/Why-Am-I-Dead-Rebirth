package Interface.MenuSystem 
{
	import flash.display.Shape;
	import flash.display3D.textures.RectangleTexture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import Interface.OverlayItem;
	import Setup.SaveFile;
	/**
	 * ...
	 * @author Peltast
	 */
	public class SaveSlot extends Button
	{
		private var saveFile:SaveFile;
		private var background:Shape;
		private var index:int;
		private var effects:Array;
		
		private var title:TextField;
		private var dateText:TextField;
		private var timeText:TextField;
		private var chapterText:TextField;
		
		private var titleShadow:TextField;
		private var dateShadow:TextField;
		private var timeShadow:TextField;
		private var chapterShadow:TextField;
		
		private var characterSilhouettes:Array;
		
		public function SaveSlot(index:int, saveFile:SaveFile, effects:Array) 
		{
			super("", 0, new Rectangle(), []);
			
			this.saveFile = saveFile;
			this.index = index;
			this.effectList = effects;
			
			background = new Shape();
			background.graphics.beginFill(0x352323, 1);
			background.graphics.drawRect(0, 0, 180, 400);
			background.graphics.endFill();
			this.addChild(background);
			
			var titleFormat:TextFormat = new TextFormat("SkinnyNoir", 24, 0xffffff);
			titleFormat.bold = true;
			var subtitleFormat:TextFormat = new TextFormat("SkinnyNoir", 16, 0xffffff);
			subtitleFormat.bold = true;
			var shadowFormat:TextFormat = new TextFormat("SkinnyNoir", 24, 0x000000);
			titleFormat.bold = true;
			var subshadowFormat:TextFormat = new TextFormat("SkinnyNoir", 16, 0x000000);
			subshadowFormat.bold = true;
			
			title = new TextField();
			title.embedFonts = true;
			title.defaultTextFormat = titleFormat;
			title.text = "File  " + (index + 1);
			title.selectable = false;
			title.y = 70;
			title.x = 20;
			title.width = title.textWidth + 5;
			titleShadow = new TextField();
			titleShadow.embedFonts = true;
			titleShadow.defaultTextFormat = shadowFormat;
			titleShadow.text = title.text;
			titleShadow.selectable = false;
			titleShadow.x = title.x;
			titleShadow.width = titleShadow.textWidth + 5;
			titleShadow.y = title.y + 2;
			
			dateText = new TextField();
			dateText.embedFonts = true;
			dateText.defaultTextFormat = subtitleFormat;
			dateText.text = saveFile.loadData("saveDate") + "";
			dateText.selectable = false;
			dateText.y = 150;
			dateText.x = 20;
			dateText.width = dateText.textWidth + 5;
			dateShadow = new TextField();
			dateShadow.embedFonts = true;
			dateShadow.defaultTextFormat = subshadowFormat;
			dateShadow.text = dateText.text;
			dateShadow.selectable = false;
			dateShadow.x = dateText.x;
			dateShadow.y = dateText.y + 2;
			dateShadow.width = dateShadow.textWidth + 5;
			
			timeText = new TextField();
			timeText.embedFonts = true;
			timeText.defaultTextFormat = subtitleFormat;
			timeText.text = saveFile.loadData("saveTime") + "";
			timeText.selectable = false;
			timeText.y = 185;
			timeText.x = 20;
			timeText.width = timeText.textWidth + 5;
			timeShadow = new TextField();
			timeShadow.embedFonts = true;
			timeShadow.defaultTextFormat = subshadowFormat;
			timeShadow.text = timeText.text;
			timeShadow.selectable = false;
			timeShadow.x = timeText.x;
			timeShadow.y = timeText.y + 2;
			timeShadow.width = timeShadow.textWidth + 5;
			
			chapterText = new TextField();
			chapterText.embedFonts = true;
			chapterText.defaultTextFormat = subtitleFormat;
			chapterText.text = saveFile.loadData("currentChapter") + "";
			chapterText.selectable = false;
			chapterText.y = 250;
			chapterText.x = 20;
			chapterText.width = chapterText.textWidth + 5;
			chapterShadow = new TextField();
			chapterShadow.embedFonts = true;
			chapterShadow.defaultTextFormat = subshadowFormat;
			chapterShadow.text = chapterText.text;
			chapterShadow.selectable = false;
			chapterShadow.x = chapterText.x;
			chapterShadow.y = chapterText.y +2;
			chapterShadow.width = chapterShadow.textWidth + 5;
			
			
			if (saveFile.loadData("init") == null) {
				dateText.text = "Empty";
				dateText.width = dateText.textWidth + 5;
				dateShadow.text = "";
				timeText.text = "";
				timeShadow.text = "";
				chapterText.text = "";
				chapterShadow.text = "";
			}
			
			
			this.addChild(titleShadow);
			this.addChild(dateShadow);
			this.addChild(timeShadow);
			this.addChild(chapterShadow);
			
			this.addChild(title);
			this.addChild(dateText);
			this.addChild(timeText);
			this.addChild(chapterText);
			
			this.removeChild(buttonShape);
			this.removeChild(buttonText);
			this.removeEventListener(Event.ENTER_FRAME, updateBorder);
		}
		
		override protected function buttonHover():void 
		{
			if (active) return;
			isHovered = true;
			
			repaintBackground(0x4F5768);
		}
		override protected function buttonUnhover():void 
		{
			isHovered = false;
			
			repaintBackground(0x352323);
		}
		
		override protected function buttonHit():void 
		{
			if (effectList != null) {
				for each(var effect:ButtonEffect in effectList)
					effect.performEffect();
			}
		}
		
		private function repaintBackground(color:uint):void {
			this.removeChild(background);
			
			background = new Shape();
			background.graphics.beginFill(color, 1);
			background.graphics.drawRect(0, 0, 180, 400);
			background.graphics.endFill();
			
			this.addChildAt(background, 0);
		}
		
		
		override protected function hitAnimation(event:Event):void 
		{
			this.removeEventListener(Event.ENTER_FRAME, hitAnimation);
		}
		
		
		
		override protected function checkMouseHover(mouse:MouseEvent):void {
			if (!isClicked) {
				if (background.hitTestPoint(mouse.stageX, mouse.stageY))
					buttonHover();
				else if(isHovered)
					buttonUnhover();
			}
			else {
				if (background.hitTestPoint(mouse.stageX, mouse.stageY)) 
					return;
				else
					buttonUnhover();
			}
		}
		
		override protected function checkMouseClick(mouse:MouseEvent):void {
			if (isHovered) {
				if (mouse.buttonDown && background.hitTestPoint(mouse.stageX, mouse.stageY)){
					isClicked = true;
				}
				else{
					isClicked = false;
				}
			}
		}
		
		override protected function checkMouseUp(mouse:MouseEvent):void {
			if (isClicked) {
				if (!mouse.buttonDown && background.hitTestPoint(mouse.stageX, mouse.stageY)){
					isClicked = false;
					isHovered = true;
					
					buttonHit();
				}
			}
		}
		
		public function resetSaveText():void {
			dateText.text = "Empty";
			dateShadow.text = "";
			timeText.text = "";
			timeShadow.text = "";
			chapterText.text = "";
			chapterShadow.text = "";
		}
		public function updateSaveText():void {
			
			dateText.text = saveFile.loadData("saveDate") + "";
			dateText.width = dateText.textWidth + 5;
			dateShadow.text = dateText.text;
			dateShadow.width = dateText.width;
			
			timeText.text = saveFile.loadData("saveTime") + "";
			timeText.width = timeText.textWidth + 5;
			timeShadow.text = timeText.text;
			timeShadow.width = timeText.width;
			
			chapterText.text = saveFile.loadData("currentChapter") + "";
			chapterText.width = chapterText.textWidth + 5;
			chapterShadow.text = chapterText.text;
			chapterShadow.width = chapterText.width;
			
			if (saveFile.loadData("init") == null) {
				dateText.text = "Empty";
				dateText.width = dateText.textWidth + 5;
				dateShadow.text = "";
				timeText.text = "";
				timeShadow.text = "";
				chapterText.text = "";
				chapterShadow.text = "";
			}
		}
		
	}

}