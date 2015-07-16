-- sh_buttonclaim

DR.ButtonsClaimed = {};

if SERVER then
	util.AddNetworkString("drReceiveButtons")
	util.AddNetworkString("drReceiveButtonsSingle")
	function DR:ResetClaims()
		DR.ButtonsClaimed = {};
		for k,v in pairs(ents.FindByClass("func_button"))do
			if not IsValid(v) or not v:GetClass() == "func_button" then continue end

			DR.ButtonsClaimed[v:EntIndex()] = {claimed = nil,pos = v:GetPos()}
		end

		net.Start("drReceiveButtons");
		net.WriteTable(DR.ButtonsClaimed);
		net.Send(team.GetPlayers(TEAM_BADDIE));
	end

	local pmeta = FindMetaTable("Player");
	function pmeta:ClaimButton(b)
		if DR.ButtonsClaimed[b] and not (DR.ButtonsClaimed[b].claimed and IsValid(DR.ButtonsClaimed[b].claimed)) then
			DR.ButtonsClaimed[b].claimed = self;

			if self.claim and DR.ButtonsClaimed[self.claim].claimed and IsValid(DR.ButtonsClaimed[self.claim].claimed)
			and DR.ButtonsClaimed[self.claim].claimed == self then
				self:UnClaimButton(self.claim);
			end

			self.claim = b;

			net.Start("drReceiveButtonsSingle");
			net.WriteInt(b,32);
			net.WriteTable(DR.ButtonsClaimed[b]);
			net.Send(team.GetPlayers(TEAM_BADDIE));
		end 
	end
	function pmeta:UnClaimButton(b)
		if DR.ButtonsClaimed[b] and DR.ButtonsClaimed[b].claimed and IsValid(DR.ButtonsClaimed[b].claimed) and DR.ButtonsClaimed[b].claimed == self then
			DR.ButtonsClaimed[b].claimed = nil;

			self.claim = nil;

			net.Start("drReceiveButtonsSingle");
			net.WriteInt(b,32);
			net.WriteTable(DR.ButtonsClaimed[b]);
			net.Send(team.GetPlayers(TEAM_BADDIE));
		end 
	end
	concommand.Add("dr_claim",function(p)
		if p and IsValid(p) and p:Team() == TEAM_BADDIE
			and p:GetEyeTrace() and p:GetEyeTrace().Entity and IsValid(p:GetEyeTrace().Entity)
			and p:GetEyeTrace().Entity:GetClass() == "func_button" then
			p:ClaimButton(p:GetEyeTrace().Entity:EntIndex());
		end
	end)
	hook.Add("PlayerUse","drCheckClaimsOnUse",function(p,ent)
		if p:Team() == TEAM_BADDIE and ent and ent:GetClass() == "func_button" 
		and DR.ButtonsClaimed[ent:EntIndex()] and DR.ButtonsClaimed[ent:EntIndex()].claimed and IsValid(DR.ButtonsClaimed[ent:EntIndex()].claimed) then
			if DR.ButtonsClaimed[ent:EntIndex()].claimed != p then
				return false
			else
				p:UnClaimButton(ent:EntIndex());
			end
		end
	end)
	timer.Create("checkIfPlayersNearClaimedButtons",1,0,function()
		for k,v in pairs(DR.ButtonsClaimed)do
			if v and v.claimed and IsValid(v.claimed) and v.claimed:GetPos():Distance(v.pos) > 300 then
				v.claimed:UnClaimButton(k);
			end
		end
	end)
elseif CLIENT then
	function DR:OnSpawnMenuOpen()
		local p = LocalPlayer()
		if IsValid(p) and p:Team() == TEAM_BADDIE and p:GetEyeTrace() and p:GetEyeTrace().Entity then
			RunConsoleCommand("dr_claim")
		end
	end

	net.Receive("drReceiveButtonsSingle",function()
		DR.ButtonsClaimed[net.ReadInt(32)] = net.ReadTable();
	end)
	net.Receive("drReceiveButtons",function()
		DR.ButtonsClaimed = net.ReadTable();
	end)
	hook.Add("HUDPaint","drPaintButtons",function()
		local p = LocalPlayer();
		if p:Team() == TEAM_BADDIE then	
			for k,v in pairs(DR.ButtonsClaimed) do
				if v and v.pos:Distance(p:GetPos()) < 200 then
					local ps = (v.pos):ToScreen();
					
					if v.claimed and IsValid(v.claimed) and v.claimed:IsPlayer() then
						draw.SimpleText("Claimed by "..v.claimed:Nick(),"ESDefault+.Shadow",ps.x,ps.y + math.sin(CurTime()*2)*20,Color(0,0,0,255 - 255 * (v.pos:Distance(p:GetPos())/200)),1,1);
						draw.SimpleText("Claimed by "..v.claimed:Nick(),"ESDefault+",ps.x,ps.y + math.sin(CurTime()*2)*20,Color(255,255,255,255 - 255 * (v.pos:Distance(p:GetPos())/200)),1,1);
					else
						draw.SimpleText("Press "..string.upper(input.LookupBinding("+menu") or "UNBOUND").." to claim","ESDefault+.Shadow",ps.x,ps.y + math.sin(CurTime()*2)*20,Color(0 ,0,0,255 - 255 * (v.pos:Distance(p:GetPos())/200)),1,1);
						draw.SimpleText("Press "..string.upper(input.LookupBinding("+menu") or "UNBOUND").." to claim","ESDefault+",ps.x,ps.y + math.sin(CurTime()*2)*20,Color(255,255,255,255 - 255 * (v.pos:Distance(p:GetPos())/200)),1,1);
					end
					
				end
			end
		end
	end)
end