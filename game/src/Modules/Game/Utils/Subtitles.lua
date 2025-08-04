local function toLast(t, value)
    t[#t+1] = value
end



local function _clear(t)
    local function getiter(x)
        if type(x) == "table" and x[1] ~= nil then
            return ipairs
        elseif type(x) == "table" then
            return pairs
        end
        error("expected table", 3)
    end

    local iter = getiter(t)
    for k in iter(t) do
        t[k] = nil
    end
    return t
end

local function _seconds(str)
    local time = string.split(str, ":")
    --print(tonumber(time[1]) * 60, tonumber(time[2]), tonumber(time[3]) * 0.01)
    return tonumber(time[1]) * 60 + tonumber(time[2]) + tonumber(time[3]) * 0.01
end

local subtitle = setmetatable({
    text = {},
    size = 18,
    opacity = 1,
},
{__call = function(self, text, time)
    local allowSub = gameslot.save.game.user.settings.subtitles
    if allowSub then
        toLast(self.text, {text = text, time = time})
    end
end})

function subtitle.clear()
    _clear(subtitle.text)
end

function subtitle.queue(_sub)
    for i = 1, #_sub, 1 do
        local _time2
        local _time1 = _seconds(_sub[i][1])
        if _sub[i + 1] == nil then
            _time2 =  _seconds(_sub[i][1])
        else
            _time2 = _seconds(_sub[i + 1][1])
        end
        --local _time2 = _seconds(_sub[i + 1].time) or 0
        subtitle(_sub[i][2], _time2 - _time1)
    end
end

function subtitle:draw()
    local allowSub = gameslot.save.game.user.settings.subtitles
    if #self.text == 0 and allowSub then return end
    
    if self.text[1] then
        local offset = 110
        local startY = 660
        local paddingX = 120
        local paddingY = 4
    
        local _, _lines = fnt_subtitle:getWrap(self.text[1].text, shove.getViewportWidth() - offset)
        for i = 0, #_lines - 1, 1 do
            local wtxt = fnt_subtitle:getWidth(_lines[i + 1])
            local tx = ((shove.getViewportWidth() + offset) - wtxt) / 2 - paddingX / 2
            local ty = (startY - fnt_subtitle:getHeight() * #_lines) + (fnt_subtitle:getHeight() + paddingY) * i
            local tw = paddingX + wtxt
            local th = fnt_subtitle:getHeight() + paddingY
    
            love.graphics.setColor(0.1, 0.1, 0.1, self.opacity)
                love.graphics.draw(bg_subtitles, tx, ty, 0, tw, th)
            love.graphics.setColor(1, 1, 1, 1)
        end
    
        love.graphics.setColor(1, 1, 1, self.opacity)
            love.graphics.printf(self.text[1].text, fnt_subtitle, offset, startY - fnt_subtitle:getHeight() * #_lines, shove.getViewportWidth() - offset, "center")
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function subtitle:update(elapsed)
    local allowSub = gameslot.save.game.user.settings.subtitles
    if #self.text <= 0 and allowSub then return end

    if self.text[1] then
        if self.text[1].time > 0.4 then
            self.text[1].time = self.text[1].time - elapsed
            if self.opacity < 0.8 then
                self.opacity = self. opacity + 6 * elapsed
            end
        else
            if self.opacity > 0 then
                self.opacity = self.opacity - 6 * elapsed
            else
                table.remove(self.text, 1)
            end
        end
    end
end

return subtitle