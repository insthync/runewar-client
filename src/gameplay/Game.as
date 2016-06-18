package gameplay
{
	import assets.*;
	import character.BaseCharacterInformation;
	import character.CharacterEntity;
	import character.EffectBuff;
	import character.Entity;
	import character.SkilledArcherCharacterEntity;
	import character.SkilledAssasinCharacterEntity;
	import character.SkilledFighterCharacterEntity;
	import character.SkilledHermitCharacterEntity;
	import character.SkilledKnightCharacterEntity;
	import character.SkilledMageCharacterEntity;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.external.ExternalInterface;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import network.PacketHeader;
	import gameplay.Board;
	import gametutorial.UIArrow;
	import gametutorial.UINPC;
	import gametutorial.UITutorial;
	import player.PlayerEntity;
	import player.PlayerInformation;
	import player.PlayerTypes;
	import scene.Scene;
	import scene.SceneManager;
	import starling.animation.Tween;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class Game extends Scene
	{
		private var battleid:int;
		private var gameMode:int;							// Game play type
		private var intervalBeforeStart:int = 10;			// Interval before start game play in seconds
		private var countDownEntity:Timer;					// The count down entity for Interval before start game play
		// An environments in the game
		private var envBG:Image;
		// Enemy home
		private var envEnemyHomeBack:Image;
		private var envEnemyHomeFront:Image;
		// Player home
		private var envHomeBack:Image;
		private var envHomeFront:Image;
		// Enemy Cannon;
		private var envEnemyCannonTop:MovieClip;
		private var envEnemyCannonBottom:MovieClip;
		// Player Cannon
		private var envCannonTop:MovieClip;
		private var envCannonBottom:MovieClip;
		// Count down number
		private var envNumber:Array;
		// Choose character UI
		private var envChooseChar01:UIChooseCharacter;
		private var envChooseChar02:UIChooseCharacter;
		// Player information UI
		private var envPlayerInfo01:UIPlayerInfo;
		private var envPlayerInfo02:UIPlayerInfo;
		// Waypoints
		public static const DIR_WAYPOINT_TO_LEFT:int = -1;
		public static const DIR_WAYPOINT_TO_RIGHT:int = 1;
		public static const DIR_WAYPOINT_TOP:int = 0;
		public static const DIR_WAYPOINT_BOTTOM:int = 1;
		public static const SPAWN_WAYPOINT_TOP_LEFT:int = 0;
		public static const SPAWN_WAYPOINT_TOP_RIGHT:int = 1;
		public static const SPAWN_WAYPOINT_BOTTOM_LEFT:int = 2;
		public static const SPAWN_WAYPOINT_BOTTOM_RIGHT:int = 3;
		private var waypoints:Array;
		private var spawnpoints:Array;
		// Players
		private var players:Vector.<PlayerEntity>;
		private var playersInfo:Vector.<PlayerInformation>;
		private var boards:Vector.<Board>;					// Play area for each players
		private var charactersID:int;
		private var EntitiesKeeper:Dictionary;
		private var characters:Vector.<Vector.<CharacterEntity>>;
		// Game ending
		private var isGameStart:Boolean;
		private var isGameEnd:Boolean;
		private var looser:PlayerEntity;
		private var envGameResult:UIFightResult;
		// An layers
		private var floorLayer:Sprite;
		// Character layer
		private var layerCharactersTop:Sprite;
		private var layerCharactersBottom:Sprite;
		// Gate layer
		private var layerGate:Sprite;
		// Effects layer
		private var layerCharacterEffects:GameEffects;
		// Board layer
		private var layerBoard:Sprite;
		// UI
		private var layerUI:Sprite;
		// Env Atlas
		private var atlas:TextureAtlas;
		private var countdownAtlas:TextureAtlas;
		private var runeAtlas:TextureAtlas;
		private var effect1Atlas:TextureAtlas;
		private var effect2Atlas:TextureAtlas;
		private var achievementAtlas:TextureAtlas;
		// Tutorial
		private var isTutorial:Boolean;
		private var tutorialAtlas:TextureAtlas;
		private var tutorialArrow:UIArrow;
		private var tutorialDialog:UITutorial;
		private var tutorialNPC:UINPC;
		private var tutorialState:int;
		// Game affect effects
		public static const HEAL_VALUE:int = 150;
		public static const CANNON_DAMAGE:int = 50;
		public static const STUN_TIME:int = 6000;
		public static const METEOR_DAMAGE:int = 75;
		public function Game(mgr:SceneManager, battleid:int, playersInfo:Vector.<PlayerInformation>, gameMode:int = GameModes.SINGLEPLAYER, isTutorial:Boolean = false)
		{
			super(mgr);
			atlas = GameTexturesHelper.getEnvTextureAtlas();
			countdownAtlas = CountDownTexturesHelper.getTextureAtlas();
			runeAtlas = RuneTexturesHelper.getTextureAtlas();
			achievementAtlas = AchievementTexturesHelper.getTextureAtlas();
			isGameStart = false;
			isGameEnd = false;
			this.battleid = battleid;
			this.playersInfo = playersInfo;
			this.players = new Vector.<PlayerEntity>();
			this.players.length = 2;
			this.boards = new Vector.<Board>();
			this.boards.length = 2;
			this.charactersID = 0;
			this.EntitiesKeeper = new Dictionary();
			this.characters = new Vector.<Vector.<CharacterEntity>>();
			this.characters.length = 2;
			this.characters[0] = new Vector.<CharacterEntity>();
			this.characters[1] = new Vector.<CharacterEntity>();
			this.gameMode = gameMode;
			this.isTutorial = isTutorial;
		}
		
		protected override function addedToStage(e:Event):void {
			super.addedToStage(e);
			InitWaypoints();
			InitEvironment();
			InitGame();
			countDownEntity = new Timer(1000);
			countDownEntity.addEventListener(TimerEvent.TIMER, CountDown);
			addEventListener(EnterFrameEvent.ENTER_FRAME, loading);
		}
		
		private function loading(e:EnterFrameEvent):void {
			removeEventListener(EnterFrameEvent.ENTER_FRAME, loading);
			if (gameMode == GameModes.SINGLEPLAYER) {
				if (isTutorial) {
					TutorialState = 0;
				} else {
					countDownEntity.start();
				}
			} else {
				var data:Object = new Object();
				data.key = PacketHeader.game_load_finish;
				data.values = null;
				Manager.clientPacket.writeLine(data);
			}
		}
		
		protected override function removedFromStage(e:Event):void {
			trace("Game disposing...");
			StopGame();
			destroy();
			super.removedFromStage(e);
		}
		
		public function InitGame():void {
			// Setting players type
			var isSimulation:Boolean = (gameMode == GameModes.MULTIPLAYER_JOIN);
			var player1_type:int = PlayerTypes.NORMAL;
			var player2_type:int = PlayerTypes.AI;
			if (gameMode == GameModes.MULTIPLAYER_HOST) {
				player1_type = PlayerTypes.NORMAL;
				player2_type = PlayerTypes.OTHER;
			}
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				player1_type = PlayerTypes.OTHER;
				player2_type = PlayerTypes.NORMAL;
			}
			// Player 1
			var player_1_gate_1:Image = new Image(atlas.getTexture("Gate01"));
			var player_1_gate_2:Image = new Image(atlas.getTexture("Gate02"));
			players[0] = new PlayerEntity(this, ++charactersID, playersInfo[0], player1_type, new BaseCharacterInformation(BaseCharacterInformation.MODE_GAME), player_1_gate_1, player_1_gate_2, envHomeFront, envHomeBack, envCannonTop, envCannonBottom, isSimulation);
			players[0].x = players[0].width / 2;
			players[0].y = 435;
			EntitiesKeeper[charactersID] = players[0];
			layerGate.addChild(players[0]);
			
			// Player 2
			var player_2_gate_1:Image = new Image(atlas.getTexture("EnemyGate01"));
			var player_2_gate_2:Image = new Image(atlas.getTexture("EnemyGate02"));
			players[1] = new PlayerEntity(this, ++charactersID, playersInfo[1], player2_type, new BaseCharacterInformation(BaseCharacterInformation.MODE_GAME), player_2_gate_1, player_2_gate_2, envEnemyHomeFront, envEnemyHomeBack, envEnemyCannonTop, envEnemyCannonBottom, isSimulation);
			players[1].x = 1200 - players[1].width / 2;
			players[1].y = 435;
			EntitiesKeeper[charactersID] = players[1];
			layerGate.addChild(players[1]);
			
			// Boards
			// Board for player 1
			boards[0] = new Board(this, players[0]);
			boards[0].x = 300;
			boards[0].y = 100;
			// Board for player 2
			boards[1] = new Board(this, players[1]);
			boards[1].x = 300;
			boards[1].y = 100;
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				// If player is joiner, so they are player 2 so hide player's 1 board
				boards[0].visible = false;
			} else {
				// If player is joiner, so they are player 1 so hide player's 2 board
				boards[1].visible = false;
			}
			
			// Add boards to the game
			layerBoard.addChild(boards[0]);
			layerBoard.addChild(boards[1]);
			
			// Player information UI
			envPlayerInfo01 = new UIPlayerInfo(this, players[0]);
			envPlayerInfo01.x = 20;
			envPlayerInfo01.y = 5;
			envPlayerInfo02 = new UIPlayerInfo(this, players[1]);
			envPlayerInfo02.x = 1000;
			envPlayerInfo02.y = 5;
			layerUI.addChild(envPlayerInfo01);
			layerUI.addChild(envPlayerInfo02);
			
			// Choose character UI
			// for player 1
			if (boards[0].Player.Type == PlayerTypes.NORMAL) {
				envChooseChar01 = new UIChooseCharacter(this, boards[0], UIChooseCharacter.TYPE_TOP);
				envChooseChar01.x = 150;
				envChooseChar01.y = 185;
				layerUI.addChild(envChooseChar01);
				envChooseChar02 = new UIChooseCharacter(this, boards[0], UIChooseCharacter.TYPE_BOTTOM);
				envChooseChar02.x = 150;
				envChooseChar02.y = 470;
				layerUI.addChild(envChooseChar02);
			}
			// for player 2
			if (boards[1].Player.Type == PlayerTypes.NORMAL) {
				envChooseChar01 = new UIChooseCharacter(this, boards[1], UIChooseCharacter.TYPE_TOP);
				envChooseChar01.x = 1050;
				envChooseChar01.y = 185;
				layerUI.addChild(envChooseChar01);
				envChooseChar02 = new UIChooseCharacter(this, boards[1], UIChooseCharacter.TYPE_BOTTOM);
				envChooseChar02.x = 1050;
				envChooseChar02.y = 470;
				layerUI.addChild(envChooseChar02);
			}
			
			// Random start character for test AI
			if (boards[0].Player.Type == PlayerTypes.AI) {
				boards[0].chooseCharacterByIndex(0, CharacterIndex.random());
				boards[0].chooseCharacterByIndex(1, CharacterIndex.random());
				boards[0].chooseCharacterByIndex(2, CharacterIndex.random());
				boards[0].chooseCharacterByIndex(3, CharacterIndex.random());
			}
			
			// Random start character for enemy (AI)
			if (boards[1].Player.Type == PlayerTypes.AI) {
				boards[1].chooseCharacterByIndex(0, CharacterIndex.random());
				boards[1].chooseCharacterByIndex(1, CharacterIndex.random());
				boards[1].chooseCharacterByIndex(2, CharacterIndex.random());
				boards[1].chooseCharacterByIndex(3, CharacterIndex.random());
			}
			
			// Game result UI
			envGameResult = new UIFightResult(this);
			layerUI.addChild(envGameResult);
		}
		
		public function InitEvironment():void {
			// Map background
			envBG = new Image(GameTexturesHelper.getTexture("BackgroundFight"));
			envBG.blendMode = BlendMode.NONE;
			floorLayer = new Sprite();
			// Homes
			envEnemyHomeBack = new Image(atlas.getTexture("EnemyHomeBack"));
			envEnemyHomeBack.pivotX = envEnemyHomeBack.width / 2;
			envEnemyHomeBack.x = 1050;
			envEnemyHomeBack.y = 450;
			envEnemyHomeFront = new Image(atlas.getTexture("EnemyHomeFront"));
			envEnemyHomeFront.pivotX = envEnemyHomeFront.width / 2;
			envEnemyHomeFront.x = 1050;
			envEnemyHomeFront.y = 155;
			envHomeBack = new Image(atlas.getTexture("HomeBack"));
			envHomeBack.pivotX = envHomeBack.width / 2;
			envHomeBack.x = 150;
			envHomeBack.y = 450;
			envHomeFront = new Image(atlas.getTexture("HomeFront"));
			envHomeFront.pivotX = envHomeFront.width / 2;
			envHomeFront.x = 150;
			envHomeFront.y = 165;
			
			// Cannons
			envEnemyCannonTop = new MovieClip(GameTexturesHelper.getCannonTextureAtlas().getTextures("CannonSprite_"));
			envEnemyCannonTop.pivotX = envEnemyCannonTop.width / 2;
			envEnemyCannonTop.pivotY = envEnemyCannonTop.height;
			envEnemyCannonTop.scaleX = -1;
			envEnemyCannonTop.x = 1010;
			envEnemyCannonTop.y = 220;
			envEnemyCannonTop.fps = 8; 
			envEnemyCannonTop.touchable = false;
			
			envEnemyCannonBottom = new MovieClip(GameTexturesHelper.getCannonTextureAtlas().getTextures("CannonSprite_"));
			envEnemyCannonBottom.pivotX = envEnemyCannonBottom.width / 2;
			envEnemyCannonBottom.pivotY = envEnemyCannonBottom.height;
			envEnemyCannonBottom.scaleX = -1;
			envEnemyCannonBottom.x = 1010;
			envEnemyCannonBottom.y = 680;
			envEnemyCannonBottom.fps = 8;
			envEnemyCannonBottom.touchable = false;
			
			envCannonTop = new MovieClip(GameTexturesHelper.getCannonTextureAtlas().getTextures("CannonSprite_"));
			envCannonTop.pivotX = envCannonTop.width / 2;
			envCannonTop.pivotY = envCannonTop.height;
			envCannonTop.x = 190;
			envCannonTop.y = 220;
			envCannonTop.fps = 8;
			envCannonTop.touchable = false;
			
			envCannonBottom = new MovieClip(GameTexturesHelper.getCannonTextureAtlas().getTextures("CannonSprite_"));
			envCannonBottom.pivotX = envCannonBottom.width / 2;
			envCannonBottom.pivotY = envCannonBottom.height;
			envCannonBottom.x = 190;
			envCannonBottom.y = 680;
			envCannonBottom.fps = 8;
			envCannonBottom.touchable = false;
			
			// An layers
			// character
			layerCharactersTop = new Sprite();
			layerCharactersBottom = new Sprite();
			// gate
			layerGate = new Sprite();
			// effect
			layerCharacterEffects = new GameEffects(this);
			// board
			layerBoard = new Sprite();
			// ui
			layerUI = new Sprite();
			
			// add layers and environment to stage
			addChild(envBG);
			addChild(floorLayer);
			addChild(envCannonTop);
			addChild(envEnemyCannonTop);
			addChild(envHomeFront);
			addChild(envEnemyHomeFront);
			addChild(layerCharactersTop);
			addChild(layerBoard);
			addChild(layerCharactersBottom);
			addChild(layerGate);
			addChild(envHomeBack);
			addChild(envEnemyHomeBack);
			addChild(envCannonBottom);
			addChild(envEnemyCannonBottom);
			addChild(layerCharacterEffects);
			addChild(layerUI);
			
			// Count down number
			envNumber = new Array();
			for (var i:int = 1; i <= 10; ++i) {
				envNumber.push(new Image(countdownAtlas.getTexture("Number_" + i)));
				envNumber[envNumber.length - 1].pivotX = envNumber[envNumber.length - 1].width / 2;
				envNumber[envNumber.length - 1].pivotY = envNumber[envNumber.length - 1].height / 2;
				envNumber[envNumber.length - 1].x = GlobalVariables.screenWidth / 2;
				envNumber[envNumber.length - 1].y = GlobalVariables.screenHeight / 2;
				envNumber[envNumber.length - 1].touchable = false;
				envNumber[envNumber.length - 1].useHandCursor = false;
			}
			
			// Tutorial
			if (isTutorial) {
				// Add a tutorial scene
				tutorialAtlas = TutorialTexturesHelper.getTextureAtlas();
				tutorialArrow = new UIArrow(tutorialAtlas, this);
				tutorialDialog = new UITutorial(tutorialAtlas, this);
				tutorialNPC = new UINPC(tutorialAtlas, this);
				addChild(tutorialArrow);
				tutorialArrow.visible = false;
				addChild(tutorialDialog);
				addChild(tutorialNPC);
			}
		}
		
		public function InitWaypoints():void {
			this.waypoints = new Array();
			this.waypoints.length = 2;
			// up:		20,220 -> 65,220 -> 170,220 -> 170,-50 -> 880,-50 -> 880,220 -> 995,220 -> 1020,220
			// down:	20,360 -> 65,360 -> 170,360 -> 170,640 -> 880,640 -> 880,360 -> 995,360 -> 1020,360
			// Left team
			//waypoints[0] = new Array(new Point(1020, 220), new Point(995, 220), new Point(880, 220), new Point(880, -50), new Point(170, -50), new Point(170, 220), new Point(65, 220));
			//waypoints[1] = new Array(new Point(1020, 360), new Point(995, 360), new Point(880, 360), new Point(880, 640), new Point(170, 640), new Point(170, 360), new Point(65, 360));
			// Right team
			//waypoints[2] = new Array(new Point(20,220), new Point(65, 220), new Point(170, 220), new Point(170, -50), new Point(880, -50), new Point(880, 220), new Point(995, 220));
			//waypoints[3] = new Array(new Point(20,360), new Point(65, 360), new Point(170, 360), new Point(170, 640), new Point(880, 640), new Point(880, 360), new Point(995, 360));
			// Top
			waypoints[DIR_WAYPOINT_TOP] = new Array(new Point( -100, 365), new Point(245, 365), new Point(245, 85), new Point(955, 85), new Point(955, 365), new Point(1300, 365));
			waypoints[DIR_WAYPOINT_BOTTOM] = new Array(new Point( -100, 505), new Point(245, 505), new Point(245, 785), new Point(955, 785), new Point(955, 505), new Point(1300, 505));
			this.spawnpoints = new Array();
			this.spawnpoints.length = 4;
			spawnpoints[SPAWN_WAYPOINT_TOP_LEFT] = new Point(150, 365);
			spawnpoints[SPAWN_WAYPOINT_TOP_RIGHT] = new Point(1050, 365);
			spawnpoints[SPAWN_WAYPOINT_BOTTOM_LEFT] = new Point(150, 505);
			spawnpoints[SPAWN_WAYPOINT_BOTTOM_RIGHT] = new Point(1050, 505);
		}
		
		public function CountDown(e:TimerEvent):void {
			var data:Object = new Object();
			if (intervalBeforeStart > 0) {
				--intervalBeforeStart;
				DoCountDownEffect(intervalBeforeStart);
				if (gameMode == GameModes.MULTIPLAYER_HOST) {
					data.key = PacketHeader.game_host_count_down;
					data.values = [ intervalBeforeStart ];
					Manager.clientPacket.writeLine(data);
				}
				Manager.SFXSoundManager.play("countdown");
			} else {
				countDownEntity.stop();
				countDownEntity.removeEventListener(TimerEvent.TIMER, CountDown);
				StartGame();
				if (isTutorial) {
					TutorialState = 3;
				}
				if (gameMode == GameModes.MULTIPLAYER_HOST) {
					data.key = PacketHeader.game_host_start;
					data.values = null;
					Manager.clientPacket.writeLine(data);
				}
			}
		}
		
		public function DoCountDownEffect(num:int):void {
			if (gameMode != GameModes.SINGLEPLAYER) {
				envChooseChar01.sendToServer();
				envChooseChar02.sendToServer();
			}
			envNumber[num].scaleX = 0.25;
			envNumber[num].scaleY = 0.25;
			addChild(envNumber[num]);
			var cdTween:Tween = new Tween(envNumber[num], 0.5, Transitions.EASE_OUT_BACK);
			cdTween.animate("scaleX", 1.25);
			cdTween.animate("scaleY", 1.25);
			cdTween.onComplete = function():void {
				var cdTweenEnd:Tween = new Tween(envNumber[num], 0.3);
				cdTweenEnd.animate("scaleX", 10.0);
				cdTweenEnd.animate("scaleY", 10.0);
				cdTweenEnd.fadeTo(0);
				cdTweenEnd.onComplete = function():void {
					removeChild(envNumber[num], true);
				};
				Starling.juggler.add(cdTweenEnd);
			};
			Starling.juggler.add(cdTween);
		}
		
		public function StartGame():void {
			envChooseChar01.close(true);
			envChooseChar02.close(true);
			if (!Manager.BGMSoundManager.Playing("bgm_battle01"))
				Manager.BGMSoundManager.play("bgm_battle01", 0, int.MAX_VALUE);
			if (boards[0] != null)
				(boards[0] as Board).start();
			if (boards[1] != null)
				(boards[1] as Board).start();
			isGameStart = true;
			isGameEnd = false;
		}
		
		public function StopGame():void {
			if (boards[0] != null)
				(boards[0] as Board).stop();
			if (boards[1] != null)
				(boards[1] as Board).stop();
			isGameStart = false;
			isGameEnd = true;
		}
		
		public function destroy():void {
			var i:int;
			var key:String;
			envNumber.splice(0, spawnpoints.length);
			waypoints.splice(0, waypoints.length);
			spawnpoints.splice(0, spawnpoints.length);
			//for (i = 0; i < boards.length; ++i) {
			//	boards[0].destroy();
			//}
			boards.splice(0, boards.length);
			for (i = 0; i < players.length; ++i) {
				players[0].destroy();
			}
			players.splice(0, players.length);
			playersInfo.splice(0, playersInfo.length);
			for (i = 0; i < characters.length; ++i )
			{
				characters[i].splice(0, characters[i].length);
			}
			characters.splice(0, characters.length);
			for (key in EntitiesKeeper) {
				delete EntitiesKeeper[key];
			}
			while (numChildren > 0) {
				var asImage:Image = getChildAt(0) as Image;
				if (asImage != null) {
					asImage.texture.dispose();
					removeChildAt(0, true);
				} else {
					removeChildAt(0, true);
				}
			}
			removeChildren(0, -1, true);
			var t:Texture;
			for each (t in atlas.getTextures()) 
				t.dispose();
			atlas.dispose();
			for each (t in countdownAtlas.getTextures())
				t.dispose();
			countdownAtlas.dispose();
			for each (t in runeAtlas.getTextures())
				t.dispose();
			runeAtlas.dispose();
			for each (t in achievementAtlas.getTextures())
				t.dispose();
			achievementAtlas.dispose();
			if (isTutorial) {
				for each (t in tutorialAtlas.getTextures())
					t.dispose();
				tutorialAtlas.dispose();
			}
		}
		
		public function AppendCharacter(playerIdx:int, charactersID:int, runeType:int, runeLevel:int):void {
			var isSimulation:Boolean = (gameMode == GameModes.MULTIPLAYER_JOIN);
			var board:Board = boards[playerIdx];
			var charInfo:BaseCharacterInformation;
			if (runeType == RuneTypes.SP_RAND) {
				runeType = Rune.GetRandomNormalRune();
				charInfo = board.getChosenCharacter(runeType);
			} else {
				charInfo = board.getChosenCharacter(runeType);
			}
			var playerEnt:PlayerEntity = board.Player;
			var enemyPlayerEnt:PlayerEntity;
			var new_character:CharacterEntity;
			var waypoint:Array = new Array();
			var from_waypoint:Array;
			var dir_waypoint:int;
			var spawnpoint:Point;
			var i:int;
			var env:Sprite;
			if (board == boards[0]) {
				enemyPlayerEnt = boards[1].Player;
				if (runeType == RuneTypes.YELLOW || runeType == RuneTypes.RED) {
					from_waypoint = waypoints[DIR_WAYPOINT_TOP];
					env = layerCharactersTop;
					spawnpoint = spawnpoints[SPAWN_WAYPOINT_TOP_LEFT];
				} else {
					from_waypoint = waypoints[DIR_WAYPOINT_BOTTOM];
					env = layerCharactersBottom;
					spawnpoint = spawnpoints[SPAWN_WAYPOINT_BOTTOM_LEFT];
				}
				dir_waypoint = DIR_WAYPOINT_TO_RIGHT;
			} else {
				enemyPlayerEnt = boards[0].Player;
				if (runeType == RuneTypes.YELLOW || runeType == RuneTypes.RED) {
					from_waypoint = waypoints[DIR_WAYPOINT_TOP];
					env = layerCharactersTop;
					spawnpoint = spawnpoints[SPAWN_WAYPOINT_TOP_RIGHT];
				} else {
					from_waypoint = waypoints[DIR_WAYPOINT_BOTTOM];
					env = layerCharactersBottom;
					spawnpoint = spawnpoints[SPAWN_WAYPOINT_BOTTOM_RIGHT];
				}
				dir_waypoint = DIR_WAYPOINT_TO_LEFT;
			}
			for (i = 0; i < from_waypoint.length; ++i) {
				waypoint.push(from_waypoint[i]);
			}
			this.removeEventListener(EnterFrameEvent.ENTER_FRAME, UpdateCharactersLayer);
			var useSkill:Boolean = runeLevel == RuneLevels.NORMAL ? false : true;
			
			if (!useSkill) {
				new_character = new CharacterEntity(this, charactersID, charInfo.Clone(), playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, false, isSimulation);
			} else {
				switch (charInfo.CharIndex) {
					case CharacterTextureHelper.CHAR_ARCHER:
						new_character = new SkilledArcherCharacterEntity(this, charactersID, charInfo.Clone(), playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
						break;
					case CharacterTextureHelper.CHAR_ASSASIN:
						new_character = new SkilledAssasinCharacterEntity(this, charactersID, charInfo.Clone(), playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
						break;
					case CharacterTextureHelper.CHAR_FIGHTER:
						new_character = new SkilledFighterCharacterEntity(this, charactersID, charInfo.Clone(), playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
						break;
					case CharacterTextureHelper.CHAR_KNIGHT:
						new_character = new SkilledKnightCharacterEntity(this, charactersID, charInfo.Clone(), playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
						break;
					case CharacterTextureHelper.CHAR_HERMIT:
						new_character = new SkilledHermitCharacterEntity(this, charactersID, charInfo.Clone(), playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
						break;
					case CharacterTextureHelper.CHAR_MAGE:
						new_character = new SkilledMageCharacterEntity(this, charactersID, charInfo.Clone(), playerEnt, enemyPlayerEnt, waypoint, dir_waypoint, spawnpoint, isSimulation);
						break;
				}
			}
			playerEnt.addTeamBuffToChar(new_character);
			env.addChild(new_character);
			// Push to characters list
			if (board == boards[0]) {
				characters[0].push(new_character);
			} else {
				characters[1].push(new_character);
			}
			EntitiesKeeper["" + charactersID] = new_character;
			if (gameMode == GameModes.MULTIPLAYER_HOST) {
				var data:Object = new Object();
				data.key = PacketHeader.game_append_character;
				data.values = [ playerIdx, charactersID, runeType, runeLevel ];
				Manager.clientPacket.writeLine(data);
			}
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, UpdateCharactersLayer);
		}
		
		public function SpawnCharacter(board:Board, runeType:int, runeLevel:int = RuneLevels.NORMAL):void {
			var playerIdx:int = boards.indexOf(board);
			var data:Object = new Object();
			if (playerIdx < 0) {
				// No player found.
				return;
			} 
			if (gameMode == GameModes.SINGLEPLAYER) {
				AppendCharacter(playerIdx, ++charactersID, runeType, runeLevel);
			} else {
				// Connect to server to spawn a character
				data.key = PacketHeader.game_spawn_character;
				data.values = [ runeType, runeLevel ];
				Manager.clientPacket.writeLine(data);
			}
		}
		
		public function RemoveCharacterFromList(charEnt:CharacterEntity):void {
			var playerEnt:PlayerEntity = charEnt.Player;
			var charIndex:int;
			if (playerEnt == players[0]) {
				charIndex = characters[0].indexOf(charEnt);
				characters[0].splice(charIndex, 1);
				delete EntitiesKeeper["" + charEnt.ID];
			} else {
				charIndex = characters[1].indexOf(charEnt);
				characters[1].splice(charIndex, 1);
				delete EntitiesKeeper["" + charEnt.ID];
			}
		}
		
		public function numCharacters(playerEnt:PlayerEntity):int {
			if (playerEnt == players[0]) {
				return characters[0].length;
			} else {
				return characters[1].length;
			}
		}
		
		public function FindForEnemy(finder:CharacterEntity):void {
			var that:Game = this;
			var func:Function = function():void {
				var characters:Array = new Array();
				var i:int;
				// An comparing characters
				var theCharacter:Entity;	// Temporary character
				var distance:Number;	// Distance between 2 characters
				// Add an other character for finding 
				var playerEnt:PlayerEntity = finder.Enemy;
				if (playerEnt == players[0]) {
					for (i = 0; i < that.characters[0].length; ++i)
						characters.push(that.characters[0][i]);
				} else {
					for (i = 0; i < that.characters[1].length; ++i)
						characters.push(that.characters[1][i]);
				}
				characters.push(finder.Enemy);
				for (i = 0; i < characters.length; ++i) {
					theCharacter = characters[i] as CharacterEntity;
					if (theCharacter != null && theCharacter != finder 
						&& (theCharacter as CharacterEntity).Player != finder.Player) 
					{
						distance = Math.sqrt(Math.pow(theCharacter.x - finder.x, 2) + Math.pow(theCharacter.y - finder.y, 2));
						if (distance <= finder.CharacterInfo.AtkRange && finder.isInSamePath(theCharacter as CharacterEntity)) {
							finder.CurrentEnemy = theCharacter;
							return;
						}
					} else {
						theCharacter = characters[i] as PlayerEntity;
						if (theCharacter != null && (theCharacter as PlayerEntity).CurrentHP > 0) {
							distance = Math.sqrt(Math.pow(theCharacter.x - finder.x, 2) + Math.pow(theCharacter.y - finder.y, 2));
							if (distance <= /*finder.CharacterInfo.AtkRange*/ 100) {
								finder.CurrentEnemy = theCharacter;
								return;
							}
						}
					}
				}
				finder.removeEventListener(EnterFrameEvent.ENTER_FRAME, func);
			}; // End of function declaration
			finder.addEventListener(EnterFrameEvent.ENTER_FRAME, func);
		}
		
		public function UpdateCharactersLayer(e:EnterFrameEvent):void {
			SortCharacterLayer(layerCharactersTop);
			SortCharacterLayer(layerCharactersBottom);
		}
		
		private function SortCharacterLayer(env:Sprite):void {
			var i:int;
			var j:int;
			var sortingCharacters:Array = new Array(); // Sorting from low to high
			var theCharacter:CharacterEntity;
			for (i = 0; i < env.numChildren; ++i) {
				theCharacter = env.getChildAt(i) as CharacterEntity;
				if (theCharacter.CurrentDirection == CharacterEntity.DIRECTION_UP || theCharacter.CurrentDirection == CharacterEntity.DIRECTION_DOWN) {
					sortingCharacters.push(theCharacter);
				}
			}
			// Sorting
			for (i = 1; i < sortingCharacters.length; i++) {
				j = i;
				while ((j > 0) && (sortingCharacters[j - 1].y > sortingCharacters[j].y))
				{
					env.swapChildren(sortingCharacters[j], sortingCharacters[j - 1]);
					j--;
				}
			}
		}
		
		public function GameEnd(looser:PlayerEntity):void {
			if (!isGameEnd) {
				Manager.SFXSoundManager.play("game_sfx_home_broken");
				this.looser = looser;
				var isWin:Boolean = looser != players[0];
				if (!isWin) {
					KillAll(players[0]);
				} else {
					KillAll(players[1]);
				}
				// Dispose objects
				StopGame();
				// Show end game dialog
				var timerTween:Tween = new Tween(this, 2);
				timerTween.onComplete = function():void {
					if (gameMode == GameModes.SINGLEPLAYER) {
						envGameResult.end(isWin);
					}
					if (gameMode == GameModes.MULTIPLAYER_HOST) {
						var winnerPlayerIdx:int = isWin ? 0 : 1;
						var data:Object = new Object();
						data.key = PacketHeader.game_result;
						data.values = [ winnerPlayerIdx ];
						Manager.clientPacket.writeLine(data);
					}
				}
				Starling.juggler.add(timerTween);
			}
		}
		
		public override function doBlackFade(delay:Number = 0.75):void {
			super.doBlackFade();
			layerUI.addChildAt(fadeImg, layerUI.getChildIndex(envGameResult));
			Starling.juggler.add(fadeTween);
		}
		
		// Cannon shoot
		public function DoCannonShoot(playerIdx:int, collectedCannon:int):void {
			var playerEnt:PlayerEntity = players[playerIdx];
			var theCharacter:CharacterEntity;
			var index:int = 0;
			var func:Function = function():void {
				playerEnt.removeEventListener(EnterFrameEvent.ENTER_FRAME, func);
				
				if (playerEnt == players[0]) {
					if (characters[1].length > 0) {
						index = Helper.randomRange(0, characters[1].length - 1);
						theCharacter = characters[1][index];
					}
				} else {
					if (characters[0].length > 0) {
						index = Helper.randomRange(0, characters[0].length - 1);
						theCharacter = characters[0][index];
					}
				}
				
				if (layerCharactersTop.contains(theCharacter)) {
					// Top cannon shoot
					EffectLayer.cannonTo(theCharacter, playerEnt, 0, collectedCannon, CANNON_DAMAGE);
				} else {
					// Bottom cannon shoot
					EffectLayer.cannonTo(theCharacter, playerEnt, 1, collectedCannon, CANNON_DAMAGE);
				}
			}
			playerEnt.addEventListener(EnterFrameEvent.ENTER_FRAME, func);
		}
		
		public function CannonShoot(playerEnt:PlayerEntity, collectedCannon:int):void {
			var playerIdx:int = players.indexOf(playerEnt);
			var data:Object = new Object();
			if (playerIdx < 0) {
				// No player found.
				return;
			}
			if (gameMode == GameModes.SINGLEPLAYER) {
				DoCannonShoot(playerIdx, collectedCannon);
			} else {
				// Connect to server to shoot cannon
				data.key = PacketHeader.game_use_cannon;
				data.values = [ collectedCannon ];
				Manager.clientPacket.writeLine(data);
			}
		}
		
		// Special Rune Activated
		public function DoHeal(playerIdx:int):void {
			var playerEnt:PlayerEntity = players[playerIdx];
			Manager.SFXSoundManager.play("game_sfx_heal");
			EffectLayer.healTo(playerEnt, HEAL_VALUE);
			/*
			var i:int = 0;
			var func:Function = function():void {
				playerEnt.removeEventListener(EnterFrameEvent.ENTER_FRAME, func);
				var theCharacter:CharacterEntity;
				if (playerEnt == players[0]) {
					for (i = 0; i < characters[0].length; ++i) {
						theCharacter = characters[0][i];
						EffectLayer.healTo(theCharacter, HEAL_VALUE);
					}
				} else {
					for (i = 0; i < characters[1].length; ++i) {
						theCharacter = characters[1][i];
						EffectLayer.healTo(theCharacter, HEAL_VALUE);
					}
				}
			}
			playerEnt.addEventListener(EnterFrameEvent.ENTER_FRAME, func);
			*/
		}
		
		public function Heal(playerEnt:PlayerEntity):void {
			var playerIdx:int = players.indexOf(playerEnt);
			var data:Object = new Object();
			if (playerIdx < 0) {
				// No player found.
				return;
			}
			if (gameMode == GameModes.SINGLEPLAYER) {
				DoHeal(playerIdx);
			} else {
				// Connect to server to heal
				data.key = PacketHeader.game_use_heal;
				data.values = null;
				Manager.clientPacket.writeLine(data);
			}
		}
		
		public function DoMeto(playerIdx:int):void {
			var playerEnt:PlayerEntity = players[playerIdx];
			var i:int = 0;
			var func:Function = function():void {
				playerEnt.removeEventListener(EnterFrameEvent.ENTER_FRAME, func);
				var theCharacter:CharacterEntity;
				if (playerEnt == players[0]) {
					for (i = 0; i < characters[1].length; ++i) {
						theCharacter = characters[1][i];
						EffectLayer.meteorAttackTo(theCharacter, METEOR_DAMAGE);
						EffectLayer.meteorAttackTo(theCharacter, METEOR_DAMAGE);
					}
				} else {
					for (i = 0; i < characters[0].length; ++i) {
						theCharacter = characters[0][i];
						EffectLayer.meteorAttackTo(theCharacter, METEOR_DAMAGE);
						EffectLayer.meteorAttackTo(theCharacter, METEOR_DAMAGE);
					}
				}
			}
			playerEnt.addEventListener(EnterFrameEvent.ENTER_FRAME, func);
		}
		
		public function Meto(playerEnt:PlayerEntity):void {
			var data:Object = new Object();
			var playerIdx:int = players.indexOf(playerEnt);
			if (playerIdx < 0) {
				// No player found.
				return;
			}
			if (gameMode == GameModes.SINGLEPLAYER) {
				DoMeto(playerIdx);
			} else {
				// Connect to server to call meteor
				data.key = PacketHeader.game_use_meteor;
				data.values = null;
				Manager.clientPacket.writeLine(data);
			}
		}
		
		public function DoStun(playerIdx:int):void {
			var playerEnt:PlayerEntity = players[playerIdx];
			Manager.SFXSoundManager.play("stun");
			var i:int = 0;
			var func:Function = function():void {
				playerEnt.removeEventListener(EnterFrameEvent.ENTER_FRAME, func);
				var theCharacter:CharacterEntity;
				if (playerEnt == players[0]) {
					for (i = 0; i < characters[1].length; ++i) {
						theCharacter = characters[1][i];
						EffectLayer.stunTo(theCharacter, STUN_TIME);
					}
				} else {
					for (i = 0; i < characters[0].length; ++i) {
						theCharacter = characters[0][i];
						EffectLayer.stunTo(theCharacter, STUN_TIME);
					}
				}
			}
			playerEnt.addEventListener(EnterFrameEvent.ENTER_FRAME, func);
		}
		
		public function Stun(playerEnt:PlayerEntity):void {
			var data:Object = new Object();
			var playerIdx:int = players.indexOf(playerEnt);
			if (playerIdx < 0) {
				// No player found.
				return;
			}
			if (gameMode == GameModes.SINGLEPLAYER) {
				DoStun(playerIdx);
			} else {
				// Connect to server to call stun
				data.key = PacketHeader.game_use_stun;
				data.values = null;
				Manager.clientPacket.writeLine(data);
			}
		}
		
		public function KillAll(playerEnt:PlayerEntity):void {
			var i:int = 0;
			var func:Function = function():void {
				playerEnt.removeEventListener(EnterFrameEvent.ENTER_FRAME, func);
				var theCharacter:CharacterEntity;
				if (playerEnt == players[0]) {
					for (i = 0; i < characters[0].length; ++i) {
						theCharacter = characters[0][i];
						theCharacter.CurrentHP = 0;
					}
				} else {
					for (i = 0; i < characters[1].length; ++i) {
						theCharacter = characters[1][i];
						theCharacter.CurrentHP = 0;
					}
				}
			}
			playerEnt.addEventListener(EnterFrameEvent.ENTER_FRAME, func);
		}
		
		public function addTeamBuff(playerEnt:PlayerEntity, buffId:int):void {
			var q:int = playerEnt.addTeamBuff(buffId);
			var i:int = 0;
			var buff:EffectBuff;
			var func:Function = function():void {
				playerEnt.removeEventListener(EnterFrameEvent.ENTER_FRAME, func);
				var theCharacter:CharacterEntity;
				if (playerEnt == players[0]) {
					for (i = 0; i < characters[0].length; ++i) {
						theCharacter = characters[0][i];
						buff = new EffectBuff(buffId);
						theCharacter.addBuff(buff, EffectLayer);
					}
				} else {
					for (i = 0; i < characters[1].length; ++i) {
						theCharacter = characters[1][i];
						buff = new EffectBuff(buffId);
						theCharacter.addBuff(buff, EffectLayer);
					}
				}
			}
			if (q > 0)
				playerEnt.addEventListener(EnterFrameEvent.ENTER_FRAME, func);
		}
		
		public function delTeamBuff(playerEnt:PlayerEntity, buffId:int):void {
			var q:int = playerEnt.delTeamBuff(buffId);
			var i:int = 0;
			var func:Function = function():void {
				playerEnt.removeEventListener(EnterFrameEvent.ENTER_FRAME, func);
				var theCharacter:CharacterEntity;
				if (playerEnt == players[0]) {
					for (i = 0; i < characters[0].length; ++i) {
						theCharacter = characters[0][i];
						theCharacter.removeBuff(buffId);
					}
				} else {
					for (i = 0; i < characters[1].length; ++i) {
						theCharacter = characters[1][i];
						theCharacter.removeBuff(buffId);
					}
				}
			}
			if (q <= 0)
				playerEnt.addEventListener(EnterFrameEvent.ENTER_FRAME, func);
		}
		
		// Network functions
		public function allFightResult(playerIdx:int, totalGold:int, totalExp:int):void {
			if (gameMode != GameModes.SINGLEPLAYER) {
				var isWin:Boolean = false;
				if (gameMode == GameModes.MULTIPLAYER_HOST) {
					isWin = (playerIdx == 0);
				}
				if (gameMode == GameModes.MULTIPLAYER_JOIN) {
					isWin = (playerIdx == 1);
				}
				envGameResult.setRewardTotalGold(totalGold);
				envGameResult.setRewardTotalExp(totalExp);
				envGameResult.end(isWin);
			}
		}
		
		public function allChooseBoardCharacter(playerIdx:int, setIndex:int, charIdx:int):void {
			var board:Board = boards[playerIdx];
			if (gameMode != GameModes.SINGLEPLAYER) {
				if (board != null) {
					board.chooseCharacterByIndex(setIndex, charIdx);
				}
			}
		}
		
		// Functions for host player
		public function hostAllLoaded():void {
			if (gameMode == GameModes.MULTIPLAYER_HOST) {
				countDownEntity.start();
			}
		}
		
		public function hostSpawnCharacter(playeridx:int, runeType:int, runeLevel:int):void {
			if (gameMode == GameModes.MULTIPLAYER_HOST) {
				AppendCharacter(playeridx, ++charactersID, runeType, runeLevel);
			}
		}
		
		public function hostCannon(playeridx:int, collected_cannon:int):void {
			if (gameMode == GameModes.MULTIPLAYER_HOST) {
				DoCannonShoot(playeridx, collected_cannon);
			}
		}
		
		public function hostMeteor(playeridx:int):void {
			if (gameMode == GameModes.MULTIPLAYER_HOST) {
				DoMeto(playeridx);
			}
		}
		
		public function hostStun(playeridx:int):void {
			if (gameMode == GameModes.MULTIPLAYER_HOST) {
				DoStun(playeridx);
			}
		}
		
		public function hostHeal(playeridx:int):void {
			if (gameMode == GameModes.MULTIPLAYER_HOST) {
				DoHeal(playeridx);
			}
		}
		
		// Functions for client player
		public function clientCountDown(num:int):void {
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				DoCountDownEffect(num);
			}
		}
		
		public function clientGameStart():void {
			// Receiving rune type data
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				StartGame();
			}
		}
		
		public function clientAppendCharacter(id:int, playeridx:int, runeType:int, runeLevel:int):void {
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				AppendCharacter(playeridx, id, runeType, runeLevel);
			}
		}
		
		public function clientCannonTo(id:int, playeridx:int, cannonidx:int, collected_cannon:int):void {
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				// Calling from GameEffects for cannon effects
				var player:PlayerEntity = players[playeridx];
				var charEnt:Entity = EntitiesKeeper["" + id] as Entity;
				if (player != null && charEnt != null) {
					EffectLayer.cannonTo(charEnt, player, cannonidx, collected_cannon, CANNON_DAMAGE);
				}
			}
		}
		
		public function clientMeteorTo(id:int):void {
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				// Calling from GameEffects for meteor effects
				var charEnt:Entity = EntitiesKeeper["" + id] as Entity;
				if (charEnt != null) {
					EffectLayer.meteorTo(charEnt, METEOR_DAMAGE);
				}
			}
		}
		
		public function clientStunTo(id:int):void {
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				// Calling from GameEffects for stun effects
				var charEnt:Entity = EntitiesKeeper["" + id] as Entity;
				if (charEnt != null) {
					EffectLayer.stunTo(charEnt, STUN_TIME);
				}
			}
		}
		
		public function clientHealTo(id:int):void {
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				// Calling from GameEffects for heal effects
				var charEnt:Entity = EntitiesKeeper["" + id] as Entity;
				if (charEnt != null) {
					Manager.SFXSoundManager.play("game_sfx_heal");
					EffectLayer.healTo(charEnt, HEAL_VALUE);
				}
			}
		}
		
		public function clientUpdateEntity(id:int, state:int, x:Number, y:Number, currentHP:int):void {
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				var charEnt:Entity = EntitiesKeeper["" + id] as Entity;
				if (charEnt != null) {
					if (charEnt is CharacterEntity) {
						(charEnt as CharacterEntity).CurrentState = state;
						charEnt.MoveTo(new Point(x, y));
					}
					charEnt.CurrentHP = currentHP;
				}
			}
		}
		
		public function clientAppendEntityDamage(id:int, damage_type:String, damage:String, fromid:int):void {
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				var charEnt:Entity = EntitiesKeeper["" + id] as Entity;
				var fromEnt:CharacterEntity = EntitiesKeeper["" + fromid] as CharacterEntity;
				if (charEnt != null && fromEnt != null) {
					var damageInfo:Vector.<String> = new Vector.<String>();
					damageInfo[0] = damage_type;
					damageInfo[1] = damage;
					charEnt.appendDamage(damageInfo, fromEnt);
				}
			}
		}
		
		public function clientCharacterAttackingTo(id:int, targetid:int):void {
			if (gameMode == GameModes.MULTIPLAYER_JOIN) {
				var charEnt:CharacterEntity = EntitiesKeeper["" + id] as CharacterEntity;
				var targetEnt:CharacterEntity = EntitiesKeeper["" + targetid] as CharacterEntity;
				if (charEnt != null && targetEnt != null) {
					charEnt.Attacking(targetEnt);
				}
			}
		}
		
		public function checkPlayerIndex(playerEnt:PlayerEntity):int {
			return players.indexOf(playerEnt);
		}
		
		// An tutorial methods
		private function doTutorial():void {
			var that:Game = this;
			if (!isTutorial)
				return;
			var i:int = 0;
			switch (tutorialState) {
				case 0:
					// Dialog 3
					tutorialDialog.setMessages("เอาล่ะ ! ตอนนี้ท่านอยู่ในหน้าต่อสู้แล้ว \n\nก่อนเริ่มต่อสู้\nท่านสามารถเลือกทหารในการต่อสู้ได้โดยการคลิก\nที่สัญลักษณ์ประจำตัวของทหารอาชีพนั้น \n\nลองกดดูสิ !");
					tutorialDialog.removeAllOKButtonTriggerEvents();
					tutorialDialog.addOKButtonTriggerEvent(function(evt:Event):void {
						if (that != null) {
							that.TutorialState = 1;
						}
					});
					tutorialDialog.open();
					tutorialNPC.open();
				break;
				case 1:
					tutorialDialog.close();
					tutorialNPC.close();
					tutorialArrow.visible = true;
					tutorialArrow.setPosRot(95, 250, 0);
				break;
				case 2:
					countDownEntity.start();
				break;
				case 3:
					// Dialog 4
					tutorialArrow.visible = false;
					tutorialDialog.setMessages("เยี่ยมมาก ! เมื่อท่านเลือกทหารมาประจำตำแหน่งของป้อม\nแล้ว ต่อไปก็จะเป็นการเรียกทหารออกมาสู้รบโดยการเลื่อน\nศิลาที่มีสีเดียวกันให้ตรงกันอย่างน้อย 3 ศิลา ก็จะเป็นการ\nเสกทหารประจำศิลานั้นออกมาสู้รบ \n\nเอ้า ลองดู !!");
					tutorialDialog.removeAllOKButtonTriggerEvents();
					tutorialDialog.addOKButtonTriggerEvent(function(evt:Event):void {
						if (that != null) {
							that.TutorialState = 4;
						}
					});
					for (i = 0; i < boards.length; ++i) {
						boards[i].IsPause = true;
					}
					tutorialDialog.open();
					tutorialNPC.open();
				break;
				case 4:
					// Dialog 4
					for (i = 0; i < boards.length; ++i) {
						boards[i].IsPause = false;
					}
					tutorialDialog.close();
					tutorialNPC.close();
				break;
				case 5:
					// Dialog 5
					tutorialArrow.visible = false;
					tutorialDialog.setMessages("ยอดเยี่ยม บทเรียนต่อไป \n\nทหารแต่ละอาชีพมีสกิลพิเศษแตกต่างกันไป... \n\nและการเรียกใช้สกิลนั้น ท่านต้องเรียงศิลาให้ตรงกัน \n4 ชิ้น ศิลาจะถูกผนึกให้เป็นศิลาพิเศษและท่านต้องเรียง\nอีกครั้งเพื่อปลดปล่อยทหารที่มีสกิลออกมา \n\nท่านลองเรียกทหารที่มีสกิลพิเศษออกมาดูสิ");
					tutorialDialog.removeAllOKButtonTriggerEvents();
					tutorialDialog.addOKButtonTriggerEvent(function(evt:Event):void {
						if (that != null) {
							that.TutorialState = 6;
						}
					});
					for (i = 0; i < boards.length; ++i) {
						boards[i].IsPause = true;
					}
					tutorialDialog.open();
					tutorialNPC.open();
				break;
				case 6:
					// Dialog 5
					for (i = 0; i < boards.length; ++i) {
						boards[i].IsPause = false;
					}
					tutorialDialog.close();
					tutorialNPC.close();
				break;
				case 7:
					// Dialog 6
					tutorialArrow.visible = false;
					tutorialDialog.setMessages("ยอดเยี่ยมมาก ตอนนี้ท่านก็มาถึงบทเรียนสุดท้าย \n\nเมื่อท่านเรียงศิลาตรงกัน 5 ชิ้น ท่านจะได้ไอเท็มพิเศษ \nสามารถใช้งานได้โดยการคลิ๊กที่ไอเท็มนั้น ซึ่งแต่ละ\nไอเท็มจะช่วยให้ท่านมีโอกาศชนะมากขึ้น \n\nสำหรับภารกิจบทเรียนสุดท้าย จงเรียกทหารออกมา ทำลายปราการของศัตรู \n\nขอให้ท่านโชคดี");
					tutorialDialog.removeAllOKButtonTriggerEvents();
					tutorialDialog.addOKButtonTriggerEvent(function(evt:Event):void {
						if (that != null) {
							that.TutorialState = 8;
						}
					});
					for (i = 0; i < boards.length; ++i) {
						boards[i].IsPause = true;
					}
					tutorialDialog.open();
					tutorialNPC.open();
				break;
				case 8:
					// Dialog 6
					for (i = 0; i < boards.length; ++i) {
						boards[i].IsPause = false;
					}
					tutorialDialog.close();
					tutorialNPC.close();
				break;
			}
		}
		
		// Field
		public function get BattleId():int {
			return battleid;
		}
		
		public function get IsGameStart():Boolean {
			return isGameStart;
		}
		
		public function get IsGameEnd():Boolean {
			return isGameEnd;
		}
		
		public function get FloorLayer():Sprite {
			return floorLayer;
		}
		
		public function get EffectLayer():GameEffects {
			return layerCharacterEffects;
		}
		
		public function get UILayer():Sprite {
			return layerUI;
		}
		
		public function get Atlas():TextureAtlas {
			return atlas;
		}
		public function get CountDownAtlas():TextureAtlas {
			return countdownAtlas;
		}
		public function get RuneAtlas():TextureAtlas {
			return runeAtlas;
		}
		public function get GameMode():int {
			return gameMode;
		}
		public function get Players():Vector.<PlayerEntity> {
			return players;
		}
		public function get Boards():Vector.<Board> {
			return boards;
		}
		public function get AchievementAtlas():TextureAtlas {
			return achievementAtlas;
		}
		// Tutorial
		public function get TutorialAtlas():TextureAtlas {
			return tutorialAtlas;
		}
		public function get IsTutorial():Boolean {
			return isTutorial;
		}
		public function get TutorialState():int {
			return tutorialState;
		}
		public function set TutorialState(value:int):void {
			tutorialState = value;
			doTutorial();
		}
	}

}