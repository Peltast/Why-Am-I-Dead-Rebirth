package SpectralGraphics.EffectTypes 
{
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import Misc.Queue;
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralManager;
	import SpectralGraphics.SpectralObject;
	import SpectralGraphics.SpectralText;
	/**
	 * ...
	 * @author Peltast
	 */
	public class MindReadEffect extends SpectralEffect
	{
		private var thoughts:Vector.<String>;
		private var fadeIn:Boolean;
		private var fadeOut:Boolean;
		private var fadeinLength:int;
		private var fadeoutLength:int;
		private var duration:int;
		private var interval:int;
		private var noise:int;
		private var noOfThoughts:int;
		private var color:uint;
		private var smallestSize:int;
		private var largestSize:int;
		
		private var intervalCount:int;
		private var durationCount:int;
		private var fadeinList:Vector.<SpectralText>;
		private var fadeoutList:Vector.<SpectralText>;
		private var thoughtQueue:Queue;
		private var durationQueue:Queue;
		private var allThoughtBounds:Array;
		private var area:Rectangle;
		private var randomOrder:Boolean;
		private var randomPlace:Boolean;
		private var outline:Boolean;
		private var orderCount:int;
		
		public function MindReadEffect(thoughtLib:ByteArray, thoughtKey:String, fadeIn:Boolean, fadeOut:Boolean, 
			fadeinLength:int, fadeoutLength:int, duration:int, interval:int, noise:int, noOfThoughts:int, 
			color:uint, smallestSize:int, largestSize:int, area:Rectangle = null, randomOrder:Boolean = true,
			randomPlace:Boolean = true, outline:Boolean = true) 
		{
			super(this, false);
			
			this.thoughts = parseThoughts(thoughtLib, thoughtKey);
			this.fadeIn = fadeIn;
			this.fadeOut = fadeOut;
			this.fadeinLength = fadeinLength;
			this.fadeoutLength = fadeoutLength;
			this.duration = duration;
			this.interval = interval;
			this.noise = noise;
			this.noOfThoughts = noOfThoughts;
			this.color = color;
			this.smallestSize = smallestSize;
			this.largestSize = largestSize;
			this.randomOrder = randomOrder;
			this.randomPlace = randomPlace;
			this.outline = outline;
			this.orderCount = 0;
			if (area == null) this.area = new Rectangle(0, 0, 540, 400);
			else this.area = area;
			
			intervalCount = 0;
			durationCount = 0;
			fadeinList = new Vector.<SpectralText>();
			fadeoutList = new Vector.<SpectralText>();
			allThoughtBounds = [];
			thoughtQueue = new Queue();
			durationQueue = new Queue();
		}
		private function parseThoughts(thoughtLibrary:ByteArray, thoughtKey:String):Vector.<String> {
			var thoughtList:Vector.<String> = new Vector.<String>();
			var fileStr:String = thoughtLibrary.toString();
			var fileArray:Array = fileStr.split(/\n/);
			var onKey:Boolean = false;
			
			for (var i:int = 0; i < fileArray.length; i++) {
				if (fileArray[i].indexOf("ThoughtsInit") >= 0 && !onKey) {
					var title:String = fileArray[i];
					title = title.replace("\n", "");
					title = title.replace("\r", "");
					var parsedTitle:Array = title.split(':');
					
					if (parsedTitle[1] == thoughtKey){
						onKey = true;
						continue;
					}
				}
				
				if (fileArray[i].indexOf("end thoughts") >= 0) {
					if (onKey)
						break;
				}
				
				if (onKey) {
					var newThought:String = fileArray[i];
					newThought = newThought.replace("\n", "");
					newThought = newThought.replace("\r", "");
					
					var newlinePos:int = newThought.indexOf("<n>");
					if (newlinePos > 0) {
						newThought = newThought.substr(0, newlinePos) + "\n" + newThought.substr(newlinePos + 3);
					}
					thoughtList.push(newThought);
				}
				
			}
			
			return thoughtList;
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			
			for (var i:int = 0; i < fadeinList.length; i++) {
				var thought:SpectralText = fadeinList[i];
				thought.alpha += 1 / fadeinLength;
				if (fadeinLength == 0) thought.alpha = 1;
				
				if (thought.alpha >= 1) {
					thought.alpha = 1;
					thoughtQueue.push(thought);
					durationQueue.push(new int(duration));
					allThoughtBounds.push(thought);
					fadeinList.splice(i, 1);
				}
			}
			for (var j:int = 0; j < fadeoutList.length; j++) {
				thought = fadeoutList[j];
				thought.alpha -= 1 / fadeoutLength;
				if (thought.alpha == 0) thought.alpha = 0;
				
				if (thought.alpha <= 0) {
					layer.removeObject(thought);
					fadeoutList.splice(j, 1);
				}
			}
			
			if(!durationQueue.isEmpty()){
				durationCount++;
				if (durationCount >= durationQueue.peek() ) {
					durationQueue.pop();
					var oldThought:SpectralText = thoughtQueue.pop() as SpectralText;
					
					for (var k:int = 0; k < allThoughtBounds.length; k++ ) {
						if(oldThought == allThoughtBounds[k])
							allThoughtBounds.splice(k, 1);
					}
					
					fadeoutList.push(oldThought);
					durationCount = 0;
				}
			}
			intervalCount--;
			if (intervalCount <= 0) {
				if (allThoughtBounds.length >= noOfThoughts) 
					return;
				
				var random:int = Math.random() * 100;
				if (random < noise) return;
				
				var index:int;
				if(randomOrder)
					index = Math.random() * (thoughts.length - 1);
				else {
					if (orderCount >= thoughts.length) return;
					index = orderCount;
					orderCount++;
				}
				
				var size:int = (Math.random() * (largestSize - smallestSize)) + smallestSize;
				if (outline)
					var glowFilter:GlowFilter = new GlowFilter(0x000000, 1, 2, 2, 10);
				else 
					glowFilter = null;
					
				var newThought:SpectralText = new SpectralText(thoughts[index], glowFilter, size, color, 0);
				if (newThought.width > 520)
					newThought = new SpectralText(thoughts[index], glowFilter, smallestSize, color, 0);
				var thoughtPos:Point;
				
				if (randomPlace){
					thoughtPos = SpectralManager.getSingleton().findVacantArea
						(new Rectangle(0, 0, newThought.width, newThought.height), allThoughtBounds, area);
					if (thoughtPos == null)
						return;
				}
				else
					thoughtPos = new Point
						(area.x + (area.width / 2) - (newThought.width / 2), 
						area.y + (area.height / 2) - (newThought.height / 2));
				
				newThought.alpha = 0;
				layer.addObject(newThought, thoughtPos.x, thoughtPos.y);
				fadeinList.push(newThought);
				
				intervalCount = interval;
			}
			
		}
		
		
	}

}
