import 'CoreLibs/animator'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/math'
import 'deathsound.wav'
import 'hitsound.wav'

local geo = playdate.geometry
local gfx = playdate.graphics

local deathsound =  playdate.sound.sampleplayer.new("deathsound")
deathsound:setVolume(.5)

local hitsound =  playdate.sound.sampleplayer.new("hitsound")
hitsound:setVolume(.3)

local square_image = gfx.image.new(25,25)
gfx.pushContext(square_image)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, 25, 25)
	gfx.setColor(gfx.kColorWhite)
	gfx.drawRect(0, 0, 25, 25)
gfx.popContext()

local gfx = playdate.graphics

class('Enemy').extends(gfx.sprite)


function Enemy:init()
	if self.className ~= Powerup then --sloppy, fix later
		totalenemycount +=1
		--print ("total enemy count = "..totalenemycount)
	end
	
	Enemy.super.init(self)
	self.basehealth = self.health or 2
	self.health = self.basehealth
	self.image = self.image or square_image
	self.speed = self.speed or .5
	self.killscore = self.killscore or 10
	self.hitstyle = self.hitstyle or 1 
	-- Self.hitstyle indicates 
	--1: collides with bullets' collideRect, 
	--2: alphacollides with bullets (for bosses) or 
	--3: does not collide with bullets
	self:setImage(self.image)
	self:add()
	self:setCollideRect(0,0,25,25)
	
	function self:placement()
	
		local spot = math.random (0, 1280) -- this process places the enemy randomly along the outer perimeter, 13 pixels outside the perimeter
		if spot < 401 then
			self.x = spot
			self.y = -13
		elseif spot < 801 then
			self.x = spot - 400
			self.y = 240 + 13
		elseif spot < 1041 then
			self.x = -13
			self.y = spot - 800
		else
			self.x = 400 + 13
			self.y = spot - 1040
		end
		
		--self.x = math.random(0, 375)
		--self.y = math.random(0, 215)
		self:moveTo(self.x, self.y)
		
		--if self:alphaCollision(triangle) then
		--	self:placement()
		--end
	end
	
	
	
	--function self:death()
	--	score += self.killscore
	--	self.health = self.basehealth
	--	self:placement()
	--end
	
	
		
	self:placement()
	
	function self:update()
		local speedmod = self.speed/geo.distanceToPoint(self.x, self.y, triangle.x, triangle.y)
		if player_alive == false then
			speedmod = 0
		end
		local xspeed = (triangle.x - self.x)*speedmod
		local yspeed = (triangle.y - self.y)*speedmod
		self.x = self.x + xspeed
		self.y = self.y + yspeed
		self:moveTo(self.x,self.y)
		
		gfx.drawText("test", 50, 50)
	
	end
	
	return self
end

function Enemy:collide(object)
	object:explode()
end

function Enemy:death()
	deathsound:play()
	score += self.killscore
	self.health = self.basehealth
	if self.is_mortal == true then
		self:remove()
	else
		self:placement()
	end
	
end

function Enemy:hit(damage)
	hitsound:play()
	self.health -= damage or 1
	if self.health <1 then
		self:death()
	end
end
