package Misc{

	public class Queue
	{
		public var front:StackNode;
		public var back:StackNode;
		
		public function Queue() {
			
		}
		
		public function isEmpty():Boolean {
			return front == null;
		}
		
		public function push(newObject:Object):void {
			
			if(isEmpty()){
				front = new StackNode();
				front.content = newObject;
				back = front;
			}
			else{
				var newBack:StackNode = new StackNode();
				newBack.content = newObject;
				back.nextNode = newBack;
				back = newBack;
			}
		}
		
		public function pop():Object {
			if (!isEmpty()) {
				var second:StackNode = front.nextNode;
				var poppedObject:Object = front.content;
				front = second;
				if (front == null)
					back = front;
					
				return poppedObject;
			}
			else {
				trace("Warning: Stack empty when pop was called.");
				return null;
			}
		}
		
		public function peek():Object {
			if(!isEmpty())
				return front.content;
			else {
				trace("Warning: Stack empty when peek was called.");
				return null;
			}
		}
		
	}

}