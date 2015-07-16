-- FOONTS
surface.CreateFont("BHSBFont",{
	font = "Roboto",
	size = 16,
	weight = 400,
})
surface.CreateFont("DR.SB.Header",{
	font="Roboto",
	size=52,
	weight=700
})

-- FX
local fx=0;

-- LOCALS
local popModelMatrix = cam.PopModelMatrix
local pushModelMatrix = cam.PushModelMatrix
local pushFilterMag = render.PushFilterMag
local pushFilterMin = render.PushFilterMin
local popFilterMag = render.PopFilterMag
local popFilterMin = render.PopFilterMin
local matrixAngle = Angle(0, 0, 0)
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)
local infoPanelWide = 250
local playersPanelWide = 380
local matrix,x,y,width,height,rad,sb
local function addPerformanceRow(parent,name,value)
	parent.performanceRows = (parent.performanceRows or -1)+1;

	local pnl = vgui.Create("DRSBoard.InfoRow",parent);
	pnl:SetSize(300,40);
	pnl:DockMargin(0,0,0,10)
	pnl:Dock(TOP)
	pnl.text = string.upper(name);
	pnl.value = value;
	pnl.delay=CurTime()+(parent.performanceRows *.1)

	return pnl
end

-- PANELS
vgui.Register("DRSBoard",{
	Init = function(self)
		self.TimeCreate=SysTime()
		self:DockPadding(0,40,0,40)

		local pnl,lbl,clr;

		pnl = self:Add("Panel")
		pnl:SetWide(infoPanelWide)
		pnl:DockMargin(0,20,20,20)
		pnl:Dock(LEFT)

		lbl = pnl:Add("DLabel")
		lbl:SetFont("DR.SB.Header")
		lbl:SetText("DEATHRUN")
		lbl:SizeToContents()
		lbl:SetColor(ES.Color.White)
		lbl:Dock(TOP)

		lbl = pnl:Add("DLabel")
		lbl:SetFont("ESDefaultBold")
		lbl:SetText("A gamemode by Excl\nHosted by Casual Bananas")
		lbl:SizeToContents()
		lbl:SetColor(ES.Color.White)
		lbl:Dock(TOP)
		lbl:DockMargin(0,0,0,10)

		addPerformanceRow(pnl,"MOTD","Visit us at http://casualbananas.com/. To join our community, put [CB] in front of your Steam name.")
		addPerformanceRow(pnl,"Map",game.GetMap())
		addPerformanceRow(pnl,"Players",#player.GetAll())
		addPerformanceRow(pnl,"Rounds left",DR.Config.roundsPerMap - DR.RoundsPassed)

		self.info_best=addPerformanceRow(pnl,"Best player","Loading...")
		self.info_worst=addPerformanceRow(pnl,"Worst player","Loading...")
		self.info_spec=addPerformanceRow(pnl,"Spectators","Loading...")

		self.pnl_info = pnl;

		pnl = self:Add("DRSBoard.TeamContainer")
		pnl:SetWide(playersPanelWide)
		pnl:DockMargin(0,20,20,20)
		pnl:Dock(RIGHT)
		pnl:DockPadding(3,3,3,3)
		pnl.Team = TEAM_BADDIE

		local container=pnl:Add("Panel")
		container:Dock(FILL)

		local sb=container:Add("esScrollbar")
		sb.button.Paint=function(self,w,h)
			draw.RoundedBox(4,0,0,w,h,team.GetColor(TEAM_BADDIE));
		end

		local scrollBuddy=container:Add("Panel")
		scrollBuddy.PerformLayout = function(self)
			local maxh=0

			for k,v in ipairs(self:GetChildren())do
				if v.y + v:GetTall() + 5 > maxh then
					maxh=v.y + v:GetTall() + 5;
				end
			end

			self:SetWide(self:GetParent():GetWide()-10)
			self:SetTall(maxh)

			sb:Setup()
		end
		scrollBuddy.Team = TEAM_BADDIE

		clr=team.GetColor(TEAM_BADDIE)
		clr=Color(20+clr.r * .3,20+clr.g * .3,20+clr.b * .3)

		pnl:SetColor(clr)

		lbl = pnl:Add("DLabel")
		lbl:SetFont("ESDefault+++")
		lbl:SetText("Baddies")
		lbl:SizeToContents()
		lbl:SetColor(ES.Color.White)
		lbl:DockMargin(7,7,5,8)
		lbl:Dock(TOP)

		self.pnl_players_bad = scrollBuddy;

		pnl = self:Add("DRSBoard.TeamContainer")
		pnl:SetWide(playersPanelWide)
		pnl:DockMargin(20,20,20,20)
		pnl:Dock(RIGHT)
		pnl:DockPadding(3,3,3,3)
		pnl.Team = TEAM_GOODIE

		local container=pnl:Add("Panel")
		container:Dock(FILL)

		local sb=container:Add("esScrollbar")
		sb.button.Paint=function(self,w,h)
			draw.RoundedBox(4,0,0,w,h,team.GetColor(TEAM_GOODIE));
		end

		local scrollBuddy=container:Add("Panel")
		scrollBuddy.PerformLayout = function(self)
			local maxh=0

			for k,v in ipairs(self:GetChildren())do
				if v.y + v:GetTall() + 5 > maxh then
					maxh=v.y + v:GetTall() + 5;
				end
			end

			self:SetWide(self:GetParent():GetWide()-10)
			self:SetTall(maxh)

			sb:Setup()
		end
		scrollBuddy.Team = TEAM_GOODIE

		clr=team.GetColor(TEAM_GOODIE)
		clr=Color(20+clr.r * .3,20+clr.g * .3,20+clr.b * .3)

		pnl:SetColor(clr)

		lbl = pnl:Add("DLabel")
		lbl:SetFont("ESDefault+++")
		lbl:SetText("Goodies")
		lbl:SizeToContents()
		lbl:SetColor(ES.Color.White)
		lbl:DockMargin(7,7,5,8)
		lbl:Dock(TOP)

		self.pnl_players_good = scrollBuddy;
	end,
	Think=function(self)
		local worst=NULL;
		local best=NULL;
		local spec={}
		for k,v in ipairs(player.GetAll())do
			if not IsValid(worst) or v:GetScore() < worst:GetScore() then
				worst=v;
			end
			if not IsValid(best) or v:GetScore() > best:GetScore() then
				best=v;
			end

			if v:Team() == TEAM_SPECTATOR or v:Team() == TEAM_UNASSIGNED then
				table.insert(spec,v:Nick())
			end
		end

		if not spec[1] then
			spec[1] = "Nobody"
		end

		self.info_worst.value =worst:Nick()
		self.info_best.value =best:Nick()
		self.info_spec.value = table.concat(spec,",- ",1)

 		for k,v in ipairs(player.GetAll())do
 			if v:Team() == TEAM_BADDIE or v:Team() == TEAM_GOODIE then
 				if not IsValid(v._sbPanel) or v._sbPanel:GetParent().Team ~= v:Team() then
 					if IsValid(v._sbPanel) then
 						v._sbPanel:Remove()
 					end

 					v._sbPanel=vgui.Create("DRSBoard.PlayerRow",v:Team() == TEAM_BADDIE and self.pnl_players_bad or self.pnl_players_good)
 					v._sbPanel:Setup(v)
 					v._sbPanel:Dock(TOP)
 				end 				
 			elseif IsValid(v._sbPanel) then
 				v._sbPanel:Remove()
 				v._sbPanel=nil
 			end
 		end
	end,
	PerformLayout = function(self)
		self:SetSize(playersPanelWide*2 + infoPanelWide + 20 * 3,ScrH())
		self:Center()
	end
},"Panel");

vgui.Register("DRSBoard.TeamContainer",{
	Init=function(self)
		self.exp=0
	end,
	Paint=function(self,w,h)
		self.exp = self.exp + FrameTime()*1600
		render.ClearStencil()
		render.SetStencilEnable( true )
	 
		// First we set every pixel with the prop + outline to 1
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
		render.SetStencilReferenceValue( 1 )
	 	
	 	surface.SetDrawColor(ES.Color.Black)
	 	draw.NoTexture()
		surface.DrawPoly{{x=0,y=-w},{x=w,y=0},{x=w,y=self.exp},{x=0,y=self.exp-w}}
	 
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )

		self.BaseClass.Paint(self,w,h)	
		draw.RoundedBox(2,2,2,w-4,47,ES.Color["#000000AA"])	
	end,
	PaintOver=function()
		render.SetStencilEnable( false )
	end,
},"esPanel")

