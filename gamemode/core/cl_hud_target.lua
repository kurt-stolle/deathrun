surface.CreateFont("DR.TargetID",{
  font="Roboto",
  size=21,
  weight=400
})
surface.CreateFont("DR.TargetID.Shadow",{
  font="Roboto",
  size=21,
  weight=400,
  blursize=2
})

surface.CreateFont("DR.TargetID-",{
  font="Roboto",
  size=17,
  weight=400
})
surface.CreateFont("DR.TargetID-.Shadow",{
  font="Roboto",
  size=17,
  weight=400,
  blursize=2
})


local ply,posLocal,posTarget;

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)
local color_job;
local drawText = draw.SimpleText
local matGrad=  Material("exclserver/gradient.png")
local jobstring;

hook.Add("HUDPaint","DR.HUDPaint.TargetID",function()
  ply=LocalPlayer();

  if IsValid(ply) then
    posLocal=ply:EyePos();
    for k,v in ipairs(player.GetAll())do
      if not IsValid(v) or not v:Alive() --[[or v == ply]] then continue end

      posTarget=v:LookupBone("ValveBiped.Bip01_Neck1")

      if not posTarget then continue end

      posTarget=v:GetBonePosition(posTarget)

      if not posTarget then continue end

      if posTarget:Distance(posLocal) > 500 then
        v._hud_nameFade = Lerp(FrameTime()*12,v._hud_nameFade or 0,0);
      else
        v._hud_nameFade = Lerp(FrameTime()*8,v._hud_nameFade or 0,255)
      end

      if v._hud_nameFade < 1 then continue end

      color_white.a = v._hud_nameFade;

      posTarget.z = posTarget.z + 28;

      v._hud_nameTarget = LerpVector(FrameTime()*12,v._hud_nameTarget or posTarget,posTarget)

      posTarget=v._hud_nameTarget:ToScreen();

      x,y = math.floor(posTarget.x),math.floor(posTarget.y)

      surface.SetMaterial(matGrad)
      color_black.a = v._hud_nameFade * .6;
      surface.SetDrawColor(color_black)
      surface.DrawTexturedRectRotated(x+70,y+10,48,140,90)
      surface.DrawTexturedRectRotated(x-70,y+10,48,140,-90)
      surface.DrawTexturedRectRotated(x+50,y+11-48/2,1,100,90)
      surface.DrawTexturedRectRotated(x-50,y+11-48/2,1,100,-90)
      surface.DrawTexturedRectRotated(x+50,y+10+48/2,1,100,90)
      surface.DrawTexturedRectRotated(x-50,y+10+48/2,1,100,-90)

      color_black.a = v._hud_nameFade;

      local namestring = v:Nick();
      drawText(namestring,"DR.TargetID",x,y+1,color_black,1,1)
      drawText(namestring,"DR.TargetID.Shadow",x,y,color_black,1,1)
      drawText(namestring,"DR.TargetID.Shadow",x,y,color_black,1,1)
      drawText(namestring,"DR.TargetID",x,y,color_white,1,1)

      y = y + 22

      jobstring,color_job = v:HealthString()
      drawText(jobstring,"DR.TargetID-",x,y+1,color_black,1,1)
      drawText(jobstring,"DR.TargetID-.Shadow",x,y,color_black,1,1)
      drawText(jobstring,"DR.TargetID-.Shadow",x,y,color_black,1,1)
      drawText(jobstring,"DR.TargetID-",x,y,color_job,1,1)
    end
  end
end)
