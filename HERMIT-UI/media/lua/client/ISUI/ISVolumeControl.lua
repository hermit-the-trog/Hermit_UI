--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "ISUI/ISPanel"

ISVolumeControl = ISPanel:derive("ISVolumeControl")

-- Function to handle mouse button press
function ISVolumeControl:onMouseDown(x, y)
    local volume = self:getVolumeAtX(self:getMouseX()) -- Get volume level based on mouse X position
    self:setVolume(volume) -- Set the volume to the calculated level
    self.dragging = true -- Set dragging to true to indicate the user is dragging the slider
    self:setCapture(true) -- Capture mouse events
end

-- Function to handle mouse button release
function ISVolumeControl:onMouseUp(x, y)
    self.dragging = false -- Set dragging to false to indicate the user stopped dragging
    self:setCapture(false) -- Release mouse capture
end

-- Function to handle mouse button release outside the control
function ISVolumeControl:onMouseUpOutside(x, y)
    self.dragging = false -- Set dragging to false to indicate the user stopped dragging
    self:setCapture(false) -- Release mouse capture
end

-- Function to handle mouse movement
function ISVolumeControl:onMouseMove(dx, dy)
    if self.dragging then -- Check if the user is dragging the slider
        local volume = self:getVolumeAtX(self:getMouseX()) -- Get volume level based on mouse X position
        self:setVolume(volume) -- Set the volume to the calculated level
    end
end

-- Function to calculate volume level based on X position
function ISVolumeControl:getVolumeAtX(x)
    local padX = 8 -- Padding on the X axis
    local oneTenth = math.floor((self:getWidth() - padX * 2) / 10) -- Width of one volume level segment
    padX = padX + (self:getWidth() - padX * 2 - oneTenth * 10) / 2 -- Adjust padding to center the segments
    local volume = math.floor(((x - padX) + oneTenth / 2) / oneTenth) -- Calculate volume level based on X position
    if volume < 0 then return 0 end -- Ensure volume is not less than 0
    if volume > 10 then return 10 end -- Ensure volume is not more than 10
    return volume -- Return the calculated volume level
end

-- Function to render the volume control
function ISVolumeControl:prerender()
    ISPanel.prerender(self) -- Call the parent class's prerender function

    self.fade:setFadeIn(self.joypadFocused or self.dragging or self:isMouseOver()) -- Set fade-in effect based on focus or interaction
    self.fade:update() -- Update the fade effect

    if self:isMouseOver() and self.tooltip then -- Check if the mouse is over the control and a tooltip is set
        local text = self.tooltip -- Get the tooltip text
        if not self.tooltipUI then -- Check if the tooltip UI is not created
            self.tooltipUI = ISToolTip:new() -- Create a new tooltip UI
            self.tooltipUI:setOwner(self) -- Set the owner of the tooltip UI
            self.tooltipUI:setVisible(false) -- Set the tooltip UI to be invisible initially
            self.tooltipUI:setAlwaysOnTop(true) -- Ensure the tooltip UI is always on top
            self.tooltipUI:addToUIManager() -- Add the tooltip UI to the UI manager
        end
        if not self.tooltipUI:getIsVisible() then -- Check if the tooltip UI is not visible
            self.tooltipUI:setVisible(true) -- Set the tooltip UI to be visible
        end
        self.tooltipUI.description = self.tooltip -- Set the description of the tooltip UI
        self.tooltipUI:setX(self:getMouseX() + 23) -- Set the X position of the tooltip UI
        self.tooltipUI:setY(self:getMouseY() + 23) -- Set the Y position of the tooltip UI
    elseif self.tooltipUI and self.tooltipUI:getIsVisible() then
        self.tooltipUI:setVisible(false) -- Hide the tooltip UI if the mouse is not over the control
    end
end

function ISVolumeControl:render()
    -- Draw the background rectangle
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    
    -- Calculate alpha for the border color with fade effect
    local alpha = math.min(self.borderColor.a + 0.2 * self.fade:fraction(), 1.0)
    
    -- Draw the border rectangle
    self:drawRectBorder(0, 0, self.width, self.height, alpha, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local padX = 8 -- Padding on the X axis
    local oneTenth = math.floor((self:getWidth() - padX * 2) / 10) -- Width of one volume level segment
    local sliderWidth = 16 -- Width of the slider
    local sliderPadY = 4 -- Padding on the Y axis for the slider
    padX = padX + (self:getWidth() - padX * 2 - oneTenth * 10) / 2 -- Adjust padding to center the segments
    local sliderX = padX + oneTenth * self.volume - sliderWidth / 2 -- X position of the slider
    local rgb1 = 0.1 + 0.1 * self.fade:fraction() -- Color for inactive segments
    local rgb2 = 0.3 + 0.1 * self.fade:fraction() -- Color for active segments
    
    -- Draw the left padding rectangle
    self:drawRect(2, sliderPadY, padX - 2, self:getHeight() - sliderPadY * 2, 1, rgb2, rgb2, rgb2)
    
    -- Draw the volume level segments
    for i = 1, 10 do
        local rgb = (i <= self.volume) and rgb2 or rgb1 -- Determine color based on volume level
        self:drawRect(padX + (i - 1) * oneTenth, sliderPadY, oneTenth, self:getHeight() - sliderPadY * 2, 1, rgb, rgb, rgb)
    end

    local x = padX + oneTenth * 10 -- X position for the right padding rectangle
    -- Draw the right padding rectangle
    self:drawRect(x, sliderPadY, self:getWidth() - x - 2, self:getHeight() - sliderPadY * 2, 1, rgb1, rgb1, rgb1)

    -- Draw the slider
    self:drawRect(sliderX, 2, sliderWidth, self:getHeight() - 2 * 2, 1.0, 0.85, 0.56, 0.03) -- gold
    self:drawRect(sliderX, 2, sliderWidth, 1, 1.0, 0.85, 0.56, 0.03) -- gold
    self:drawRect(sliderX + sliderWidth - 1, 2, 1, self:getHeight() - 2 * 2, 1.0, 0.85, 0.56, 0.03) -- gold
    self:drawRect(sliderX, 2, 1, self:getHeight() - 2 * 2, 1.0, 0.85, 0.56, 0.03) -- gold
    self:drawRect(sliderX, self:getHeight() - 2 - 1, sliderWidth, 1, 1.0, 0.85, 0.56, 0.03) -- gold
end

-- Function to get the current volume level
function ISVolumeControl:getVolume()
    return self.volume
end

-- Function to set the volume level
function ISVolumeControl:setVolume(volume)
    if volume >= 0 and volume <= 10 and volume ~= self.volume then -- Ensure volume is within valid range and different from current volume
        self.volume = volume -- Set the volume to the new level
        if self.targetFunc then -- Check if a target function is set
            self.targetFunc(self.target, self, self.volume) -- Call the target function with the new volume
        end
    end
end

function ISVolumeControl:setJoypadFocused(focused)
    self.joypadFocused = focused
end

function ISVolumeControl:onJoypadDirLeft(joypadData)
    self:setVolume(math.max(self.volume - 1, 0))
end

function ISVolumeControl:onJoypadDirRight(joypadData)
    self:setVolume(math.min(self.volume + 1, 10))
end

function ISVolumeControl:new(x, y, width, height, target, targetFunc)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r = 0.0, g = 0.0, b = 0.0, a = 0.8} --black
    o.borderColor = {r = 0.0, g = 0.0, b = 0.0, a = 0.8}
    o.volume = 0
    o.target = target
    o.targetFunc = targetFunc
    o.fade = UITransition.new()
    o.isSlider = true
    return o
end
