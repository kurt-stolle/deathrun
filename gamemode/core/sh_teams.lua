-- sh_teams

TEAM_GOODIE = 1;
TEAM_BADDIE = 2;

function DR:CreateTeams()
	team.SetUp (TEAM_GOODIE, "Goodies", ES.Color.Green);
	team.SetUp (TEAM_BADDIE, "Baddies", ES.Color.Red);

	local ctBadMaps = {};

	if table.HasValue(ctBadMaps,game.GetMap()) then
		team.SetSpawnPoint( TEAM_BADDIE, "info_player_counterterrorist" );
		team.SetSpawnPoint( TEAM_GOODIE, "info_player_terrorist" );
	else
		team.SetSpawnPoint( TEAM_BADDIE, "info_player_terrorist");
		team.SetSpawnPoint( TEAM_GOODIE, "info_player_counterterrorist");
	end
end

function DR:CountAliveInTeam(tm)
	local cnt=0
	for k,v in ipairs(team.GetPlayers(tm))do
		if v:Alive() then
			cnt=cnt+1
		end
	end

	return cnt;
end

function DR:AliveBaddies()
	return DR:CountAliveInTeam(TEAM_BADDIE)
end

function DR:AliveGoodies()
	return DR:CountAliveInTeam(TEAM_GOODIE)
end