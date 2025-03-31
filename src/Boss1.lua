import 'CoreLibs/animator'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/Math'
import 'Enemy'
import 'CoreLibs/timer'

gfx = playdate.graphics
local snd = playdate.sound
local geo = playdate.geometry



--testsound:playMIDINote("C4", .2)

--l:setCenter(playdate.getCrankPosition()/360)
--test = playdate.timer.new(10, 0, 1, playdate.easingFunctions.inQuint)

boss_one_image = gfx.image.new(100, 100)
boss_one_image_part_two = gfx.image.new(100, 100)

gfx.pushContext(boss_one_image_part_two)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0,0,100,100)
	
	gfx.setColor(gfx.kColorClear)
	gfx.fillCircleAtPoint(0, 0, 50)
	gfx.fillCircleAtPoint(0, 100, 50)
	gfx.fillCircleAtPoint(100, 0, 50)
	gfx.fillCircleAtPoint(100, 100, 50)
	
	gfx.setColor(gfx.kColorBlack)
	gfx.drawCircleAtPoint(0, 0, 50)
	gfx.drawCircleAtPoint(0, 100, 50)
	gfx.drawCircleAtPoint(100, 0, 50)
	gfx.drawCircleAtPoint(100, 100, 50)
	gfx.setColor(gfx.kColorClear)
	
	--gfx.fillRect(0, 0, 25, 25)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(50,50, 20)
	
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(50,50, 10)
	
	gfx.setColor(gfx.kColorBlack)
	--gfx.fillCircleAtPoint(50,50, 5)
	
gfx.popContext()

gfx.pushContext(boss_one_image)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillPolygon(0, 50, 50, 100, 100, 50, 50, 0)
	gfx.setColor(gfx.kColorClear)
	gfx.fillCircleAtPoint(0, 0, 50)
	gfx.fillCircleAtPoint(0, 100, 50)
	gfx.fillCircleAtPoint(100, 0, 50)
	gfx.fillCircleAtPoint(100, 100, 50)
	gfx.setColor(gfx.kColorBlack)
	boss_one_image_part_two:drawRotated(50, 50, 45)
	--gfx.fillRect(0, 0, 25, 25)
	--gfx.setColor(gfx.kColorWhite)
	--gfx.drawRect(0, 0, 25, 25)
gfx.popContext()


boss_shield_reset = gfx.image.new(100,100)





class('BossOne').extends(Enemy)

function BossOne:init()
	if phase > 1 then
		self.cohort()
	end
	
	self.lasersound = playdate.sound.synth.new(playdate.sound.kWaveSawtooth)
	self.lasersound:setVolume(.5)
	self.lasersoundfilter = snd.lfo.new()
	self.lasersoundfilter:setRate(0)
	self.lasersoundfilter:setDepth(0)
	self.lasersound:setFrequencyMod(self.lasersoundfilter)
	self.lasersoundtimer = {}
	self.lasersoundtimer.value  = 1
	self.hitstyle = 2
	
	
	
	self.image = boss_one_image
	self.speed = 5
	self.health = 100
	self.killscore = 500
	self.justhit = 0
	self.bosstimer = 200 --this timer counts down, so this should give some space for the boss to arrive on screen before e.g. firing.
	self.targetx = 200 --default values in case for some reason targetting fails
	self.targety = 120
	self.giftdir = 0
	
	self.lasershimmer = {}
	
	for i=1, 5 do
		self.lasershimmer[i] = gfx.image.new(400, 200)--TO_FIX: use masking to make this less processor-intensive
	end
	
	BossOne.super.init(self)
	
	self:setZIndex(5)--TO_FIX: probably unnecessarily high; consider revising.
	
	function self:update()
		--print("Boss health = "..self.health)
		
		self.lasersoundfilter:setCenter(self.lasersoundtimer.value)
		--print ("timer value = "..self.lasersoundtimer.value)
		
		
		if self.bosstimer > 0 then
			self.bosstimer -=1
		else
			self.bosstimer = 200 -- abstract this
		end
		
		if self.bosstimer > 70 then
			self:movement()
		end
		
		if self.bosstimer == 200 then
			if self.giftdir == 0 then
				local gift = White_Square()
				gift:moveTo(200, -10)
				self.giftdir = 1
				
			else
				local gift = White_Square()
				gift:moveTo(200, 250)
				self.giftdir = 0
			end
		end
		
		if phase > 4 then
			if self.bosstimer == 150 then --fix this so it matches the bosstimer reset or something
				self.cohort()
			end
		end
		
		--print( "boos timer = "..self.bosstimer)
		
		gfx.lockFocus(boss_one_image)
		
		---the following chunk is part of the boss-shield animation, not implemented (yet?)
		if self.justhit > 1 then
			gfx.setColor(gfx.kColorBlack)
			gfx.fillRect(95, 0, 5, 100)
			gfx.unlockFocus()
			self.justhit -=1
		elseif self.justhit == 1 then
			justhit = 0
			gfx.setColor(gfx.kColorClear)
			gfx.fillRect(0, 0, 5, 100)
			gfx.fillRect(0, 0, 100, 5)
			gfx.fillRect(95, 0, 5, 100)
			gfx.fillRect(0, 95, 100, 5)
		end
		
		if self.bosstimer >= 70 then
			gfx.setColor(gfx.kColorWhite)
			gfx.fillCircleAtPoint(50, 50, 9)		
			gfx.setColor(gfx.kColorBlack)
			local exspeedmod = 4/geo.distanceToPoint(self.x, self.y, triangle.x, triangle.y)
			local ex = 50 + (triangle.x-self.x)*exspeedmod
			local ey = 50 +(triangle.y-self.y)*exspeedmod
			
			gfx.fillCircleAtPoint(ex, ey, 5)
		end
		
		gfx.unlockFocus()
	end
	
	function self:hit(damage, hitx, hity)
		BossOne.super.hit(self)
		--self.justhit = 3 -- intended to make a shield visual, not yet implemented fully
		
	end
		
	
	function self:death()
		BossOne.super.death(self)
		boss_alive = false
		playdate.resetElapsedTime()--TO_FIX: this should only happen when the boss stage is cleared, if there are multiple boss-enemies
		self:remove()
	end
	
	self:setCollideRect(10, 10, 80, 80) -- fix later, this should be abstracted so that Enemy draws fromt he size of self.image
