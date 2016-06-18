package scene
{
	import assets.*;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.Socket;
	import gamelobby.Arena;
	import gamelobby.Lobby;
	import gameplay.Game;
	import gameplay.GameModes;
	import network.Packet;
	import network.PacketHeader;
	import sound.SoundManager;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	import player.PlayerInformation;
	import gameload.*;
	import service.*;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class SceneManager extends Sprite
	{
		public static const STATE_LOADING_LOBBY:int = 0;
		public static const STATE_LOADING_ARENA:int = 1;
		public static const STATE_LOADING_BATTLE:int = 2;
		public static const STATE_PLAYING_LOBBY:int = 3;
		public static const STATE_PLAYING_ARENA:int = 4;
		public static const STATE_PLAYING_BATTLE:int = 5;
		
		private var currentState:int = -1;
		private var _scene:Scene;
		private var loadFail:Boolean;
		
		private var bgmSoundMgr:SoundManager;
		private var sfxSoundMgr:SoundManager;
		
		private var sceneContainer:Sprite;
		private var msgContainer:Sprite;
		
		private var isOnline:Boolean;
		private var packet:Packet;
		
		public function SceneManager() 
		{
			super();
			sceneContainer = new Sprite();
			msgContainer = new Sprite();
			addChild(sceneContainer);
			initBgmSoundManager();
			initSfxSoundManager();
			connectToServer();
			loadFail = false;
			isOnline = false;
			// First start
			var lobbyService:LobbyService = new LobbyService(this);
			lobbyService.initLobbyLoader();
			lobbyService.start();
		}
		
		private function connectToServer():void {
			if (Main.server_ip != null && Main.server_port > 0) {
				try {
					trace("Connecting to server " + Main.server_ip + ":" + Main.server_port);
					packet = new Packet(new Socket());
					packet.socket.addEventListener(Event.CONNECT, onClientConnected);
					packet.socket.addEventListener(ProgressEvent.SOCKET_DATA, onClientMessageReceived);
					packet.socket.addEventListener(IOErrorEvent.IO_ERROR, onClientIOError);
					packet.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onClientSecurityError);
					packet.socket.connect(Main.server_ip, Main.server_port);
				} catch (ex:Error) {
					trace(ex);
				}
			}
		}
		
		private function onClientIOError(e:IOErrorEvent):void {
			trace("ioErrorHandler: " + e);
			/*
			try {
				ExternalInterface.call("alertFromFlash", "ioErrorHandler: " + e);
			} catch (ex:Error) {
				trace(ex);
			}
			*/
		}
		
		private function onClientSecurityError(e:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + e);
			/*
			try {
				ExternalInterface.call("alertFromFlash", "securityErrorHandler: " + e);
			} catch (ex:Error) {
				trace(ex);
			}
			*/
		}
		
		private function onClientConnected(e:Event):void {
			// Login !!
			var obj:Object = new Object();
			obj.key = PacketHeader.login;
			obj.values = [ Main.userid, Main.token ];
			packet.writeLine(obj);
		}
		
		private function onClientMessageReceived(e:ProgressEvent):void {
			var obj:Object;
			while ((obj = packet.readLine()) != null) {
				ClientMessageProcess.Process(this, obj);
			}
			obj = new Object();
			obj.key = PacketHeader.ping;
			obj.values = null;
			packet.writeLine(obj);
		}
		
		private function clearCharacterAssets():void {
			var i:Object;
			var j:Object;
			var k:Object;
			var obj:Object;
			var obj2:Object;
			var obj3:Object;
			for (i in LobbyTexturesHelper.list_profile_textures) {
				obj = LobbyTexturesHelper.list_profile_textures[i];
				if (obj is Texture) {
					obj.dispose();
				}
				delete LobbyTexturesHelper.list_profile_textures[i];
			}
			for (i in CharacterTextureHelper.list_avatars_textures) {
				obj = CharacterTextureHelper.list_avatars_textures[i];
				for (j in obj) {
					obj2 = obj[j];
					for (k in obj2) {
						obj3 = obj2[k];
						if (obj3[0] is TextureAtlas) {
							obj3[0].dispose();
						}
						delete obj3[0];
						delete obj3[1];
					}
					delete obj[j];
				}
				delete CharacterTextureHelper.list_avatars_textures[i];
			}
			for (i in CharacterTextureHelper.list_avatars_icon_textures) {
				obj = CharacterTextureHelper.list_avatars_icon_textures[i];
				for (j in obj) {
					obj2 = obj[j];
					if (obj2 is Texture) {
						obj2.dispose();
					}
					delete obj[j];
				}
				delete CharacterTextureHelper.list_avatars_icon_textures[i];
			}
			for (i in CharacterTextureHelper.list_avatars_status_textures) {
				obj = CharacterTextureHelper.list_avatars_status_textures[i];
				for (j in obj) {
					obj2 = obj[j];
					if (obj2 is Texture) {
						obj2.dispose();
					}
					delete obj[j];
				}
				delete CharacterTextureHelper.list_avatars_status_textures[i];
			}
			for (i in CharacterTextureHelper.list_skills_icon_textures) {
				obj = CharacterTextureHelper.list_skills_icon_textures[i];
				for (j in obj) {
					obj2 = obj[j];
					if (obj2 is Texture) {
						obj2.dispose();
					}
					delete obj[j];
				}
				delete CharacterTextureHelper.list_skills_icon_textures[i];
			}
		}
		
		private function initBgmSoundManager():void {
			bgmSoundMgr = new SoundManager();
			bgmSoundMgr.load("bgm_lobby01", Main.serviceurl + "sounds/bgm/bgm_lobby01.mp3");
			bgmSoundMgr.load("bgm_battle01", Main.serviceurl + "sounds/bgm/bgm_battle01.mp3");
		}
		
		private function initSfxSoundManager():void {
			sfxSoundMgr = new SoundManager();
			sfxSoundMgr.load("click_button", Main.serviceurl + "sounds/button/click_button.mp3");
			sfxSoundMgr.load("click_button_close", Main.serviceurl + "sounds/button/click_button_close.mp3");
			sfxSoundMgr.load("ui_sfx_open", Main.serviceurl + "sounds/ui_sfx/sfx_open.mp3");
			sfxSoundMgr.load("game_sfx_swap", Main.serviceurl + "sounds/game_sfx/swap.mp3");
			sfxSoundMgr.load("game_sfx_spawn", Main.serviceurl + "sounds/game_sfx/spawn.mp3");
			sfxSoundMgr.load("game_sfx_remove", Main.serviceurl + "sounds/game_sfx/remove.mp3");
			sfxSoundMgr.load("game_sfx_drop1", Main.serviceurl + "sounds/game_sfx/drop1.mp3");
			sfxSoundMgr.load("game_sfx_drop2", Main.serviceurl + "sounds/game_sfx/drop2.mp3");
			sfxSoundMgr.load("game_sfx_attacked1", Main.serviceurl + "sounds/game_sfx/attacked1.mp3");
			sfxSoundMgr.load("game_sfx_attacked2", Main.serviceurl + "sounds/game_sfx/attacked2.mp3");
			sfxSoundMgr.load("game_sfx_attacked3", Main.serviceurl + "sounds/game_sfx/attacked3.mp3");
			sfxSoundMgr.load("game_sfx_attacked4", Main.serviceurl + "sounds/game_sfx/attacked4.mp3");
			sfxSoundMgr.load("game_sfx_attacked5", Main.serviceurl + "sounds/game_sfx/attacked5.mp3");
			sfxSoundMgr.load("game_sfx_hit", Main.serviceurl + "sounds/game_sfx/hit.mp3");
			sfxSoundMgr.load("game_sfx_heal", Main.serviceurl + "sounds/game_sfx/heal.mp3");
			sfxSoundMgr.load("game_sfx_wind1", Main.serviceurl + "sounds/game_sfx/wind1.mp3");
			sfxSoundMgr.load("game_sfx_wind2", Main.serviceurl + "sounds/game_sfx/wind2.mp3");
			sfxSoundMgr.load("game_sfx_wind3", Main.serviceurl + "sounds/game_sfx/wind3.mp3");
			sfxSoundMgr.load("game_sfx_explosion1", Main.serviceurl + "sounds/game_sfx/explosion1.mp3");
			sfxSoundMgr.load("game_sfx_explosion2", Main.serviceurl + "sounds/game_sfx/explosion2.mp3");
			sfxSoundMgr.load("game_sfx_home_broken", Main.serviceurl + "sounds/game_sfx/home_broken.mp3");
			sfxSoundMgr.load("cannon_blast", Main.serviceurl + "sounds/game_sfx/cannon_blast.mp3");
			sfxSoundMgr.load("countdown", Main.serviceurl + "sounds/game_sfx/countdown.mp3");
			sfxSoundMgr.load("stun", Main.serviceurl + "sounds/game_sfx/stun.mp3");
		}
		
		public function initSceneLoadingLobby(user:Object, friends:Array, isTutorial:Boolean = false):void {
			BGMSoundManager.stopAll();
			clearCharacterAssets();
			var userInfo:PlayerInformation = new PlayerInformation(PlayerInformation.MODE_LOBBY, user);
			var newScene:Scene = new LoadingLobbyScene(this, userInfo, friends, isTutorial);
			clearScene();
			_scene = newScene;
		}
		
		public function initSceneLoadingArena(userInfo:PlayerInformation, targets:Array, isTutorial:Boolean = false):void {
			
			var newScene:Scene = new LoadingArenaScene(this, userInfo, targets, isTutorial);
			clearScene();
			_scene = newScene;
		}
		
		public function initSceneLoadingBattle(battleid:int, attacker:Object, defender:Object, gameMode:int, isTutorial:Boolean = false):void {
			clearCharacterAssets();
			var atkInfo:PlayerInformation = new PlayerInformation(PlayerInformation.MODE_GAME, attacker);
			var defInfo:PlayerInformation = new PlayerInformation(PlayerInformation.MODE_GAME, defender);
			var newScene:Scene = new LoadingGameScene(this, battleid, atkInfo, defInfo, gameMode, isTutorial);
			clearScene();
			_scene = newScene;
		}
		
		public function initScenePlayingLobby(userInfo:PlayerInformation, friends:Vector.<PlayerInformation>, isTutorial:Boolean = false):void {
			var newScene:Scene = new Lobby(this, userInfo, friends, isTutorial);
			if (!BGMSoundManager.Playing("bgm_lobby01"))
				BGMSoundManager.play("bgm_lobby01", 0, int.MAX_VALUE);
			clearScene();
			_scene = newScene;
		}
		
		public function initScenePlayingArena(userInfo:PlayerInformation, targets:Vector.<PlayerInformation>, isTutorial:Boolean = false):void {
			var newScene:Scene = new Arena(this, userInfo, targets, isTutorial);
			clearScene();
			_scene = newScene;
		}
		
		public function initScenePlayingBattle(battleid:int, players:Vector.<PlayerInformation>, gameMode:int, isTutorial:Boolean = false):void {
			BGMSoundManager.stopAll();
			var newScene:Scene = new Game(this, battleid, players, gameMode, isTutorial);
			clearScene();
			_scene = newScene;
		}
		
		public function clearScene():void {
			sceneContainer.removeChildren(0, -1, true);
			msgContainer.removeChildren(0, -1, true);
			Starling.juggler.purge();
		}
		
		public function set CurrentState(value:int):void {
			trace("SceneManager:CurrentState -> " + value);
			if (value == currentState)
				return;
			switch (value) {
				case STATE_LOADING_LOBBY:
					if (_scene is LoadingLobbyScene) {
						sceneContainer.addChild(_scene);
						(_scene as LoadingScene).start();
						currentState = value;
						loadFail = false;
					} else {
						loadFail = true;
					}
					break;
				case STATE_LOADING_ARENA:
					if (_scene is LoadingArenaScene) {
						sceneContainer.addChild(_scene);
						(_scene as LoadingScene).start();
						currentState = value;
						loadFail = false;
					} else {
						loadFail = true;
					}
					break;
				case STATE_LOADING_BATTLE:
					if (_scene is LoadingGameScene) {
						sceneContainer.addChild(_scene);
						(_scene as LoadingScene).start();
						currentState = value;
						loadFail = false;
					} else {
						loadFail = true;
					}
					break;
				case STATE_PLAYING_LOBBY:
					if (_scene is Lobby) {
						sceneContainer.addChild(_scene);
						currentState = value;
						loadFail = false;
					} else {
						loadFail = true;
					}
					break;
				case STATE_PLAYING_ARENA:
					if (_scene is Arena) {
						sceneContainer.addChild(_scene);
						currentState = value;
						loadFail = false;
					} else {
						loadFail = true;
					}
					break;
				case STATE_PLAYING_BATTLE:
					if (_scene is Game) {
						sceneContainer.addChild(_scene);
						currentState = value;
						loadFail = false;
					} else {
						loadFail = true;
					}
					break;
			}
			if (loadFail) {
				trace("Scene change fail.");
			}
		}
		
		public function pushMessage(message:String, color:uint, duration:Number = 2.0):void {
			var TF:TextField = new TextField(300, 50, message, "RWFont", 40, color);
			TF.pivotX = TF.width / 2;
			TF.pivotY = TF.height / 2;
			TF.x = GlobalVariables.screenWidth / 2;
			TF.y = GlobalVariables.screenHeight / 2;
			TF.autoScale = true;
			TF.touchable = false;
			TF.vAlign = VAlign.CENTER;
			TF.hAlign = HAlign.CENTER;
			msgContainer.addChild(TF);
			TF.alpha = 0;
			var FadeIn:Tween = new Tween(TF, 0.5);
			FadeOut.fadeTo(1);
			var Showing:Tween = new Tween(TF, duration);
			var FadeOut:Tween = new Tween(TF, 0.5);
			FadeOut.fadeTo(0);
			FadeIn.onComplete = function():void {
				Starling.juggler.add(Showing);
			};
			Showing.onComplete = function():void {
				Starling.juggler.add(FadeOut);
			};
			FadeOut.onComplete = function():void {
				msgContainer.removeChild(TF, true);
			};
			Starling.juggler.add(FadeIn);
		}
		
		public function get CurrentState():int {
			return currentState;
		}
		
		public function get LoadFail():Boolean {
			return loadFail;
		}
		
		public function get BGMSoundManager():SoundManager {
			return bgmSoundMgr;
		}
		
		public function get SFXSoundManager():SoundManager {
			return sfxSoundMgr;
		}
		
		public function get IsOnline():Boolean {
			return isOnline;
		}
		
		public function set IsOnline(val:Boolean):void {
			isOnline = val;
		}
		
		public function get currentScene():Scene {
			return _scene;
		}
		
		public function get clientPacket():Packet {
			return packet;
		}
	}

}