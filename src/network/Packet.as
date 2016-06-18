package network 
{
	import flash.external.ExternalInterface;
	import flash.net.Socket;
	public class Packet 
	{
		private var s:Socket;
		public function Packet(s:Socket) 
		{
			this.s = s;
		}
		
		public function writeLine(obj:Object):void {
			var text:String = JSON.stringify(obj) + "\n";
			//trace("Sending to server: " + text);
			s.writeUTFBytes(text);
			s.flush();
		}
		
		public function readLine():Object {
			var text:String = "";
			try {
				while (s.bytesAvailable > 0) {
					var byteChar:String = s.readUTFBytes(1);
					if (byteChar != "\n") {
						text += byteChar;
					} else {
						break;
					}
				}
				//trace("Received from server: " + text);
				return JSON.parse(text);
			} catch (ex:Error) {
				//trace(ex);
			}
			return null;
		}
		
		public function connect(host:String, port:int):void {
			try {
				s.connect(host, port);
			} catch (ex:Error) {
				trace(ex);
			}
		}
		
		public function close():void {
			try {
				s.close();
			} catch (ex:Error) {
				trace(ex);
			}
		}
		
		public function isConnected():Boolean {
			return s.connected;
		}
		
		public function get socket():Socket {
			return s;
		}
	}
}