package Interface.MenuSystem 
{
	import adobe.utils.CustomActions;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import Interface.OverlayItem;
	import Misc.Tuple;
	/**
	 * ...
	 * @author Peltast
	 */
	public class Slider extends OverlayItem
	{
		private var increaseTri:Shape;
		private var decreaseTri:Shape;
		private var increaseEffect:ButtonEffect;
		private var decreaseEffect:ButtonEffect;
		
		private var slideFrame:Shape;
		private var filledSlide:Shape;
		
		private var increments:int;
		private var status:Number;
		private var horizontal:Boolean;
		private var slideLength:int;
		
		public function Slider(horizontal:Boolean, slideLength:int, increments:int, status:Number, effects:Tuple) 
		{
			super(this, false);
			
			this.horizontal = horizontal;
			this.slideLength = slideLength;
			this.increments = increments;
			this.status = status;
			
			this.increaseEffect = effects.former as ButtonEffect;
			this.decreaseEffect = effects.latter as ButtonEffect;
			
			drawSlider();
		}
		override public function activateOverlayItem():void 
		{
			super.activateOverlayItem();
			
			this.addEventListener(MouseEvent.MOUSE_UP, changeSlideListener);
		}
		override public function deactivateOverlayItem():void 
		{
			super.deactivateOverlayItem();
			
			this.removeEventListener(MouseEvent.MOUSE_UP, changeSlideListener);
		}
		
		private function changeSlideListener(event:MouseEvent):void {
			if (increaseTri.hitTestPoint(event.stageX, event.stageY, true)) {
				
				if (incrementSlider(1))
					increaseEffect.performEffect();
			}
			else if (decreaseTri.hitTestPoint(event.stageX, event.stageY, true)) {
				
				if (incrementSlider( -1))
					decreaseEffect.performEffect();
			}
		}
		
		private function drawSlider():void {
			
			var triangleWidth:Number = slideLength / 20;
			var triangleHeight:Number = slideLength / 10;
			
			increaseTri = createTriangle(triangleWidth, triangleHeight, true, 0x2268E2);
			decreaseTri = createTriangle(triangleWidth, triangleHeight, false, 0x2268E2);
			
			slideFrame = createSlider(slideLength / 10, slideLength, 0x10326D);
			filledSlide = createSlider(slideLength / 10, slideLength, 0x70A4FF);
			
			filledSlide.width = slideLength * status;
			
			this.addChild(increaseTri);
			this.addChild(decreaseTri);
			this.addChild(slideFrame);
			this.addChild(filledSlide);
		}
		
		private function incrementSlider(delta:int):Boolean {
			
			var newStatus:Number = delta * (1 / increments) + status;
			if (newStatus > 1 || newStatus < 0) return false;
			
			filledSlide.width = slideLength * newStatus;
			status = newStatus;
			
			return true;
		}
		
		private function createTriangle(triangleWidth:Number, triangleHeight:Number, increase:Boolean, color:uint = 0xffffff):Shape {
			
			var pointArray:Array;
			var returnTriangle:Shape = new Shape();
			
			if (horizontal) {
				if (increase) {
					pointArray = [new Point(triangleWidth, triangleHeight / 2), new Point(0, triangleHeight)];
					returnTriangle = drawShape(pointArray, color);
					returnTriangle.x = slideLength + triangleWidth * 2;
				}
				else {
					pointArray = [new Point( -triangleWidth, triangleHeight / 2), new Point(0, triangleHeight)];
					returnTriangle = drawShape(pointArray, color);
				}
			}
			else {
				if (increase) {
					pointArray = [new Point(triangleWidth / 2, -triangleHeight), new Point(triangleWidth, 0)];
					returnTriangle = drawShape(pointArray, color);
				}
				else {
					pointArray = [new Point(triangleWidth / 2, triangleHeight), new Point(triangleWidth, 0)];
					returnTriangle = drawShape(pointArray, color);
					returnTriangle.y = slideLength + triangleHeight * 2;
				}
			}
			
			return returnTriangle;
		}
		
		private function createSlider(sliderWidth:Number, sliderLength:Number, color:uint = 0xffffff):Shape {
			
			var pointArray:Array;
			var returnSlider:Shape;
			
			if (horizontal) {
				pointArray = [new Point(sliderLength, 0), new Point(sliderLength, sliderWidth), new Point(0, sliderWidth)];
				returnSlider = drawShape(pointArray, color);
				returnSlider.x = sliderLength / 20;
			}
			else {
				pointArray = [new Point(sliderWidth, 0), new Point(sliderWidth, sliderLength), new Point(0, sliderLength)];
				returnSlider = drawShape(pointArray, color);
				returnSlider.y = sliderLength / 20;
			}
			return returnSlider;
		}
		
		
		private function drawShape(points:Array, color:uint = 0xffffff):Shape {
			
			var newShape:Shape = new Shape();
			newShape.graphics.beginFill(color);
			newShape.graphics.lineStyle(1, color, 1, true);
			
			for each(var point:Point in points)
				newShape.graphics.lineTo(point.x, point.y);
			newShape.graphics.lineTo(0, 0);
			newShape.graphics.endFill();
			
			return newShape;
		}
		
	}

}