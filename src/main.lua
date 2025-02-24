import 'CoreLibs/animator'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
--import 'CoreLibs/math'
import 'CoreLibs/timer'
import 'CoreLibs/ui'

import 'Bullet'
import 'Triangle'
import 'Enemy'
import 'WhiteBox'
import 'Powerup'
import 'melody1.wav'
import 'notopensource.wav'
import 'Boss1'


local mainmenu = playdate.getSystemMenu()

local text_overlay = gfx.image.new(400,240)
local gameover_font = gfx.font.new("fonts/Roobert-24-Medium")
local gameover_font_small = gfx.font.new("fonts/Roobert-20-Medium")
local font_small = gfx.font.new("fonts/Roobert-11-Medium")
--local gameover_text = "Game Over\nScore: "


local snd = playdate.sound
local geo = playdate.geometry

local blink_timer = 0

local melody =  playdate.sound.sampleplayer.new("melody1")
melody:setVolume(.2)
local melodyb =  playdate.sound.sampleplayer.new("notopensource")
melodyb:setVolume(.4)

local soundtrack = melodyb

local gfx = playdate.graphics
local geom = playdate.geometry
local scoretext = "Score: "
score = 0
player_alive = false
local debug = 0
local difficulty = 0
local credits = false

high_score_table = playdate.datastore.read()
high_score_table = high_score_table or {0}



local needtoundock = playdate.isCrankDocked()
local crankframe = -18
function playdate.crankUndocked()
	if needtoundock == true then
		needtoundock = false
		NewGame()
	end
end

--local imagecount = 1 --remove for release, for screenshotting

local crank_image_import, crank_import_error = playdate.graphics.imagetable.new("images/PlayDateButtons")
if crank_import_error then print(crank_import_error) end

crank_animation = {}
for i=9, 14 do
	crank_animation[i-8] = crank_image_import:getImage(i)
end

function NewGame()
	print("newgame")
	player_alive = true
	totalenemycount = 0
	boss_alive = false
	soundtrack:play(0)
	gfx.sprite.removeAll()
	triangle = NewTriangle()
	enemynumber = 0
	score = 0
	enemytimer = 0
	phase = 0
	blink_timer = 90
	new_high_score = 0
	
	if debug == 1 then
		test = Powerup(200, 120)
	end
end

if not needtoundock then
	NewGame()
end



function playdate.update()
	print("updating, needtoundock =", needtoundock)
	if needtoundock == true then
		gfx.clear()
		playdate.display.setScale(8)
		
		local frame = nil
		if crankframe < 1 then
			frame = crank_animation[1]--:draw(15,8)
		elseif crankframe <=6 then
			frame = crank_animation[crankframe]--:draw(15,8)
		else
			frame = crank_animation[6]--:draw(15,8)
		end
		
		local screenWidth, screenHeight = playdate.display.getSize()
		frame:drawAnchored(screenWidth/2+2, screenHeight/2, 0.5, 0.5)
		
		crankframe += 1
		if crankframe>26 then crankframe =-18 end
		
		-- for screenshotting, remove in release:
		
		--if imagecount < 45 then
		--	local screenshot_unscaled = playdate.graphics.getWorkingImage()
		--	local screenshot = gfx.image.new(400, 240)
		--	gfx.lockFocus(screenshot)
		--	screenshot_unscaled:scaledImage(8):draw(0, 0)
		--	gfx.unlockFocus()
		--	local destination = "/Users/xavier/Developer/Playdate Projects/imageexports/AVLauncher/"..imagecount..".png"
		--	playdate.simulator.writeToFile(screenshot, destination)
		--	
		--end
		--
		--imagecount += 1-- for screenshotting, remove in release
		--gfx.clear()
		--playdate.display.setScale(1)
		
	else
		playdate.display.setScale(1)
		gameUpdate()
	end
end
	