end

function BossOne:bossGraphics()
	if self.bosstimer == 70 then
		self.targetx = triangle.x
		self.targety = triangle.y
		self.lasersound:playMIDINote("C4", .2, 2.5)
		self.lasersoundtimer = playdate.timer.new(1000, 0, 1, playdate.easingFunctions.inQuint)
		self:laserShimmerSetup()
	elseif self.bosstimer <40 then
		self:fireLaser()
	elseif self.bosstimer <70 then
		self:laserShimmerDisplay()
	end
	
end

function BossOne:laserShimmerSetup()
	
	for i=1, 5 do -- this initializes each of the 5 shimmer layers
		self.laserShimmerTimer = -1 --should prevent displaying rogue beams
		self:laserShimmerDisplay(i)
		
	end
	
	
	self.laserShimmerTimer = 15
end

function BossOne:laserShimmerDisplay(lasernumber) --lasernumber represents 1 of 5 layers of shimmer that update independently
	lasernumber = lasernumber or 0 -- 0 skips updating shimmer layer to create less flickery effect
	if self.laserShimmerTimer == 15 then -- updates one layer each 3 frames
		lasernumber = 5
	elseif self.laserShimmerTimer == 12 then
		lasernumber = 4
	elseif self.laserShimmerTimer == 9 then
		lasernumber = 3
	elseif self.laserShimmerTimer == 6 then
		lasernumber = 2
	elseif self.laserShimmerTimer == 3 then
		lasernumber = 1
	end
	
	local laser = self:laserMath() -- pulls the coordinates of the laser's four corners
	
	--i.e.:
	-- (x1,y1)----------------(x4,y4)
	--    |                      |
	-- (x2,y2)----------------(x3,y3)
	
	
	if lasernumber <=5 and lasernumber >=1 then
		gfx.lockFocus(self.lasershimmer[lasernumber])
			gfx.clear(gfx.kColorClear)
			--this section would ideally change automatically if laserwidth is later updated, but it doesn't.
			--manually update this if laserwidth changes
			--current width of laser is 20, length is 400
			for i=1, 80 do --change number to increase or decrease density of shimmer; may be cause of performance issues
				local relative_height = math.random(1, 20) /20
				local relative_width = math.random(1, 400) / 400
				local height_change_x = (laser.x2 - laser.x1)
				local height_change_y = (laser.y2 - laser.y1)
				local width_change_x = (laser.x4 - laser.x1)
				local width_change_y = (laser.y4 - laser.y1)
				
				local pixel_x = laser.x1 + height_change_x * relative_height
				pixel_x += width_change_x * relative_width
				local pixel_y = laser.y1 + height_change_y * relative_height
				pixel_y += width_change_y * relative_width
				gfx.drawPixel(pixel_x, pixel_y)
				
			end
			print("lasernumber = "..lasernumber.."\nAt: "..laser.x4..","..laser.y4)
		gfx.unlockFocus()
	end
	
	
	if self.laserShimmerTimer >= 0 then
		for i=1, 5 do
			self.lasershimmer[i]:draw(0,0)
		end
	end
	
	self.laserShimmerTimer -= 1
	if self.laserShimmerTimer <= 0 then
		self.laserShimmerTimer = 15
	end
