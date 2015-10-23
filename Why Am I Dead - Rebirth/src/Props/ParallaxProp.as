package Props 
{
	import Dialogue.Dialogue;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import Interface.GameScreen;
	/**
	 * ...
	 * @author Peltast
	 */
	public class ParallaxProp extends Prop
	{
		private var childProps:Vector.<Prop>;
		private var childDistances:Vector.<int>;
		private var gameScreen:GameScreen;
		
		public function ParallaxProp(propTag:String, collidable:Boolean, xCoord:Number, yCoord:Number,
					childProps:Vector.<Prop>, childDistances:Vector.<int>, gameScreen:GameScreen,
					bounds:Rectangle = null, permissions:Vector.<String> = null, sucDia:Dialogue = null, failDia:Dialogue = null)
		{
			super(null, propTag, collidable, xCoord, yCoord, bounds, permissions, sucDia, failDia);
			
			this.childProps = childProps;
			this.childDistances = childDistances;
			this.gameScreen = gameScreen;
			
			for each(var child:Prop in childProps)
				this.addChild(child);
		}
		
		override public function updateProp():void 
		{
			super.updateProp();
			
			for each(var child:Prop in childProps)
				child.updateProp();
			
			if (gameScreen.x != 0) {
				var offset:int = gameScreen.x;
				
				for (var i:int = 0; i < childProps.length; i++) {
					if (childDistances[i] < 0) continue;
					if (childDistances[i] > 0) {
						childProps[i].x = -gameScreen.x * (1 / childDistances[i]);
					}
				}
			}
			
		}
		
	}

}