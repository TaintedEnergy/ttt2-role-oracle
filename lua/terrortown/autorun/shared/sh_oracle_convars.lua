-- replicated convars have to be created on both client and server
CreateConVar("ttt_oracle_min_message_time", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
CreateConVar("ttt_oracle_max_message_time", 60, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
CreateConVar("ttt_oracle_display_message_time", 7, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_dynamic_nova_convars", function(tbl)
	tbl[ROLE_ORACLE] = tbl[ROLE_ORACLE] or {}

	table.insert(tbl[ROLE_ORACLE], {
		cvar = "ttt_oracle_min_message_time",
		slider = true,
		min = 0,
		max = 6000,
		decimal = 0,
		desc = "ttt_oracle_min_message_time (def. 30)"
	})
	table.insert(tbl[ROLE_ORACLE], {
		cvar = "ttt_oracle_max_message_time",
		slider = true,
		min = 0,
		max = 6000,
		decimal = 0,
		desc = "ttt_oracle_max_message_time (def. 60)"
	})
	table.insert(tbl[ROLE_ORACLE], {
		cvar = "ttt_oracle_display_message_time",
		slider = true,
		min = 0,
		max = 6000,
		decimal = 0,
		desc = "ttt_oracle_display_message_time (def. 7)"
	})
end)
