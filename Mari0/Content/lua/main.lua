
function love.load()
	require "class"
	require "variables"
	require "quad"
	require "entity"
	require "menu"
	require "hatconfigs"
	require "bighatconfigs"
	require "game"
	require "levelscreen"
	require "screenboundary"
	require "tile"
	require "goomba"
	require "mario"
	require "physics"

	width = 25
	graphicspack = "smb"
	yoffset = 0

	if not pcall(loadconfig) then
		players = 1
		defaultconfig()
	end

	saveconfig()

	changescale(scale)
	love.window.setTitle( "Mari0" )

	--Backgroundcolors
	backgroundcolor = {}
	backgroundcolor[1] = { 92/255, 148/255, 252/255}
	backgroundcolor[2] = {  0/255,   0/255,   0/255}
	backgroundcolor[3] = { 32/255,  56/255, 236/255}

	fontimage = love.graphics.newImage("graphics/SMB/font.png")
	fontglyphs = "0123456789abcdefghijklmnopqrstuvwxyz.:/,'C-_>* !{}?"
	fontquads = {}
	for i = 1, string.len(fontglyphs) do
		fontquads[string.sub(fontglyphs, i, i)] = love.graphics.newQuad((i-1)*8, 0, 8, 8, 512, 8)
	end

	love.graphics.clear()

	playertypei = 1
	playertype = playertypelist[playertypei] --portal, minecraft

	uispace = math.floor(width*16*scale/4)
	guielements = {}

	--IMAGES--
	menuselection = love.graphics.newImage("graphics/" .. graphicspack .. "/menuselect.png")
	mappackback = love.graphics.newImage("graphics/" .. graphicspack .. "/mappackback.png")
	mappacknoicon = love.graphics.newImage("graphics/" .. graphicspack .. "/mappacknoicon.png")
	mappackoverlay = love.graphics.newImage("graphics/" .. graphicspack .. "/mappackoverlay.png")
	mappackhighlight = love.graphics.newImage("graphics/" .. graphicspack .. "/mappackhighlight.png")

	mappackscrollbar = love.graphics.newImage("graphics/" .. graphicspack .. "/mappackscrollbar.png")

	--tiles
	smbtilesimg = love.graphics.newImage("graphics/" .. graphicspack .. "/smbtiles.png")
	portaltilesimg = love.graphics.newImage("graphics/" .. graphicspack .. "/portaltiles.png")
	entitiesimg = love.graphics.newImage("graphics/" .. graphicspack .. "/entities.png")
	tilequads = {}

	rgblist = {}

	--add smb tiles
	local imgwidth, imgheight = smbtilesimg:getWidth(), smbtilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("graphics/" .. graphicspack .. "/smbtiles.png")

	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(smbtilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r, g, b})
		end
	end
	smbtilecount = width*height

	--add portal tiles
	local imgwidth, imgheight = portaltilesimg:getWidth(), portaltilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("graphics/" .. graphicspack .. "/portaltiles.png")

	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(portaltilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r, g, b})
		end
	end
	portaltilecount = width*height

	--add entities
	entityquads = {}
	local imgwidth, imgheight = entitiesimg:getWidth(), entitiesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("graphics/" .. graphicspack .. "/entities.png")

	for y = 1, height do
		for x = 1, width do
			table.insert(entityquads, entity:new(entitiesimg, x, y, imgwidth, imgheight))
			entityquads[#entityquads]:sett(#entityquads)
		end
	end
	entitiescount = width*height

	fontimage2 = love.graphics.newImage("graphics/" .. graphicspack .. "/smallfont.png")
	numberglyphs = "012458"
	font2quads = {}
	for i = 1, 6 do
		font2quads[string.sub(numberglyphs, i, i)] = love.graphics.newQuad((i-1)*4, 0, 4, 8, 32, 8)
	end

	oneuptextimage = love.graphics.newImage("graphics/" .. graphicspack .. "/oneuptext.png")

	blockdebrisimage = love.graphics.newImage("graphics/" .. graphicspack .. "/blockdebris.png")
	blockdebrisquads = {}
	for y = 1, 4 do
		blockdebrisquads[y] = {}
		for x = 1, 2 do
			blockdebrisquads[y][x] = love.graphics.newQuad((x-1)*8, (y-1)*8, 8, 8, 16, 32)
		end
	end

	coinblockanimationimage = love.graphics.newImage("graphics/" .. graphicspack .. "/coinblockanimation.png")
	coinblockanimationquads = {}
	for i = 1, 30 do
		coinblockanimationquads[i] = love.graphics.newQuad((i-1)*8, 0, 8, 52, 256, 64)
	end

	coinanimationimage = love.graphics.newImage("graphics/" .. graphicspack .. "/coinanimation.png")
	coinanimationquads = {}
	for j = 1, 4 do
		coinanimationquads[j] = {}
		for i = 1, 3 do
			coinanimationquads[j][i] = love.graphics.newQuad((i-1)*5, (j-1)*8, 5, 8, 16, 32)
		end
	end

	--coinblock
	coinblockimage = love.graphics.newImage("graphics/" .. graphicspack .. "/coinblock.png")
	coinblockquads = {}
	for j = 1, 4 do
		coinblockquads[j] = {}
		for i = 1, 3 do
			coinblockquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 64, 64)
		end
	end

	--coin
	coinimage = love.graphics.newImage("graphics/" .. graphicspack .. "/coin.png")
	coinquads = {}
	for j = 1, 4 do
		coinquads[j] = {}
		for i = 1, 3 do
			coinquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 64, 64)
		end
	end

	--axe
	axeimg = love.graphics.newImage("graphics/" .. graphicspack .. "/axe.png")
	axequads = {}
	for i = 1, 3 do
		axequads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end

	--spring
	springimg = love.graphics.newImage("graphics/" .. graphicspack .. "/spring.png")
	springquads = {}
	for i = 1, 4 do
		springquads[i] = {}
		for j = 1, 3 do
			springquads[i][j] = love.graphics.newQuad((j-1)*16, (i-1)*31, 16, 31, 48, 124)
		end
	end

	--toad
	toadimg = love.graphics.newImage("graphics/" .. graphicspack .. "/toad.png")

	--queen I mean princess
	peachimg = love.graphics.newImage("graphics/" .. graphicspack .. "/peach.png")

	platformimg = love.graphics.newImage("graphics/" .. graphicspack .. "/platform.png")
	platformbonusimg = love.graphics.newImage("graphics/" .. graphicspack .. "/platformbonus.png")

	seesawimg = love.graphics.newImage("graphics/" .. graphicspack .. "/seesaw.png")
	seesawquad = {}
	for i = 1, 4 do
		seesawquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end

	titleimage = love.graphics.newImage("graphics/" .. graphicspack .. "/title.png")
	playerselectimg = love.graphics.newImage("graphics/" .. graphicspack .. "/playerselectarrow.png")

	starimg = love.graphics.newImage("graphics/" .. graphicspack .. "/star.png")
	starquad = {}
	for i = 1, 4 do
		starquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end

	flowerimg = love.graphics.newImage("graphics/" .. graphicspack .. "/flower.png")
	flowerquad = {}
	for i = 1, 4 do
		flowerquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end

	fireballimg = love.graphics.newImage("graphics/" .. graphicspack .. "/fireball.png")
	fireballquad = {}
	for i = 1, 4 do
		fireballquad[i] = love.graphics.newQuad((i-1)*8, 0, 8, 8, 80, 16)
	end

	for i = 5, 7 do
		fireballquad[i] = love.graphics.newQuad((i-5)*16+32, 0, 16, 16, 80, 16)
	end

	vineimg = love.graphics.newImage("graphics/" .. graphicspack .. "/vine.png")
	vinequad = {}
	for i = 1, 4 do
		vinequad[i] = {}
		for j = 1, 2 do
			vinequad[i][j] = love.graphics.newQuad((j-1)*16, (i-1)*16, 16, 16, 32, 64)
		end
	end

	--enemies
	goombaimage = love.graphics.newImage("graphics/" .. graphicspack .. "/goomba.png")
	goombaquad = {}

	for y = 1, 4 do
		goombaquad[y] = {}
		for x = 1, 2 do
			goombaquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end

	spikeyimg = love.graphics.newImage("graphics/" .. graphicspack .. "/spikey.png")

	spikeyquad = {}
	for x = 1, 4 do
		spikeyquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 16, 64, 16)
	end

	lakitoimg = love.graphics.newImage("graphics/" .. graphicspack .. "/lakito.png")
	lakitoquad = {}
	for x = 1, 2 do
		lakitoquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 24, 32, 24)
	end

	koopaimage = love.graphics.newImage("graphics/" .. graphicspack .. "/koopa.png")
	kooparedimage = love.graphics.newImage("graphics/" .. graphicspack .. "/koopared.png")
	beetleimage = love.graphics.newImage("graphics/" .. graphicspack .. "/beetle.png")
	koopaquad = {}

	for y = 1, 4 do
		koopaquad[y] = {}
		for x = 1, 5 do
			koopaquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*24, 16, 24, 128, 128)
		end
	end

	cheepcheepimg = love.graphics.newImage("graphics/" .. graphicspack .. "/cheepcheep.png")
	cheepcheepquad = {}

	cheepcheepquad[1] = {}
	cheepcheepquad[1][1] = love.graphics.newQuad(0, 0, 16, 16, 32, 32)
	cheepcheepquad[1][2] = love.graphics.newQuad(16, 0, 16, 16, 32, 32)

	cheepcheepquad[2] = {}
	cheepcheepquad[2][1] = love.graphics.newQuad(0, 16, 16, 16, 32, 32)
	cheepcheepquad[2][2] = love.graphics.newQuad(16, 16, 16, 16, 32, 32)

	squidimg = love.graphics.newImage("graphics/" .. graphicspack .. "/squid.png")
	squidquad = {}
	for x = 1, 2 do
		squidquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 24, 32, 32)
	end

	bulletbillimg = love.graphics.newImage("graphics/" .. graphicspack .. "/bulletbill.png")
	bulletbillquad = {}

	for y = 1, 4 do
		bulletbillquad[y] = love.graphics.newQuad(0, (y-1)*16, 16, 16, 16, 64)
	end

	hammerbrosimg = love.graphics.newImage("graphics/" .. graphicspack .. "/hammerbros.png")
	hammerbrosquad = {}
	for y = 1, 4 do
		hammerbrosquad[y] = {}
		for x = 1, 4 do
			hammerbrosquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*34, 16, 34, 64, 256)
		end
	end

	hammerimg = love.graphics.newImage("graphics/" .. graphicspack .. "/hammer.png")
	hammerquad = {}
	for j = 1, 4 do
		hammerquad[j] = {}
		for i = 1, 4 do
			hammerquad[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 64, 64)
		end
	end

	plantimg = love.graphics.newImage("graphics/" .. graphicspack .. "/plant.png")
	plantquads = {}
	for j = 1, 4 do
		plantquads[j] = {}
		for i = 1, 2 do
			plantquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*23, 16, 23, 32, 128)
		end
	end

	fireimg = love.graphics.newImage("graphics/" .. graphicspack .. "/fire.png")
	firequad = {love.graphics.newQuad(0, 0, 24, 8, 48, 8), love.graphics.newQuad(24, 0, 24, 8, 48, 8)}

	upfireimg = love.graphics.newImage("graphics/" .. graphicspack .. "/upfire.png")

	bowserimg = love.graphics.newImage("graphics/" .. graphicspack .. "/bowser.png")
	bowserquad = {}
	bowserquad[1] = {love.graphics.newQuad(0, 0, 32, 32, 64, 64), love.graphics.newQuad(32, 0, 32, 32, 64, 64)}
	bowserquad[2] = {love.graphics.newQuad(0, 32, 32, 32, 64, 64), love.graphics.newQuad(32, 32, 32, 32, 64, 64)}

	decoysimg = love.graphics.newImage("graphics/" .. graphicspack .. "/decoys.png")
	decoysquad = {}
	for y = 1, 7 do
		decoysquad[y] = love.graphics.newQuad(0, (y-1)*32, 32, 32, 64, 256)
	end

	boximage = love.graphics.newImage("graphics/" .. graphicspack .. "/box.png")
	boxquad = love.graphics.newQuad(0, 0, 12, 12, 16, 16)

	flagimg = love.graphics.newImage("graphics/" .. graphicspack .. "/flag.png")
	castleflagimg = love.graphics.newImage("graphics/" .. graphicspack .. "/castleflag.png")

	bubbleimg = love.graphics.newImage("graphics/" .. graphicspack .. "/bubble.png")

	--eh
	rainboomimg = love.graphics.newImage("graphics/rainboom.png")
	rainboomquad = {}
	for x = 1, 7 do
		for y = 1, 7 do
			rainboomquad[x+(y-1)*7] = love.graphics.newQuad((x-1)*204, (y-1)*182, 204, 182, 1428, 1274)
		end
	end

	logo = love.graphics.newImage("graphics/stabyourself.png")
	logoblood = love.graphics.newImage("graphics/stabyourselfblood.png")

	--GUI
	checkboximg = love.graphics.newImage("graphics/GUI/checkbox.png")
	checkboxquad = {{love.graphics.newQuad(0, 0, 9, 9, 18, 18), love.graphics.newQuad(9, 0, 9, 9, 18, 18)}, {love.graphics.newQuad(0, 9, 9, 9, 18, 18), love.graphics.newQuad(9, 9, 9, 9, 18, 18)}}

	dropdownarrowimg = love.graphics.newImage("graphics/GUI/dropdownarrow.png")

	--players
	marioanimations = {}
	marioanimations[0] = love.graphics.newImage("graphics/" .. graphicspack .. "/player/marioanimations0.png")
	marioanimations[1] = love.graphics.newImage("graphics/" .. graphicspack .. "/player/marioanimations1.png")
	marioanimations[2] = love.graphics.newImage("graphics/" .. graphicspack .. "/player/marioanimations2.png")
	marioanimations[3] = love.graphics.newImage("graphics/" .. graphicspack .. "/player/marioanimations3.png")

	minecraftanimations = {}
	minecraftanimations[0] = love.graphics.newImage("graphics/Minecraft/marioanimations0.png")
	minecraftanimations[1] = love.graphics.newImage("graphics/Minecraft/marioanimations1.png")
	minecraftanimations[2] = love.graphics.newImage("graphics/Minecraft/marioanimations2.png")
	minecraftanimations[3] = love.graphics.newImage("graphics/Minecraft/marioanimations3.png")

	marioidle = {}
	mariorun = {}
	marioslide = {}
	mariojump = {}
	mariodie = {}
	marioclimb = {}
	marioswim = {}
	mariogrow = {}

	for i = 1, 5 do
		marioidle[i] = love.graphics.newQuad(0, (i-1)*20, 20, 20, 512, 128)

		mariorun[i] = {}
		mariorun[i][1] = love.graphics.newQuad(20, (i-1)*20, 20, 20, 512, 128)
		mariorun[i][2] = love.graphics.newQuad(40, (i-1)*20, 20, 20, 512, 128)
		mariorun[i][3] = love.graphics.newQuad(60, (i-1)*20, 20, 20, 512, 128)

		marioslide[i] = love.graphics.newQuad(80, (i-1)*20, 20, 20, 512, 128)
		mariojump[i] = love.graphics.newQuad(100, (i-1)*20, 20, 20, 512, 128)
		mariodie[i] = love.graphics.newQuad(120, (i-1)*20, 20, 20, 512, 128)

		marioclimb[i] = {}
		marioclimb[i][1] = love.graphics.newQuad(140, (i-1)*20, 20, 20, 512, 128)
		marioclimb[i][2] = love.graphics.newQuad(160, (i-1)*20, 20, 20, 512, 128)

		marioswim[i] = {}
		marioswim[i][1] = love.graphics.newQuad(180, (i-1)*20, 20, 20, 512, 128)
		marioswim[i][2] = love.graphics.newQuad(200, (i-1)*20, 20, 20, 512, 128)

		mariogrow[i] = love.graphics.newQuad(260, 0, 20, 24, 512, 128)
	end


	bigmarioanimations = {}
	bigmarioanimations[0] = love.graphics.newImage("graphics/" .. graphicspack .. "/player/bigmarioanimations0.png")
	bigmarioanimations[1] = love.graphics.newImage("graphics/" .. graphicspack .. "/player/bigmarioanimations1.png")
	bigmarioanimations[2] = love.graphics.newImage("graphics/" .. graphicspack .. "/player/bigmarioanimations2.png")
	bigmarioanimations[3] = love.graphics.newImage("graphics/" .. graphicspack .. "/player/bigmarioanimations3.png")

	bigminecraftanimations = {}
	bigminecraftanimations[0] = love.graphics.newImage("graphics/Minecraft/bigmarioanimations0.png")
	bigminecraftanimations[1] = love.graphics.newImage("graphics/Minecraft/bigmarioanimations1.png")
	bigminecraftanimations[2] = love.graphics.newImage("graphics/Minecraft/bigmarioanimations2.png")
	bigminecraftanimations[3] = love.graphics.newImage("graphics/Minecraft/bigmarioanimations3.png")

	bigmarioidle = {}
	bigmariorun = {}
	bigmarioslide = {}
	bigmariojump = {}
	bigmariofire = {}
	bigmarioclimb = {}
	bigmarioswim = {}
	bigmarioduck = {} --hehe duck.

	for i = 1, 5 do
		bigmarioidle[i] = love.graphics.newQuad(0, (i-1)*36, 20, 36, 512, 256)

		bigmariorun[i] = {}
		bigmariorun[i][1] = love.graphics.newQuad(20, (i-1)*36, 20, 36, 512, 256)
		bigmariorun[i][2] = love.graphics.newQuad(40, (i-1)*36, 20, 36, 512, 256)
		bigmariorun[i][3] = love.graphics.newQuad(60, (i-1)*36, 20, 36, 512, 256)

		bigmarioslide[i] = love.graphics.newQuad(80, (i-1)*36, 20, 36, 512, 256)
		bigmariojump[i] = love.graphics.newQuad(100, (i-1)*36, 20, 36, 512, 256)
		bigmariofire[i] = love.graphics.newQuad(120, (i-1)*36, 20, 36, 512, 256)

		bigmarioclimb[i] = {}
		bigmarioclimb[i][1] = love.graphics.newQuad(140, (i-1)*36, 20, 36, 512, 256)
		bigmarioclimb[i][2] = love.graphics.newQuad(160, (i-1)*36, 20, 36, 512, 256)

		bigmarioswim[i] = {}
		bigmarioswim[i][1] = love.graphics.newQuad(180, (i-1)*36, 20, 36, 512, 256)
		bigmarioswim[i][2] = love.graphics.newQuad(200, (i-1)*36, 20, 36, 512, 256)

		bigmarioduck[i] = love.graphics.newQuad(260, (i-1)*36, 20, 36, 512, 256)
	end

	--optionsmenu
	skinpuppet = {}
	secondskinpuppet = {}
	for i = 0, 3 do
		skinpuppet[i] = love.graphics.newImage("graphics/" .. graphicspack .. "/options/skin" .. i .. ".png")
		secondskinpuppet[i] = love.graphics.newImage("graphics/" .. graphicspack .. "/options/secondskin" .. i .. ".png")
	end

	--menu_load()
	game_load()
