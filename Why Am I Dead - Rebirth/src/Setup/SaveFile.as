package Setup 
{
	import air.update.net.FileDownloader;
	import Core.Game;
	import flash.display.LoaderInfo;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import Maps.Map;
	import Misc.Tuple;
	import Props.SaveProp;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SaveFile 
	{
		private var saveName:String;
		private var saveObject:SharedObject;
		//private var saveFile:File;
		//private var saveStream:FileStream;
		private var local:Boolean;
		
		private var loadedData:Dictionary;
		
		public function SaveFile(saveName:String, local:Boolean) 
		{
			this.saveName = saveName;
			this.loadedData = new Dictionary();
			this.local = local;
			
			var rootPath:String = Main.getSingleton().loaderInfo.url;
			
			if (local) {
				this.saveObject = SharedObject.getLocal("WhyAmIDeadRebirth" + saveName);
				instatiateLoadDataObject(saveObject);
			}
			else{
				/*saveFile = new File(File.applicationDirectory.resolvePath("saves/" + saveName + ".txt").nativePath);
				
				saveStream = new FileStream();
				saveStream.open(saveFile, FileMode.READ);
				var fileContent:String = saveStream.readUTFBytes(saveStream.bytesAvailable);
				var fileArray:Array = fileContent.split(/\n/);
				instantiateLoadDataStream(fileArray);
				
				saveStream.close();*/
			}
		}
		
		private function instatiateLoadDataObject(sharedObject:SharedObject):void {
			
			for (var dataName:String in sharedObject.data) {
				parseLoadedDataObject(dataName, sharedObject.data[dataName]);
			}
		}
		private function parseLoadedDataObject(dataTag:String, data:Object):void {
			
			if (data is String) {
				var dataStr:String = data + "";
				
				if (dataStr.indexOf("dictionary") >= 0) {
					dataStr = dataStr.replace("dictionary", "");
					loadedData[dataTag] = parseLoadedDictionary(dataStr);
				}
				else if (data.indexOf("tuple") >= 0) {
					dataStr = dataStr.replace("tuple", "");
					loadedData[dataTag] = parseLoadedTuple(dataStr);
				}
				else loadedData[dataTag] = data;
			}
			else loadedData[dataTag] = data;
		}
		
		private function instantiateLoadDataStream(fileArray:Array):void {
			
			for (var i:int = 0; i < fileArray.length; i++) {
				var parsedData:Array = fileArray[i].split('~');
				
				var dataTag:String = parsedData[0];
				var dataType:String = parsedData[1];
				var data:String = parsedData[2];
				
				parseLoadedDataStream(dataTag, dataType, data);
			}
			
		}
		private function parseLoadedDataStream(dataTag:String, dataType:String, data:String):void {
			
			if (dataType == "String") loadedData[dataTag] = data;
			else if (dataType == "Int") loadedData[dataTag] = parseInt(data);
			else if (dataType == "Float") loadedData[dataTag] = parseFloat(data);
			else if (dataType == "Boolean") {
				if (data == "true") loadedData[dataTag] = true;
				else if (data == "false") loadedData[dataTag] = false;
			}
			else if (dataType == "Array")
				loadedData[dataTag] = data.split(',');
			else if (dataType == "Dictionary")
				loadedData[dataTag] = parseLoadedDictionary(data);
			else if (dataType == "Tuple")
				loadedData[dataTag] = parseLoadedTuple(data);
			else if (dataType == "Point")
				loadedData[dataTag] = parseLoadedPoint(data);
			else if (dataType == "Vector")
				loadedData[dataTag] = parseLoadedVector(data);
			else if (dataType == "VectorPoint")
				loadedData[dataTag] = parseLoadedPointVector(data);
		}
		
		private function parseLoadedTuple(data:String):Tuple{
			var parsedData:Array = data.split(',');
			return new Tuple(parsedData[0], parsedData[1]);
		}
		private function parseLoadedPoint(data:String):Point {
			var parsedData:Array = data.split('(').join("").split(')').join("").split(',');
			var parsedX:Array = parsedData[0].split('=');
			var parsedY:Array = parsedData[1].split('=');
			return new Point(parseFloat(parsedX[1]), parseFloat(parsedY[1]));
		}
		private function parseLoadedDictionary(data:String):Dictionary {
			var dictionary:Dictionary = new Dictionary();
			
			var parsedData:Array = data.split(',');
			for (var j:int = 0; j < parsedData.length; j++) {
				var parsedElement:Array = parsedData[j].split('_');
				
				dictionary[parsedElement[0]] = parsedElement[1];
			}
			return dictionary;
		}
		private function parseLoadedVector(data:String):Vector.<String> {
			var vector:Vector.<String> = new Vector.<String>();
			
			var parsedData:Array = data.split(',');
			for (var j:int = 0; j < parsedData.length; j++) {
				vector.push(parsedData[j]);
			}
			return vector;
		}
		private function parseLoadedPointVector(data:String):Vector.<Point> {
			var vector:Vector.<Point> = new Vector.<Point>();
			
			var parsedData:Array = data.split('(').join("").split(')');
			for (var j:int = 0; j < parsedData.length; j++) {
				var currentPoint:String = parsedData[j];
				if (currentPoint.charAt(0) == ',') 
					currentPoint = currentPoint.slice(1);
				var parsedPoint:Array = currentPoint.split(',')
				if (parsedPoint.length < 2) continue;
				
				var parsedX:Array = parsedPoint[0].split('=');
				var parsedY:Array = parsedPoint[1].split('=');
				vector.push(new Point(parsedX[1], parsedY[1]));
			}
			return vector;
		}
		
		
		public function isChapterFile():Boolean {
			if (this.saveName.indexOf("Chapter") >= 0) return true;
			else return false;
		}
		
		public function saveData(dataName:String, data:Object):void {
			
			if (local)
				handleSaveObjectData(dataName, data);
			//else	
			//	handleSaveStreamData(dataName, data);
			
			instatiateLoadDataObject(this.saveObject);
		}
		
		public function loadData(dataName:String):Object {
			
			return loadedData[dataName];
		}
		
		public function beginSave():void {
			
			//if (!local)
			//	saveStream.open(saveFile, FileMode.WRITE);
		}
		public function finishSave():void {
			
			if(!local){
				saveObject.flush();
				//saveStream.close();
			}
		}
		
		public function clearData():void {
			if (local) {
				saveObject.clear();
			}
			else{
				/*saveStream.open(saveFile, FileMode.WRITE);
				saveStream.close();
				loadedData = new Dictionary();*/
			}
		}
		
		//public function copyData(copyTo:SaveFile):void {
		//	copyTo.copyFromSharedObject(this.loadedData, this.saveFile);
		//}
		/*
		public function copyFromSharedObject(data:Dictionary, file:File):void {
			this.clearData();
			
			this.loadedData = new Dictionary();
			for (var key:String in data) {
				loadedData[key] = data[key];
			}
			
			var copyStream:FileStream = new FileStream();
			copyStream.open(file, FileMode.READ);
			saveStream.open(saveFile, FileMode.WRITE);
			
			var fileContent:String = copyStream.readUTFBytes(copyStream.bytesAvailable);
			saveStream.writeUTFBytes(fileContent);
			
			copyStream.close();
			saveStream.close();
		}*/
		
		private function handleSaveObjectData(dataName:String, data:Object):void {
			
			if(getDataType(data) == "Dictionary")
				saveObject.data[dataName] = dictionaryToString(data as Dictionary);
			else if (getDataType(data) == "Tuple")
				saveObject.data[dataName] = tupleToString(data as Tuple);
			else saveObject.data[dataName] = data;
			
			var j:int = 2;
		}
		
		/*private function handleSaveStreamData(dataName:String, data:Object):void {
			
			saveStream.writeUTFBytes(dataName + "~" + getDataType(data) + "~");
			
			if (getDataType(data) == "Dictionary")
				saveStream.writeUTFBytes(dictionaryToString(data as Dictionary));
			else if (getDataType(data) == "Tuple")
				saveStream.writeUTFBytes(tupleToString(data as Tuple));
			else
				saveStream.writeUTFBytes(data + "");
			
			saveStream.writeUTFBytes("\n");
		}*/
		private function getDataType(data:Object):String {
			if (data is int) return "Int";
			else if (data is Number) return "Float";
			else if (data is Boolean) return "Boolean";
			else if (data is String) return "String";
			else if (data is Array) return "Array";
			else if (data is Dictionary) return "Dictionary";
			else if (data is Tuple) return "Tuple";
			else if (data is Point) return "Point";
			else if (data is Vector.<String>) return "Vector";
			else if (data is Vector.<Point>) return "VectorPoint";
			
			else return "null";
		}
		
		private function dictionaryToString(dictionary:Dictionary):String {
			var endString:String = "";
			if (local) endString += "dictionary"
			
			for (var key:String in dictionary) {
				endString += key + "_" + dictionary[key] + ",";
			}
			return endString;
		}
		private function tupleToString(tuple:Tuple):String {
			var endString:String = "";
			if (local) endString += "tuple";
			
			var map:Map = tuple.latter as Map;
			var point:Point = tuple.former as Point;
			
			endString += map.getMapName() + "," + point.x + "_" + point.y;
			return endString;
		}
		
	}

}