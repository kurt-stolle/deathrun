surface.CreateFont( "drHudTiny",
{
font= "helvetica",
size= 12,
})
surface.CreateFont( "drRoundsLeft",
{
font= "helvetica",
size= 20,
weight = 700
})
surface.CreateFont( "drHUDSPectexrt",
{
font= "Arial Narrow",
size= 14,
weight= 800
})
function DR:HUDShouldDraw(name)
	return name=="CHudGMod";
end

local function convertTime(t)
	local sec = tostring( math.Round(t - math.floor(t/60)*60));
	if string.len(sec) < 2 then
		sec = "0"..sec;
	end
	return (tostring( math.floor(t/60) )..":"..sec )
end

ES.Color.White = ES.Color.White or Color(255,255,255,255);
ES.Color.Black = ES.Color.Black or Color(0,0,0,255);
local mat = Material("deathrunexcl/hudthingy.png","nolod");
local COLOR_TIME = Color(51,204,255);
local COLOR_HEALTH = Color(200,0,0);
local COLOR_SHINY = Color(255,255,255,10);
local hp = 100;

surface.CreateFont("DRKeyFont",{
	font = "Roboto",
	size = 14,
	weight = 500,
	italic = false,
})
surface.CreateFont("DRKeyFontShadow",{
	font = "DRKeyFont",
	blursize = 2,
})
surface.CreateFont("DRInfo",{
	font = "Roboto",
	size = 26,
	weight = 500

})
surface.CreateFont("DRInfoTiny",{
	font = "Arial",
	size = 12,
	weight = 700
})

local colorKeyPressed = Color(20,20,20);
local colorKeyMain = Color(40,40,40);
local colorKeyOverlay = Color(255,255,255,10);
local colorKeyGloss = Color(255,255,255,2);
local plKeys = {};

local margin = 10;
local function drawKey(x,y,w,h,text,pressed)
	if pressed then
		x = x+2;
		y = y+2;
	end

	draw.RoundedBox(4,x,y,w,h,ES.Color.Black)
	if !pressed then
		draw.RoundedBox(4,x+1,y+1,w,h,ES.Color.Black)
		draw.RoundedBox(4,x+2,y+2,w,h,ES.Color.Black)

		draw.RoundedBox(4,x+1,y+1,w-2,h-2,colorKeyMain)
		draw.RoundedBox(4,x+2,y+2,w-4,h-4,colorKeyOverlay)
	else
		draw.RoundedBox(4,x+1,y+1,w-2,h-2,colorKeyPressed)
		draw.RoundedBox(2,x+2,y+2,w-4,h-4,colorKeyOverlay)
	end


	draw.SimpleText(text,"ESDefaultBold.Shadow",x+w/2,y+h/2,ES.Color.Black,1,1)
	draw.SimpleText(text,"ESDefaultBold",x+w/2,y+h/2,Color(220,220,220),1,1)
end
local vel = 0;
local function drawInfoBox(x,y,w,h,text,info,lightup)
	text = string.upper(text);

	draw.RoundedBox(2,x,y,w,h,colorKeyMain)
	draw.RoundedBox(2,x+1,y+1,w-2,h-2,colorKeyOverlay);
	if lightup then
		local color = team.GetColor(LocalPlayer():Team());
		color.a = lightup*50;

		draw.RoundedBox(2,x+2,y+2,w-4,h-4,color);
	end
	draw.SimpleText(text,"ESDefaultBold.Shadow",x+6,y+2,ES.Color.Black)
	draw.SimpleText(text,"ESDefaultBold",x+6,y+2,Color(220,220,220))
	draw.SimpleText(info,"DRInfo",x+5,y+13,ES.Color.White)
end

