local bit_band=bit.band
local bit_bnot=bit.bnot
hook.Add( "SetupMove", "DR.Cheat.AutoJump", function( ply, move )
    if ply:Alive() then
	    if not ply:IsOnGround() and ply:KeyDown(IN_JUMP) then
	      move:SetButtons( bit_band( move:GetButtons(), bit_bnot( IN_JUMP ) ) )
	    elseif SERVER and ply:IsOnGround() and ply:KeyDown(IN_JUMP) then
	    	ply:EmitSound("ambient/levels/canals/drip3.wav",50,120,.5)
	    end
	end
end )

hook.Add("Initialize","DR.ES.EnableAntiIdle",function()
	ES.AntiIdle = true;
end);

hook.Add("CanPlayerSuicide", "DR.CanPlayerSuicide.NoBaddieSuicide", function(p)
	if p:Team() == TEAM_BADDIE then
		p:ESSendNotificationPopup("Error","It looks like you're trying to kill yourself. This is not allowed while you are on the Baddie team. Please play one more round before killing yourself.");
		return false;
	end
end)
