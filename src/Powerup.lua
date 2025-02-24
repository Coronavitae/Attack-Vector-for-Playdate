import "Enemy"
import "powerupsound.wav"
local gfx = playdate.graphics

local powerup_image = gfx.image.new(12,12)
gfx.pushContext(powerup_image)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawLine(0, 5, 12, 5)
	gfx.drawLine(0, 6, 12, 6)
	gfx.drawLine(5, 0, 5, 12)
	gfx.drawLine(6, 0, 6, 12)
	gfx.drawCircleAtPoint(6, 6, 6)
gfx.popContext()

local powerupsound =  playdate.sound.sampleplayer.new("powerupsound")
powerupsound:setVolume(.3)


class('Powerup').extends(Enemy)

function Powerup:init(x, y)
	self.image = powerup_image
	self.health = 1000
	self.speed = 0
	self.killscore = 0
	self.hitstyle = 3
	
	Powerup.super.init(self)
	
	self:moveTo(x, y)
	self:setCollideRect(-5, -5, 22, 22)
	
	self.hit = false
	
	--print("should be true", self.hit == false)
end

function Powerup:collide(object)
	
	self:remove()
	object:powerup("speedshot", 100)
	powerupsound:play()
end