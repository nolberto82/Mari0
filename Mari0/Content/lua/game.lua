function game_load(suspended)
	editormode = false
	scrollfactor = 0
	backgroundcolor = {}
	backgroundcolor[1] = {92/255, 148/255, 252/255}
	backgroundcolor[2] = {0, 0, 0}
	backgroundcolor[3] = {32/255, 56/255, 236/255}
	love.graphics.setBackgroundColor(backgroundcolor[1])

	scrollingstart = 12 --when the scrolling begins to set in (Both of these take the player who is the farthest on the left)
	scrollingcomplete = 10 --when the scrolling will be as fast as mario can run
	scrollingleftstart = 6 --See above, but for scrolling left, and it takes the player on the right-estest.
	scrollingleftcomplete = 4
	superscroll = 100

	--LINK STUFF

	mariocoincount = 0
	marioscore = 0

	--get mariolives
	mariolivecount = 3
	if love.filesystem.getInfo("mappacks/" .. mappack .. "/settings.txt") then
		local s = love.filesystem.read( "mappacks/" .. mappack .. "/settings.txt" )
		local s1 = s:split("\n")
		for j = 1, #s1 do
			local s2 = s1[j]:split("=")
			if s2[1] == "lives" then
				mariolivecount = tonumber(s2[2])
			end
		end
	end

	if mariolivecount == 0 then
		mariolivecount = false
	end

	mariolives = {}
	for i = 1, players do
		mariolives[i] = mariolivecount
	end

	mariosizes = {}
	for i = 1, players do
		mariosizes[i] = 1
	end

	autoscroll = true

	inputs = { "door", "groundlight", "wallindicator", "cubedispenser", "walltimer", "notgate", "laser", "lightbridge"}
	inputsi = {28, 29, 30, 43, 44, 45, 46, 47, 48, 67, 74, 84, 52, 53, 54, 55, 36, 37, 38, 39}

	outputs = { "button", "laserdetector", "box", "pushbutton", "walltimer", "notgate"}
	outputsi = {40, 56, 57, 58, 59, 20, 68, 69, 74, 84}

	enemies = { "goomba", "koopa", "hammerbro", "plant", "lakito", "bowser", "cheep", "squid", "flyingfish", "goombahalf", "koopahalf", "cheepwhite", "cheepred", "koopared", "kooparedhalf", "koopa", "kooparedflying", "beetle", "beetlehalf", "spikey", "spikeyhalf"}

	jumpitems = { "mushroom", "oneup" }

	marioworld = 1
	mariolevel = 1
	mariosublevel = 0
	respawnsublevel = 0

	objects = nil
	if suspended == true then
		continuegame()
	elseif suspended then
		marioworld = suspended
	end

	--remove custom sprites
	for i = smbtilecount+portaltilecount+1, #tilequads do
		tilequads[i] = nil
	end

	for i = smbtilecount+portaltilecount+1, #rgblist do
		rgblist[i] = nil
	end

	--add custom tiles
	if love.filesystem.getInfo("mappacks/" .. mappack .. "/tiles.png") then
		customtiles = true
		customtilesimg = love.graphics.newImage("mappacks/" .. mappack .. "/tiles.png")
		local imgwidth, imgheight = customtilesimg:getWidth(), customtilesimg:getHeight()
		local width = math.floor(imgwidth/17)
		local height = math.floor(imgheight/17)
		local imgdata = love.image.newImageData("mappacks/" .. mappack .. "/tiles.png")

		for y = 1, height do
			for x = 1, width do
				table.insert(tilequads, quad:new(customtilesimg, imgdata, x, y, imgwidth, imgheight))
				local r, g, b = getaveragecolor(imgdata, x, y)
				table.insert(rgblist, {r, g, b})
			end
		end
		customtilecount = width*height
	else
		customtiles = false
		customtilecount = 0
	end

	custommusic = false
	if love.filesystem.getInfo("mappacks/" .. mappack .. "/music.ogg") then
		custommusic = "mappacks/" .. mappack .. "/music.ogg"
		music:load(custommusic)
	elseif love.filesystem.getInfo("mappacks/" .. mappack .. "/music.mp3") then
		custommusic = "mappacks/" .. mappack .. "/music.mp3"
		music:load(custommusic)
	end
	print(custommusic)

	--FINALLY LOAD THE DAMN LEVEL
	levelscreen_load("initial")
end

