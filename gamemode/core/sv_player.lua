-- sv_player
util.AddNetworkString("OpenHelp");
concommand.Add("dr_volunteer_baddie",function(p)
	if p.volunteerBaddie then
		p:ESSendNotificationPopup("Error","You already are on the volunteers list.");
		return
	end
	p.volunteerBaddie = true;
	p:ESSendNotificationPopup("Success","You have been added to the Baddie volunteers list.");
end)

util.AddNetworkString("deathrun.keypress")
hook.Add("KeyPress","DRHandlePeopleKeys",function(p,key)
	if IsValid(p) and (p:Team() == TEAM_BADDIE or p:Team() == TEAM_GOODIE) and p:Alive() and key == IN_FORWARD or key == IN_MOVELEFT or key == IN_BACK or key == IN_MOVERIGHT or key == IN_DUCK or key == IN_JUMP then
		net.Start("deathrun.keypress");
		net.WriteUInt(key,16);
		net.WriteEntity(p);
		net.SendOmit(p);
	end
end);
util.AddNetworkString("deathrun.keyrelease")
hook.Add("KeyRelease","DRHandlePeopleKeysRelease",function(p,key)
	if IsValid(p) and (p:Team() == TEAM_BADDIE or p:Team() == TEAM_GOODIE) and p:Alive() and key == IN_FORWARD or key == IN_MOVELEFT or key == IN_BACK or key == IN_MOVERIGHT or key == IN_DUCK then
		net.Start("deathrun.keyrelease");
		net.WriteUInt(key,16);
		net.WriteEntity(p);
		net.SendOmit(p);
	end
end);

function DR:CanPlayerSuicide(p)
	return true;
end
function DR:PlayerCanHearPlayersVoice()
	return true
end

function DR:PlayerRequestTeam( ply, teamid )
	return;
end
function DR:PlayerSetModel(p)
	player_manager.RunClass( p, "SelectModel" )
end
function DR:PlayerCanPickupWeapon(p,e)
	return ((p:Team() == TEAM_BADDIE or p:Team() == TEAM_GOODIE) and not p:HasWeapon(e:GetClass()));
end
function DR:PlayerInitialSpawn(p)
	p:SetTeam(TEAM_GOODIE);
end
function DR:PlayerSpawn(p)
	if ( p:Team() ~= TEAM_GOODIE and p:Team() ~= TEAM_BADDIE ) or (DR.State ~= STATE_SETUP) then
		return DR:PlayerSpawnAsSpectator(p)
	end

	p:UnSpectate();
	p:StripWeapons()
	p:SetMoveType(MOVETYPE_WALK);

	if p:Team() == TEAM_BADDIE then
		player_manager.SetPlayerClass( p, "player_baddie" )
	elseif p:Team() == TEAM_GOODIE then
		player_manager.SetPlayerClass( p, "player_goodie" )
	end

	player_manager.OnPlayerSpawn( p )
	player_manager.RunClass( p, "Spawn" )

	player_manager.RunClass( p, "Loadout" )

	hook.Call( "PlayerSetModel", DR, p )
	hook.Call("PlayerLoadout",DR,p);

	p:SetAvoidPlayers(false);
	p:SetNoCollideWithTeammates(true);
end

function DR:PlayerSpawnAsSpectator( p )
	p:StripWeapons()
	p:KillSilent()

	if ( p:Team() == TEAM_UNASSIGNED ) then
		p:Spectate( OBS_MODE_FIXED )
		return
	end

	p:Spectate( OBS_MODE_ROAMING )
end

function DR:PlayerDeath(p,infl,att)
	if p:Team() == TEAM_GOODIE or p:Team() == TEAM_BADDIE then
		if ES then
			p:ESAddBananas(1);
		end

		if ES and p.ESAddBananas and p:Team() == TEAM_BADDIE and att and IsValid(att) and att:IsPlayer() then
			att:ESAddBananas(5);
		elseif ES and p.ESAddBananas and p:Team() == TEAM_GOODIE and att and IsValid(att) and att:IsPlayer() then
			if !ES.BaddieBottle then
				ES.BaddieBottle = 1;
			else
				ES.BaddieBottle = ES.BaddieBottle+1;
			end
		end
	end
end

concommand.Add("dr_doselectplay",function(p)
	p:SetTeam(TEAM_GOODIE);
	p:Spawn();
end);
concommand.Add("dr_doselectspec",function(p)
	p:SetTeam(TEAM_SPECTATOR);
	p:Spawn();
end);
function DR:ShowHelp(p)
	net.Start("OpenHelp"); net.Send(p);
end
function DR:ShowTeam(p)
end
function DR:ShowSpare1(p)
end
function DR:ShowSpare2(p)
end


