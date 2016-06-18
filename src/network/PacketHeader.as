package network 
{
	public class PacketHeader 
	{
		public static const login:int = 0;
		public static const login_success:int = 1;
		public static const login_fail:int = 2;
		public static const online_status:int = 3;
		public static const online_status_return:int = 4;
		public static const send_request:int = 5;
		public static const send_request_success:int = 6;
		public static const send_request_fail:int = 7;
		public static const request_receive:int = 8;
		public static const request_expire:int = 9;
		public static const request_accept:int = 10;
		public static const request_accept_success:int = 11;
		public static const request_accept_fail:int = 12;
		public static const request_decline:int = 13;
		public static const request_decline_success:int = 14;
		public static const request_decline_fail:int = 15;
		public static const game_start_as_host:int = 16;
		public static const game_start_as_client:int = 17;
		public static const game_load_finish:int = 18;
		public static const game_host_count_down:int = 19;
		public static const game_host_start:int = 20;
		public static const game_set_rune:int = 21;
		public static const game_spawn_character:int = 22;
		public static const game_append_character:int = 23;
		public static const game_update_entity:int = 24;
		public static const game_append_character_damage:int = 25;
		public static const game_character_attack_to:int = 26;
		public static const game_use_cannon:int = 27;
		public static const game_cannon_to:int = 28;
		public static const game_use_meteor:int = 29;
		public static const game_meteor_to:int = 30;
		public static const game_use_heal:int = 31;
		public static const game_heal_to:int = 32;
		public static const game_use_stun:int = 33;
		public static const game_stun_to:int = 34;
		public static const game_result:int = 35;
		public static const game_end:int = 36;
		public static const ping:int = 37;
	}
}