vgui.Register("DRSBoard.InfoRow",{
	Init=function(self)
		self.scale=0
		self.delay=0
		self.compx = 0
		self.pausemv=0;
		self.scroll_right=false
	end,
	Think=function(self,w,h)
		if self.delay > CurTime() then return end

		self.scale=Lerp(FrameTime()*8,self.scale,1)
	end,
	Paint=function(self,w,h)
		pushFilterMag( TEXFILTER.ANISOTROPIC )
		pushFilterMin( TEXFILTER.ANISOTROPIC )

		x,y=self:LocalToScreen(w/2,h/2)
		x,y=(self.scale-1)*-x,(self.scale-1)*-y

		matrix=Matrix()
		matrix:SetAngles( matrixAngle )
		matrixTranslation.x = x
		matrixTranslation.y = y
		matrix:SetTranslation( matrixTranslation )
		matrixScale.x = self.scale
		matrixScale.y = self.scale
		matrix:Scale( matrixScale )

		-- push matrix
		pushModelMatrix( matrix )

		draw.RoundedBox(2,0,0,w,h,ES.Color["#1E1E1EFF"]);
		draw.RoundedBox(2,1,1,w-2,h-2,Color(255,255,255,10));

		draw.SimpleText(self.text,"ESDefault-",6,4,ES.Color.White);
		local txtw = draw.SimpleText(self.value,"ESDefault+",5+self.compx,16,ES.Color.White)

		if txtw > w - 10 and self.pausemv < CurTime() then
			if self.scroll_right then
				self.compx = self.compx + FrameTime() * 50;

				if self.compx >= 0 then
					self.compx = 0
					self.scroll_right = false
					self.pausemv=CurTime()+.2
				end
			else
				self.compx = self.compx - FrameTime() * 50;

				local diff=txtw - (w-10)
				if self.compx <= -diff then
					self.compx = -diff
					self.scroll_right = true
					self.pausemv=CurTime()+.2
				end
			end
		end
	end,
	PaintOver=function(self,w,h)
		popModelMatrix()
		popFilterMag( TEXFILTER.ANISOTROPIC )
		popFilterMin( TEXFILTER.ANISOTROPIC )
	end
},"Panel")

