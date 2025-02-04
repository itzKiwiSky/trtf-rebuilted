SystemCheckState = {}

local sunLogo = [[
                ██                
    ██          ██           ██   
      ██        ██         ██     
        ██               ██       
             ████████             
           ██        ██           
         ██   ██  ██   ██         
█████    ██            ██  ███████
         ██   █    █   ██         
         ██    ████    ██         
           ██        ██           
             ████████             
        ██               ██       
      ██        ██         ██     
    ██          ██           ██   
                ██                
]]

local lovelogo = [[
    ████      ████    
  ██▒▒▒▒██  ██▒▒▒▒██  
██▒▒▒▒▒▒▒▒██▒▒▒▒▒▒▓▓██
██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓██
██▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓██
██▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓██
  ██▒▒▒▒▓▓▓▓▓▓▓▓▓▓██  
    ██▓▓▓▓▓▓▓▓▓▓██    
      ██▓▓▓▓▓▓██      
        ██▓▓██        
          ██          
]]



local function fnull()end

function SystemCheckState:enter()
    self.gameRun = true
    local syssupport = love.graphics.getSupported()
    local syslimits = love.graphics.getSystemLimits()

    if not syssupport.fullnpot or syslimits.texturesize < 1900 then
        self.gameRun = false

        love.mousepressed = fnull
        love.mousereleased = fnull
        love.keypressed = fnull
        love.keyreleased = fnull

        love.window.showMessageBox("[Runtime Error]", "The engine can't be initialized due invalid resources limits on this device!", "error")
    else
        gamestate.switch(SplashState)
    end
end

function SystemCheckState:update(elapsed)
    if self.gameRun then
        self.terminal:update(elapsed)
        self.animTimer:update(elapsed)
    else
        love.event.quit()
    end
end

return SystemCheckState