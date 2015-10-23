package Misc 
{
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	
	public class Stack 
	{
		public var first:StackNode;
		private var length:int;
		
		public function Stack()	{
			
		}
		
		
		public function isEmpty():Boolean {
			return first == null;
		}
		
		public function push(newObject:Object):void {
			var second:StackNode = first;
			first = new StackNode();
			first.nextNode = second;
			first.content = newObject;
			length++;
		}
		
		public function pop():Object {
			if (!isEmpty()) {
				length--;
				var second:StackNode = first.nextNode;
				var poppedObject:Object = first.content;
				first = second;
				return poppedObject;
			}
			else {
				trace("Error: Stack empty when pop was called.");
				return null;
			}
		}
		
		public function peek():Object {
			if(!isEmpty())
				return first.content;
			else {
				trace("Error: Stack empty when peek was called.");
				return null;
			}
		}
		
		public function getLength():int
		{
			return length;
		}
		
	}

}