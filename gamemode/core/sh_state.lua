-- ####################################################################################
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     CASUAL BANANAS CONFIDENTIAL                                                ##
-- ##                                                                                ##
-- ##     __________________________                                                 ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Copyright 2014 (c) Casual Bananas                                          ##
-- ##     All Rights Reserved.                                                       ##
-- ##                                                                                ##
-- ##     NOTICE:  All information contained herein is, and remains                  ##
-- ##     the property of Casual Bananas. The intellectual and technical             ##
-- ##     concepts contained herein are proprietary to Casual Bananas and may be     ##
-- ##     covered by U.S. and Foreign Patents, patents in process, and are           ##
-- ##     protected by trade secret or copyright law.                                ##
-- ##     Dissemination of this information or reproduction of this material         ##
-- ##     is strictly forbidden unless prior written permission is obtained          ##
-- ##     from Casual Bananas                                                        ##
-- ##                                                                                ##
-- ##     _________________________                                                  ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Casual Bananas is registered with the "Kamer van Koophandel" (Dutch        ##
-- ##     chamber of commerce) in The Netherlands.                                   ##
-- ##                                                                                ##
-- ##     Company (KVK) number     : 59449837                                        ##
-- ##     Email                    : info@casualbananas.com                          ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ####################################################################################



--------------------------------------------------------------------------------------
--
--
--   REGARDING CUSTOM MAPVOTE SYSTEMS:
--
--   _________________________
--
--
--   If you want to code your own mapvote, hook the DeathrunStartMapvote hook,
--   start your own mapvote here. Remember to return true in order to stop the
--   round system for a while, while you run your mapvote.
--
--   _________________________
--
--
--   You might want to use the following functions as well if you're writing a
--   custom mapvote:
--
--   DR:Mapvote_ExtendCurrentMap()
--   DR:Mapvote_StartMapVote()
--
--
--------------------------------------------------------------------------------------


/*

Compatability hooks - implement these in your admin mods

*/

function DR:DeathrunStartMapvote(rounds_passed,extentions_passed) // hook.Add("DeathrunStartMapvote",...) to implement your own mapvote. NOTE: Remember to return true!
	return false // return true in your own mapvote function, else there won't be a pause between rounds!
end

/*

State chaining

*/
local chainState;
if SERVER then
	local stateTime = 0;
	local stateCallback;
	hook.Add("Think","DR.Think.StateLogic",function()
		if stateTime > 0 and stateTime < CurTime() then
			ES.DebugPrint("State chain ended")

			stateTime = 0
			stateCallback()
		end
	end)
	chainState=function(state,time,callback)
		ES.DebugPrint("State chained: "..tostring(state).." ["..tostring(time).." s]["..tostring(callback).."]")

		DR.State = state;

		stateTime=CurTime()+time;
		stateCallback=callback;
	end
end

/*

Utility functions

*/
local ententionsDone = 0;
function DR:Mapvote_ExtendCurrentMap() 		// You can call this from your own admin mod/mapvote if you want to extend the current map.
	DR.RoundsPassed = 0;
	ententionsDone = ententionsDone+1;
	chainState(STATE_ENDED,5,function()
		DR:NewRound();
	end);
end
function DR:Mapvote_StartMapVote()			// You can call this from your admin mod/mapvote to initiate a mapvote.
	if hook.Call("DeathrunStartMapvote",DR,DR.RoundsPassed,ententionsDone) then
		DR.State = STATE_MAPVOTE;
		return true;
	end
	return false;
end

/*

Enums

*/
STATE_IDLE = 1; -- when the map loads, we wait for everyone to join
STATE_SETUP = 2; -- first few seconds of the round, when everyone can still spawn and damage is disabled
STATE_PLAYING = 3; -- normal playing
STATE_LASTREQUEST = 4; -- last request taking place, special rules apply
STATE_ENDED = 5; -- round ended, waiting for next round to start
STATE_MAPVOTE = 6; -- voting for a map, will result in either a new map loading or restarting the current without reloading

/*

Network strings

*/
if SERVER then
	util.AddNetworkString("DR.LR.GetReady");
	util.AddNetworkString("DR.SendRoundUpdate");
end

