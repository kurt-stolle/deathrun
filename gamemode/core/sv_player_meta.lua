local PLAYER=FindMetaTable("Player")

util.AddNetworkString("DR.SyncHullSize");
function PLAYER:SetupHull()
	self:SetAvoidPlayers(false);
	self:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 60 ) )
	self:SetViewOffset(Vector(0,0,60))
	self:SetHullDuck(Vector(-16,-16,0), Vector( 16, 16, 44 ))
	self:SetViewOffsetDucked(Vector(0,0,44))

	net.Start("DR.SyncHullSize");
	net.Send(self);
end
