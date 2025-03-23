
import 'CoreLibs/animator'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'firesound.wav'
import 'laser.wav'
import 'deathsound.wav'

local gfx = playdate.graphics


local firesound =  playdate.sound.sampleplayer.new("firesound")
firesound:setVolume(.5)

local laser =  playdate.sound.sampleplayer.new("laser")
laser:setVolume(.5)

local shoot = firesound -- variable for changing with powerup

local triangle_image = gfx.image.new(30,30)
gfx.pushContext(triangle_image)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillPolygon(5, 10, 15, 30, 25, 10)
gfx.popContext()

local triangle_outline = gfx.image.new(30,30)
gfx.pushContext(triangle_outline)
	gfx.setLineWidth(1)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawPolygon(5, 10, 15, 30, 25, 10)
gfx.popContext()

local triangle_outline_white = gfx.image.new(30,30)
gfx.pushContext(triangle_outline_white)
	gfx.setLineWidth(1)
	gfx.setColor(gfx.kColorWhite)
	gfx.drawPolygon(5, 10, 15, 30, 25, 10)
gfx.popContext()

local triangle_white = gfx.image.new(30,30)
gfx.pushContext(triangle_white)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillPolygon(5, 10, 15, 30, 25, 10)
gfx.popContext()

--local triangle_flare = gfx.image.new(30,30)
--gfx.pushContext(triangle_flare)
--	gfx.setColor(gfx.kColorBlack)
--	--gfx.fillPolygon(5, 10, 15, 30, 25, 10)
--	gfx.fillPolygon(9, 4, 15, 16, 21, 4)
--	
--	--gfx.setColor(gfx.kColorClear)
--	--gfx.fillPolygon(5, 10, 15, 30, 25, 10)
--gfx.popContext()

local triangle_boost_image = {}

triangle_boost_image[12]=triangle_image	
triangle_boost_image[1] = gfx.image.new(30, 45)

temp_dither = 111
temp_dither_depth = .8
	
gfx.pushContext(triangle_boost_image[1])
	
	--triangle_image:drawFaded(0, 5+10, temp_dither_depth, temp_dither)
	--triangle_outline_white:draw(0,5)
	triangle_image:drawFaded(0, 5, 1, temp_dither)--
	triangle_outline_white:draw(0,5-10)
	--triangle_white:draw(0,5-10)
	triangle_image:drawFaded(0, 5-10, temp_dither_depth, temp_dither)
	gfx.fillPolygon(10, 15, 15, 0, 20, 15)
	--gfx.fillPolygon(5, 15, 15, 35, 25, 15)

gfx.popContext()

for i = 2, 11, 1 do
	triangle_boost_image[i] = gfx.image.new(30, 45)
	gfx.pushContext(triangle_boost_image[i])
		
		--triangle_image:drawFaded(0, 5+12-i, temp_dither_depth, temp_dither)--
		
		triangle_image:drawFaded(0, 5, 1, temp_dither)--
		triangle_outline_white:draw(0,5-9-i)
		triangle_outline_white:draw(0,5-12+i)
		--triangle_white:draw(0,5-12+i)
		triangle_image:drawFaded(0, 5-12+i, temp_dither_depth, temp_dither)
		
	gfx.popContext()
	
	if i == 12 then print("12 reached") end
end

function NewTriangle()
	local triangle = gfx.sprite.new(triangle_image)
	triangle.fireSpeed = 5 --change to set the number of frames per shot fired, fix later to allow powerups
	triangle.timer = 0
	triangle.boost_timer = 12
	triangle:moveTo(300,120)
	triangle:add()
	--ugh the bounds change as it rotates triangle:setCollideRect(10, 10, 10, 10) -- previously 0,0,20,20, this makes it easier
	triangle.turns = 90 -- fix this later, I hate that this means you aren't alligned with the crank anymore (if set to 0 then alligned, but bad place to start)
	triangle.x = 200
	triangle.y = 120
	triangle.className = "fakeclassTriangle"
	triangle.powerupTimer = 0
	triangle.powerupName = ""
	
	function triangle:update()
		self.powerupTimer -= 1
		self:checkPowerup()
		
		self.turns = self.turns + playdate.getCrankChange()
		
		local up = playdate.buttonIsPressed( playdate.kButtonUp )
		local left = playdate.buttonIsPressed( playdate.kButtonLeft )
		local right = playdate.buttonIsPressed( playdate.kButtonRight )
		local down = playdate.buttonIsPressed( playdate.kButtonDown )
		local is_boosting = up or left or right or down 
		
		local xDirection = -math.sin( math.rad(self.turns))
		local yDirection = math.cos( math.rad(self.turns))
		
		if is_boosting then --TO_FIX: this should be linked with the firing function somehow, so that we don't have two "if is_boosting"
			
			speed = 5
			if debug == 1 then
				speed = 14-self.boost_timer
			end
			
			triangle:setImage(triangle_boost_image[self.boost_timer])--self.boost_timer])
			if self.boost_timer > 1 then
				self.boost_timer -= 1
			end
		else
			if self.boost_timer < 12 then
				self.boost_timer += 3
				if self.boost_timer > 12 then
					self.boost_timer = 12
				end
			end
			triangle:setImage(triangle_boost_image[self.boost_timer])
			speed = 2
		end
		
		self:setRotation(self.turns)
		
		self.x = self.x + speed*xDirection
		self.y = self.y + speed*yDirection
		if self.x < 0 then 
			self.x = 400
		elseif self.x > 400 then
			self.x = 0
		end
		
		if self.y < 0 then
			self.y = 240
		elseif self.y > 240 then
			self.y = 0
		end
		
		local bounds = {} --this block is necessary in order to center the colliderect as the triangle rotates, which shifts the bounds of the sprite
		bounds[0], bounds[1], bounds[2], bounds[3] = self:getBounds()
		--print("bound width, height = "..bounds[2]..","..bounds[3])
		self:setCollideRect(bounds[2]/2-5, bounds[3]/2-5, 10, 10)
		
		
		self:moveTo(self.x, self.y)
		
		
		
		
		local collisions = self:overlappingSprites()
		
		for i = 1, #collisions do
			-- print("colliding with: "..collisions[i].className)
				--if self:alphaCollision(collisions[i]) then
					--print("alpha colliding with "..collisions[i].className)
					if collisions[i].collide then
						collisions[i]:collide(self)
					end
				--end
		end
		
		if (self.timer < self.fireSpeed and self.timer ~= 0) then
			
			self.timer +=1
		else 
			self.timer = 0
		end
		
		if not is_boosting then
			
			if self.timer == 0 then
				self.timer +=1
				local directionx = -math.sin( math.rad(self.turns))
				local directiony = math.cos( math.rad(self.turns))
				shoot:play()
				local bullet = Bullet:new(self.x + 15 * directionx, self.y + 15 * directiony , 10 * directionx, 10 * directiony)
			end
			
		end
		
	end
	
	function triangle:explode()
		
		player_alive = false
		laser:stop()
		
		if boss_alive then
			--print("Final Boss health = "..current_boss.health)
		end
		self:remove()
		if score > high_score_table[1] then
			high_score_table = {score}
			playdate.datastore.write(high_score_table)
			new_high_score = 1
		end
	end
	
	function triangle:powerup(name, timer)
		self.powerupTimer = timer
		self.powerupName = name
		laser:play()
	end
	
	function triangle:checkPowerup()
		if self.powerupTimer > 0 then
			if self.powerupName == "speedshot" then
				self.fireSpeed = 1
			end
			
		else
			self.fireSpeed = 5
			laser:stop()
		end
	end
	
	return triangle 
end