end

function love.update(dt)
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
		menu_update(dt)
	elseif gamestate == "levelscreen" or gamestate == "gameover" or gamestate == "sublevelscreen" or gamestate == "mappackfinished" then
		levelscreen_update(dt)
	elseif gamestate == "game" then
		game_update(dt)
	end
end

function love.draw()
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
		menu_draw()
	elseif gamestate == "levelscreen" or gamestate == "gameover" or gamestate == "mappackfinished" then
		levelscreen_draw()
	elseif gamestate == "game" then
		game_draw()
	end

	love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key, unicode)
--	if keyprompt then
--		keypromptenter("key", key)
--		return
--	end

	for i, v in pairs(guielements) do
		if v:keypress(key) then
			return
		end
	end

	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
		--konami code
		if key == konami[konamii] then
			konamii = konamii + 1
			if konamii == #konami+1 then
				playsound(konamisound)
				gamefinished = true
				saveconfig()
				konamii = 1
			end
		else
			konamii = 1
		end
		menu_keypressed(key, unicode)
	elseif gamestate == "game" then
		game_keypressed(key, unicode)
	end
end

function love.keyreleased(key, unicode)
	if gamestate == "menu" or gamestate == "options" then
		menu_keyreleased(key, unicode)
	elseif gamestate == "game" then
		game_keyreleased(key, unicode)
	end
