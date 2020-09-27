function menu_load()
	love.audio.stop()
	editormode = false
	gamestate = "menu"
	selection = 1
	coinanimation = 1
	love.graphics.setBackgroundColor(92, 148, 252)
	scrollsmoothrate = 4
	optionstab = 2
	optionsselection = 1
	skinningplayer = 1
	rgbselection = 1
	mappackselection = 1
	onlinemappackselection = 1
	mappackhorscroll = 0
	mappackhorscrollsmooth = 0
	checkpointx = false
	love.graphics.setBackgroundColor(backgroundcolor[1])

	controlstable = {"left", "right", "up", "down", "run", "jump", "reload", "use", "aimx", "aimy", "portal1", "portal2"}

	infmarioY = 0
	infmarioR = 0

	infmarioYspeed = 200
	infmarioRspeed = 4

	RGBchangespeed = 200/255
	huechangespeed = 0.5
	spriteset = 1

	continueavailable = false
	if love.filesystem.getInfo("suspend.txt") then
		continueavailable = true
	end

	mariolevel = 1
	marioworld = 1
	mariosublevel = 0

	--load 1-1 as background
	loadbackground("1-1.txt")

	skipupdate = true
end

function menu_update(dt)
	--coinanimation
	coinanimation = coinanimation + dt*6.75
	while coinanimation >= 6 do
		coinanimation = coinanimation - 5
	end

end

