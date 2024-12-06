local function toLast(t, value)
    t[#t+1] = value
end


local function _seconds(str)
    local time = string.split(str, ":")
    return tonumber(time[1]) * 60 + tonumber(time[2]) + tonumber(time[3]) * 0.1
end

local subtitle = setmetatable({
    text = {},
    size = 18,
    opacity = 1,
},
{__call = function(self, text, time)
    toLast(self.text, {text = text, time = time})
end})

function subtitle.clear()
    lume.clear(subtitle.text)
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
    if #self.text == 0 then
        return
    end
    local _, _lines = love.graphics.getFont():getWrap(self.text[1].text, 820)

    love.graphics.setColor(1, 1, 1, self.opacity)
    love.graphics.printf(self.text[1].text, 90, 600 - self.size * #_lines, 820, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

function subtitle:update(elapsed)
    if #self.text == 0 then
        return
    end

    if self.text[1].time > 0.4 then
        self.text[1].time = self.text[1].time - elapsed
        if self.opacity < 0.8 then
            self.opacity = self. opacity + 2 * elapsed
        end
    else
        if self.opacity > 0 then
            self.opacity = self.opacity - 2 * elapsed
        else
            table.remove(self.text, 1)
        end
    end
end

return subtitle