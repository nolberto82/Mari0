scrollingscore = class:new()

function scrollingscore:init(i, x, y)
	self.x = x-xscroll
	self.y = y
	self.i = i
	self.timer = 0
end

function scrollingscore:update(dt)
	self.timer = self.timer + dt
	if self.timer > scrollingscoretime then
		return true
	end
	
	return false
end