--[[
	Yeah, this is a damn ugly solution, but I don't want to spend my time figuring out how to convert images to an image-table.
	TO_FIX: convert images to image-table.
]]

local gfx <const> = playdate.graphics

laser_table = {}

for i=1, 30 do
	path = "images/Laser_Table/"..tostring(i)
	laser_table[i] = playdate.graphics.image.new(path)
end

return laser_table