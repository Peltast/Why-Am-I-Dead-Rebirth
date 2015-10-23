package Interface.DialogueSystem 
{
	import Core.Game;
	import Dialogue.Response;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import SpectralGraphics.EffectTypes.SpectralEffect;
	import SpectralGraphics.EffectTypes.ZoomEffect;
	import SpectralGraphics.SpectralImage;
	import SpectralGraphics.SpectralText;
	/**
	 * ...
	 * @author Peltast
	 */
	public class SpectralResponse extends ResponseInterface
	{
		private var textSize:int;
		private var textColor:uint;
		private var spectralImage:SpectralImage;
		private var spectralText:Array;
		private var textEffects:Array;
		private var mouseEffects:Array;
		
		private var selection:int;
		
		public function SpectralResponse(textSize:int, textColor:uint, textEffects:Array, mouseEffects:Array) 
		{
			super(this);
			
			this.textSize = textSize;
			this.textColor = textColor;
			this.textEffects = textEffects;
			this.mouseEffects = mouseEffects;
			spectralText = [];
			selection = -1;
		}
		
		override public function updateResponse(event:Event, mouse:Point):void 
		{
			var tempDict:Dictionary = new Dictionary();
			
			for (var i:int = 0; i < spectralText.length; i++) {
				var tempText:SpectralText = spectralText[i] as SpectralText;
				if (tempText.hitTestPoint(mouse.x, mouse.y)) {
					
					var proximity:int = Math.abs((tempText.x + tempText.getTextWidth() / 2) - mouse.x) + 
										Math.abs((tempText.y + tempText.getTextHeight() / 2 ) - mouse.y);
					tempDict[i] = proximity;
				}
			}
			var smallestDistance:int = int.MAX_VALUE;
			var closestIndex:int = -1;
			for (var key:Object in tempDict) {
				if (tempDict[key] < smallestDistance) {
					closestIndex = key as int;
					smallestDistance = tempDict[key];
				}
			}
			
			if (selection != -1 && selection != closestIndex) {
				spectralImage.removeEffect(selection, true);
			}
			if (closestIndex != -1 && selection != closestIndex) {
				spectralImage.addEffect(closestIndex, new ZoomEffect(true, true, .01, .01, .03, .1, false));
			}
			selection = closestIndex;
		}
		
		override public function drawResponse(currentResponse:Response):void 
		{
			var pastVals:Dictionary = new Dictionary();
			spectralImage = new SpectralImage(currentResponse.getResponses().length, 
							Main.getSingleton().getStageWidth(), Main.getSingleton().getStageHeight());
			
			for (var i:int = 0; i < currentResponse.getResponses().length; i++) {
				
				var newSpectralText:SpectralText = new SpectralText
					(currentResponse.getResponse(i), new GlowFilter(0x000000, 1, 2, 2, 10), textSize, textColor, 1);
				spectralText.push(newSpectralText);
				
				var posX:int = Math.random() * 
					(Main.getSingleton().getStageWidth() - (newSpectralText.getTextWidth() * 1.2));
				
				var dice:int = Math.random() * currentResponse.getResponses().length;
				while (pastVals[dice] != null) {
					dice = Math.random() * currentResponse.getResponses().length;
				}
				pastVals[dice] = dice;
				
				var workingHeight:int = Main.getSingleton().getStageHeight() - (newSpectralText.getTextHeight() * 1.5);
				var temp:int = workingHeight * ((dice + 0) / currentResponse.getResponses().length);
				var temp2:int = workingHeight * ((dice + 1) / currentResponse.getResponses().length);
				var posY:int = temp + Math.random() * (temp2 - temp);
				
				spectralImage.addObject(i, newSpectralText, posX, posY);
				
				for (var j:int = 0; j < textEffects.length; j++) {
					if (!textEffects[j] is SpectralEffect) continue;
					spectralImage.addEffect(i, textEffects[j]);
				}
			}
			
			this.addChild(spectralImage);
			spectralImage.beginImage();
			
		}
		override public function undrawResponse():void 
		{
			spectralImage.clearImage();
			this.removeChild(spectralImage);
			spectralText = [];
			selection = -1;
		}
		
		override public function checkResponseKey(key:KeyboardEvent, enterKeyDown:Boolean):int 
		{
			return -1;
		}
		override public function checkResponseMouse(mouse:MouseEvent):int 
		{
			return selection;
		}
		
	}

}