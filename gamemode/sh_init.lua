-- sh_init
local config = {};

local function makeConfig(name,default)
	if SERVER then
		CreateConVar(name,default,{ FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_DONTRECORD });
	end
	
	return {name=name,default=default};
end

config.joinTime = makeConfig("dr_config_jointime","20");
config.roundsPerMap = makeConfig("dr_config_rounds_per_map","10");
config.setupTime = makeConfig("jb_config_setuptime","30")
config.baddiePercentage = makeConfig("jb_config_baddiepercentage","20")

DR={}
DR._IndexCallback = {}
setmetatable(DR,{
	__index=function(self,key)
		return DR._IndexCallback[key] and DR._IndexCallback[key].get() or (GM or GAMEMODE)[key] or rawget(self,key)
	end,
	__newindex=function(self,key,value)
		if DR._IndexCallback[key] and DR._IndexCallback[key].set then
			DR._IndexCallback[key].set(value);
			return nil;
		end

		rawset(GM or GAMEMODE,key,value)
		return nil
	end
})
DR.Config = {};
setmetatable(DR.Config,{
	__index = function(tbl,key)
		if config[key] then
			if SERVER then
				local val = GetConVarString(config[key].name);
				return val and val ~= "" and val or config[key] and config[key].default or "0";
			elseif CLIENT then
				return config[key].v or config[key].default;
			end
		end
		return nil;
	end
})


function DR:DebugPrint(...)
	ES.DebugPrint("[DR] ",...)
end

function DR:GetGameDescription()
	return "Deathrun";
end

COLOR_WHITE = COLOR_WHITE or Color(255,255,255,255);

DR.Name 		= "Deathrun"
DR.Author 		= "Excl"
DR.Email 		= "facepunch: _NewBee"
DR.Website 		= "www.exclstudios.com"
DR.TeamBased = true;

--some DR stuff

MsgC(COLOR_WHITE,"\n\n# Loading Deathrun by Excl...\n|\n");
function exclEasyInclude(folder,filey)
	local a = string.Left(filey,3);

	local path = filey;
	if folder then
		path = (folder.."/"..filey);
	end

	MsgC(COLOR_WHITE,"|-> ./"..path.."\n");

	if a == "cl_" then
		if SERVER then
			AddCSLuaFile (path);
		elseif CLIENT then
			include (path);
		end
	elseif a == "sv_" then
		if SERVER then
			include (path);
		end
	else
		if SERVER then
			AddCSLuaFile (path);
			include (path);
		elseif CLIENT then
			include (path);
		end
	end
end

exclEasyInclude("player_class","player_baddie.lua");
exclEasyInclude("player_class","player_goodie.lua");
exclEasyInclude("core","sv_main.lua")
exclEasyInclude("core","sv_player.lua");
exclEasyInclude("core","sv_player_meta.lua")
exclEasyInclude("core","sh_weapons.lua");
exclEasyInclude("core","sh_teams.lua");
exclEasyInclude("core","sh_state.lua");
exclEasyInclude("core","cl_hud.lua");
exclEasyInclude("core","cl_hud_target.lua")
exclEasyInclude("core","cl_scoreboard.lua");
exclEasyInclude("core","cl_help.lua");
exclEasyInclude("core","sh_player.lua")
exclEasyInclude("core","sh_player_meta.lua")
exclEasyInclude("core","sh_buttonclaim.lua");
exclEasyInclude("core","cl_player.lua");
exclEasyInclude("core","cl_player_meta.lua");
MsgC(COLOR_WHITE,"|\n# Done!\n\n");