function gameUpdate()
	playdate.timer.updateTimers()
	gfx.clear()
	gfx.sprite.update()
	
	if debug == 1 and (playdate.buttonIsPressed( playdate.kButtonA )) then
		print("buttonA")
		NewGame()
	end--fix this, shouldn't be in update
	
	local conda = player_alive == true--fix this with a real game tracker
	local condb = boss_alive == false
	local condc = score > (100 + 1500 * phase) --this should be 300, easier for reviewing
	
	if conda and condb and condc then
		
		current_boss = BossOne()
		boss_alive = true
		current_boss.health = 100 + 100 * phase
		current_boss:moveTo(-50, 120)
		phase += 1
	end
	
	local difficulty_enemy_number = 20 --hotfix
	local difficulty_enemy_timer = 100
	
	if difficulty == 1 then --easy mode
		difficulty_enemy_number = 10
		difficulty_enemy_timer = 200
	end
	
	if enemynumber <difficulty_enemy_number then
		if enemytimer < difficulty_enemy_timer then
			enemytimer += 1
		else
			enemytimer = 0
			enemynumber += 1
			if enemynumber == 5 or enemynumber == 10 or enemynumber ==20 or enemynumber ==15 then
				local enemy = White_Square()
			else
				local enemy = Enemy()
			end
		end
	end
	
	
	
	
	if debug ~= 0 then
		--local test = triangle:getCollideRect()
		--local boundsx, boundsy = triangle:getBounds()
		----print("tribound at ".. boundsx..","..boundsy)
		--
	--
		--test.x = boundsx +test.x
		--test.y = boundsy +test.y
	--
		--gfx.drawRect(test)
		--gfx.drawRect(triangle:getBounds())
		
		
		local testobject = false --change this name to variable to show collision boundaries
		
		if testobject then
			local aboundsx, aboundsy = testobject:getBounds()
			print (aboundsx..","..aboundsy)
			local testcollide = testobject:getCollideRect()
			print ("testcollide: "..testcollide.x..","..testcollide.y)
			testcollide.x = testcollide.x + aboundsx
			testcollide.y = testcollide.y + aboundsy
			
			print ("testcollide2: "..testcollide.x..","..testcollide.y)
			gfx.drawRect(testcollide)
		end
		
		playdate.drawFPS(385,0)
		
		
	end
	
	bossGraphicsUpdate()
	
	gfx.lockFocus(text_overlay)
	gfx.clear(gfx.kColorClear)
	if player_alive == true then
		font_small:drawText(scoretext..score, 1,0)
	else
		--gfx.setColor(gfx.kColorWhite)
		--gfx.fillRect(97, 99, 220, 20)
		
		gameover_font:drawTextAligned("Game Over", 200, 100, kTextAlignment.center)
		gameover_font_small:drawTextAligned("Score: "..score, 200, 126, kTextAlignment.center)
		
		
		
		if blink_timer >40 then
			blink_timer -= 1
		elseif blink_timer > 20 then
			--gfx.setColor(gfx.kColorWhite)
			--gfx.fillRect(97, 200, 100, 20)
			
			gameover_font_small:drawTextAligned("Press A", 200, 200, kTextAlignment.center)
			
			blink_timer -= 1
		elseif blink_timer > 0 then
			blink_timer -= 1
		else
			blink_timer = 40
		end
		font_small:drawText("High Score: "..high_score_table[1], 1,0)
		if new_high_score == 1 then
			--the following cycles the text every 10 frames
			weird_math_thing = math.floor(blink_timer/10)/2
			if math.floor(weird_math_thing) < weird_math_thing then
				font_small:drawText("New High Score!", 1,17)
			end
		end
	end
	gfx.unlockFocus()
	
	
	gfx.setImageDrawMode(gfx.kDrawModeNXOR)--this sucks, fix this later
	text_overlay:draw(0,0)
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
	
	if credits then
		gfx.clear()
		--gameover_font:drawTextAligned("Credits", 200, 0, kTextAlignment.center)
		creditstext = [[
Game By CoronaVitae

Main Theme
'Videogame Theme'
by The J. Arthur Keenes Band
Thank you to Dan McLay

Special Thanks to SeaofGlitter
]]
		font_small:drawTextAligned(creditstext, 200, 30, kTextAlignment.center)
		
	end
end

function playdate.downButtonDown()
	if debug == 1 then
		print("down")
		soundtrack:stop()
		
		if soundtrack == melody then
			soundtrack = melodyb
			soundtrack:play(0)
		else
			soundtrack = melody
			soundtrack:play(0)
		end
	end
	
end

function playdate.AButtonDown()
	if not needtoundock then
		if debug == 1 then
			print("buttonA")
			NewGame()
		elseif player_alive == false then
			NewGame()
		end--fix this, shouldn't be in update
		
		if playdate.buttonIsPressed("b") then
			if playdate.buttonIsPressed("down") then
				debug = 1
				local menuitem2, menuerror2 = mainmenu:addMenuItem("Clear Save", clearSave)
			end
		end
	end
	
	credits = false
end

function playdate.BButtonDown()
	if debug == 1 then
		testobject = BossOne()
		current_boss = testobject
		boss_alive = true
		testobject:moveTo(-50, 120)
		
		delete = Powerup(200, 120)
	end
end

function playdate.leftButtonDown()
	if debug == 1 then
		delete = Powerup(200, 120)
	end
end

function toggleDebug(value)--this was used for a menu item, now defunct
	if value == true then
		debug = 1
		soundtrack:stop()
	else
		debug = 0
		soundtrack:play()
	end
end
--local menuitem, menuerror = mainmenu:addCheckmarkMenuItem("Debug", toggleDebug)

local function setDifficulty(menu_argument)
	if menu_argument == "Normal" then
		difficulty = 1 --easy mode
	else
		difficulty = 0 --hard mode
	end
end




function bossGraphicsUpdate()
	if boss_alive then
		if current_boss.bossGraphics then current_boss:bossGraphics() end
	end
end

function playdate.keyPressed(key)
	
	if key == "d" then
		debug = 1
		local menuitem2, menuerror2 = mainmenu:addMenuItem("Clear Save", clearSave)
		print("!msg test")
	end
	
end

function clearSave()
	if not playdate.datastore.delete() then
		print("No save data to delete.")
	else
		high_score_table = {0}
	end
	
end

--local menuitem2, menuerror2 = mainmenu:addMenuItem("New Game", NewGame)



function roll_credits()
	credits = true
	player_alive = false
	gfx.sprite.removeAll()
end

local menuitem3, menuerror3 = mainmenu:addOptionsMenuItem("Mode:", {"Hard", "Normal"}, setDifficulty)
local menuitem4, menuerror4 = mainmenu:addMenuItem("Credits", roll_credits)

function playdate.serialMessageReceived(message)
	scoretext = message.." "
end