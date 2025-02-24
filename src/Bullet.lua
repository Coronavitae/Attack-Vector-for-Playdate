import 'CoreLibs/animator'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'

local gfx = playdate.graphics
local bulletImage = playdate.graphics.image.new(6, 6) -- Small square bullet

playdate.graphics.pushContext(bulletImage)
	playdate.graphics.fillCircleAtPoint(3, 3, 3) -- Fill it as a solid square
playdate.graphics.popContext()

class('Bullet').extends(gfx.sprite)

function Bullet:new(x, y, speedX, speedY)
	self = Bullet()
	Bullet.super.init(self)
	
	
	self:setCollideRect(0,0,10,10)
	
	self:setImage(bulletImage)
	self:moveTo(x, y)
	self:add()

	self.speedX = speedX
	self.speedY = speedY
	return self
end





function Bullet:update()
	
	self:moveBy(self.speedX or 1, self.speedY or 1) -- Move in a straight line
	
	local collisions = self:overlappingSprites()
	
	for i = 1, #collisions do
		if collisions[i].hitstyle == 1 then
			--print("Bullet hit "..collisions[i].className.." which has " , (collisions[i].hit == nil))
			collisions[i]:hit(nil, self.x, self.y)
			self:remove()
		elseif collisions[i].hitstyle == 2 then
			if self:alphaCollision(collisions[i]) then
				collisions[i]:hit(nil, self.x, self.y)
				self:remove()
			end
		--elseif collisions[i].hitstyle == 3 then
		--do nothing
		end
	end
	
	if self.x < 0 or self.x > 400 or self.y < 0 or self.y > 240 then self:remove() end
end