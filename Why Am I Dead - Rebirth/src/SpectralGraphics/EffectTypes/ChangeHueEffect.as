package SpectralGraphics.EffectTypes 
{
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class ChangeHueEffect extends SpectralEffect
	{
		private var redOffset:uint;
		private var greenOffset:uint;
		private var blueOffset:uint;
		private var delta:int;
		private var redPos:int;
		private var redDiff:int;
		private var greenPos:int;
		private var greenDiff:int;
		private var bluePos:int;
		private var blueDiff:int;
		private var redDelta:int;
		private var greenDelta:int;
		private var blueDelta:int;
		private var startColor:uint;
		private var noise:Number;
		
		public function ChangeHueEffect(redOffset:uint, greenOffset:uint, blueOffset:uint, delta:int, startColor:uint = 0, noise:Number = 0) 
		{
			super(this);
			this.redOffset = redOffset;
			this.greenOffset = greenOffset;
			this.blueOffset = blueOffset;
			this.startColor = startColor;
			this.noise = noise;
			
			var colorHex:String = startColor.toString(16);
			var hexLength:int = colorHex.length;
			for (var i:int = 0; i < 8 - hexLength; i++)
				colorHex = "0" + colorHex;
			
			redPos = parseInt(colorHex.substring(2, 4), 16);
			greenPos = parseInt(colorHex.substring(4, 6), 16);
			bluePos = parseInt(colorHex.substring(6, 8), 16);
			
			this.delta = delta;
			if (redOffset != 0)
				this.redDelta = delta;
			if (greenOffset != 0)
				this.greenDelta = delta;
			if (blueOffset != 0)
				this.blueDelta = delta;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			// Noise is the percentage of times the effect doesn't fire
			if (Math.random() * 100 < noise) return;
			
			var temp:int = object.getColor();
			
			if (redDiff < -redOffset / 2) redDelta = -redDelta;
			else if (redDiff > redOffset / 2) redDelta = -redDelta;
			if (greenDiff < -greenOffset / 2) greenDelta = -greenDelta;
			else if (greenDiff > greenOffset / 2) greenDelta = -greenDelta;
			if (blueDiff < -blueOffset / 2) blueDelta = -blueDelta;
			else if (blueDiff > blueOffset / 2) blueDelta = -blueDelta;
			
			redPos += redDelta;
			redDiff += redDelta;
			greenPos += greenDelta;
			greenDiff += greenDelta;
			bluePos += blueDelta;
			blueDiff += blueDelta;
			
			if (redPos > 255)
				redPos = 255;
			if (greenPos > 255)
				greenPos = 255;
			if (bluePos > 255)
				bluePos = 255;
			
			var alphaHex:String = startColor.toString(16).substr(0, 2);
			var redHex:String = redPos.toString(16);
			if (redHex.length < 2) redHex = "0" + redHex;
			var greenHex:String = greenPos.toString(16);
			if (greenHex.length < 2) greenHex = "0" + greenHex;
			var blueHex:String = bluePos.toString(16);
			if (blueHex.length < 2) blueHex = "0" + blueHex;
			
			var hexStr:String = "0x" + alphaHex + redHex + greenHex + blueHex;
			temp = parseInt(hexStr, 16);
			
			object.changeColor(temp);
		}
		
	}

}