--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "ISUI/ISPanel"
require "ISUI/ISToolTip"
require "UITransition"

ISMegaVolumeControl = ISPanel:derive("ISMegaVolumeControl")

-- Handles mouse down event
function ISMegaVolumeControl:onMouseDown(x, y)
    local volume = self:getVolumeAtX(self:getMouseX())
    self:setVolume(volume)
    self.dragging = true
    self:setCapture(true)
end

-- Handles mouse up event
function ISMegaVolumeControl:onMouseUp(x, y)
    self.dragging = false
    self:setCapture(false)
end

-- Handles mouse up outside event
function ISMegaVolumeControl:onMouseUpOutside(x, y)
    self.dragging = false
    self:setCapture(false)
end

-- Handles mouse move event
function ISMegaVolumeControl:onMouseMove(dx, dy)
    if self.dragging then
        local volume = self:getVolumeAtX(self:getMouseX())
        self:setVolume(volume)
    end
end

-- Calculates volume based on x position
function ISMegaVolumeControl:getVolumeAtX(x)
    local padX = 8
    local oneTenth = math.floor((self:getWidth() - padX * 2) / 11)
    if oneTenth == 0 then
        return 0
    end
    padX = padX + (self:getWidth() - padX * 2 - oneTenth * 11) / 2
    local volume = math.floor(((x - padX) + oneTenth / 2) / oneTenth)
    if volume < 0 then return 0 end
    if volume > 11 then return 11 end
    return volume
end

-- Pre-renders the volume control
function ISMegaVolumeControl:prerender()
    ISPanel.prerender(self)

    self.fade:setFadeIn(self.joypadFocused or self.dragging or self:isMouseOver())
    self.fade:update()

    if self:isMouseOver() and self.tooltip then
        local text = self.tooltip
        if not self.tooltipUI then
            self.tooltipUI = ISToolTip:new()
            self.tooltipUI:setOwner(self)
            self.tooltipUI:setVisible(false)
            self.tooltipUI:setAlwaysOnTop(true)
            self.tooltipUI:addToUIManager()
        end
        if not self.tooltipUI:getIsVisible() then
            self.tooltipUI:setVisible(true)
        end
        self.tooltipUI:setName(text)
        self.tooltipUI:bringToTop()
    elseif self.tooltipUI then
        self.tooltipUI:setVisible(false)
    end
end

-- Renders the volume control
function ISMegaVolumeControl:render()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    local alpha = math.min(self.borderColor.a + 0.2 * self.fade:fraction(), 1.0)
    self:drawRectBorder(0, 0, self.width, self.height, alpha, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local padX = 8
    local oneTenth = math.floor((self:getWidth() - padX * 2) / 11)
    local sliderWidth = 16
    local sliderPadX = 1
    local sliderPadY = 4
    padX = padX + (self:getWidth() - padX * 2 - oneTenth * 11) / 2
    local sliderX = padX + oneTenth * self.volume - sliderWidth / 2
    local rgb1 = 0.1 + 0.1 * self.fade:fraction()
    local rgb2 = 0.3 + 0.1 * self.fade:fraction()
    self:drawRect(2, sliderPadY, padX - sliderPadX - 2, self:getHeight() - sliderPadY * 2, 1, rgb2, rgb2, rgb2)
    for i = 1, 11 do
        local rgb = (i <= self.volume) and rgb2 or rgb1
        local eleven_vol_red = 0.0
        if ((self.volume > 10) and (i > 10)) then
            eleven_vol_red = 0.5
        end
        self:drawRect(padX + (i - 1) * oneTenth + sliderPadX, sliderPadY, oneTenth - sliderPadX * 2, self:getHeight() - sliderPadY * 2, 1, rgb + eleven_vol_red, rgb, rgb)
    end

    local x = padX + oneTenth * 11 + sliderPadX
    self:drawRect(x, sliderPadY, self:getWidth() - x - 2, self:getHeight() - sliderPadY * 2, 1, rgb1, rgb1, rgb1)
    self:drawRect(sliderX, 2, sliderWidth, self:getHeight() - 2 * 2, 1.0, 0.85, 0.56, 0.03) -- gold
    self:drawRect(sliderX, 2, sliderWidth, 1, 1.0, 0.85, 0.56, 0.03) -- gold
    self:drawRect(sliderX + sliderWidth - 1, 2, 1, self:getHeight() - 2 * 2, 1.0, 0.85, 0.56, 0.03) -- gold
    self:drawRect(sliderX, 2, 1, self:getHeight() - 2 * 2, 1.0, 0.85, 0.56, 0.03) -- gold
    self:drawRect(sliderX, self:getHeight() - 2 - 1, sliderWidth, 1, 1.0, 0.85, 0.56, 0.03) -- gold
end

-- Gets the current volume
function ISMegaVolumeControl:getVolume()
    return self.volume
end

-- Sets the volume
function ISMegaVolumeControl:setVolume(volume)
    if volume >= 0 and volume <= 11 and volume ~= self.volume then
        self.volume = volume
        if self.targetFunc then
            self.targetFunc(self.target, self, self.volume)
        end
    end
end

-- Sets joypad focus
function ISMegaVolumeControl:setJoypadFocused(focused)
    self.joypadFocused = focused
end

-- Handles joypad left direction
function ISMegaVolumeControl:onJoypadDirLeft(joypadData)
    self:setVolume(self.volume - 1)
end

-- Handles joypad right direction
function ISMegaVolumeControl:onJoypadDirRight(joypadData)
    self:setVolume(self.volume + 1)
end

-- Constructor for ISMegaVolumeControl
function ISMegaVolumeControl:new(x, y, width, height, target, targetFunc)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r = 0.0, g = 0.0, b = 0.0, a = 0.8} --black
    o.borderColor = {r = 0.0, g = 0.0, b = 0.0, a = 0.8} --black
    o.volume = 0
    o.target = target
    o.targetFunc = targetFunc
    o.fade = UITransition.new()
    o.isSlider = true
    return o
end