/*

Round System

*/
DR.ThisRound = {};
local wantStartup = false;
function DR:NewRound(rounds_passed)
	rounds_passed = rounds_passed or DR.RoundsPassed;

	DR.ThisRound = {};

	if SERVER then
		DR:ResetClaims()
		
		game.CleanUpMap();

		rounds_passed = rounds_passed + 1;
		DR.RoundsPassed = rounds_passed;
		DR.RoundStartTime = CurTime();

		ES.DebugPrint("Setup finished, round started.")
		chainState(STATE_SETUP,DR.Config.setupTime,function()
			chainState(STATE_PLAYING,(DR.maxRoundTime) - tonumber(DR.Config.setupTime),function()
				DR:EndRound();
			end);
		end)

		for k,v in ipairs(team.GetPlayers(TEAM_BADDIE))do
			v:SetTeam(TEAM_GOODIE)
		end
		
		local amtBaddies = math.ceil(DR.Config.baddiePercentage/100 * #team.GetPlayers(TEAM_GOODIE))
		while (#team.GetPlayers(TEAM_BADDIE) < amtBaddies) do
			local goodie=team.GetPlayers(TEAM_GOODIE)[math.random(1,#team.GetPlayers(TEAM_GOODIE))]

			goodie:SetTeam(TEAM_BADDIE)
			goodie:ESSendNotification("generic","You are a BADDIE, kill all GOODIES!")
		end

		for k,v in ipairs(player.GetAll())do
			v:Spawn();
		end

		net.Start("DR.SendRoundUpdate"); net.WriteInt(STATE_SETUP,8); net.WriteInt(rounds_passed,32); net.Broadcast();
	elseif CLIENT and IsValid(LocalPlayer()) then
		notification.AddLegacy("Round "..rounds_passed,NOTIFY_GENERIC);

		LocalPlayer():ConCommand("-voicerecord");
	end

	hook.Call("DeathrunRoundStart",DR,DR.RoundsPassed);
end
local _winner=0;
function DR:EndRound(winner)
	if not winner then
		winner = 0
	end

	DR:DebugPrint("Rounded ended with winner "..winner)

	_winner=winner

	if SERVER then
		if DR.RoundsPassed >= tonumber(DR.Config.roundsPerMap) and DR:Mapvote_StartMapVote() then
			return; 
			// Hal the round system; we're running a custom mapvote!
		end

		for k,v in ipairs(player.GetAll())do
			v:Freeze(true)
		end

		chainState(STATE_ENDED,5,function()
			DR:NewRound();
		end);

		net.Start("DR.SendRoundUpdate"); net.WriteInt(STATE_ENDED,8); net.WriteInt(winner or 0, 8); net.Broadcast();
	elseif CLIENT then
		notification.AddLegacy(winner == TEAM_BADDIE and "Baddies win" or winner == TEAM_GOODIE and "Goodies win" or "Draw",NOTIFY_GENERIC);
	end

	hook.Call("DeathrunRoundEnd",DR,DR.RoundsPassed);
end

if CLIENT then
	surface.CreateFont("RoundEndFont",{
		font="Roboto",
		weight=400,
		size=100
})

	local fx=0;
	local tab={}
	tab[ "$pp_colour_mulr" ] = 0
	tab[ "$pp_colour_mulg" ] = 0
	tab[ "$pp_colour_mulb" ] = 0
	tab[ "$pp_colour_addr" ] = 0
	tab[ "$pp_colour_addg" ] = 0
	tab[ "$pp_colour_addb" ] = 0
	tab[ "$pp_colour_brightness" ] = 0
	hook.Add( "RenderScreenspaceEffects", "DR.State.PostProcess", function()
		if DR.State == STATE_ENDED then
			fx=Lerp(FrameTime() * .5,fx,1)

			tab[ "$pp_colour_contrast" ] = 1-fx
			tab[ "$pp_colour_colour" ] = 1-fx

			DrawColorModify( tab )
		elseif fx ~= 0 then
			fx=0
		end
	end)

	hook.Add("HUDPaint","deathrun.state.roundend.paint",function()
		if DR.State == STATE_ENDED then
			local w,h=draw.SimpleText("ROUND ENDED","RoundEndFont",ScrW()/2,ScrH()/2,ES.Color.White,1,1)
			draw.SimpleText(_winner==TEAM_BADDIE and "Baddies killed everyone!" or _winner == TEAM_GOODIE and "Goodies survived the round!" or "","ESDefault+++",ScrW()/2,ScrH()/2+h*.6,ES.Color.White,1,1)
		end
	end)

	net.Receive("DR.SendRoundUpdate",function()
		local state = net.ReadInt(8);
		if state == STATE_ENDED then
			DR:EndRound(net.ReadInt(8));
			surface.PlaySound("vo/k_lab/kl_initializing02.wav")
		elseif state == STATE_SETUP then
			DR:NewRound(net.ReadInt(32));
		end
	end);
elseif SERVER then
	timer.Create("DRRoundEndLogic",1,0,function()
		if DR.State == STATE_IDLE and wantStartup then
			if #team.GetPlayers(TEAM_GOODIE) + #team.GetPlayers(TEAM_BADDIE) >= 2 then
				ES.DebugPrint("State is currently idle, but people have joined; Starting round 1.")
				DR:NewRound();
			end
		end

		if (DR.State ~= STATE_PLAYING and DR.State ~= STATE_SETUP) or #team.GetPlayers(TEAM_BADDIE) + #team.GetPlayers(TEAM_GOODIE) < 2 then return end

		local count_goodie = DR:AliveGoodies();
		local count_baddie = DR:AliveBaddies();

		if count_baddie < 1 and count_goodie < 1 then
			DR:EndRound(0); -- both win!
		elseif count_baddie < 1 then
			DR:EndRound(TEAM_GOODIE);
		elseif count_goodie < 1 then
			DR:EndRound(TEAM_BADDIE);
		end
	end);
end

/*

Transmission Entity

*/
DR.TRANSMITTER = DR.TRANSMITTER or NULL;
hook.Add("InitPostEntity","deathrun.setup_state",function()
	if SERVER and not IsValid(DR.TRANSMITTER) then
		DR.TRANSMITTER = ents.Create("dr_transmitter_state");
		DR.TRANSMITTER:Spawn();
		DR.TRANSMITTER:Activate();

		chainState(STATE_IDLE,tonumber(DR.Config.joinTime),function()
			wantStartup = true; -- request a startup.
		end);
	elseif CLIENT then
		timer.Simple(0,function()
			notification.AddLegacy("Welcome to Deathrun",NOTIFY_GENERIC);
			if DR.State == STATE_IDLE then
				notification.AddLegacy("The round will start once everyone had a chance to join",NOTIFY_GENERIC);
			elseif DR.State == STATE_PLAYING or DR.State == STATE_LASTREQUEST then
				notification.AddLegacy("A round is currently in progress",NOTIFY_GENERIC);
				notification.AddLegacy("You will spawn when the current ends",NOTIFY_GENERIC);
			elseif DR.State == STATE_MAPVOTE then
				notification.AddLegacy("A mapvote is currently in progress",NOTIFY_GENERIC);
			end
		end);
	end
end);

if CLIENT then
	hook.Add("OnEntityCreated","deathrun.locate_transmitter",function(ent)
		if ent:GetClass() == "jb_transmitter_state" and not IsValid(DR.TRANSMITTER) then
			DR.TRANSMITTER = ent;
			ES.DebugPrint("Transmitter found (OnEntityCreated)");
		end
	end)

	timer.Create("deathrun.check_setup",10,0,function()
		if not IsValid(DR.TRANSMITTER) then
			ES.DebugPrint("Panic! State Transmitter not found!");
			local trans=ents.FindByClass("jb_transmitter_state");
			if trans and trans[1] and IsValid(trans[1]) then
				DR.TRANSMITTER=trans[1];
				ES.DebugPrint("Automatically resolved; Transmitter relocated.");
			else
				ES.DebugPrint("Failed to locate transmitter - contact a developer!");
			end
		end
	end);
end

/*

Index Callback methods

*/


// State
DR.maxRoundTime = 600
DR._IndexCallback.State = {
	get = function()
		return IsValid(DR.TRANSMITTER) and DR.TRANSMITTER.GetDRState and DR.TRANSMITTER:GetDRState() or STATE_IDLE;
	end,
	set = function(state)
		if SERVER and IsValid(DR.TRANSMITTER) then
			DR.TRANSMITTER:SetDRState(state or STATE_IDLE);
			ES.DebugPrint("State changed to: "..state)
		else
			Error("Can not set state!\n")
		end
	end
}

// Round-related methods.
DR._IndexCallback.RoundsPassed = {
	get = function()
		return IsValid(DR.TRANSMITTER) and DR.TRANSMITTER.GetDRRoundsPassed and DR.TRANSMITTER:GetDRRoundsPassed() or 0;
	end,
	set = function(amount)
		if SERVER and IsValid(DR.TRANSMITTER) then
			DR.TRANSMITTER:SetDRRoundsPassed(amount > 0 and amount or 0);
		else
			Error("Can not set rounds passed!\n");
		end
	end
}
DR._IndexCallback.RoundStartTime = {
	get = function()
		return IsValid(DR.TRANSMITTER) and DR.TRANSMITTER.GetDRRoundStartTime and  DR.TRANSMITTER:GetDRRoundStartTime() or 0;
	end,
	set = function(amount)
		if SERVER and IsValid(DR.TRANSMITTER) then
			DR.TRANSMITTER:SetDRRoundStartTime(amount > 0 and amount or 0);
		else
			Error("Can not set round start time!\n");
		end
	end
}

/*

Prevent Cleanup

*/
local old_cleanup = game.CleanUpMap;
function game.CleanUpMap(send,tab)
	if not tab then tab = {} end
	table.insert(tab,"dr_transmitter_state");
	old_cleanup(send,tab);
end