function game_update(dt)
	--coinanimation
	coinanimation = coinanimation + dt*6.75
	while coinanimation >= 6 do
		coinanimation = coinanimation - 5
	end

	if math.floor(coinanimation) == 4 then
		coinframe = 2
	elseif math.floor(coinanimation) == 5 then
		coinframe = 1
	else
		coinframe = math.max(1, math.floor(coinanimation))
	end

	--UPDATE OBJECTS
	for i, v in pairs(objects) do
		if i ~= "tile" and i ~= "portalwall" and i ~= "screenboundary" then
			delete = {}

			for j, w in pairs(v) do
				if w.update and w:update(dt) then
					table.insert(delete, j)
				elseif w.autodelete then
					if w.x < xscroll - width or w.y > 16 then
						table.insert(delete,j)
					end
				end
			end

			if #delete > 0 then
				table.sort(delete, function(a,b) return a>b end)

				for j, w in pairs(delete) do
					table.remove(v, w)
				end
			end
		end
	end

	local oldscroll = splitxscroll[1]

	if autoscroll then
		local splitwidth = width/#splitscreen
		for split = 1, #splitscreen do
			local oldscroll = splitxscroll[split]
			--scrolling
			--LEFT
			local i = 1
			while i <= players and objects["player"][i].dead do
				i = i + 1
			end
			local fastestplayer = objects["player"][i]

			if fastestplayer then
				for i = 1, players do
					if not objects["player"][i].dead and objects["player"][i].x > fastestplayer.x then
						fastestplayer = objects["player"][i]
					end
				end

				local oldscroll = splitxscroll[split]

				if fastestplayer.x < splitxscroll[split] + scrollingleftstart and splitxscroll[split] > 0 then

					if fastestplayer.x < splitxscroll[split] + scrollingleftstart and fastestplayer.speedx < 0 then
						if fastestplayer.speedx < -scrollrate then
							splitxscroll[split] = splitxscroll[split] - scrollrate*dt
						else
							splitxscroll[split] = splitxscroll[split] + fastestplayer.speedx*dt
						end
					end

					if fastestplayer.x < splitxscroll[split] + scrollingleftcomplete then
						if fastestplayer.x > splitxscroll[split] + scrollingleftcomplete - 1/16 then
							splitxscroll[split] = splitxscroll[split] - scrollrate*dt
						else
							splitxscroll[split] = splitxscroll[split] - superscrollrate*dt
						end
					end

					if splitxscroll[split] < 0 then
						splitxscroll[split] = 0
					end
				end

				--RIGHT

				if fastestplayer.x > splitxscroll[split] + width - scrollingstart and splitxscroll[split] < mapwidth - width then
					if fastestplayer.x > splitxscroll[split] + width - scrollingstart and fastestplayer.speedx > 0.3 then
						if fastestplayer.speedx > scrollrate then
							splitxscroll[split] = splitxscroll[split] + scrollrate*dt
						else
							splitxscroll[split] = splitxscroll[split] + fastestplayer.speedx*dt
						end
					end

					if fastestplayer.x > splitxscroll[split] + width - scrollingcomplete then
						if fastestplayer.x > splitxscroll[split] + width - scrollingcomplete then
							splitxscroll[split] = splitxscroll[split] + scrollrate*dt
							if splitxscroll[split] > fastestplayer.x - (width - scrollingcomplete) then
								splitxscroll[split] = fastestplayer.x - (width - scrollingcomplete)
							end
						else
							splitxscroll[split] = fastestplayer.x - (width - scrollingcomplete)
						end
					end
				end

				--just force that shit
				if not levelfinished then
					if fastestplayer.x > splitxscroll[split] + width - scrollingcomplete then
						splitxscroll[split] = splitxscroll[split] + superscroll*dt
						if fastestplayer.x < splitxscroll[split] + width - scrollingcomplete then
							splitxscroll[split] = fastestplayer.x - width + scrollingcomplete
						end
						--splitxscroll[split] = fastestplayer.x + width - scrollingcomplete - width
					end
				end

				if splitxscroll[split] > mapwidth-width then
					splitxscroll[split] = math.max(0, mapwidth-width)
					hitrightside()
				end

				if (axex and splitxscroll[split] > axex-width and axex >= width) then
					splitxscroll[split] = axex-width
					hitrightside()
				end
			end
		end
	end

	if editormode == false and splitxscroll[1] < mapwidth-width then
		for x = math.ceil(oldscroll)+width+1, math.floor(splitxscroll[1])+width+1 do
			for y = 1, 15 do
				spawnenemy(x, y)
			end
			if goombaattack then
				local randomtable = {}
				for y = 1, 15 do
					table.insert(randomtable, y)
				end
				while #randomtable > 0 do
					local rand = math.random(#randomtable)
					if tilequads[map[x][randomtable[rand]][1]].collision then
						table.remove(randomtable, rand)
					else
						table.insert(objects["goomba"], goomba:new(x-.5, math.random(13)))
						break
					end
				end
			end
		end
	end
	--PHYSICS
	physicsupdate(dt)
end

function game_draw()
	for split = 1, #splitscreen do
		love.graphics.translate((split-1)*width*16*scale/#splitscreen, yoffset*scale)

		--This is just silly
		if earthquake > 0 then
			local colortable = {{242, 111, 51}, {251, 244, 174}, {95, 186, 76}, {29, 151, 212}, {101, 45, 135}, {238, 64, 68}}
			for i = 1, backgroundstripes do
				local r, g, b = unpack(colortable[math.fmod(i-1, 6)+1])
				local a = earthquake/rainboomearthquake*255

				love.graphics.setColor(r, g, b, a)

				local alpha = math.rad((i/backgroundstripes + math.fmod(sunrot/5, 1)) * 360)
				local point1 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}

				local alpha = math.rad(((i+1)/backgroundstripes + math.fmod(sunrot/5, 1)) * 360)
				local point2 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}

				love.graphics.polygon("fill", width*8*scale, 112*scale, point1[1], point1[2], point2[1], point2[2])
			end
		end

		love.graphics.setColor(1, 1, 1, 1)
		--tremoooor!
		if earthquake > 0 then
			tremorx = (math.random()-.5)*2*earthquake
			tremory = (math.random()-.5)*2*earthquake

			love.graphics.translate(round(tremorx), round(tremory))
		end

		local currentscissor = {(split-1)*width*16*scale/#splitscreen, 0, width*16*scale/#splitscreen, 15*16*scale}
		--love.graphics.setScissor(table.unpack(currentscissor))
		xscroll = splitxscroll[split]

		love.graphics.setColor(1, 1, 1, 1)

		local xtodraw
		if mapwidth < width+1 then
			xtodraw = math.ceil(mapwidth/#splitscreen)
		else
			if mapwidth > width and xscroll < mapwidth-width then
				xtodraw = width+1
			else
				xtodraw = width
			end
		end

		--custom background
		if custombackground then
			for i = #custombackgroundimg, 1, -1  do
				local xscroll = xscroll / (i * scrollfactor + 1)
				if reversescrollfactor() == 1 then
					xscroll = 0
				end
				for y = 1, math.ceil(15/custombackgroundheight[i]) do
					for x = 1, math.ceil(width/custombackgroundwidth[i])+1 do
						love.graphics.draw(custombackgroundimg[i], math.floor(((x-1)*custombackgroundwidth[i])*16*scale) - math.floor(math.fmod(xscroll, custombackgroundwidth[i])*16*scale), (y-1)*custombackgroundheight[i]*16*scale, 0, scale, scale)
					end
				end
			end
		end



		local lmap = map

		for y = 1, 15 do
			for x = 1, xtodraw do
				local bounceyoffset = 0
				for i, v in pairs(blockbouncex) do
					if blockbouncex[i] == math.floor(xscroll)+x and blockbouncey[i] == y then
						if blockbouncetimer[i] < blockbouncetime/2 then
							bounceyoffset = blockbouncetimer[i] / (blockbouncetime/2) * blockbounceheight
						else
							bounceyoffset = (2 - blockbouncetimer[i] / (blockbouncetime/2)) * blockbounceheight
						end
					end
				end

				local t = lmap[math.floor(xscroll)+x][y]

				local tilenumber = t[1]
				if tilequads[tilenumber].coinblock and tilequads[tilenumber].invisible == false then --coinblock
					love.graphics.draw(coinblockimage, coinblockquads[spriteset][coinframe], math.floor((x-1-math.fmod(xscroll, 1))*16*scale), ((y-1-bounceyoffset)*16-8)*scale, 0, scale, scale)
				elseif tilequads[tilenumber].coin then --coin
					love.graphics.draw(coinimage, coinquads[spriteset][coinframe], math.floor((x-1-math.fmod(xscroll, 1))*16*scale), ((y-1-bounceyoffset)*16-8)*scale, 0, scale, scale)
				elseif (tilenumber > 1) then
					love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber].quad, math.floor((x-1-math.fmod(xscroll, 1))*16*scale), ((y-1)*16-8)*scale, 0, scale, scale)
				elseif bounceyoffset ~= 0 then
					if tilequads[tilenumber].invisible == false or editormode then
						love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber].quad, math.floor((x-1-math.fmod(xscroll, 1))*16*scale), ((y-1-bounceyoffset)*16-8)*scale, 0, scale, scale)
					end
				end
			end
		end

		---UI
		love.graphics.setColor(1, 1, 1)
		love.graphics.translate(0, -yoffset*scale)
		if yoffset < 0 then
			love.graphics.translate(0, yoffset*scale)
		end

		properprint("mario", uispace*.5 - 24*scale, 8*scale)
		properprint(addzeros(marioscore, 6), uispace*0.5-24*scale, 16*scale)

		properprint("*", uispace*1.5-8*scale, 16*scale)
		
		love.graphics.draw(coinanimationimage, coinanimationquads[spriteset][coinframe], uispace*1.5-16*scale, 16*scale, 0, scale, scale)
		properprint(addzeros(mariocoincount, 2), uispace*1.5-0*scale, 16*scale)

		properprint("world", uispace*2.5 - 20*scale, 8*scale)
		properprint(marioworld .. "-" .. mariolevel, uispace*2.5 - 12*scale, 16*scale)

		properprint("time", uispace*3.5 - 16*scale, 8*scale)



		--OBJECTS
		for j, w in pairs(objects) do
			if j ~= "tile" then
				for i, v in pairs(w) do
					if v.drawable then
						love.graphics.setColor(1, 1, 1)
						local dirscale, diroffset

						if v.animationdirection == "left" then
							dirscale = -scale
							diroffset = 2
						else
							dirscale = scale
							diroffset = 1
						end

						local horscale = scale
						if v.shot then
							horscale = -scale
						end

						if j == "player" and bigmario then
							horscale = horscale * scalefactor
						end

						if type(v.graphic) == "table" then
							for k = 1, #v.graphic do
								if v.colors[k] then
									love.graphics.setColor(v.colors[k])
								else
									love.graphics.setColor(1, 1, 1)
								end
								love.graphics.draw(v.graphic[k], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor((v.y*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end

							if v.drawhat and hatoffsets[v.animationstate] then
								local offsets = {}
								if v.graphic == v.biggraphic or v.animationstate == "grow" then
									if v.animationstate == "grow" then
										offsets = hatoffsets["grow"]
									elseif v.fireanimationtimer < fireanimationtime then
										offsets = bighatoffsets["fire"]
									elseif underwater and (v.animationstate == "jumping" or v.animationstate == "falling") then
										offsets = bighatoffsets["swimming"][diroffset][v.swimframe]
									elseif v.ducking then
										offsets = bighatoffsets["ducking"]
									elseif v.animationstate == "running" or v.animationstate == "falling"  then
										offsets = bighatoffsets["running"][diroffset][v.runframe]
									elseif v.animationstate == "climbing" then
										offsets = bighatoffsets["climbing"][v.climbframe]
									else
										offsets = bighatoffsets[v.animationstate][diroffset]
									end
								else
									if underwater and (v.animationstate == "jumping" or v.animationstate == "falling") then
										offsets = hatoffsets["swimming"][diroffset][v.swimframe]
									elseif v.animationstate == "running" or v.animationstate == "falling"  then
										offsets = hatoffsets["running"][diroffset][v.runframe]
									elseif v.animationstate == "climbing" then
										offsets = hatoffsets["climbing"][v.climbframe]
									else
										offsets = hatoffsets[v.animationstate][diroffset]
									end
								end

								if #v.hats > 0 then
									local yadd = 0
									for i = 1, #v.hats do
										if v.hats[i] == 1 then
											love.graphics.setColor(v.colors[1])
										else
											love.graphics.setColor(1, 1, 1)
										end
										if v.graphic == v.biggraphic or v.animationstate == "grow" then
											love.graphics.draw(bighat[v.hats[i]].graphic, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd,"bighat")
											yadd = yadd + bighat[v.hats[i]].height
										else
											love.graphics.draw(hat[v.hats[i]].graphic, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], hat[v.hats[i]].y + offsets[2] + yadd,"bighat")
											yadd = yadd + hat[v.hats[i]].height
											--offsets = hatoffsets["running"][3]
											if v.runframe == 3 then
                                                --print(v.quadcenterX - hat[v.hats[i]].x + offsets[1])
                                            end
										end
									end
								end
							end
                            --print(math.floor(((v.x-xscroll)*16+v.offsetX)*scale) + v.quadcenterX - hat[v.hats[1]].x + offsets[1])
	
							if v.graphic[0] then
								love.graphics.setColor(1, 1, 1)
								love.graphics.draw(v.graphic[0], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor((v.y*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
						else
							if v.graphic and v.quad then
								love.graphics.draw(v.graphic, v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor((v.y*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
						end
					end
				end
			end
		end

		love.graphics.setColor(1, 1, 1)
	end
end

function startlevel(level)
	skipupdate = true
	love.audio.stop()

	local sublevel = false
	if type(level) == "number" then
		sublevel = true
	end

	if sublevel then
		prevsublevel = mariosublevel
		mariosublevel = level
		if level ~= 0 then
			level = marioworld .. "-" .. mariolevel .. "_" .. level
		else
			level = marioworld .. "-" .. mariolevel
		end
	else
		mariosublevel = 0
		prevsublevel = false
		mariotime = 400
	end

	--MISC VARS
	everyonedead = false
	levelfinished = false
	coinanimation = 1
	flagx = false
	levelfinishtype = nil
	firestartx = false
	firestarted = false
	firedelay = math.random(4)
	flyingfishdelay = 1
	flyingfishstarted = false
	flyingfishstartx = false
	flyingfishendx = false
	bulletbilldelay = 1
	bulletbillstarted = false
	bulletbillstartx = false
	bulletbillendx = false
	firetimer = firedelay
	flyingfishtimer = flyingfishdelay
	bulletbilltimer = bulletbilldelay
	axex = false
	axey = false
	lakitoendx = false
	lakitoend = false
	noupdate = false
	xscroll = 0
	splitscreen = {{}}
	checkpoints = {}
	checkpointpoints = {}
	repeatX = 0
	lastrepeat = 0
	displaywarpzonetext = false
	for i = 1, players do
		table.insert(splitscreen[1], i)
	end
	checkpointi = 0
	mazestarts = {}
	mazeends = {}
	mazesolved = {}
	mazesolved[0] = true
	mazeinprogress = false
	earthquake = 0
	sunrot = 0
	gelcannontimer = 0
	pausemenuselected = 1
	coinblocktimers = {}

	portaldelay = {}
	for i = 1, players do
		portaldelay[i] = 0
	end

	--Minecraft
	breakingblockX = false
	breakingblockY = false
	breakingblockprogress = 0

	--class tables
	coinblockanimations = {}
	scrollingscores = {}
	portalparticles = {}
	portalprojectiles = {}
	emancipationgrills = {}
	platformspawners = {}
	rocketlaunchers = {}
	userects = {}
	blockdebristable = {}
	fireworks = {}
	seesaws = {}
	bubbles = {}
	rainbooms = {}
	miniblocks = {}
	inventory = {}
	for i = 1, 9 do
		inventory[i] = {}
	end
	mccurrentblock = 1

	blockbouncetimer = {}
	blockbouncex = {}
	blockbouncey = {}
	blockbouncecontent = {}
	blockbouncecontent2 = {}
	warpzonenumbers = {}

	objects = {}
	objects["player"] = {}
	objects["portalwall"] = {}
	objects["tile"] = {}
	objects["goomba"] = {}
	objects["koopa"] = {}
	objects["mushroom"] = {}
	objects["flower"] = {}
	objects["oneup"] = {}
	objects["star"] = {}
	objects["vine"] = {}
	objects["box"] = {}
	objects["door"] = {}
	objects["button"] = {}
	objects["groundlight"] = {}
	objects["wallindicator"] = {}
	objects["walltimer"] = {}
	objects["notgate"] = {}
	objects["lightbridge"] = {}
	objects["lightbridgebody"] = {}
	objects["faithplate"] = {}
	objects["laser"] = {}
	objects["laserdetector"] = {}
	objects["gel"] = {}
	objects["geldispenser"] = {}
	objects["cubedispenser"] = {}
	objects["pushbutton"] = {}
	objects["bulletbill"] = {}
	objects["hammerbro"] = {}
	objects["hammer"] = {}
	objects["fireball"] = {}
	objects["platform"] = {}
	objects["platformspawner"] = {}
	objects["plant"] = {}
	objects["castlefire"] = {}
	objects["castlefirefire"] = {}
	objects["fire"] = {}
	objects["bowser"] = {}
	objects["spring"] = {}
	objects["cheep"] = {}
	objects["flyingfish"] = {}
	objects["upfire"] = {}
	objects["seesawplatform"] = {}
	objects["lakito"] = {}
	objects["squid"] = {}

	objects["screenboundary"] = {}
	objects["screenboundary"]["left"] = screenboundary:new(0)

	splitxscroll = {0}

	startx = 3
	starty = 13
	pipestartx = nil
	pipestarty = nil
	animation = nil

	enemiesspawned = {}

	intermission = false
	haswarpzone = false
	underwater = false
	bonusstage = false
	custombackground = false
	mariotimelimit = 400
	spriteset = 1
	--LOAD THE MAP
	if loadmap(level) == false then --make one up
		mapwidth = width
		map = {}
		for x = 1, width do
			map[x] = {}
			for y = 1, 15 do
				if y > 13 then
					map[x][y] = {2}
					objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
					map[x][y]["gels"] = {}
				else
					map[x][y] = {1}
					map[x][y]["gels"] = {}
				end
			end
		end
	else
		if sublevel == false and mariosublevel ~= 0 then
			level = marioworld .. "-" .. mariolevel
			mariosublevel = 0
			loadmap(level)
		end
	end

	objects["screenboundary"]["right"] = screenboundary:new(mapwidth)

	if flagx then
		objects["screenboundary"]["flag"] = screenboundary:new(flagx+6/16)
	end

	if axex then
		objects["screenboundary"]["axe"] = screenboundary:new(axex+1)
	end

	if intermission then
		animation = "intermission"
	end

	if not sublevel then
		mariotime = mariotimelimit
	end

	--Maze setup
	--check every block between every start/end pair to see how many gates it contains
	if #mazestarts == #mazeends then
		mazegates = {}
		for i = 1, #mazestarts do
			local maxgate = 1
			for x = mazestarts[i], mazeends[i] do
				for y = 1, 15 do
					if map[x][y][2] and entityquads[map[x][y][2]].t == "mazegate" then
						if tonumber(map[x][y][3]) > maxgate then
							maxgate = tonumber(map[x][y][3])
						end
					end
				end
			end
			mazegates[i] = maxgate
		end
	else
		print("Mazenumber doesn't fit!")
	end

	--background
	love.graphics.setBackgroundColor(backgroundcolor[background])

	--check if it's a bonusstage (boooooooonus!)
	if bonusstage then
		animation = "vinestart"
	end

	--set startx to checkpoint
	if checkpointx and checkcheckpoint then
		startx = checkpointx
		starty = checkpointpoints[checkpointx] or 13

		--clear enemies from spawning near
		for y = 1, 15 do
			for x = startx-8, startx+8 do
				if inmap(x, y) and #map[x][y] > 1 then
					if tablecontains(enemies, entityquads[map[x][y][2]].t) then
						table.insert(enemiesspawned, {x, y})
					end
				end
			end
		end

		--find which i it is
		for i = 1, #checkpoints do
			if checkpointx == checkpoints[i] then
				checkpointi = i
			end
		end
	end

	--set startx to pipestart
	if pipestartx then
		startx = pipestartx-1
		starty = pipestarty
		--check if startpos is a colliding block
		if tilequads[map[startx][starty][1]].collision then
			animation = "pipeup"
		end
	end

	splitxscroll = {startx-scrollingleftcomplete-2}
	if splitxscroll[1] > mapwidth - width then
		splitxscroll[1] = mapwidth - width
	end

	if splitxscroll[1] < 0 then
		splitxscroll[1] = 0
	end

	--ADD ENEMIES ON START SCREEN
	if editormode == false then
		local xtodo = width+1
		if mapwidth < width+1 then
			xtodo = mapwidth
		end
		print(true)
		for x = math.floor(splitxscroll[1]), math.floor(splitxscroll[1])+xtodo do
			for y = 1, 15 do
				spawnenemy(x, y)
			end
		end
	end

	--add the players
	local mul = 0.5
	if mariosublevel ~= 0 or prevsublevel ~= false then
		mul = 2/16
	end

	objects["player"] = {}

	for i = 1, players do
		if startx then
			objects["player"][i] = mario:new(startx + (i-1)*mul-6/16, starty-1, i, animation, mariosizes[i], playertype)
		else
			objects["player"][i] = mario:new(1.5 + (i-1)*mul-6/16+1.5, 13, i, animation, mariosizes[i], playertype)
		end
	end

	--PLAY BGM
	if intermission == false then
		playmusic()
	else
		playsound(intermissionsound)
	end

	--load editor
	--editor_load()

	--Do stuff
	for i, v in pairs(objects["laser"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["lightbridge"]) do
		v:updaterange()
	end

	--generatespritebatch()
end

function loadmap(filename)
	print("Loading " .. "mappacks/" .. mappack .. "/" .. filename .. ".txt")
	if not love.filesystem.getInfo("mappacks/" .. mappack .. "/" .. filename .. ".txt") then
		print("mappacks/" .. mappack .. "/" .. filename .. ".txt not found!")
		return false
	end
	local s = love.filesystem.read( "mappacks/" .. mappack .. "/" .. filename .. ".txt" )
	local s2 = s:split(";")

	--MAP ITSELF
	local t = s2[1]:split(",")

	if math.fmod(#t, 15) ~= 0 then
		print("Incorrect number of entries: " .. #t)
		return false
	end

	mapwidth = #t/15

	map = {}
	unstatics = {}

	for x = 1, #t/15 do
		map[x] = {}
		for y = 1, 15 do
			map[x][y] = {}
			map[x][y]["gels"] = {}

			local r = tostring(t[(y-1)*(#t/15)+x]):split("-")

			if tonumber(r[1]) > smbtilecount+portaltilecount+customtilecount then
				r[1] = 1
			end

			for i = 1, #r do
				if r[i] ~= "link" then
					map[x][y][i] = tonumber(r[i])
				else
					map[x][y][i] = r[i]
				end
			end

			--create object for block
			if tilequads[tonumber(r[1])].collision == true then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
			end
		end
	end

	for y = 1, 15 do
		for x = 1, #t/15 do
			local r = map[x][y]
			if #r > 1 then
				local t = entityquads[r[2]].t
				if t == "spawn" then
					startx = x
					starty = y

				elseif not editormode then
					if t == "warppipe" then
						table.insert(warpzonenumbers, {x, y, r[3]})

					elseif t == "manycoins" then
						map[x][y][3] = 7

					elseif t == "flag" then
						flagx = x-1
						flagy = y

					elseif t == "pipespawn" and (prevsublevel == r[3] or (mariosublevel == r[3] and blacktime == sublevelscreentime)) then
						pipestartx = x
						pipestarty = y

					elseif t == "emancehor" then
						table.insert(emancipationgrills, emancipationgrill:new(x, y, "hor"))
					elseif t == "emancever" then
						table.insert(emancipationgrills, emancipationgrill:new(x, y, "ver"))

					elseif t == "doorver" then
						table.insert(objects["door"], door:new(x, y, r, "ver"))
					elseif t == "doorhor" then
						table.insert(objects["door"], door:new(x, y, r, "hor"))

					elseif t == "button" then
						table.insert(objects["button"], button:new(x, y))

					elseif t == "pushbuttonleft" then
						table.insert(objects["pushbutton"], pushbutton:new(x, y, "left"))
					elseif t == "pushbuttonright" then
						table.insert(objects["pushbutton"], pushbutton:new(x, y, "right"))

					elseif t == "wallindicator" then
						table.insert(objects["wallindicator"], wallindicator:new(x, y, r))

					elseif t == "groundlightver" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 1, r))
					elseif t == "groundlighthor" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 2, r))
					elseif t == "groundlightupright" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 3, r))
					elseif t == "groundlightrightdown" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 4, r))
					elseif t == "groundlightdownleft" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 5, r))
					elseif t == "groundlightleftup" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 6, r))

					elseif t == "faithplateup" then
						table.insert(objects["faithplate"], faithplate:new(x, y, "up"))
					elseif t == "faithplateright" then
						table.insert(objects["faithplate"], faithplate:new(x, y, "right"))
					elseif t == "faithplateleft" then
						table.insert(objects["faithplate"], faithplate:new(x, y, "left"))

					elseif t == "laserright" then
						table.insert(objects["laser"], laser:new(x, y, "right", r))
					elseif t == "laserdown" then
						table.insert(objects["laser"], laser:new(x, y, "down", r))
					elseif t == "laserleft" then
						table.insert(objects["laser"], laser:new(x, y, "left", r))
					elseif t == "laserup" then
						table.insert(objects["laser"], laser:new(x, y, "up", r))

					elseif t == "lightbridgeright" then
						table.insert(objects["lightbridge"], lightbridge:new(x, y, "right", r))
					elseif t == "lightbridgeleft" then
						table.insert(objects["lightbridge"], lightbridge:new(x, y, "left", r))
					elseif t == "lightbridgedown" then
						table.insert(objects["lightbridge"], lightbridge:new(x, y, "down", r))
					elseif t == "lightbridgeup" then
						table.insert(objects["lightbridge"], lightbridge:new(x, y, "up", r))

					elseif t == "laserdetectorright" then
						table.insert(objects["laserdetector"], laserdetector:new(x, y, "right"))
					elseif t == "laserdetectordown" then
						table.insert(objects["laserdetector"], laserdetector:new(x, y, "down"))
					elseif t == "laserdetectorleft" then
						table.insert(objects["laserdetector"], laserdetector:new(x, y, "left"))
					elseif t == "laserdetectorup" then
						table.insert(objects["laserdetector"], laserdetector:new(x, y, "up"))

					elseif t == "boxtube" then
						table.insert(objects["cubedispenser"], cubedispenser:new(x, y, r))

					elseif t == "timer" then
						table.insert(objects["walltimer"], walltimer:new(x, y, r[3], r))
					elseif t == "notgate" then
						table.insert(objects["notgate"], notgate:new(x, y, r))

					elseif t == "platformspawnerup" then
						table.insert(platformspawners, platformspawner:new(x, y, "up", r[3]))
					elseif t == "platformspawnerdown" then
						table.insert(platformspawners, platformspawner:new(x, y, "down", r[3]))

					elseif t == "box" then
						table.insert(objects["box"], box:new(x, y))

					elseif t == "firestart" then
						firestartx = x

					elseif t == "flyingfishstart" then
						flyingfishstartx = x
					elseif t == "flyingfishend" then
						flyingfishendx = x

					elseif t == "bulletbillstart" then
						bulletbillstartx = x
					elseif t == "bulletbillend" then
						bulletbillendx = x

					elseif t == "axe" then
						axex = x
						axey = y

					elseif t == "lakitoend" then
						lakitoendx = x

					elseif t == "spring" then
						table.insert(objects["spring"], spring:new(x, y))

					elseif t == "seesaw" then
						table.insert(seesaws, seesaw:new(x, y, r[3]))

					elseif t == "checkpoint" then
						if not tablecontains(checkpoints, x) then
							table.insert(checkpoints, x)
							checkpointpoints[x] = y
						end
					elseif t == "mazestart" then
						if not tablecontains(mazestarts, x) then
							table.insert(mazestarts, x)
						end

					elseif t == "mazeend" then
						if not tablecontains(mazeends, x) then
							table.insert(mazeends, x)
						end

					elseif t == "geltop" then
						if tilequads[map[x][y][1]].collision then
							map[x][y]["gels"]["top"] = r[3]
						end
					elseif t == "gelleft" then
						if tilequads[map[x][y][1]].collision then
							map[x][y]["gels"]["left"] = r[3]
						end
					elseif t == "gelbottom" then
						if tilequads[map[x][y][1]].collision then
							map[x][y]["gels"]["bottom"] = r[3]
						end
					elseif t == "gelright" then
						if tilequads[map[x][y][1]].collision then
							map[x][y]["gels"]["right"] = r[3]
						end
					end
				end
			end
		end
	end

	--sort checkpoints
	table.sort(checkpoints)

	--Add links
	for i, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.link then
				w:link()
			end
		end
	end

	if flagx then
		flagimgx = flagx+8/16
		flagimgy = 3+1/16
	end

	for x = 0, -30, -1 do
		map[x] = {}
		for y = 1, 13 do
			map[x][y] = {1}
		end

		for y = 14, 15 do
			map[x][y] = {2}
			objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
		end
	end

	--MORE STUFF
	for i = 2, #s2 do
		s3 = s2[i]:split("=")
		if s3[1] == "background" then
			background = tonumber(s3[2])
		elseif s3[1] == "spriteset" then
			spriteset = tonumber(s3[2])
		elseif s3[1] == "intermission" then
			intermission = true
		elseif s3[1] == "haswarpzone" then
			haswarpzone = true
		elseif s3[1] == "underwater" then
			underwater = true
		elseif s3[1] == "music" then
			musici = tonumber(s3[2])
		elseif s3[1] == "bonusstage" then
			bonusstage = true
		elseif s3[1] == "custombackground" or s3[1] == "portalbackground" then
			custombackground = true
		elseif s3[1] == "timelimit" then
			mariotimelimit = tonumber(s3[2])
		elseif s3[1] == "scrollfactor" then
			scrollfactor = tonumber(s3[2])
		end
	end

	if custombackground then
		loadcustombackground()
	end

	return true
end

function spawnenemy(x, y)
	if not inmap(x, y) then
		return
	end

	for i = 1, #enemiesspawned do
		if x == enemiesspawned[i][1] and y == enemiesspawned[i][2] then
			return
		end
	end

	local t = map[x][y]
	if #t > 1 then
		local enemy = true
		local i = entityquads[t[2]].t
		if i == "goomba" then
			table.insert(objects["goomba"], goomba:new(x-0.5, y-1/16))
		elseif i == "goombahalf" then
			table.insert(objects["goomba"], goomba:new(x, y-1/16))
		elseif i == "koopa" then
			table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16))
		elseif i == "koopahalf" then
			table.insert(objects["koopa"], koopa:new(x, y-1/16))
		elseif i == "koopared" then
			table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16, "red"))
		elseif i == "kooparedhalf" then
			table.insert(objects["koopa"], koopa:new(x, y-1/16, "red"))
		elseif i == "beetle" then
			table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16, "beetle"))
		elseif i == "beetlehalf" then
			table.insert(objects["koopa"], koopa:new(x, y-1/16, "beetle"))
		elseif i == "kooparedflying" then
			table.insert(objects["koopa"], koopa:new(x-.5, y-1/16, "redflying"))
		elseif i == "koopaflying" then
			table.insert(objects["koopa"], koopa:new(x-.5, y-1/16, "flying"))
		elseif i == "bowser" then
			objects["bowser"][1] = bowser:new(x, y-1/16)
		elseif i == "cheepred" then
			table.insert(objects["cheep"], cheepcheep:new(x-.5, y-1/16, 1))
		elseif i == "cheepwhite" then
			table.insert(objects["cheep"], cheepcheep:new(x-.5, y-1/16, 2))
		elseif i == "spikey" then
			table.insert(objects["goomba"], goomba:new(x-0.5, y-1/16, "spikey"))
		elseif i == "spikeyhalf" then
			table.insert(objects["goomba"], goomba:new(x, y-1/16, "spikey"))
		elseif i == "lakito" then
			table.insert(objects["lakito"], lakito:new(x, y-1/16))
		elseif i == "squid" then
			table.insert(objects["squid"], squid:new(x, y-1/16))

		elseif i == "platformup" then
			table.insert(objects["platform"], platform:new(x, y, "up", t[3])) --Platform right
		elseif i == "platformright" then
			table.insert(objects["platform"], platform:new(x, y, "right", t[3])) --Platform up

		elseif i == "platformfall" then
			table.insert(objects["platform"], platform:new(x, y, "fall", t[3])) --Platform up

		elseif i == "platformbonus" then
			table.insert(objects["platform"], platform:new(x, y, "justright", 3))

		elseif i == "plant" then
			table.insert(objects["plant"], plant:new(x, y))

		elseif i == "castlefirecw" then
			table.insert(objects["castlefire"], castlefire:new(x, y, tonumber(t[3]), "cw"))

		elseif i == "castlefireccw" then
			table.insert(objects["castlefire"], castlefire:new(x, y, tonumber(t[3]), "ccw"))

		elseif i == "hammerbro" then
			table.insert(objects["hammerbro"], hammerbro:new(x, y))

		elseif i == "whitegeldown" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "down"))
		elseif i == "whitegelright" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "right"))
		elseif i == "whitegelleft" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "left"))

		elseif i == "bulletbill" then
			table.insert(rocketlaunchers, rocketlauncher:new(x, y))

		elseif i == "bluegeldown" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "down"))
		elseif i == "bluegelright" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "right"))
		elseif i == "bluegelleft" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "left"))

		elseif i == "orangegeldown" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "down"))
		elseif i == "orangegelright" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "right"))
		elseif i == "orangegelleft" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "left"))

		elseif i == "upfire" then
			table.insert(objects["upfire"], upfire:new(x, y))
		else

			enemy = false
		end

		if enemy then
			table.insert(enemiesspawned, {x, y})

			--spawn enemies in 5x1 line so they spawn as a unit and not alone.
			spawnenemy(x-2, y)
			spawnenemy(x-1, y)
			spawnenemy(x+1, y)
			spawnenemy(x+2, y)
		end
	end