end

function string:split(delimiter)
	local result = {}
	local from  = 1
	local delim_from, delim_to = string.find( self, delimiter, from  )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from  )
	end
	table.insert( result, string.sub( self, from  ) )
	return result
end

function properprint(s, x, y)
	local startx = x
	for i = 1, string.len(tostring(s)) do
		local char = string.sub(s, i, i)
		if char == "|" then
			x = startx-((i)*8)*scale
			y = y + 10*scale
		elseif fontquads[char] then
			love.graphics.draw(fontimage, fontquads[char], x+((i-1)*8)*scale, y, 0, scale, scale)
		end
	end
end

function getaveragecolor(imgdata, cox, coy)
	local xstart = (cox-1)*17
	local ystart = (coy-1)*17

	local r, g, b = 0, 0, 0

	local count = 0

	for x = xstart, xstart+15 do
		for y = ystart, ystart+15 do
			local pr, pg, pb, a = imgdata:getPixel(x, y)
			if a > 0.5 then
				r, g, b = r+pr, g+pg, b+pb
				count = count + 1
			end
		end
	end

	r, g, b = r/count, g/count, b/count

	return r, g, b
end

function changescale(s)
	scale = s

	uispace = math.floor(width*16*scale/4)
	love.window.setMode(width*16*scale, 224*scale, {fullscreen=false, vsync=vsync}) --27x14 blocks (15 blocks actual height)

	gamewidth = love.graphics.getWidth()
	gameheight = love.graphics.getHeight()

	if shaders then
		shaders:refresh()
	end
