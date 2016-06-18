package scene 
{
	import gameplay.Game;
	import gamelobby.Arena;
	import gamelobby.Lobby;
	import network.PacketHeader;
	import player.PlayerInformation;
	import service.GeneralService;
	public class ClientMessageProcess 
	{
		public static function Process(sceneMgr:SceneManager, obj:Object):void {
			var key:int = obj.key;
			var values:Array = obj.values;
			var lobby:Lobby;
			var arena:Arena;
			var game:Game;
			try {
				switch (key) {
					case PacketHeader.login_success:
						trace("Client login successfully now game's instance is online");
						sceneMgr.IsOnline = true;
						break;
					case PacketHeader.login_fail:
						trace("Client login failure now game's instance is offline");
						sceneMgr.IsOnline = false;
						break;
					case PacketHeader.online_status_return:
						// Finding for player then set online status
						var playerInfo:PlayerInformation;
						if (sceneMgr.currentScene is Lobby) {
							playerInfo = (sceneMgr.currentScene as Lobby).findFriend(values[0]);
							if (playerInfo != null) {
								playerInfo.OnlineStatus = parseInt(values[1]);
							}
						}
						if (sceneMgr.currentScene is Arena) {
							playerInfo = (sceneMgr.currentScene as Arena).findTarget(values[0]);
							if (playerInfo != null) {
								playerInfo.OnlineStatus = parseInt(values[1]);
							}
						}
						break;
					case PacketHeader.send_request_success:
						// Wait for another client to accept or decline, or wait for request expire
						break;
					case PacketHeader.send_request_fail:
						// Dispose all targets
						if (sceneMgr.currentScene is Lobby) {
							lobby = sceneMgr.currentScene as Lobby;
							lobby.EnvFightStart.enableButtons();
							lobby.EnvFightStart.disposeTarget();
						}
						if (sceneMgr.currentScene is Arena) {
							arena = sceneMgr.currentScene as Arena;
							arena.EnvFightStart.enableButtons();
							arena.EnvFightStart.disposeTarget();
						}
						break;
					case PacketHeader.request_receive:
						// Received request from server
						var funcInRequestReceive:Function;
						var servInRequestReceive:GeneralService;
						if (sceneMgr.currentScene is Lobby) {
							lobby = sceneMgr.currentScene as Lobby;
							// getting player information then create new player information then set it as receiver
							funcInRequestReceive = function(info:PlayerInformation):void {
								lobby.EnvFightStart.enableButtons();
								lobby.EnvFightStart.receiveRequest(info);
							}
							servInRequestReceive = new GeneralService(sceneMgr);
							servInRequestReceive.initPublicProfileLoader(parseInt(values[0]), funcInRequestReceive);
							servInRequestReceive.start();
						}
						if (sceneMgr.currentScene is Arena) {
							arena = sceneMgr.currentScene as Arena;
							// getting player information then create new player information then set it as receiver
							funcInRequestReceive = function(info:PlayerInformation):void {
								arena.EnvFightStart.enableButtons();
								arena.EnvFightStart.receiveRequest(info);
							}
							servInRequestReceive = new GeneralService(sceneMgr);
							servInRequestReceive.initPublicProfileLoader(parseInt(values[0]), funcInRequestReceive);
							servInRequestReceive.start();
						}
						break;
					case PacketHeader.request_accept_success:
						// Not do anything
						break;
					case PacketHeader.request_accept_fail:
						// Dispose all targets
						if (sceneMgr.currentScene is Lobby) {
							lobby = sceneMgr.currentScene as Lobby;
							lobby.EnvFightStart.enableButtons();
							lobby.EnvFightStart.disposeTarget();
						}
						if (sceneMgr.currentScene is Arena) {
							arena = sceneMgr.currentScene as Arena;
							arena.EnvFightStart.enableButtons();
							arena.EnvFightStart.disposeTarget();
						}
						break;
					case PacketHeader.request_decline_success:
						// Not do anything
						break;
					case PacketHeader.request_decline_fail:
						// Dispose all targets
						if (sceneMgr.currentScene is Lobby) {
							lobby = sceneMgr.currentScene as Lobby;
							lobby.EnvFightStart.enableButtons();
							lobby.EnvFightStart.disposeTarget();
						}
						if (sceneMgr.currentScene is Arena) {
							arena = sceneMgr.currentScene as Arena;
							arena.EnvFightStart.enableButtons();
							arena.EnvFightStart.disposeTarget();
						}
						break;
					case PacketHeader.request_expire:
						// Able player to request again
						if (sceneMgr.currentScene is Lobby) {
							lobby = sceneMgr.currentScene as Lobby;
							lobby.EnvFightStart.enableButtons();
						}
						if (sceneMgr.currentScene is Arena) {
							arena = sceneMgr.currentScene as Arena;
							arena.EnvFightStart.enableButtons();
						}
						break;
					case PacketHeader.game_start_as_host:
						// Init game as host, call after fight request accepted
						if (sceneMgr.currentScene is Lobby) {
							lobby = sceneMgr.currentScene as Lobby;
							lobby.EnvFightStart.startFightAsHost();
						}
						if (sceneMgr.currentScene is Arena) {
							arena = sceneMgr.currentScene as Arena;
							arena.EnvFightStart.startFightAsHost();
						}
						break;
					case PacketHeader.game_start_as_client:
						// Init game as client, call after fight request accepted
						if (sceneMgr.currentScene is Lobby) {
							lobby = sceneMgr.currentScene as Lobby;
							lobby.EnvFightStart.startFightAsClient();
						}
						if (sceneMgr.currentScene is Arena) {
							arena = sceneMgr.currentScene as Arena;
							arena.EnvFightStart.startFightAsClient();
						}
						break;
					case PacketHeader.game_load_finish:
						// Tell to host that ready to countdown
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.hostAllLoaded();
						}
						break;
					case PacketHeader.game_host_count_down:
						// Countdown from host in Game
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.clientCountDown(parseInt(values[0]));
						}
						break;
					case PacketHeader.game_host_start:
						// Game start from host in Game
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.clientGameStart();
						}
						break;
					case PacketHeader.game_set_rune:
						// Set rune information
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.allChooseBoardCharacter(parseInt(values[0]), parseInt(values[1]), parseInt(values[2]));
						}
						break;
					case PacketHeader.game_spawn_character:
						// Spawning character from both host and client 
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.hostSpawnCharacter(parseInt(values[0]), parseInt(values[1]), parseInt(values[2]));
						}
						break;
					case PacketHeader.game_append_character:
						// Append character from host in game
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.clientAppendCharacter(parseInt(values[1]), parseInt(values[0]), parseInt(values[2]), parseInt(values[3]));
						}
						break;
					case PacketHeader.game_update_entity:
						// Update character from host in game
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.clientUpdateEntity(parseInt(values[0]), parseInt(values[2]), parseFloat(values[3]), parseFloat(values[4]), parseInt(values[1]));
						}
						break;
					case PacketHeader.game_append_character_damage:
						// Append character damage from host in game
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.clientAppendEntityDamage(parseInt(values[0]), values[1], values[2], parseInt(values[3]));
						}
						break;
					case PacketHeader.game_character_attack_to:
						// Do character attacking to any character entity from host in game
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.clientCharacterAttackingTo(parseInt(values[0]), parseInt(values[1]));
						}
						break;
					case PacketHeader.game_use_cannon:
						// Using cannon from both host and client
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.hostCannon(parseInt(values[0]), parseInt(values[1]));
						}
						break;
					case PacketHeader.game_cannon_to:
						// Cannon called from host in game
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.clientCannonTo(parseInt(values[1]), parseInt(values[0]), parseInt(values[2]), parseInt(values[3]));
						}
						break;
					case PacketHeader.game_use_meteor:
						// Using meteor from both host and client
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.hostMeteor(parseInt(values[0]));
						}
						break;
					case PacketHeader.game_meteor_to:
						// Meteor called from host in game
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.clientMeteorTo(parseInt(values[0]));
						}
						break;
					case PacketHeader.game_use_heal:
						// Using heal from both host and client
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.hostHeal(parseInt(values[0]));
						}
						break;
					case PacketHeader.game_heal_to:
						// Heal called from host in game
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.clientHealTo(parseInt(values[0]));
						}
						break;
					case PacketHeader.game_use_stun:
						// Using stun from both host and client
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.hostStun(parseInt(values[0]));
						}
						break;
					case PacketHeader.game_stun_to:
						// Stun called from host in game
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.clientStunTo(parseInt(values[0]));
						}
						break;
					case PacketHeader.game_result:
						if (sceneMgr.currentScene is Game) {
							game = sceneMgr.currentScene as Game;
							game.allFightResult(parseInt(values[0]), parseInt(values[1]), parseInt(values[2]));
						}
						break;
				}
			} catch (ex:Error) {
				trace(ex);
			}
		}
	}

}