end


function BossOne:fireLaser()	
	local laser = self:laserMath()
	
	
	local laserart = geo.polygon.new(laser.x1,laser.y1,laser.x2, laser.y2, laser.x3, laser.y3, laser.x4, laser.y4)
	laserart:close()
	
	gfx.fillPolygon(laserart)
	
	
	if laserart:containsPoint(triangle.x, triangle.y) then
		triangle:explode()
	end
	
	
end

function BossOne:laserMath()
	--local angle = math.atan((triangle.y-self.y)/(triangle.x-self.x)) --Failed attempt to achieve laser with trigonometry
	
	local target = {}
	target.x = self.targetx
	target.y = self.targety
	
	local laser = {}
	local laserdistance = 50
	local laserwidth = 10 --actually half of the width of the laser, fix to 20, 10 for alex
	
	local distance = math.sqrt((target.x-self.x)^2 + (target.y-self.y)^2)
	local unitdx = (target.x-self.x)/distance
	local unitdy = (target.y-self.y)/distance
	
	local fulcromx = self.x + laserdistance * unitdx
	local fulcromy = self.y + laserdistance * unitdy
	
	local perpdx = -unitdy
	local perpdy = unitdx
	
	laser.x1 = fulcromx + laserwidth * perpdx
	laser.y1 = fulcromy + laserwidth * perpdy
	laser.x2 = fulcromx - laserwidth * perpdx
	laser.y2 = fulcromy - laserwidth * perpdy
	laser.x3 = laser.x2 + 400 * unitdx
	laser.y3 = laser.y2 + 400 * unitdy
	laser.x4 = laser.x1 + 400 * unitdx
	laser.y4 = laser.y1 + 400 * unitdy
	
	
	--FAILED ATTEMPT TO USE TRIG FOR THE SAME FUNCTION
	--laser.x1 = self.x + math.cos(angle) * laserdistance - math.sin(angle) * laserwidth
	--laser.y1 = self.y + math.sin(angle) * laserdistance + math.cos(angle) * laserwidth
	 --laser.x2 = self.x + math.cos(angle) * laserdistance + math.sin(angle) * laserwidth
	--laser.y2 = self.y + math.cos(angle) * laserdistance - math.cos(angle) * laserwidth
	--laser.x3 = laser.x2 + 400 * math.cos(angle)
	--laser.y3 = laser.y2 + 400 * math.sin(angle)
	--laser.x4 = laser.x1 + 400 * math.cos(angle)
	--laser.y4 = laser.y1 + 400 * math.sin(angle)
	--
	--print("laser coordinates 1, 2")
	--print(laser.x1..","..laser.y1)
	--print(laser.x2..","..laser.y2)
	--
	--gfx.fillCircleAtPoint(self.x + math.cos(angle) * laserdistance, self.y + math.sin(angle) * laserdistance, 5)
	--gfx.fillCircleAtPoint(self.x + math.cos(angle) * laserdistance - math.sin(angle)  * laserwidth, self.y + math.sin(angle) * laserdistance + math.cos(angle)--*laserwidth, 5)
	return laser
end

function BossOne:movement() -- fix to be more abstract
	if self.x < 50 then
		self:moveBy(1.5, 0)
	elseif self.x > 350 then
		self:moveBy(-1.5,0)
	elseif self.y < 50 then
		self:moveBy(0, 1.5)
	elseif self.y >190 then
		self:moveBy(0, -1.5)
	else
		if self.vertdir == nil or self.y <= 50 then
			self.vertdir = 1
		elseif self.y >= 190 then
			self.vertdir = -1
		end
		
		if self.hordir == nil or self.x <= 50 then
			self.hordir = 1
		elseif self.x >= 350 then
			self.hordir = -1
		end
		
		self:moveBy(.25*self.hordir, .5*self.vertdir)
	end
		
end

function BossOne:cohort()
	local enemyverts = {0, 30, 60, 90, 120, 150, 180, 210, 240}
	local x = Enemy()
	for i = 1, #enemyverts do
		x = Enemy()
		x:moveTo(-13, enemyverts[i])
		x.speed = 2
		x.is_mortal = true
	end

end

function BossOne:collide(object)
	if self:alphaCollision(object) then
		object:explode()
	end
end