end

function loadconfig()
	players = 1
	defaultconfig()

	if not love.filesystem.getInfo("options.txt") then
		return
	end

	local s = love.filesystem.read("options.txt")
	s1 = s:split(";")
	for i = 1, #s1-1 do
		s2 = s1[i]:split(":")

		if s2[1] == "playercontrols" then
			if controls[tonumber(s2[2])] == nil then
				controls[tonumber(s2[2])] = {}
			end

			s3 = s2[3]:split(",")
			for j = 1, #s3 do
				s4 = s3[j]:split("-")
				controls[tonumber(s2[2])][s4[1]] = {}
				for k = 2, #s4 do
					if tonumber(s4[k]) ~= nil then
						controls[tonumber(s2[2])][s4[1]][k-1] = tonumber(s4[k])
					else
						controls[tonumber(s2[2])][s4[1]][k-1] = s4[k]
					end
				end
			end
			players = math.max(players, tonumber(s2[2]))

		elseif s2[1] == "playercolors" then
			if mariocolors[tonumber(s2[2])] == nil then
				mariocolors[tonumber(s2[2])] = {}
			end
			s3 = s2[3]:split(",")
			mariocolors[tonumber(s2[2])] = {{tonumber(s3[1]), tonumber(s3[2]), tonumber(s3[3])}, {tonumber(s3[4]), tonumber(s3[5]), tonumber(s3[6])}, {tonumber(s3[7]), tonumber(s3[8]), tonumber(s3[9])}}

		elseif s2[1] == "portalhues" then
			if portalhues[tonumber(s2[2])] == nil then
				portalhues[tonumber(s2[2])] = {}
			end
			s3 = s2[3]:split(",")
			portalhues[tonumber(s2[2])] = {tonumber(s3[1]), tonumber(s3[2])}

		elseif s2[1] == "mariohats" then
			local playerno = tonumber(s2[2])
			mariohats[playerno] = {}

			if s2[3] == "mariohats" then --SAVING WENT WRONG OMG

			elseif s2[3] then
				s3 = s2[3]:split(",")
				for i = 1, #s3 do
					local hatno = tonumber(s3[i])
					if hatno > hatcount then
						hatno = hatcount
					end
					mariohats[playerno][i] = hatno
				end
			end

		elseif s2[1] == "scale" then
			scale = tonumber(s2[2])

		elseif s2[1] == "shader1" then
			for i = 1, #shaderlist do
				if shaderlist[i] == s2[2] then
					currentshaderi1 = i
				end
			end
		elseif s2[1] == "shader2" then
			for i = 1, #shaderlist do
				if shaderlist[i] == s2[2] then
					currentshaderi2 = i
				end
			end
		elseif s2[1] == "volume" then
			volume = tonumber(s2[2])
			love.audio.setVolume( volume )
		elseif s2[1] == "mouseowner" then
			mouseowner = tonumber(s2[2])
		elseif s2[1] == "mappack" then
			if love.filesystem.getInfo("mappacks/" .. s2[2] .. "/") then
				mappack = s2[2]
			end
		elseif s2[1] == "gamefinished" then
			gamefinished = true
		elseif s2[1] == "vsync" then
			vsync = true
		elseif s2[1] == "reachedworlds" then
			reachedworlds[s2[2]] = {}
			local s3 = s2[3]:split(",")
			for i = 1, #s3 do
				if tonumber(s3[i]) == 1 then
					reachedworlds[s2[2]][i] = true
				end
			end
		end
	end

	for i = 1, math.max(4, players) do
		portalcolor[i] = {getrainbowcolor(portalhues[i][1]), getrainbowcolor(portalhues[i][2])}
	end
	players = 1
