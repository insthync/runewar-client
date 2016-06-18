package gameplay 
{
	import character.*;
	import flash.utils.getTimer;
	import player.PlayerEntity;
	import player.PlayerTypes;
	import flash.geom.Point;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.animation.Tween;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class Board extends Sprite
	{
		// Fields
		public const BOARD_SIZE:int = 6;											// Size of board (col = row)
		public const TILE_SIZE:int = 100;											// Size for each tiles (pixels)
		public const UNACTIVE_INDEX:Point = new Point(-BOARD_SIZE, -BOARD_SIZE);	// Variable for unactive rune index
		private var runes:Array;													// An runes entity
		private var highlightSprite:Sprite = new Sprite();							// Sprite for hightlight which is selected rune
		private var activeIndex:Point;												// Where rune which selected
		private var activeState:int;												// Game state which tell is player able to swapping?
		private var swapInfo:SwapInfo;												// Runes swapping handler
		//private var score:int = 0;
		private var combo:int = 0;
		private var isFillAllRune:Boolean;											// Runes ready state
		private var chosenCharacters:Vector.<BaseCharacterInformation>;				// An spawning character
		private var pEntity:PlayerEntity;										// Player information
		private var game:Game;
		// AI
		private var aiSwapTimestamp:int;
		private var isPause:Boolean;
		// Cannon Power
		private var collectedCannonTime:int = 0;
		private var collectedCannon:int = 0;
		private const LIMIT_CHARACTER:int = 16;
		// SFX
		private var useSound:Boolean;
		private var selectedEffect:Image;
		
		// Constructors
		public function Board(game:Game, pEntity:PlayerEntity) {
			super();
			chosenCharacters = new Vector.<BaseCharacterInformation>();
			chosenCharacters.length = RuneTypes.MAX - RuneTypes.SPECIAL_NUM;
			
			this.game = game;
			this.pEntity = pEntity;
			this.activeState = BoardStates.FALLING_RUNES;
			this.activeIndex = UNACTIVE_INDEX;
			this.useSound = (pEntity.Type == PlayerTypes.NORMAL);
			this.swapInfo = new SwapInfo(game, useSound);
			this.isFillAllRune = false;
			this.selectedEffect = new Image(game.RuneAtlas.getTexture("Rune_Selected"));
			this.selectedEffect.visible = false;
			this.selectedEffect.touchable = false;
			this.isPause = false;
		}
		
		public function start():void {
			Init();
			this.aiSwapTimestamp = getTimer();
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, checkTriplets);
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, findTriplets);
		}
		
		public function stop():void {
			this.selectedEffect.visible = false;
			this.removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
			this.removeEventListener(EnterFrameEvent.ENTER_FRAME, checkTriplets);
			this.removeEventListener(EnterFrameEvent.ENTER_FRAME, findTriplets);
			for (var y:int = 0; y < BOARD_SIZE; y++) {
				for (var x:int = 0; x < BOARD_SIZE; x++) {
					(runes[y][x] as Rune).Dying();
					(runes[y][x] as Rune).stop();
					(runes[y][x] as Rune).destroy();
				}
			}
		}
		
		public function destroy():void {
			for (var y:int = 0; y < BOARD_SIZE; y++) {
				for (var x:int = 0; x < BOARD_SIZE; x++) {
					(runes[y][x] as Rune).destroy();
				}
				(runes[y] as Array).splice(0);
			}
			runes.splice(0);
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
		}
		
		public function chooseCharacter(index:int, info:BaseCharacterInformation):void {
			if (index < chosenCharacters.length) {
				chosenCharacters[index] = info;
			}
		}
		
		public function chooseCharacterByIndex(index:int, charIndex:int):void {
			if (!game.IsGameStart)
				chooseCharacter(index, pEntity.AvailableCharacters[charIndex]);
		}
		
		public function getChosenCharacter(index:int):BaseCharacterInformation {
			if (index < chosenCharacters.length) {
				return chosenCharacters[index];
			}
			return null;
		}
		
		public function getChosenRandomCharacter():BaseCharacterInformation {
			var idx:int = Math.round(Math.random() * (chosenCharacters.length - 1));
			if (idx > chosenCharacters.length - 1)
				idx = chosenCharacters.length - 1;
			if (idx < 0)
				idx = 0;
			if (idx < chosenCharacters.length) {
				return chosenCharacters[idx];
			}
			return null;
		}
		
		// Events
		public function findTriplets(e:EnterFrameEvent):void {
			if (game.IsGameEnd || isPause)
				return;
			
			if (activeState == BoardStates.INTERACTIVE) {
				var swapped:Boolean = false;
				var activated:Boolean = false;
				var activatingRune:Rune;
				var fromPoint:Point;
				var toPoint:Point;
				var aiDelay:int;
				if (Player.Information.Level > GlobalVariables.AIDelay.length - 1) {
					aiDelay = GlobalVariables.AIDelay[GlobalVariables.AIDelay.length - 1];
				} else {
					aiDelay = GlobalVariables.AIDelay[Player.Information.Level];
				}
				
				// For runes in all rows...
				for (var i:int = 0; i < BOARD_SIZE; ++i) {
					// and columns...
					if (swapped || activated) {
						break;
					}
					for (var j:int = 0; j < BOARD_SIZE; ++j) {
						// if they're not too close to the side... 
							
						if (runes[i][j].Type > RuneTypes.SP_RAND && runes[i][j].Type < RuneTypes.MAX && !swapped)
						{
							activatingRune = runes[i][j] as Rune;
							activated = true;
							break;
						}
						
						if (i < BOARD_SIZE - 1 && !swapped && !activated) {
							
							// swap them horizontally
							swapTile(i, j, i + 1, j);
								
							// check if they form a line
							if ((checkRow(i,j) > 2 || checkColumn(i,j) > 2 || checkRow(i + 1,j) > 2 || checkColumn(i + 1,j) > 2) && !activated)
							{
								// if so, name the move made
								fromPoint = new Point(j, i);
								toPoint = new Point(j, i + 1)
								swapped = true;
							}
							
							// swap the tiles back
							swapTile(i, j, i + 1, j);
							if (swapped || activated) {
								break;
							}
						}
						
						// then if they're not to close to the bottom...
						if (j < BOARD_SIZE - 1 && !swapped && !activated) {
							
							// swap it vertically
							swapTile(i, j, i, j + 1);
								
							// check if they form a line
							if ((checkRow(i,j) > 2 || checkColumn(i,j) > 2 || checkRow(i,j + 1) > 2 || checkColumn(i,j + 1) > 2) && !activated)
							{
								// if so, name it
								fromPoint = new Point(j, i);
								toPoint = new Point(j + 1, i);
								swapped = true;
							}
							
							// swap the tiles back
							swapTile(i, j, i, j + 1);
							if (swapped || activated) {
								break;
							}
						}
					}
				}
				if (swapped || activated) {
					if (Player.Type == PlayerTypes.AI && getTimer() - aiSwapTimestamp >= aiDelay) {
						if (swapped) {
							aiSwapTimestamp = getTimer();
							swapping(fromPoint, toPoint);
						} else {
							activatingRune.activateSRune();
						}
					}
				} else {
					// Clear board
					ReInit();
				}
			}
		}
		private function update(event:EnterFrameEvent):void {
			if (game.IsGameEnd || isPause)
				return;
			if (activeState == BoardStates.SWAPPING_RUNES) {
				// Played swapping animation
				if (swapInfo.isReadyToCheck()) {
					if (swapInfo.IsActive) {
						// Checking is able to move or not
						var fromPoint:Point = swapInfo.from.Index;
						var toPoint:Point = swapInfo.to.Index;
						swapTile(fromPoint.y, fromPoint.x, toPoint.y, toPoint.x);
						
						if (swapInfo.from.Type != RuneTypes.NULL && swapInfo.from.Type >= RuneTypes.YELLOW && swapInfo.from.Type <= RuneTypes.SP_RAND && 
							(checkColumn(fromPoint.y, fromPoint.x) > 2 || checkRow(fromPoint.y, fromPoint.x) > 2 || checkColumn(toPoint.y, toPoint.x) > 2 || checkRow(toPoint.y, toPoint.x) > 2)) 
						{
							// is triplets
							// Reset its index cause swap effect
							runes[fromPoint.y][fromPoint.x].Index = fromPoint;
							runes[toPoint.y][toPoint.x].Index = toPoint;
							runes[fromPoint.y][fromPoint.x].updateMoveTime();
							runes[toPoint.y][toPoint.x].updateMoveTime();
							activeState = BoardStates.FALLING_RUNES;
							isFillAllRune = false;
						} else {
							swapTile(fromPoint.y, fromPoint.x, toPoint.y, toPoint.x);
							swapInfo.reverse();
						}
					} else {
						swapInfo.destroy();
						activeState = BoardStates.INTERACTIVE;
					}
				}
			} else if (activeState == BoardStates.FALLING_RUNES) {
				// Played falling animation
				if (isFillAllRune && isAllRuneTweenEnd()) {
					activeState = BoardStates.INTERACTIVE;
				}
			}
		}
		
		private function isAllRuneTweenEnd():Boolean {
			for (var y:int = 0; y < BOARD_SIZE; y++) {
				for (var x:int = 0; x < BOARD_SIZE; x++) {
					var rune:Rune = runes[y][x];
					if (!rune.Tweener.isComplete)
						return false;
				}
			}
			return true;
		}
		
		private function isRuneTweenEnd(rune:Rune):Boolean {
			return rune.Tweener.isComplete;
		}
		
		private function checkTriplets(event:EnterFrameEvent):void {
			if (game.IsGameEnd || isPause)
				return;
				
			//if (!isAllRuneTweenEnd())
			//	return;
			var y:int;
			var x:int;
			var tween:Tween;
			// Checking is every runes are ready or not?
			for (y = 0; y < BOARD_SIZE; y++) {
				for (x = 0; x < BOARD_SIZE; x++) {
					if (!runes[y][x].ReadyToGo)
						return;
				}
			}
			//Assume that runes are not falling
			var runesAreFalling:Boolean = false;
			// Check each rune for space below it
			for (y = BOARD_SIZE - 2; y >= 0; y--) {
				for (x = 0; x < BOARD_SIZE; x++) {
					// If a spot contains a rune, and has an empty space below...
					if (runes[y][x].Type != RuneTypes.NULL && runes[y + 1][x].Type == RuneTypes.NULL /*&&
						isRuneTweenEnd(runes[y][x]) && isRuneTweenEnd(runes[y + 1][x])*/) {
						// Set runes falling
						runesAreFalling = true;
						var tempRune:Rune = runes[y + 1][x];
						// Swap runes
						runes[y + 1][x] = runes[y][x];
						runes[y][x] = tempRune;
						// Set runes index
						runes[y + 1][x].Index = new Point(x, y + 1);
						runes[y][x].Index = new Point(x, y);
						runes[y][x].Type = RuneTypes.NULL;
						//runes[y + 1][x].y = (y + 1) * this.TILE_SIZE;
						if (!runes[y][x].Tweener.isComplete) {
							Starling.juggler.removeTweens(runes[y][x]);
						}
						if (!runes[y + 1][x].Tweener.isComplete) {
							Starling.juggler.removeTweens(runes[y + 1][x]);
						}
						runes[y + 1][x].InitTween();
						runes[y + 1][x].updateMoveTime();
						tween = runes[y + 1][x].Tweener;
						tween.onComplete = function():void {
							if (useSound) {
								game.Manager.SFXSoundManager.play("game_sfx_drop" + Helper.randomRange(1, 2));
							}
						};
						tween.moveTo(x * TILE_SIZE, (y + 1) * this.TILE_SIZE);
						Starling.juggler.add(tween);
						//break;
					}
				}
				// If a rune is falling
				//if (runesAreFalling) {
					// don't allow any more to start falling
					//break;
				//}
			}
			// Dropping new runes
			// Assume no new runes are needed
			var needNewRune:Boolean = false
			// but check all spaces...
			for (y = BOARD_SIZE - 1; y >= 0; y--) {
				for (x = 0; x < BOARD_SIZE; x++) {
					// and if a spot is empty
					if (runes[y][x].Type == RuneTypes.NULL) {
						// now we know we need a new rune
						needNewRune = true;
						// Random new rune
						runes[0][x].Type = Rune.GetRandomRune();
						runes[0][x].Index = new Point(x, 0);
						runes[0][x].x = x * TILE_SIZE;
						runes[0][x].y = -TILE_SIZE;
						if (!runes[0][x].Tweener.isComplete) {
							Starling.juggler.removeTweens(runes[0][x]);
						}
						runes[0][x].InitTween();
						runes[0][x].updateMoveTime();
						tween = runes[0][x].Tweener;
						tween.onComplete = function():void {
							if (useSound) {
								game.Manager.SFXSoundManager.play("game_sfx_drop" + Helper.randomRange(1, 2));
							}
						};
						tween.moveTo(x * TILE_SIZE, 0);
						Starling.juggler.add(tween);
						// stop creating new runes
						//break;
					}
				}
				// if a new rune was created, stop checking
				//if (needNewRune) {
					//break;
				//}
			}
			if (!runesAreFalling && !needNewRune && isAllRuneTweenEnd()) {
				// assume no more/new lines are on the board
				var moreLinesAvailable:Boolean = false;
				// check all runes
				for (y = BOARD_SIZE - 1; y >= 0; y--)
				{
					for (x = 0; x < BOARD_SIZE; x++)
					{
						// if a line is found
						var tempPosXY:int;
						var rune:Rune = runes[y][x];
						var using_x:int = x;
						var using_y:int = y;
						var checkedRowNum:int = checkRow(using_y, using_x);
						var checkedColumnNum:int = checkColumn(using_y, using_x);
						var temp_new_x_num:int;
						var temp_new_y_num:int;
						var temp_new_x:int = using_x;
						var temp_new_y:int = using_y;
						
						if (checkedRowNum > 2) {
							// While loop to find using_x (where x triplet longest)
							tempPosXY = using_y;
							while (checkMathingFunction(rune, tempPosXY - 1, using_x))
							{
								tempPosXY--;
								temp_new_x_num = checkColumn(tempPosXY, using_x);
								if (temp_new_x_num > checkedColumnNum) {
									checkedColumnNum = temp_new_x_num;
									temp_new_y = tempPosXY;
								}
							}
							tempPosXY = using_y;
							while (checkMathingFunction(rune, tempPosXY + 1, using_x))
							{
								tempPosXY++;
								temp_new_x_num = checkColumn(tempPosXY, using_x);
								if (temp_new_x_num > checkedColumnNum) {
									checkedColumnNum = temp_new_x_num;
									temp_new_y = tempPosXY;
								}
							}
							using_y = temp_new_y;
						} else if (checkedColumnNum > 2) {
							// While loop to find using_y (where y triplet longest)
							tempPosXY = using_x;
							while (checkMathingFunction(rune, tempPosXY - 1, using_y))
							{
								tempPosXY--;
								temp_new_y_num = checkColumn(tempPosXY, using_y);
								if (temp_new_y_num > checkedRowNum) {
									checkedRowNum = temp_new_y_num;
									temp_new_x = tempPosXY;
								}
							}
							tempPosXY = using_x;
							while (checkMathingFunction(rune, tempPosXY + 1, using_y))
							{
								tempPosXY++;
								temp_new_y_num = checkColumn(tempPosXY, using_y);
								if (temp_new_y_num > checkedRowNum) {
									checkedRowNum = temp_new_y_num;
									temp_new_x = tempPosXY;
								}
							}
							using_x = temp_new_x;
						} else {
							continue;
						}
						
						if (rune.Type != RuneTypes.NULL && rune.Type >= RuneTypes.YELLOW && rune.Type <= RuneTypes.SP_RAND 
							&& rune.ReadyToGo && (checkedColumnNum > 2 || checkedRowNum > 2))
						{
							// then we know more lines are available
							moreLinesAvailable = true;
							// creat a new array, set the rune type of the line, and where it is
							var unuse_index:Array = [new Point(using_x, using_y)];
							var runeType:int = rune.Type;
							
							// Number of found triplet for row and column
							if (checkedRowNum > checkedColumnNum) {
								// check t's a vertical line...
								tempPosXY = using_y;
								while (checkMathingFunction(rune, tempPosXY - 1, using_x))
								{
									tempPosXY--;
									unuse_index.push(new Point(using_x, tempPosXY));
								}
								tempPosXY = using_y;
								while (checkMathingFunction(rune, tempPosXY + 1, using_x))
								{
									tempPosXY++;
									unuse_index.push(new Point(using_x, tempPosXY));
								}
							} else if (checkedRowNum < checkedColumnNum) {
								// check t's a horizontal line...
								tempPosXY = using_x;
								while (checkMathingFunction(rune, using_y, tempPosXY - 1))
								{
									tempPosXY--;
									unuse_index.push(new Point(tempPosXY, using_y));
								}
								tempPosXY = using_x;
								while (checkMathingFunction(rune, using_y, tempPosXY + 1))
								{
									tempPosXY++;
									unuse_index.push(new Point(tempPosXY, using_y));
								}
							} else {
								// Got level 5 rune
								tempPosXY = using_y;
								while (checkMathingFunction(rune, tempPosXY - 1, using_x))
								{
									tempPosXY--;
									unuse_index.push(new Point(using_x, tempPosXY));
								}
								tempPosXY = using_y;
								while (checkMathingFunction(rune, tempPosXY + 1, using_x))
								{
									tempPosXY++;
									unuse_index.push(new Point(using_x, tempPosXY));
								}
								tempPosXY = using_x;
								while (checkMathingFunction(rune, using_y, tempPosXY - 1))
								{
									tempPosXY--;
									unuse_index.push(new Point(tempPosXY, using_y));
								}
								tempPosXY = using_x;
								while (checkMathingFunction(rune, using_y, tempPosXY + 1))
								{
									tempPosXY++;
									unuse_index.push(new Point(tempPosXY, using_y));
								}
							}
							if (isAllRunesReadyFromIndexList(unuse_index))
							{
								var lastMoveRune:Rune = getLastestRuneFromIndexList(unuse_index);
								var maxLevelRune:Rune = getMaxRuneFromIndexList(unuse_index);
								// Summon a soldier, when triplets more than 3
								if (unuse_index.length >= 3) {
									switch (maxLevelRune.Level) {
										//case RuneLevels.FIFTH:
										//	game.SpawnCharacter(this, runeType, RuneLevels.FIFTH);
										//	break;
										case RuneLevels.FORTH:
											if (game.numCharacters(Player) < LIMIT_CHARACTER || !GlobalVariables.use_cannon) {
												if (game.IsTutorial && Player.Type == PlayerTypes.NORMAL && game.TutorialState == 6) {
													game.TutorialState = 7;
												}
												game.SpawnCharacter(this, runeType, RuneLevels.FORTH);
											} else {
												/*
												if (collectedCannonTime < 3) {
													collectedCannon += 4;
													collectedCannonTime++;
												} else {
													game.CannonShoot(Player, collectedCannon);
													collectedCannon = 0;
													collectedCannonTime = 0;
												}
												*/
												game.CannonShoot(Player, 12);
											}
											break;
										case RuneLevels.NORMAL:
											if (game.numCharacters(Player) < LIMIT_CHARACTER || !GlobalVariables.use_cannon) {
												if (game.IsTutorial && Player.Type == PlayerTypes.NORMAL && game.TutorialState == 4) {
													game.TutorialState = 5;
												}
												game.SpawnCharacter(this, runeType);
											} else {
												/*
												if (collectedCannonTime < 3) {
													collectedCannon += 3;
													collectedCannonTime++;
												} else {
													game.CannonShoot(Player, collectedCannon);
													collectedCannon = 0;
													collectedCannonTime = 0;
												}
												*/
												game.CannonShoot(Player, 9);
											}
											break;
									}
									if (useSound)
										game.Manager.SFXSoundManager.play("game_sfx_remove");
								}
								// Removing an un use nodes
								// for all runes in the line...
								for (var i:int = 0; i < unuse_index.length; i++)
								{
									var pos:Point = unuse_index[i];
									if (unuse_index.length > 3 && runes[pos.y][pos.x] == lastMoveRune) {
										(runes[pos.y][pos.x] as Rune).Level = unuse_index.length - 3;
									} else {
										if (!runes[pos.y][pos.x].Tweener.isComplete)
										{
											Starling.juggler.removeTweens(runes[pos.y][pos.x]);
										}
										runes[pos.y][pos.x].Dying();
										Starling.juggler.add(runes[pos.y][pos.x].Tweener);
										combo++;
									}
								}
							}
							// if a row was made, stop the loop
							//break;
						}
					}
					// if a line was made, stop making more lines
					//if (moreLinesAvailable) {
						//break;
					//}
				}
				// if no more lines were available...
				if (!moreLinesAvailable)
				{
					// allow new moves to be made
					isFillAllRune = true;
					combo = 0;
				}
			}
		}
		
		// Methods
		// Helper to get lastest rune
		public function getLastestRune():Rune {
			var rune:Rune = null;
			var lastMove:Number = Number.MIN_VALUE;
			var currentMove:Number = Number.MIN_VALUE;
			for (var y:int = 0; y < BOARD_SIZE; y++) {
				for (var x:int = 0; x < BOARD_SIZE; x++) {
					currentMove = runes[y][x].getMoveTime();
					if (currentMove > lastMove) {
						lastMove = currentMove;
						rune = runes[y][x];
					}
				}
			}
			return rune;
		}
		public function getLastestRuneFromIndexList(indexes:Array):Rune {
			var rune:Rune = null;
			var lastMove:Number = Number.MIN_VALUE;
			var currentMove:Number = Number.MIN_VALUE;
			var currentIndex:Point;
			for (var i:int = 0; i < indexes.length; i++) {
				currentIndex = indexes[i];
				currentMove = runes[currentIndex.y][currentIndex.x].getMoveTime()
				if (currentMove > lastMove) {
					lastMove = currentMove;
					rune = runes[currentIndex.y][currentIndex.x];
				}
			}
			return rune;
		}
		// Helper to max level rune
		public function getMaxRune():Rune {
			var rune:Rune = null;
			var level:int = int.MIN_VALUE;
			var currentLevel:int = int.MIN_VALUE;
			for (var y:int = 0; y < BOARD_SIZE; y++) {
				for (var x:int = 0; x < BOARD_SIZE; x++) {
					currentLevel = runes[y][x].Level;
					if (currentLevel > level) {
						level = currentLevel;
						rune = runes[y][x];
					}
				}
			}
			return rune;
		}
		public function getMaxRuneFromIndexList(indexes:Array):Rune {
			var rune:Rune = null;
			var level:int = int.MIN_VALUE;
			var currentLevel:int = int.MIN_VALUE;
			var currentIndex:Point;
			for (var i:int = 0; i < indexes.length; i++) {
				currentIndex = indexes[i];
				currentLevel = runes[currentIndex.y][currentIndex.x].Level;
				if (currentLevel > level) {
					level = currentLevel;
					rune = runes[currentIndex.y][currentIndex.x];
				}
			}
			return rune;
		}
		// Helper to check every runes on triplet is ready to go
		public function isAllRunesReadyFromIndexList(indexes:Array):Boolean {
			var currentIndex:Point;
			for (var i:int = 0; i < indexes.length; i++) {
				currentIndex = indexes[i];
				if (!runes[currentIndex.y][currentIndex.x].ReadyToGo)
					return false;
			}
			return true;
		}
		
		public function ReInit():void {
			this.activeState = BoardStates.FALLING_RUNES;
			this.activeIndex = UNACTIVE_INDEX;
			this.swapInfo.destroy();
			this.isFillAllRune = false;
			
			for (var y:int = 0; y < BOARD_SIZE; y++) {
				for (var x:int = 0; x < BOARD_SIZE; x++) {
					(runes[y][x] as Rune).Dying();
					(runes[y][x] as Rune).stop();
					(runes[y][x] as Rune).destroy();
				}
				(runes[y] as Array).splice(0);
			}
			runes.splice(0);
			removeChildren(0, -1, true);
			
			Init();
			this.aiSwapTimestamp = getTimer();
		}
		
		// Method for initial a game board
		public function Init():void {
			//Starling.juggler.purge();
			runes = new Array();		// New array for rows
			// Test assets
			//runes[0] = new Array(new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.GREEN));
			//runes[1] = new Array(new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.YELLOW), new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.YELLOW), new Rune(this, RuneTypes.BLUE));
			//runes[2] = new Array(new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.YELLOW), new Rune(this, RuneTypes.RED), new Rune(this, RuneTypes.GREEN));
			//runes[3] = new Array(new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.RED), new Rune(this, RuneTypes.GREEN));
			//runes[4] = new Array(new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.RED));
			//runes[5] = new Array(new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.BLUE), new Rune(this, RuneTypes.RED), new Rune(this, RuneTypes.GREEN), new Rune(this, RuneTypes.GREEN));
			
			for (var y:int = 0; y < BOARD_SIZE; y++) {
				runes[y] = new Array();	// New array for columns
				for (var x:int = 0; x < BOARD_SIZE; x++) {
					// Checking for triplets, if found replace with new entity
					do {
						runes[y][x] = new Rune(this, Rune.GetRandomRune());
					} while (checkColumn(y, x) > 2 || checkRow(y, x) > 2);
					var rune:Rune = runes[y][x];
					rune.Index = new Point(x, y); // x, y
					rune.x = x * TILE_SIZE;
					//rune.y = y * TILE_SIZE;
					rune.y = -((BOARD_SIZE - y) * TILE_SIZE);
					rune.InitTween(0.25);
					rune.updateMoveTime();
					var tween:Tween = rune.Tweener;
					tween.onComplete = function():void {
						if (useSound) {
							game.Manager.SFXSoundManager.play("game_sfx_drop" + Helper.randomRange(1, 2));
						}
					};
					tween.moveTo(x * TILE_SIZE, y * TILE_SIZE);
					Starling.juggler.add(tween);
					addChild(rune);
				}
			}
			
		}
		
		// Method for swap rune
		public function swapTile(row1:int, col1:int, row2:int, col2:int):void {
			var temp:Rune = runes[row1][col1];
			runes[row1][col1] = runes[row2][col2];
			runes[row2][col2] = temp;
		}
		
		// Method for finding number of same type rune by cols
		public function checkColumn(row:int, col:int):int {
			var rune:Rune = runes[row][col];
			var sametype_number:int = 1;
			var checking_col:int = col;
			while (checkMathingFunction(rune, row, checking_col - 1)) {
				checking_col--;
				sametype_number++;
			}
			checking_col = col;
			while (checkMathingFunction(rune, row, checking_col + 1)) {
				checking_col++;
				sametype_number++;
			}
			return sametype_number;
		}
		public function checkColumnWithHeadTail(row:int, col:int):Array {
			var rune:Rune = runes[row][col];
			var sametype_number:int = 1;
			var checking_col:int = col;
			var head:int;
			var tail:int;
			while (checkMathingFunction(rune, row, checking_col - 1)) {
				checking_col--;
				sametype_number++;
			}
			head = checking_col;
			checking_col = col;
			while (checkMathingFunction(rune, row, checking_col + 1)) {
				checking_col++;
				sametype_number++;
			}
			tail = checking_col;
			return [sametype_number, head, tail];
		}
		
		// Method for finding number of same type rune by rows
		public function checkRow(row:int, col:int):int {
			var rune:Rune = runes[row][col];
			var sametype_number:int = 1;
			var checking_row:int = row;
			while (checkMathingFunction(rune, checking_row - 1, col)) {
				checking_row--;
				sametype_number++;
			}
			checking_row = row;
			while (checkMathingFunction(rune, checking_row + 1, col)) {
				checking_row++;
				sametype_number++;
			}
			return sametype_number;
		}
		public function checkRowWithHeadTail(row:int, col:int):Array {
			var rune:Rune = runes[row][col];
			var sametype_number:int = 1;
			var checking_row:int = row;
			var head:int;
			var tail:int;
			while (checkMathingFunction(rune, checking_row - 1, col)) {
				checking_row--;
				sametype_number++;
			}
			head = checking_row;
			checking_row = row;
			while (checkMathingFunction(rune, checking_row + 1, col)) {
				checking_row++;
				sametype_number++;
			}
			tail = checking_row;
			return [sametype_number, head, tail];
		}
		
		// Method for checking is two rune have same type?
		public function checkMathingFunction(rune:Rune, row:int, col:int):Boolean {
			if (runes[row] == null) {
				return false;
			}
			if (runes[row][col] == null) {
				return false;
			}
			return rune.Type == runes[row][col].Type;
		}
		
		public function swapping(fromPoint:Point, toPoint:Point):void {
			activeState = BoardStates.SWAPPING_RUNES;
			swapInfo.Init(runes[fromPoint.y][fromPoint.x], runes[toPoint.y][toPoint.x]);
			swapInfo.start();
		}
		
		// Properties
		public function get Activable():Boolean {
			return activeState == BoardStates.INTERACTIVE;
		}
		public function get ActiveIndex():Point {
			return activeIndex;
		}
		public function set ActiveIndex(value:Point):void {
			activeIndex = value;
			if (value.equals(UNACTIVE_INDEX)) {
				selectedEffect.visible = false;
			} else {
				selectedEffect.visible = true;
				selectedEffect.x = value.x * TILE_SIZE;
				selectedEffect.y = value.y * TILE_SIZE;
				addChild(selectedEffect);
			}
		}
		public function get Player():PlayerEntity {
			return pEntity;
		}
		public function get ParentGame():Game {
			return game;
		}
		public function get IsPause():Boolean {
			return isPause;
		}
		public function set IsPause(value:Boolean):void {
			isPause = value;
			/*
			if (isPause) {
				this.removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
				this.removeEventListener(EnterFrameEvent.ENTER_FRAME, checkTriplets);
				this.removeEventListener(EnterFrameEvent.ENTER_FRAME, findTriplets);
			} else {
				this.addEventListener(EnterFrameEvent.ENTER_FRAME, update);
				this.addEventListener(EnterFrameEvent.ENTER_FRAME, checkTriplets);
				this.addEventListener(EnterFrameEvent.ENTER_FRAME, findTriplets);
			}
			*/
		}
	}

}