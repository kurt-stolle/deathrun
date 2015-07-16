local PLAYER=FindMetaTable("Player")

net.Receive("DR.SyncHullSize",function()
  timer.Simple(0,function()
    local ply=LocalPlayer()

    if not IsValid(ply) or not ply.SetHull then return end

    ply:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 60 ) )
    ply:SetViewOffset(Vector(0,0,60))
    ply:SetHullDuck(Vector(-16,-16,0), Vector( 16, 16, 44 ))
    ply:SetViewOffsetDucked(Vector(0,0,44))
  end)
end);