local clr_blind=Color(0,0,0,200)
local function paintBlind(self,w,h)
	surface.SetDrawColor(clr_blind)
	surface.DrawRect(0,0,w,h)
end
vgui.Register("DRSBoard.PlayerRow",{
	Init=function(self)
		self:DockMargin(0,0,0,1)
		self.uiAvatar=vgui.Create("AvatarImage",self)
		self.uiAvatar.PaintOver = paintBlind

		self.uiNick=vgui.Create("DLabel",self)
		self.uiNick:SetColor(ES.Color.White)
		self.uiNick:Dock(LEFT)
		self.uiNick:DockMargin(10,0,0,0)
		self.uiNick:SetExpensiveShadow(1)
		self.uiNick:SetFont("ESDefault+")

		self.uiScore=vgui.Create("DRSboard.ScoreCircle",self)
		self.uiScore:SetWide(32+10)
		self.uiScore:Dock(RIGHT)
		self.uiScore:DockMargin(0,0,10,0)

		self:SetTall(32 + 5 + 5)
	end,
	PerformLayout = function(self)
		self.uiAvatar:SetSize(self:GetWide(),self:GetWide())
		self.uiAvatar:Center()
	end,
	Setup=function(self,ply)
		self.Player = ply;
		self.uiScore.Player = ply;
		self.uiAvatar:SetPlayer(ply,184)
	end,
	Think=function(self,w,h)
		if not IsValid(self.Player) then return end
		
		if self.Player:Nick() ~= self.uiNick:GetText() then 
			self.uiNick:SetText(self.Player:Nick())
			self.uiNick:SizeToContents()
		end

		local score=self.Player:GetScore()
		if score ~= self.uiScore:GetText() then
			if score > 0 then
				score="+"..tostring(score)
			elseif score == 0 then
				score="~0"
			else
				score=tostring(score)
			end
			self.uiScore:SetText(score)
			self.uiScore:SizeToContents()
		end
	end,
	PaintOver=function(self,w,h)
		if not IsValid(self.Player) or not self.Player:Alive() then
			surface.SetDrawColor(clr_blind)
			surface.DrawRect(0,0,w,h)
		end
	end
},"Panel")

local cir;

vgui.Register("DRSboard.ScoreCircle",{
	Paint=function(self,w,h)
		if not IsValid(self.Player) then return end

		local clr;
		local score=self.Player:Frags()*5 - self.Player:Deaths()
		if score > 0 then
			score="+"..tostring(score)
		elseif score == 0 then
			score="~0"
		else
			score=tostring(score)
		end

		draw.SimpleText(score,"ESDefault++",w/2,h/2,ES.Color.White,1,1)
	end
})

-- HOOKS
function DR:ScoreboardShow()
	if sb and IsValid(sb) then sb:Remove() return end

	sb = vgui.Create("DRSBoard");
	sb:Center()
	sb:MakePopup()
end

function DR:ScoreboardHide()
  	if IsValid(sb) then sb:Remove() return end
end

local tab={}
tab[ "$pp_colour_mulr" ] = 0
tab[ "$pp_colour_mulg" ] = 0
tab[ "$pp_colour_mulb" ] = 0
tab[ "$pp_colour_addr" ] = 0
tab[ "$pp_colour_addg" ] = 0
tab[ "$pp_colour_addb" ] = 0
tab[ "$pp_colour_brightness" ] = 0
hook.Add( "RenderScreenspaceEffects", "DR.Scoreboard.PostProcess", function()
	if IsValid(sb) then
		fx=Lerp(FrameTime(),fx,1)

		tab[ "$pp_colour_contrast" ] = 1-fx*.7
		tab[ "$pp_colour_colour" ] = 1-fx

		DrawColorModify( tab )
	elseif fx ~= 0 then
		fx=0
	end
end)