function DR:ESPlayerIdle(p)
	p:SetTeam(TEAM_SPECTATOR);
	p:Spawn();


	p:ESSendNotificationPopup("Notice","You have been moved to the Spectator team, because you were idle for too long.")
end

function DR:PlayerShouldTakeDamage( victim, pl )
	if pl:IsPlayer() then -- check the attacker is player
		if( pl:Team() == victim:Team() ) then -- check the teams are equal and that friendly fire is off.
			return false -- do not damage the player
		end
	end

	return true -- damage the player
end

hook.Add( "KeyPress", "deathrun.spectator.controls", function(p,l)
	if not p:Alive() then
		if l == IN_DUCK and p:GetObserverMode() == OBS_MODE_CHASE then
			p:Spectate(OBS_MODE_IN_EYE);
			return;
		elseif l == IN_DUCK and p:GetObserverMode() == OBS_MODE_IN_EYE then
			p:Spectate(OBS_MODE_ROAMING);
			return;
		elseif l == IN_DUCK and p:GetObserverMode() == OBS_MODE_ROAMING then
			p:Spectate(OBS_MODE_CHASE);
			return;
		end

		if l == IN_ATTACK or l == IN_ATTACK2 then

			local targets={}
			for k,v in ipairs(team.GetPlayers(TEAM_GOODIE))do
				if v:Alive() then
					table.insert(targets,v)
				end
			end
			for k,v in ipairs(team.GetPlayers(TEAM_BADDIE))do
				if v:Alive() then
					table.insert(targets,v)
				end
			end

			if #targets >= 1 then

				if not p._nSpectate then
					p._nSpectate = 1
				elseif l == IN_ATTACK then
					p._nSpectate = p._nSpectate+1;

					if p._nSpectate > #targets then
						p._nSpectate = 1
					end
				elseif l == IN_ATTACK2 then
					p._nSpectate = p._nSpectate-1;

					if p._nSpectate < 1 then
						p._nSpectate = #targets
					end
				end

				local targ = targets[p._nSpectate];
				if IsValid(targ) then
					p:SpectateEntity(targ);
				end

			end
		end
	end
end)

 function DR:GetFallDamage(ply, speed)
   return 1
end

local fallsounds = {
   Sound("player/damage1.wav"),
   Sound("player/damage2.wav"),
   Sound("player/damage3.wav")
};

function DR:OnPlayerHitGround(ply, in_water, on_floater, speed)
   if in_water or speed < 650 or not IsValid(ply) then return end

   -- Everything over a threshold hurts you, rising exponentially with speed
   local damage = math.pow(0.05 * (speed - 620), 1.75)

   -- I don't know exactly when on_floater is true, but it's probably when
   -- landing on something that is in water.
   if on_floater then damage = damage / 2 end

   if math.floor(damage) > 0 then
      local dmg = DamageInfo()
      dmg:SetDamageType(DMG_FALL)
      dmg:SetAttacker(game.GetWorld())
      dmg:SetInflictor(game.GetWorld())
      dmg:SetDamageForce(Vector(0,0,1))
      dmg:SetDamage(damage)

      ply:TakeDamageInfo(dmg)

      -- play CS:S fall sound if we got somewhat significant damage
      if damage > 5 then
         sound.Play(table.Random(fallsounds), ply:GetShootPos(), 55 + math.Clamp(damage, 0, 50), 100)
      end
   end
end

function DR:IsSpawnpointSuitable(pl,spp,bms)
	return true;
end

function DR:AllowPlayerPickup( p, entity)
	return false;
end

util.AddNetworkString("DRHandleRagdollBones")
function DR:DoPlayerDeath(p,att,dmg)
	if p:Team() != TEAM_BADDIE and p:Team() != TEAM_GOODIE then return end

	p:AddDeaths(1);
	if IsValid(att) and att:IsPlayer() and att.AddFrags and att != p then
		att:AddFrags(1);
	end

	local doll = ents.Create("prop_ragdoll");
	if not IsValid(doll) then return end

	doll:SetModel(p:GetModel());
	doll:SetPos(p:GetPos());
	doll:SetAngles(p:GetAngles());
	doll:Spawn();
	doll:Activate();
	doll:SetCollisionGroup(COLLISION_GROUP_WORLD)
	local phy = doll:GetPhysicsObject();
	if IsValid(phy) then
		phy:AddVelocity(p:GetVelocity()*6);
		print(p:GetVelocity())
	end

	p:SpectateEntity(doll)
	p:SetObserverMode(OBS_MODE_CHASE)

	timer.Simple(0,function()
		p:Freeze();
		p:SetPos(doll:GetPos());
	end)
end

function DR:PlayerDeathThink(p)
	if p:KeyDown(IN_JUMP) then
		DR:PlayerSpawnAsSpectator(p)
	end
end


concommand.Remove("changeteam");
