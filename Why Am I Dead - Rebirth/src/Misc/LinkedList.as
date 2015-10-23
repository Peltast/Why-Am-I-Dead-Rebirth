package Misc 
{
	import adobe.utils.CustomActions;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class LinkedList 
	{
		private var lastNode:Node;
		private var currentNode:Node;
		
		public function LinkedList(lastNode:Node = null) {
			this.lastNode = lastNode;
			currentNode = null;
		}
		
		public function isEmpty():Boolean {
			if (lastNode == null) return true;
			return false;
		}
		public function isLongerThan(count:int):Boolean {
			var i:int = 0;
			var startNode:Node = currentNode;
			var iterNode:Node = currentNode.next;
			
			while (iterNode != startNode) {
				i++;
				iterNode = iterNode.next;
				
				if (i > count)
					return true;
			}
			return false;
		}
		
		public function getEnd():Object { return lastNode.content; }
		public function getCurrent():Object { return currentNode.content; }
		public function getNext():Object { return currentNode.next.content; }
		public function getPrevious():Object { return currentNode.previous.content; }
		
		public function insertBeforeCurrent(content:Object):void { insertBefore(currentNode, content); }
		public function insertAfterCurrent(content:Object):void { insertAfter(currentNode, content); }
		public function setForward():void { currentNode = currentNode.next; }
		public function setBackward():void { currentNode = currentNode.previous; }
		public function setCurrentNodeEnd():void { currentNode = lastNode; }
		public function setCurrentNodeTo(element:Object):Boolean {
			if (isEmpty()) return false;
			currentNode = lastNode;
			while (currentNode.next != null) {
				if (currentNode.content == element) return true;
				currentNode = currentNode.next;
			}
			return false;
		}
		public function removeCurrentNode():void {
			remove(currentNode);
		}
		
		public function getElementAt(index:int):Object {
			if (isEmpty()) return null;
			var tempNode:Node = lastNode;
			for (var i:int = 0; i < index; i++) {
				if (tempNode.next == null) return null;
				else tempNode = tempNode.next;
			}
			return tempNode.content;
		}
		public function getElementIndex(element:Object):int {
			if (isEmpty()) return -1;
			var tempNode:Node = lastNode;
			var start:Node = tempNode;
			var counter:int = 0;
			while (tempNode != start || counter == 0) {
				if (tempNode.content == element) return counter;
				tempNode = tempNode.next;
				counter++;
			}
			return -1;
		}
		
		public function insertBefore(node:Node, content:Object):void {
			if (isEmpty()) {
				insertEnd(content);
				return;
			}
			
			var newNode:Node = new Node();
			newNode.content = content;
			newNode.next = node;
			
			newNode.previous = node.previous;
			node.previous.next = newNode;
			node.previous = newNode;
			
			if (node == lastNode) lastNode = newNode;
		}
		
		private function insertAfter(node:Node, content:Object):void {
			if (isEmpty()) {
				insertEnd(content);
				return;
			}
			
			var newNode:Node = new Node();
			newNode.content = content;
			newNode.previous = node;
			
			newNode.next = node.next;
			node.next.previous = newNode;
			node.next = newNode;
		}
		private function insertEnd(content:Object):void {
			if (lastNode == null) {
				lastNode = new Node();
				lastNode.content = content;
				lastNode.next = lastNode;
				lastNode.previous = lastNode;
				currentNode = lastNode;
			}
			else
				insertAfter(lastNode, content);
		}
		
		public function remove(node:Node):void {
			
			if (lastNode.next == lastNode) 
				lastNode = null;
				
			if (currentNode == node) currentNode = node.next;
			if (lastNode == node) lastNode = node.next;
			
			node.previous.next = node.next;
			node.next.previous = node.previous;
		}
		
		public function clone():LinkedList {
			
			var clone:LinkedList = new LinkedList(lastNode);
			return clone;
		}
	}

}

class Node {
	
	public var previous:Node;
	public var next:Node;
	public var content:Object;
	
	public function Node() { }
}