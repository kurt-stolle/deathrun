net.Receive("DR.SyncHullSize",function()
  timer.Simple(0,function()
    ply=LocalPlayer()

    if not IsValid(ply) then return end

    ply:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 60 ) )
    ply:SetViewOffset(Vector(0,0,60))
    ply:SetHullDuck(Vector(-16,-16,0), Vector( 16, 16, 44 ))
    ply:SetViewOffsetDucked(Vector(0,0,44))
  end)
end);

hook.Add("InitPostEntity","deathrun.select.spectator",function()
	if GetConVarNumber("dr_alwaysspectate") == 1 then
		RunConsoleCommand("dr_doselectspec")
	end
end)

function GM:OnContextMenuOpen()
  LocalPlayer():ConCommand("+left; cl_yawspeed 320")
end

function GM:OnContextMenuClose()
  LocalPlayer():ConCommand("-left")
end