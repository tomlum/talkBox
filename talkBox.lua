talkBox = {}
talkBox.width = 0
talkBox.height = 0
local lg = love.graphics

local function strReplace(s, i, char)
	return string.sub(s, 1, i-1).. char ..string.sub(s, i+1, string.len(s))
end

local function getNextWord(s, i)
	local j = i
	local nextString = string.sub(s,j,j)
	while(string.sub(s,j,j) ~= " ") and j < string.len(s) do
		j = j + 1
		nextString = nextString..string.sub(s,j,j)
	end
	return nextString
end

local function repplay(sound)
	if sound:isStopped() then
		sound:play()
	else
		sound:rewind()
		sound:play()
	end
end

function talkBox.set(font,blurbList,speed,sound)
	talkBox.font = font
	talkBox.fontHeight = talkBox.font:getHeight()
	talkBox.lineHeight = talkBox.font:getLineHeight()

	talkBox.text = ""
	talkBox.blurbList = blurbList

	talkBox.speed = speed
	talkBox.sound = sound
	--The pixel width of the current line
	talkBox.lineWidth = 0
	talkBox.timer = 0
	talkBox.currentBlurb = 1
	talkBox.currentChar = 1

	talkBox.pageY = 1
end

function talkBox.update(continue, skip)
	if talkBox.currentBlurb > #talkBox.blurbList then
		talkBox.text = ""
		talkBox.busy = false
		--Skip to end of 
	elseif (talkBox.pageY)*talkBox.fontHeight*talkBox.lineHeight > talkBox.height then
		talkBox.busy = false
		if continue then
			if talkBox.currentBlurb > #talkBox.blurbList then
				talkBox.text = ""
			elseif talkBox.scrolling then
				--Scroll the page halfway back
				talkBox.pageY = talkBox.pageY - math.floor((talkBox.pageY))
				--Add the next Char and play sound
				talkBox.text = talkBox.text..talkBox.nextChar
				if talkBox.sound~= nil then
					repplay(talkBox.sound)
				end
			else
				talkBox.pageY = talkBox.pageY - math.floor((talkBox.pageY))
				if talkBox.sound~= nil then
					repplay(talkBox.sound)
				end
				talkBox.text = ""
				if talkBox.nextChar ~= " " then
					talkBox.text = talkBox.text..talkBox.nextChar
				end
			end
		end
		--If skip then finish the page
	elseif skip then
		while((talkBox.pageY)*talkBox.fontHeight*talkBox.lineHeight <= talkBox.height and talkBox.currentChar < string.len(talkBox.blurbList[talkBox.currentBlurb])+1) do
			talkBox.update(false,false)
		end

		--While we haven't run out of characters
	elseif talkBox.currentChar < string.len(talkBox.blurbList[talkBox.currentBlurb])+1 then
		talkBox.busy = true
		--Increment the text timer
		talkBox.timer = talkBox.timer + 1
		--If its time to get another character
		if talkBox.timer%talkBox.speed == 0 then
			--Reset timer
			talkBox.timer = 1
			--Get the next character
			talkBox.nextChar = string.sub(talkBox.blurbList[talkBox.currentBlurb],talkBox.currentChar,talkBox.currentChar)
			--Play the text sound
			if talkBox.nextChar ~= " " and talkBox.sound ~= nil then
				repplay(talkBox.sound)
			end
			--Update the width of the current Line
			talkBox.lineWidth = talkBox.lineWidth + talkBox.font:getWidth(talkBox.nextChar)
			--If we cross over to the next line
			if talkBox.lineWidth > talkBox.width then
				--Reset the lineWidth
				talkBox.lineWidth = talkBox.font:getWidth(talkBox.nextChar)
				--Increment pageY
				talkBox.pageY = talkBox.pageY + 1
				--Add the nextChar if we don't need to scroll
				if (talkBox.pageY)*talkBox.fontHeight*talkBox.lineHeight <= talkBox.height then
					talkBox.text = talkBox.text..talkBox.nextChar
				end
				--Add the next Char
			else
				talkBox.text = talkBox.text..talkBox.nextChar
			end

			--If the next word isn't going to fit on this next line, add spaces to fill out the line
			if talkBox.nextChar == " " and talkBox.font:getWidth(getNextWord(talkBox.blurbList[talkBox.currentBlurb], talkBox.currentChar+1)) > talkBox.width - talkBox.lineWidth then
				local spacer = talkBox.width - talkBox.lineWidth
				while(spacer > 0) do
					talkBox.text = talkBox.text .. " "
					spacer = spacer - 1
				end
				--Reset line width and increment pageY
				talkBox.lineWidth = 0
				talkBox.pageY = talkBox.pageY + 1
			end
			--Increment currentChar
			talkBox.currentChar = talkBox.currentChar + 1
		end
	else
		talkBox.busy = false
		if continue then
			talkBox.pageY = 1
			talkBox.text = ""
			talkBox.currentChar = 1
			talkBox.lineWidth = 0
			talkBox.timer = 1
			talkBox.currentBlurb = talkBox.currentBlurb + 1
		end
	end
end

function talkBox.draw(x, y, width, height)
	talkBox.width = width
	talkBox.height = height
	lg.setScissor(x, y, talkBox.width, talkBox.height)
	lg.setFont(talkBox.font)
	lg.printf(talkBox.text, x, y, talkBox.width)
	lg.setScissor()
end

--Returns whether or not the talkBox is in the middle of talking
function talkBox.isBusy()
	return talkBox.busy
end

--Returns which blurb the talkBox is at
function talkBox.blurbNumber()
	return talkBox.currentBlurb
end