end

function defaultconfig()
	--------------
	-- CONTORLS --
	--------------

	-- Joystick stuff:
	-- joy, #, hat, #, direction (r, u, ru, etc)
	-- joy, #, axe, #, pos/neg
	-- joy, #, but, #
	-- You cannot set Hats and Axes as the jump button. Bummer.

	mouseowner = 1

	controls = {}

	local i = 1
	controls[i] = {}
	controls[i]["right"] = {"right"}
	controls[i]["left"] = {"left"}
	controls[i]["down"] = {"down"}
	controls[i]["up"] = {"up"}
	controls[i]["run"] = {"x"}
	controls[i]["jump"] = {"z"}
	controls[i]["aimx"] = {""} --mouse aiming, so no need
	controls[i]["aimy"] = {""}
	controls[i]["portal1"] = {""}
	controls[i]["portal2"] = {""}
	controls[i]["reload"] = {"r"}
	controls[i]["use"] = {"e"}

	for i = 2, 4 do
		controls[i] = {}
		controls[i]["right"] = {"joy", i-1, "hat", 1, "r"}
		controls[i]["left"] = {"joy", i-1, "hat", 1, "l"}
		controls[i]["down"] = {"joy", i-1, "hat", 1, "d"}
		controls[i]["up"] = {"joy", i-1, "hat", 1, "u"}
		controls[i]["run"] = {"joy", i-1, "but", 3}
		controls[i]["jump"] = {"joy", i-1, "but", 1}
		controls[i]["aimx"] = {"joy", i-1, "axe", 5, "neg"}
		controls[i]["aimy"] = {"joy", i-1, "axe", 4, "neg"}
		controls[i]["portal1"] = {"joy", i-1, "but", 5}
		controls[i]["portal2"] = {"joy", i-1, "but", 6}
		controls[i]["reload"] = {"joy", i-1, "but", 4}
		controls[i]["use"] = {"joy", i-1, "but", 2}
	end

	--hats.
	mariohats = {}
	for i = 1, 4 do
		mariohats[i] = {1}
	end

	------------------
	-- MARIO COLORS --
	------------------
	--1: hat, pants (red)
	--2: shirt, shoes (brown-green)
	--3: skin (yellow-orange)

	mariocolors = {}
	mariocolors[1] = {{224/255,  32/255,   0/255}, {136/255, 112/255,   0/255}, {252/255, 152/255,  56/255}}
	mariocolors[2] = {{255/255, 255/255, 255/255}, {  0/255, 160/255,   0/255}, {252/255, 152/255,  56/255}}
	mariocolors[3] = {{  0/255,   0/255,   0/255}, {200/255,  76/255,  12/255}, {252/255, 188/255, 176/255}}
	mariocolors[4] = {{ 32/255,  56/255, 236/255}, {  0/255, 128/255, 136/255}, {252/255, 152/255,  56/255}}
	for i = 5, players do
		mariocolors[i] = mariocolors[math.random(4)]
	end

	--STARCOLORS
	starcolors = {}
	starcolors[1] = {{  0/255,   0/255,   0/255}, {200/255,  76/255,  12/255}, {252/255, 188/255, 176/255}}
	starcolors[2] = {{  0/255, 168/255,   0/255}, {252/255, 152/255,  56/255}, {252/255, 252/255, 252/255}}
	starcolors[3] = {{252/255, 216/255, 168/255}, {216/255,  40/255,   0/255}, {252/255, 152/255,  56/255}}
	starcolors[4] = {{216/255,  40/255,   0/255}, {252/255, 152/255,  56/255}, {252/255, 252/255, 252/255}}

	flowercolor = {{252/255, 216/255, 168/255}, {216/255,  40/255,   0/255}, {252/255, 152/255,  56/255}}

	--options
	scale = 3
	volume = 1
	mappack = "smb"
	vsync = true

	reachedworlds = {}
