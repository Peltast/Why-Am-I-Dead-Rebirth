package SpectralGraphics 
{
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Peltast
	 */
	public class SpectralText extends SpectralObject
	{
		private var objectText:String;
		private var objectFontSize:int;
		private var objectTextField:TextField;
		private var outline:GlowFilter;
		
		public function SpectralText(text:String, outline:GlowFilter, size:int, color:uint, alpha:Number) 
		{
			objectText = text;
			objectFontSize = size;
			objectColor = color;
			this.outline = outline;
			
			var tempFormat:TextFormat = new TextFormat("AppleKid", objectFontSize, objectColor);
			
			objectTextField = new TextField();
			objectTextField.embedFonts = true;
			objectTextField.defaultTextFormat = tempFormat;
			objectTextField.selectable = false;
			objectTextField.text = objectText;
			objectTextField.width = objectTextField.textWidth + 10;
			objectTextField.height = objectTextField.textHeight + 10;
			if (outline != null ) objectTextField.filters = [outline];
			
			super(this, color, alpha, objectTextField.width, objectTextField.height);
			
			this.addChild(objectTextField);
		}
		
		public function getTextWidth():int {
			return objectTextField.textWidth;
		}
		public function getTextHeight():int {
			return objectTextField.textHeight;
		}
		public function getTextLength():int {
			return objectTextField.text.length;
		}
		
		public function appendText(text:String):void {
			objectTextField.appendText(text);
		}
		public function setText(text:String):void {
			objectTextField.text = text;
			objectText = text;
			
			objectTextField.width = objectTextField.textWidth + 5;
			objectTextField.height = objectTextField.textHeight + 5;
			
			if (objectTextField.width > 400) {
				objectTextField.width = 400;
				objectTextField.wordWrap = true;
				objectTextField.height = objectTextField.textHeight + 5;
			}
		}
		
		override public function getClone():SpectralObject 
		{
			return new SpectralText(this.objectText, this.outline, this.objectFontSize, this.objectColor, this.alpha);
		}
	}

}