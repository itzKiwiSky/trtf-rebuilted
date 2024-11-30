local CameraController = {}
CameraController.__index = CameraController

local function Distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function CameraController.new(frameObject, camera)
    local self = setmetatable({}, CameraController)

    local X_LEFT_FRAME = camera.x
    local X_RIGHT_FRAME = camera.x + frameObject.width
    local Y_TOP_FRAME = camera.y
    local Y_BOTTOM_FRAME = camera.y + frameObject.height

    self.divisor = 35
    self.margin = 200
    self.resX = X_RIGHT_FRAME - X_LEFT_FRAME
    self.resY = Y_BOTTOM_FRAME - Y_TOP_FRAME
    self.XR = Distance((X_LEFT_FRAME + (X_RIGHT_FRAME / 2)) - self.margin, 0, X_LEFT_FRAME, 0) / (self.divisor + 0.0)
    self.XL = self.XR * -1
    self.YB = Distance((Y_TOP_FRAME + (Y_BOTTOM_FRAME / 2)) - (self.margin / (self.resX / (self.resY + 0.0))), 0, Y_TOP_FRAME, 0) / (self.divisor + 0.0)
    self.YT = self.YB * -1
    return self
end

function CameraController:update(elapsed)
    
end

return CameraController