end

function saveconfig()
	local s = ""
	for i = 1, #controls do
		s = s .. "playercontrols:" .. i .. ":"
		local count = 0
		for j, k in pairs(controls[i]) do
			local c = ""
			for l = 1, #controls[i][j] do
				c = c .. controls[i][j][l]
				if l ~= #controls[i][j] then
					c = c ..  "-"
				end
			end
			s = s .. j .. "-" .. c
			count = count + 1
			if count == 12 then
				s = s .. ";"
			else
				s = s .. ","
			end
		end
	end

	for i = 1, #mariocolors do
		s = s .. "playercolors:" .. i .. ":"
		for j = 1, 3 do
			for k = 1, 3 do
				s = s .. mariocolors[i][j][k]
				if j == 3 and k == 3 then
					s = s .. ";"
				else
					s = s .. ","
				end
			end
		end
	end

	for i = 1, #mariohats do
		s = s .. "mariohats:" .. i
		if #mariohats[i] > 0 then
			s = s .. ":"
		end
		for j = 1, #mariohats[i] do
			s = s .. mariohats[i][j]
			if j == #mariohats[i] then
				s = s .. ";"
			else
				s = s .. ","
			end
		end

		if #mariohats[i] == 0 then
			s = s .. ";"
		end
	end

	s = s .. "scale:" .. scale .. ";"

	s = s .. "mappack:" .. mappack .. ";"

	if vsync then
		s = s .. "vsync;"
	end

	if gamefinished then
		s = s .. "gamefinished;"
	end

	--reached worlds
	for i, v in pairs(reachedworlds) do
		s = s .. "reachedworlds:" .. i .. ":"
		for j = 1, 8 do
			if v[j] then
				s = s .. 1
			else
				s = s .. 0
			end

			if j == 8 then
				s = s .. ";"
			else
				s = s .. ","
			end
		end
	end

	love.filesystem.write("options.txt", s)
end

function tablecontains(t, entry)
	for i, v in pairs(t) do
		if v == entry then
			return true
		end
	end
	return false
end