function menu_draw()
	--GUI LIBRARY?! Never heard of that.
	--I'm not proud of this at all; But I'm even lazier than not proud.

	--TILES
	love.graphics.translate(0, yoffset*scale)
	local xtodraw
	if mapwidth < width+1 then
		xtodraw = mapwidth
	else
		if mapwidth > width then
			xtodraw = width+1
		else
			xtodraw = width
		end
	end

	--custom background
	if custombackground then
		for i = #custombackgroundimg, 1, -1 do
			for y = 1, math.ceil(15/custombackgroundheight[i]) do
				for x = 1, math.ceil(width/custombackgroundwidth[i])+1 do
					love.graphics.draw(custombackgroundimg[i], math.floor(((x-1)*custombackgroundwidth[i])*16*scale), (y-1)*custombackgroundheight[i]*16*scale, 0, scale, scale)
				end
			end
		end
	end

	local coinframe
	if math.floor(coinanimation) == 4 then
		coinframe = 2
	elseif math.floor(coinanimation) == 5 then
		coinframe = 1
	else
		coinframe = math.max(1, math.floor(coinanimation))
	end

	for y = 1, 15 do
		for x = 1, xtodraw do
			local t = map[x][y]
			local tilenumber = tonumber(t[1])
			if tilequads[tilenumber].coinblock and tilequads[tilenumber].invisible == false then --coinblock
				love.graphics.draw(coinblockimage, coinblockquads[spriteset][coinframe], math.floor((x-1)*16*scale), ((y-1)*16-8)*scale, 0, scale, scale)
			elseif tilenumber ~= 0 and tilequads[tilenumber].invisible == false then
				love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber].quad, math.floor((x-1)*16*scale), ((y-1)*16-8)*scale, 0, scale, scale)
			end
		end
	end

	---UI

	properprint("mario", uispace*.5 - 24*scale, 8*scale)
	properprint("000000", uispace*0.5-24*scale, 16*scale)

	properprint("*", uispace*1.5-8*scale, 16*scale)

	love.graphics.draw(coinanimationimage, coinanimationquads[1][coinframe], uispace*1.5-16*scale, 16*scale, 0, scale, scale)
	properprint("00", uispace*1.5-0*scale, 16*scale)

	properprint("world", uispace*2.5 - 20*scale, 8*scale)
	properprint("1-1", uispace*2.5 - 12*scale, 16*scale)

	properprint("time", uispace*3.5 - 16*scale, 8*scale)

	for j = 1, players do

		--draw player
		love.graphics.setColor(1, 1, 1, 1)
		for k = 1, 3 do
			love.graphics.setColor(table.unpack(mariocolors[j][k]))
			love.graphics.draw(skinpuppet[k], (startx*16-6)*scale+8*(j-1)*scale, (starty*16-23)*scale, 0, scale, scale)
		end

		--hat

		offsets = hatoffsets["idle"]
		if #mariohats[j] > 1 or mariohats[j][1] ~= 1 then
			local yadd = 0
			for i = 1, #mariohats[j] do
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(hat[mariohats[j][i]].graphic, (startx*16-11)*scale+8*(j-1)*scale, (starty*16-25)*scale, 0, scale, scale, - hat[mariohats[j][i]].x + offsets[1], - hat[mariohats[j][i]].y + offsets[2] + yadd)
				yadd = yadd + hat[mariohats[j][i]].height
			end
		elseif #mariohats[j] == 1 then
			love.graphics.setColor(mariocolors[j][1])
			love.graphics.draw(hat[mariohats[j][1]].graphic, (startx*16-11)*scale+8*(j-1)*scale, (starty*16-25)*scale, 0, scale, scale, - hat[mariohats[j][1]].x + offsets[1], - hat[mariohats[j][1]].y + offsets[2])
		end

		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.draw(skinpuppet[0], (startx*16-6)*scale+8*(j-1)*scale, (starty*16-23)*scale, 0, scale, scale)
	end

	love.graphics.setColor(1, 1, 1, 1)

	if gamestate == "menu" then
		love.graphics.draw(titleimage, 40*scale, 24*scale, 0, scale, scale)

		if updatenotification then
			love.graphics.setColor(1, 0, 0)
			properprint("version outdated!|go to stabyourself.net|to download latest", 220*scale, 90*scale)
			love.graphics.setColor(1, 1, 1, 1)
		end

		if selection == 0 then
			love.graphics.draw(menuselection, 73*scale, (137+(selection-1)*16)*scale, 0, scale, scale)
		elseif selection == 1 then
			love.graphics.draw(menuselection, 73*scale, (137+(selection-1)*16)*scale, 0, scale, scale)
		elseif selection == 2 then
			love.graphics.draw(menuselection, 81*scale, (137+(selection-1)*16)*scale, 0, scale, scale)
		elseif selection == 3 then
			love.graphics.draw(menuselection, 73*scale, (137+(selection-1)*16)*scale, 0, scale, scale)
		elseif selection == 4 then
			love.graphics.draw(menuselection, 98*scale, (137+(selection-1)*16)*scale, 0, scale, scale)
		end

		local start = 9
		if custombackground then
			start = 1
		end

		for i = start, 9 do
			local tx, ty = -scale, scale
			love.graphics.setColor(0, 0, 0)
			if i == 2 then
				tx, ty = scale, scale
			elseif i == 3 then
				tx, ty = -scale, -scale
			elseif i == 4 then
				tx, ty = scale, -scale
			elseif i == 5 then
				tx, ty = 0, -scale
			elseif i == 6 then
				tx, ty = 0, scale
			elseif i == 7 then
				tx, ty = scale, 0
			elseif i == 8 then
				tx, ty = -scale, 0
			elseif i == 9 then
				tx, ty = 0, 0
				love.graphics.setColor(1, 1, 1)
			end

			love.graphics.translate(tx, ty)

			if continueavailable then
				properprint("continue game", 87*scale, 122*scale)
			end

			properprint("player game", 103*scale, 138*scale)

			properprint("level editor", 95*scale, 154*scale)

			properprint("select mappack", 87*scale, 170*scale)

			properprint("options", 111*scale, 186*scale)

			properprint(players, 87*scale, 138*scale)

			love.graphics.translate(-tx, -ty)
		end

		if players > 1 then
			love.graphics.draw(playerselectimg, 82*scale, 138*scale, 0, scale, scale)
		end

		if players < 4 then
			love.graphics.draw(playerselectimg, 102*scale, 138*scale, 0, -scale, scale)
		end

		if selectworldopen then
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle("fill", 30*scale, 92*scale, 200*scale, 60*scale)
			love.graphics.setColor(1, 1, 1)
			drawrectangle(31, 93, 198, 58)
			properprint("select world", 83*scale, 105*scale)
			for i = 1, 8 do
				if selectworldcursor == i then
					love.graphics.setColor(1, 1, 1)
				elseif reachedworlds[mappack][i] then
					love.graphics.setColor(0.8, 0.8, 0.8)
				elseif selectworldexists[i] then
					love.graphics.setColor(0.2, 0.2, 0.2)
				else
					love.graphics.setColor(0, 0, 0)
				end

				properprint(i, (55+(i-1)*20)*scale, 130*scale)
				if i == selectworldcursor then
					properprint("v", (55+(i-1)*20)*scale, 120*scale)
				end
			end
		end

	elseif gamestate == "mappackmenu" then
		--background
		love.graphics.setColor(0, 0, 0, 0.2)
		love.graphics.rectangle("fill", 21*scale, 16*scale, 218*scale, 200*scale)
		love.graphics.setColor(1, 1, 1, 1)

		--set scissor
		love.graphics.setScissor(21*scale, 16*scale, 218*scale, 200*scale)

		if loadingonlinemappacks then
			love.graphics.setColor(0, 0, 0, 0.8)
			love.graphics.rectangle("fill", 21*scale, 16*scale, 218*scale, 200*scale)
			love.graphics.setColor(1, 1, 1, 1)
			properprint("a little patience..|downloading " .. currentdownload .. " of " .. downloadcount, 50*scale, 30*scale)
			drawrectangle(50, 55, 152, 10)
			love.graphics.rectangle("fill", 50*scale, 55*scale, 152*((currentfiledownload-1)/(filecount-1))*scale, 10*scale)
		else
			love.graphics.translate(-round(mappackhorscrollsmooth*scale*mappackhorscrollrange), 0)

			if mappackhorscrollsmooth < 1 then
				--draw each butten (even if all you do, is press ONE. BUTTEN.)
				--scrollbar offset
				love.graphics.translate(0, -round(mappackscrollsmooth*60*scale))

				love.graphics.setScissor(240*scale, 16*scale, 200*scale, 200*scale)
				love.graphics.setColor(0, 0, 0, 0.8)
				love.graphics.rectangle("fill", 240*scale, 81*scale, 115*scale, 61*scale)
				love.graphics.setColor(1, 1, 1)
				if not savefolderfailed then
					properprint("press right to|access the dlc||press m to|open your|mappack folder", 241*scale, 83*scale)
				else
					properprint("press right to|access the dlc||could not|open your|mappack folder", 241*scale, 83*scale)
				end
				love.graphics.setScissor(21*scale, 16*scale, 218*scale, 200*scale)

				for i = 1, #mappacklist do
					--back
					love.graphics.draw(mappackback, 25*scale, (20+(i-1)*60)*scale, 0, scale, scale)

					--icon
					if mappackicon[i] ~= nil then
						local scale2w = scale*50 / math.max(1, mappackicon[i]:getWidth())
						local scale2h = scale*50 / math.max(1, mappackicon[i]:getHeight())
						love.graphics.draw(mappackicon[i], 29*scale, (24+(i-1)*60)*scale, 0, scale2w, scale2h)
					else
						love.graphics.draw(mappacknoicon, 29*scale, (24+(i-1)*60)*scale, 0, scale, scale)
					end
					love.graphics.draw(mappackoverlay, 29*scale, (24+(i-1)*60)*scale, 0, scale, scale)

					--name
					love.graphics.setColor(0.8, 0.8, 0.8)
					if mappackselection == i then
						love.graphics.setColor(1, 1, 1)
					end

					properprint(string.sub(mappackname[i]:lower(), 1, 17), 83*scale, (26+(i-1)*60)*scale)

					--author
					love.graphics.setColor(0.4, 0.4, 0.4)
					if mappackselection == i then
						love.graphics.setColor(0.4, 0.4, 0.4)
					end

					if mappackauthor[i] then
						properprint(string.sub("by " .. mappackauthor[i]:lower(), 1, 16), 91*scale, (35+(i-1)*60)*scale)
					end

					--description
					love.graphics.setColor(0.5, 0.5, 0.5)
					if mappackselection == i then
						love.graphics.setColor(0.7, 0.7, 0.7)
					end

					if mappackdescription[i] then
						properprint( string.sub(mappackdescription[i]:lower(), 1, 17), 83*scale, (47+(i-1)*60)*scale)

						if mappackdescription[i]:len() > 17 then
							properprint( string.sub(mappackdescription[i]:lower(), 18, 34), 83*scale, (56+(i-1)*60)*scale)
						end

						if mappackdescription[i]:len() > 34 then
							properprint( string.sub(mappackdescription[i]:lower(), 35, 51), 83*scale, (65+(i-1)*60)*scale)
						end
					end

					love.graphics.setColor(1, 1, 1)

					--highlight
					if i == mappackselection then
						love.graphics.draw(mappackhighlight, 25*scale, (20+(i-1)*60)*scale, 0, scale, scale)
					end
				end

				love.graphics.translate(0, round(mappackscrollsmooth*60*scale))

				local i = mappackscrollsmooth / (#mappacklist-3.233)

				love.graphics.draw(mappackscrollbar, 227*scale, (20+i*160)*scale, 0, scale, scale)

			end
		end
	end
	love.graphics.translate(0, yoffset*scale)
end

function loadbackground(background)
	if not love.filesystem.getInfo("mappacks/" .. mappack .. "/" .. background) then

		map = {}
		mapwidth = width
		for x = 1, width do
			map[x] = {}
			for y = 1, 13 do
				map[x][y] = {1}
			end

			for y = 14, 15 do
				map[x][y] = {2}
			end
		end
		startx = 3
		starty = 13
		custombackground = false
		backgroundi = 1
		love.graphics.setBackgroundColor(backgroundcolor[backgroundi])
	else
		local s = love.filesystem.read( "mappacks/" .. mappack .. "/" .. background )
		local s2 = s:split(";")

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

		--MAP ITSELF
		local t = s2[1]:split(",")

		if math.fmod(#t, 15) ~= 0 then
			print("Incorrect number of entries: " .. #t)
			return false
		end

		mapwidth = #t/15
		startx = 3
		starty = 13

		map = {}

		for y = 1, 15 do
			for x = 1, #t/15 do
				if y == 1 then
					map[x] = {}
				end

				map[x][y] = t[(y-1)*(#t/15)+x]:split("-")

				r = map[x][y]

				if #r > 1 then
					if entityquads[tonumber(r[2])].t == "spawn" then
						startx = x
						starty = y
					end
				end

				if tonumber(r[1]) > smbtilecount+portaltilecount+customtilecount then
					r[1] = 1
				end
			end
		end

		--get background color
		custombackground = false

		for i = 2, #s2 do
			s3 = s2[i]:split("=")
			if s3[1] == "background" then
				local backgroundi = tonumber(s3[2])

				love.graphics.setBackgroundColor(backgroundcolor[backgroundi])
			elseif s3[1] == "spriteset" then
				spriteset = tonumber(s3[2])
			elseif s3[1] == "custombackground" or s3[1] == "portalbackground" then
				custombackground = true
			end
		end

		if custombackground then
			loadcustombackground()
		end
	end
end

function menu_keypressed(key, unicode)
	if gamestate == "menu" then
		if selectworldopen then
			if (key == "right" or key == "d") then
				local target = selectworldcursor+1
				while target < 9 and not reachedworlds[mappack][target] do
					target = target + 1
				end
				if target < 9 then
					selectworldcursor = target
				end
			elseif (key == "left" or key == "a") then
				local target = selectworldcursor-1
				while target > 0 and not reachedworlds[mappack][target] do
					target = target - 1
				end
				if target > 0 then
					selectworldcursor = target
				end
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == "space") then
				selectworldopen = false
				game_load(selectworldcursor)
			elseif key == "escape" then
				selectworldopen = false
			end
			return
		end
		if (key == "up" or key == "w") then
			if continueavailable then
				if selection > 0 then
					selection = selection - 1
				end
			else
				if selection > 1 then
					selection = selection - 1
				end
			end
		elseif (key == "down" or key == "s") then
			if selection < 4 then
				selection = selection + 1
			end
		elseif (key == "return" or key == "enter" or key == "kpenter" or key == "space") then
			if selection == 0 then
				game_load(true)
			elseif selection == 1 then
				selectworld()
			elseif selection == 2 then
				editormode = true
				players = 1
				playertype = "portal"
				playertypei = 1
				bullettime = false
				portalknockback = false
				bigmario = false
				goombaattack = false
				sonicrainboom = false
				playercollisions = false
				infinitetime = false
				infinitelives = false
				game_load()
			elseif selection == 3 then
				gamestate = "mappackmenu"
				mappacks()
			elseif selection == 4 then
				gamestate = "options"
			end
		elseif key == "escape" then
			love.event.quit()
		elseif (key == "left" or key == "a") then
			if players > 1 then
				players = players - 1
			end
		elseif (key == "right" or key == "d") then
			players = players + 1
			if players > 4 then
				players = 4
			end
		end
	elseif gamestate == "mappackmenu" then
		if (key == "up" or key == "w") then
			if mappacktype == "local" then
				if mappackselection > 1 then
					mappackselection = mappackselection - 1
					mappack = mappacklist[mappackselection]

					--load background
					if mappackbackground[mappackselection] then
						loadbackground(mappackbackground[mappackselection] .. ".txt")
					else
						loadbackground("1-1.txt")
					end

					updatescroll()
				end
			else
				if onlinemappackselection > 1 then
					onlinemappackselection = onlinemappackselection - 1
					mappack = onlinemappacklist[onlinemappackselection]

					--load background
					if onlinemappackbackground[onlinemappackselection] then
						loadbackground(onlinemappackbackground[onlinemappackselection] .. ".txt")
					else
						loadbackground("1-1.txt")
					end

					onlineupdatescroll()
				end
			end
		elseif (key == "down" or key == "s") then
			if mappacktype == "local" then
				if mappackselection < #mappacklist then
					mappackselection = mappackselection + 1
					mappack = mappacklist[mappackselection]

					--load background
					if mappackbackground[mappackselection] then
						loadbackground(mappackbackground[mappackselection] .. ".txt")
					else
						loadbackground("1-1.txt")
					end

					updatescroll()
				end
			else
				if onlinemappackselection < #onlinemappacklist then
					onlinemappackselection = onlinemappackselection + 1
					mappack = onlinemappacklist[onlinemappackselection]

					--load background
					if onlinemappackbackground[onlinemappackselection] then
						loadbackground(onlinemappackbackground[onlinemappackselection] .. ".txt")
					else
						loadbackground("1-1.txt")
					end

					onlineupdatescroll()
				end
			end
		elseif key == "escape" or (key == "return" or key == "enter" or key == "kpenter" or key == "space") then
			gamestate = "menu"
			saveconfig()
			if mappack == "custom_mappack" then
				createmappack()
			end
		elseif (key == "right" or key == "d") then
			loadonlinemappacks()
			mappackhorscroll = 1
		elseif (key == "left" or key == "a") then
			loadmappacks()
			mappackhorscroll = 0
		elseif key == "m" then
			if not openSaveFolder("mappacks") then
				savefolderfailed = true
			end
		end
	elseif gamestate == "onlinemenu" then
		if CLIENT == false and SERVER == false then
			if key == "c" then
				client_load()
			elseif key == "s" then
				server_load()
			end
		elseif SERVER then
			if (key == "return" or key == "enter" or key == "kpenter" or key == "space") then
				server_start()
			end
		end
	end
end

function selectworld()
	if not reachedworlds[mappack] then
		game_load()
	end

	local noworlds = true
	for i = 2, 8 do
		if reachedworlds[mappack][i] then
			noworlds = false
			break
		end
	end

	if noworlds then
		game_load()
		return
	end

	selectworldopen = true
	selectworldcursor = 1

	selectworldexists = {}
	for i = 1, 8 do
		if love.filesystem.getInfo("mappacks/" .. mappack .. "/" .. i .. "-1.txt") then
			selectworldexists[i] = true
		end
	end
end