local wide = 302;
local wideNoMargin = 302-10;
local wideHealth = 	wideNoMargin * 11/20;
local wideSpeed = 	wideNoMargin * 5/20;
local wideRound = 	wideNoMargin * 4/20;
local oldW,oldH
function DR:HUDPaint()
	local watch = LocalPlayer();
	local p = LocalPlayer();
	local spectator=false;

	local oldW,oldH=ScrW(),ScrH()

	local watch = LocalPlayer();
	if not p:Alive() then
		spectator=true
		watch = (LocalPlayer():GetObserverTarget() or LocalPlayer())

		if not IsValid(watch) or watch == LocalPlayer() or not watch:IsPlayer() then 
			drawInfoBox(ScrW()-20-130,ScrH()-20-40,130,40,"LEFT MOUSE","Next target");
			drawInfoBox(ScrW()-20-130-20-145,ScrH()-20-40,145,40,"CTRL","Change mode");
			return
		end
	end

	local xKeyboard = 20;
	drawKey(xKeyboard,ScrH()-20-40,80,40,"Crouch",											(watch == LocalPlayer() and watch:KeyDown(IN_DUCK)) 		or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_DUCK]) 		)
	drawKey(xKeyboard+80+margin,ScrH()-20-40,40,40,"A",										(watch == LocalPlayer() and watch:KeyDown(IN_MOVELEFT)) 	or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_MOVELEFT]) 	)
	drawKey(xKeyboard+80+margin+40+margin,ScrH()-20-40-margin-40,40,40,"W",					(watch == LocalPlayer() and watch:KeyDown(IN_FORWARD)) 		or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_FORWARD]) 		)
	drawKey(xKeyboard+80+margin+40+margin,ScrH()-20-40,40,40,"S",							(watch == LocalPlayer() and watch:KeyDown(IN_BACK)) 		or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_BACK]) 		)
	drawKey(xKeyboard+80+margin+40+margin+40+margin,ScrH()-20-40,40,40,"D",					(watch == LocalPlayer() and watch:KeyDown(IN_MOVERIGHT)) 	or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_MOVERIGHT]) 	)
	drawKey(xKeyboard+80+margin+40+margin+40+margin+40+margin,ScrH()-20-40,180,40,"Jump",	(watch == LocalPlayer() and watch:KeyDown(IN_JUMP))			or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_JUMP]) 		)

	vel = Lerp(0.2,vel,watch:GetVelocity():Length())
	drawInfoBox(ScrW()-20-80,ScrH()-20-40,80,40,"Velocity",math.floor(vel),math.floor(vel)/700);
	drawInfoBox(ScrW()-20-80-20-120,ScrH()-20-40,120,40,"Round time",convertTime(DR.maxRoundTime-DR.RoundStartTime));

	local progress = math.Clamp(math.Clamp(watch:Health()/100,0,1)*(100-2),0,(100-2));
		local x,y = ScrW()-20-80-20-120-20-100,ScrH()-20-40;
		drawInfoBox(x,y,100,40,"HEALTH",math.Clamp(watch:Health(),0,100).." %");

		if progress > 8 then
			local color = team.GetColor(LocalPlayer():Team());
			color.a = 20 + 255*.3;

			draw.RoundedBox(0,x+1,y+40-3,progress,2,color);
		end

	if p != watch then
		drawInfoBox(ScrW()-20-80-20-120-20-100-20-250,ScrH()-20-40,250,40,"Spectating",watch:Nick());
	end
end
net.Receive("deathrun.keypress",function()
	local key = net.ReadUInt(16);
	local pl = net.ReadEntity();

	if not IsValid(pl) then return end
	if not plKeys[pl:UniqueID()] then plKeys[pl:UniqueID()] = {} end

	plKeys[pl:UniqueID()][key] = true;

	if key == IN_JUMP then
		timer.Simple(0.3,function()
			if plKeys and IsValid(pl) and pl:UniqueID() and key and plKeys[pl:UniqueID()] then
				plKeys[pl:UniqueID()][key] = false;
			end
		end)
	end
end)
net.Receive("deathrun.keyrelease",function()
	local key = net.ReadUInt(16);
	local pl = net.ReadEntity();

	if not IsValid(pl) then return end
	if not plKeys[pl:UniqueID()] then plKeys[pl:UniqueID()] = {} end
	plKeys[pl:UniqueID()][key] = false;
end)