end

function inmap(x, y)
	if not x or not y then
		return false
	end
	if x >= 1 and x <= mapwidth and y >= 1 and y <= 15 then
		return true
	else
		return false
	end
end

function addzeros(s, i)
	for j = string.len(s)+1, i do
		s = "0" .. s
	end
	return s
end

function properprint2(s, x, y)
	for i = 1, string.len(tostring(s)) do
		if fontquads[string.sub(s, i, i)] then
			love.graphics.draw(fontimage2, font2quads[string.sub(s, i, i)], x+((i-1)*4)*scale, y, 0, scale, scale)
		end
	end
end

function game_keypressed(key, unicode)
	if pausemenuopen then
		if menuprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					pausemenuopen = false
					menuprompt = false
					menu_load()
				else
					menuprompt = false
				end
			elseif key == "escape" then
				menuprompt = false
			end
			return
		elseif desktopprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == "space") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					love.event.quit()
				else
					desktopprompt = false
				end
			elseif key == "escape" then
				desktopprompt = false
			end
			return
		elseif suspendprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == "space") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					suspendgame()
					suspendprompt = false
					pausemenuopen = false
				else
					suspendprompt = false
				end
			elseif key == "escape" then
				suspendprompt = false
			end
			return
		end
		if (key == "down" or key == "s") then
			if pausemenuselected < #pausemenuoptions then
				pausemenuselected = pausemenuselected + 1
			end
		elseif (key == "up" or key == "w") then
			if pausemenuselected > 1 then
				pausemenuselected = pausemenuselected - 1
			end
		elseif (key == "return" or key == "enter" or key == "kpenter" or key == "space") then
			if pausemenuoptions[pausemenuselected] == "resume" then
				pausemenuopen = false
				playmusic()
			elseif pausemenuoptions[pausemenuselected] == "suspend" then
				suspendprompt = true
				pausemenuselected2 = 1
			elseif pausemenuoptions2[pausemenuselected] == "menu" then
				menuprompt = true
				pausemenuselected2 = 1
			elseif pausemenuoptions2[pausemenuselected] == "desktop" then
				desktopprompt = true
				pausemenuselected2 = 1
			end
		elseif key == "escape" then
			pausemenuopen = false
			playmusic()
		elseif (key == "right" or key == "d") then
			if pausemenuoptions[pausemenuselected] == "volume" then
				if volume < 1 then
					volume = volume + 0.1
					love.audio.setVolume( volume )
					soundenabled = true
					playsound(coinsound)
				end
			end

		elseif (key == "left" or key == "a") then
			if pausemenuoptions[pausemenuselected] == "volume" then
				volume = math.max(volume - 0.1, 0)
				love.audio.setVolume( volume )
				if volume == 0 then
					soundenabled = false
				end
				playsound(coinsound)
			end
		end

		return
	end

	for i = 1, players do
		if controls[i]["jump"][1] == key then
			objects["player"][i]:jump()
		elseif controls[i]["run"][1] == key then
			objects["player"][i]:fire()
		elseif controls[i]["reload"][1] == key then
			objects["player"][i]:removeportals()
		elseif controls[i]["use"][1] == key then
			objects["player"][i]:use()
		elseif controls[i]["left"][1] == key then
			objects["player"][i]:leftkey()
		elseif controls[i]["right"][1] == key then
			objects["player"][i]:rightkey()
		end

		if controls[i]["portal1"][i] == key then
			shootportal(i, 1, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
			return
		end

		if controls[i]["portal2"][i] == key then
			shootportal(i, 2, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
			return
		end
	end

	if key == "escape" then
		if not editormode and testlevel then
			marioworld = testlevelworld
			mariolevel = testlevellevel
			testlevel = false
			editormode = true
			startlevel(marioworld .. "-" .. mariolevel)
			return
		elseif not editormode and not everyonedead then
			pausemenuopen = true
			love.audio.pause()
			playsound(pausesound)
		end
	end

	if editormode then
		editor_keypressed(key)
	end
end

function game_keyreleased(key, unicode)
	for i = 1, players do
		if controls[i]["jump"][1] == key then
			objects["player"][i]:stopjump()
		end
	end
end

function runkey(i)
	local s = controls[i]["run"]
	return checkkey(s)
end

function rightkey(i)
	local s = controls[i]["right"]
	return checkkey(s)
end

function leftkey(i)
	local s = controls[i]["left"]
	return checkkey(s)
end

function downkey(i)
	local s = controls[i]["down"]
	return checkkey(s)
end

function upkey(i)
	local s = controls[i]["up"]
	return checkkey(s)
end

function checkkey(s)
	if love.keyboard.isDown(s[1]) then
		return true
	else
		return false
	end
end

function playsound(sound)
	if soundenabled then
		--sound:stop()
		--sound:play()
	end
end

function playmusic()
	if musici == 7 and custommusic then
		--music:play(custommusic)
	elseif musici ~= 1 then
		if mariotime < 100 and mariotime > 0 then
			--music:playIndex(musici-1, true)
		else
			--music:playIndex(musici-1)
		end
	end
end

function stopmusic()
	if musici ~= 1 then
		if mariotime < 100 and mariotime > 0 then
			--music:stopIndex(musici-1, true)
		else
			--music:stopIndex(musici-1)
		end
	end
end