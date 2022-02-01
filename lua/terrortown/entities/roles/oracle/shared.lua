if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_oracle")
	util.AddNetworkString("ttt2_oracle_message")
end


function ROLE:PreInitialize()
	self.color                      = Color(58, 122, 96, 255)

	self.abbr                       = "oracle"
	self.surviveBonus               = 0
	self.score.killsMultiplier      = 2
	self.score.teamKillsMultiplier  = -8
	self.unknownTeam                = true

	self.defaultTeam                = TEAM_INNOCENT

	self.conVarData = {
		pct          = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum      = 1, -- maximum amount of roles in a round
		minPlayers   = 7, -- minimum amount of players until this role is able to get selected
		credits      = 0, -- the starting credits of a specific role
		shopFallback = SHOP_DISABLED,
		togglable    = true, -- option to toggle a role for a client if possible (F1 menu)
		random       = 33
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_INNOCENT)
end

if SERVER then
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		OracleMessage(ply)
	end

	function OracleMessage(ply)
		local messageTime = math.random( GetConVar("ttt_oracle_min_message_time"):GetInt(), GetConVar("ttt_oracle_max_message_time"):GetInt() )
		timer.Create("oracle-message" .. ply:SteamID64(), messageTime, 1, function()
			if not IsValid(ply) then return end
			if SpecDM and (ply.IsGhost and ply:IsGhost()) then return end

			local target1 = ""
			local target2 = ""
			local shown_team = ""

			local tmp = {}

			for _, p in ipairs(player.GetAll()) do
				if not p:IsActive() or not p:IsTerror() then continue end

				if p:GetBaseRole() ~= ROLE_DETECTIVE and p ~= ply then
					tmp[#tmp + 1] = p
				end
			end
			if #tmp >= 2 then
				local target_team_to_show = math.random(0,1) -- randomly pick first or second target to show their team
				local index = math.random(1, #tmp) -- pick a random target from list of players

				if target_team_to_show == 0 then -- take first target's team
					shown_team = GetTeamDisplay(tmp[index]:GetTeam())
				end
				target1 = tmp[index]:GetName() -- get first target's name
				table.remove(tmp, index) -- remove first target from list

				index = math.random(1, #tmp) -- pick a random target from list of players (excluding first target)
				if target_team_to_show == 1 then -- take second target's team
					shown_team = GetTeamDisplay(tmp[index]:GetTeam())
				end
				target2 = tmp[index]:GetName() -- get second target's name

				net.Start("ttt2_oracle_message")
				net.WriteString(target1)
				net.WriteString(target2)
				net.WriteString(shown_team)
				net.Send(ply)
			end

			OracleMessage(ply)
		end)
	end

	function GetTeamDisplay(playerTeam) 
		if playerTeam == TEAM_INNOCENT then
			return "Innocents"
		elseif playerTeam == TEAM_TRAITOR then
			return "Traitors"
		end
		return "Neutral"
	end

	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		timer.Remove("oracle-message" .. ply:SteamID64())
	end
end

if CLIENT then
    net.Receive("ttt2_oracle_message", function()
        local msg_target1 = net.ReadString()
		local msg_target2 = net.ReadString()
		local msg_team = net.ReadString()

		local team_colour = Color(255,0,255,255)
		if msg_team == "Innocents" then
			team_colour = Color(0,255,0,255)
		elseif msg_team == "Traitors" then
			team_colour = Color(255,0,0,255)
		end

        EPOP:AddMessage({text = msg_team, color = team_colour}, {
			text = "One or more of " .. msg_target1 .. " & " .. msg_target2 .. " are on this team...",
            color = Color(255, 255, 255, 255)}, 
			GetConVar("ttt_oracle_display_message_time"):GetInt())

		if GetConVar("ttt_oracle_message_chat_window"):GetInt() >= 1 then
			chat.AddText(Color(255, 255, 255, 255), "Oracle: One or more of " .. msg_target1 .. " & " .. msg_target2 .. " are on the team: ", team_colour, msg_team)
		end
    end)
end