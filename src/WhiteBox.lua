import 'Enemy.lua'
local gfx = playdate.graphics

local white_square_image = gfx.image.new(15,15)
gfx.pushContext(white_square_image)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 15, 15)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRect(0, 0, 15, 15)
gfx.popContext()



class('White_Square').extends(Enemy)

function White_Square:init()
	self.image = white_square_image
	self.speed = 1
	self.killscore = 20
	White_Square.super.init(self)
	
	self:setZIndex(1)
	
	function self:death()
		Powerup(self.x, self.y)
		White_Square.super.death(self)
		self:remove()
	end
	
	self:setCollideRect(0, 0, 15, 15) -- fix later, this should be abstracted so that Enemy draws fromt he size of self.image
end
	