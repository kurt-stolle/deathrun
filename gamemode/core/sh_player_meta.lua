local PLAYER=FindMetaTable("Player")

local oldAlive = PLAYER.Alive;
function PLAYER:Alive()
	if self:Team() == TEAM_GOODIE or self:Team() == TEAM_BADDIE then
		return oldAlive(self)
	end
	return false;
end

function PLAYER:HealthString()
	if self:Health() == 100 then
		return "Full health",ES.Color.Green;
	elseif self:Health() > 90 then
		return "Healthy",ES.Color.LightGreen;
	elseif self:Health() > 70 then
		return "Slightly injured",ES.Color.Yellow;
	elseif self:Health() > 50 then
		return "Injured",ES.Color.Orange;
	elseif self:Health() > 25 then
		return "Hurt",ES.Color.Red
	elseif self:Health() > 10 then
		return "Very hurt",ES.Color.DarkRed
	end

	return "Near death"
end

function PLAYER:GetScore()
	return (self:Frags()*5 - self:Deaths())
end