package SpectralGraphics.EffectTypes 
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import SpectralGraphics.SpectralLayer;
	import SpectralGraphics.SpectralObject;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class ScreenWrapEffect extends SpectralEffect
	{
		// The sole job of this effect is to detect objects that are exiting the screen, and have them appear to
		// wrap around.  Thus if the layer it is in doesn't have a move effect, this will not do anything.
		private var screenBounds:Rectangle;
		private var objects:Dictionary;
		
		public function ScreenWrapEffect(screenBounds:Rectangle ) 
		{
			super(this);
			this.screenBounds = screenBounds;
			objects = new Dictionary();
		}
		
		override public function applyEffect(object:SpectralObject, layer:SpectralLayer):void 
		{
			
			// Take into account all ways that an object's dimensions can change.
			var objectWidth:int = (object.getShapeWidth()) * object.scaleX;
			var objectHeight:int = (object.getShapeHeight()) * object.scaleY;
			var offsetX:int;
			var offsetY:int;
			
			if (objects[object] == null){
				
				if (object.x < screenBounds.x) {
					// Object is exiting the left side of the screen.
					offsetX = screenBounds.width + object.x;					
					var wrapObject:SpectralObject = object.getClone();
					wrapObject.scaleX = object.scaleX;
					wrapObject.scaleY = object.scaleY;
					layer.addObject(wrapObject, offsetX, object.y);
					
					// Add the object and its wrapped version to the objects dictionary.
					objects[object] = wrapObject;
					objects[wrapObject] = object;
				}
				else if (object.x + objectWidth / 2 > screenBounds.width + screenBounds.x) {
					// Object is exiting the right side of the screen.
					offsetX = screenBounds.x - screenBounds.width - object.width;
					if (offsetX <= 0 - objectWidth / 2) 
						offsetX = 0 - objectWidth / 2 + 5;
					
					wrapObject = object.getClone();
					wrapObject.scaleX = object.scaleX;
					wrapObject.scaleY = object.scaleY;
					layer.addObject(wrapObject, offsetX, object.y);
					
					// Add the object and its wrapped version to the objects dictionary.
					objects[object] = wrapObject;
					objects[wrapObject] = object;
				}
				
				if (object.y < screenBounds.y) {
					// Object is exiting the top of the screen.					
					offsetY = screenBounds.height + object.y;
					wrapObject = object.getClone();
					wrapObject.scaleX = object.scaleX;
					wrapObject.scaleY = object.scaleY;
					layer.addObject(wrapObject, object.x, offsetY);
					
					// Add the object and its wrapped version to the objects dictionary.
					objects[object] = wrapObject;
					objects[wrapObject] = object;
				}
				else if (object.y + objectHeight / 2 > screenBounds.height + screenBounds.y) {
					// Object is exiting the bottom of the screen.					
					offsetY = screenBounds.y - screenBounds.height - object.height;
					if (offsetY <= 0 - objectHeight / 2) 
						offsetY = 0 - objectHeight / 2 + 5;
					
					wrapObject = object.getClone();
					wrapObject.scaleX = object.scaleX;
					wrapObject.scaleY = object.scaleY;
					layer.addObject(wrapObject, object.x, offsetY);
					
					// Add the object and its wrapped version to the objects dictionary.
					objects[object] = wrapObject;
					objects[wrapObject] = object;
				}
				
			}
			
			if (object.x + objectWidth / 2 < screenBounds.x) {
				// Object has finished exiting left side of screen.
				if (objects[object] != null) {
					layer.removeObject(object);
					objects[objects[object]] = null;
					delete objects[object];
				}
			}
			else if (object.x > screenBounds.width + screenBounds.x) {
				// Object has finished exiting right side of screen.
				if (objects[object] != null) {
					layer.removeObject(object);
					objects[objects[object]] = null;
					delete objects[object];
				}
			}
			if (object.y + objectHeight / 2 < screenBounds.y) {
				// Object has finished exiting top of screen.
				if (objects[object] != null) {
					layer.removeObject(object);
					objects[objects[object]] = null;
					delete objects[object];
				}
			}
			else if (object.y > screenBounds.height + screenBounds.y) {
				// Object has finished exiting bottom of screen.
				if (objects[object] != null) {
					layer.removeObject(object);
					objects[objects[object]] = null;
					delete objects[object];
				}
			}	
		}
		
		
	}

}