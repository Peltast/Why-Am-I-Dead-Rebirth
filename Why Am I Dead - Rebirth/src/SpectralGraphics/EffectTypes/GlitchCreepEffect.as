package SpectralGraphics.EffectTypes 
{
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import SpectralGraphics.*;
	/**
	 * ...
	 * @author Peltast
	 */
	public class GlitchCreepEffect extends SpectralEffect
	{
		private var frequency:int;
		private var noise:int;
		private var shapeColor:uint;
		private var shapeWidth:int;
		private var shapeHeight:int;
		private var maxNumber:int;
		private var randomDimensions:Boolean;
		private var randomPlace:Boolean;
		private var minimumWidth:int;
		private var minimumHeight:int;
		
		private var checkerBoard:Dictionary;
		private var checkerPlaces:Array;
		private var checkerSize:int;
		private var numberCount:int;
		private var timerCount:int;
		private var blockBounds:Array;
		private var objectFactory:ObjectFactory;
		
		public function GlitchCreepEffect(frequency:int, noise:int, shapeColor:uint, shapeWidth:int, shapeHeight:int,
			maxNumber:int, randomDimensions:Boolean, randomPlace:Boolean = true, 
			checkerSize:int = 0, minimumWidth:int = 0, minimumHeight:int = 0) 
		{
			super(this, false);
			this.frequency = frequency;
			this.noise = noise;
			this.shapeColor = shapeColor;
			this.shapeWidth = shapeWidth;
			this.shapeHeight = shapeHeight;
			this.maxNumber = maxNumber;
			this.randomDimensions = randomDimensions;
			this.randomPlace = randomPlace;
			this.minimumWidth = minimumWidth;
			this.minimumHeight = minimumHeight;
			this.numberCount = 0;
			this.timerCount = 0;
			this.blockBounds = [];
			this.checkerSize = checkerSize;
			this.checkerBoard = new Dictionary();
			this.objectFactory = new ObjectFactory();
			
			if (!randomPlace) {
				checkerPlaces = [];
				for (var j:int = 0; j < 20; j++) {
					var row:Array = [];
					for (var i:int = 0; i < 540; i += 20)
						row.push(i);
					checkerPlaces.push(row);
				}
			}
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			if (numberCount >= maxNumber) return;
			timerCount++;
			
			if (timerCount > frequency) {
				var diceRoll:int = Math.random() * 100;
				if (diceRoll < noise) {
					timerCount = 0;
					return;
				}
				else {					
					timerCount = 0;
					generateBlock(layer);
					generateBlock(layer);
					numberCount++;
				}
			}
		}
		
		private function generateBlock(layer:SpectralLayer):void {
			var tempWidth:int = shapeWidth;
			var tempHeight:int = shapeHeight;
			
			if (randomDimensions) {
				tempWidth = (Math.random() * (shapeWidth - minimumWidth)) + minimumWidth;
				tempHeight = (Math.random() * (shapeHeight - minimumHeight)) + minimumHeight;
			}
			else if (!randomPlace) {
				tempWidth = checkerSize;
				tempHeight = checkerSize;
			}
			
			var newBlock:SpectralObject = objectFactory.createRectangle(tempWidth, tempHeight, shapeColor, 1);
			
			if (randomPlace) {
				var newBlockPos:Point = SpectralManager.getSingleton().findVacantArea
				(new Rectangle(0, 0, tempWidth, tempHeight), blockBounds, new Rectangle(0, 0, 540, 400));
				if (newBlockPos == null) return;
			}
			else {
				if (checkerPlaces.length == 0) return;
				
				var yRoll:int = Math.floor(Math.random() * checkerPlaces.length);
				var xRoll:int = Math.floor(Math.random() * checkerPlaces[yRoll].length);
				
				var xPos:int = checkerPlaces[yRoll][xRoll];
				checkerPlaces[yRoll].splice(xRoll, 1);
				if (checkerPlaces[yRoll].length == 0) checkerPlaces.splice(yRoll, 1);
				var yPos:int = yRoll * 20;
				newBlockPos = new Point(xPos, yPos);
			}
			
			layer.addObject(newBlock, newBlockPos.x, newBlockPos.y);
			blockBounds.push(new Rectangle(newBlockPos.x, newBlockPos.y, tempWidth, tempHeight));
		}
		
	}

}