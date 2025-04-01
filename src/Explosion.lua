import 'CoreLibs/animator'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
--import 'CoreLibs/math'
import 'CoreLibs/timer'
import 'CoreLibs/ui'

local snd <const> = playdate.sound
local geo <const> = playdate.geometry
local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry

local explosion_image_table, error = gfx.imagetable.new("images/Explosion_Table/explosion")

local boom =  playdate.sound.sampleplayer.new("boom")
boom:setVolume(.5)

class('Explosion').extends(gfx.sprite)

function Explosion:init(x, y, countdown, mute)
	Explosion.super.init(self)
	

	self:moveTo(x, y)
	self:add()
	self.sound = boom:copy()
	
	if mute == true then
		self.sound:setVolume(0)
	end
	
	if countdown == nil or countdown <=0 then
		self:start()
	elseif countdown > 0 then
		self.frame = -countdown
	end
	
	print("explosion:"..x..","..y..","..tostring(countdown))
end

function Explosion:start()
	self.sound:play()
	self.frame = 1
	self:setImage(explosion_image_table[1])
end

function Explosion:update()
	self.frame += 1
	if self.frame < 1 then
		if self.frame == 0 then
			self:start()
		end
	elseif self.frame <= #explosion_image_table then
		self:setImage(explosion_image_table[self.frame])
	else
		self:remove()
	end
	
end