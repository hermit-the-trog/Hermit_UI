------------------------------------------
-- SpiffUI Main Radial
----  One Radial to Rule Them All
-- Hermit edit this
------------------------------------------

SpiffUI = SpiffUI or {}

-- Register our Radials
local spiff = SpiffUI:Register("radials")

-- Add proper requires
-- require "ISUI/ISHotbar"  -- Wrong path
require "Hotbar/ISHotbar"  -- Correct path for Project Zomboid's structure

local SpiffUIOneRadial = spiff.radialmenu:derive("SpiffUIOneRadial")

------------------------------------------

local SpiffUIOneRadialCommand = spiff.radialcommand:derive("SpiffUIOneRadialCommand")

function SpiffUIOneRadialCommand:Action()
    local radial = spiff.radials[self.mode]
    if radial then
        local menu = radial:new(self.player, self.menu)
        menu:display()
    end

end

function SpiffUIOneRadialCommand:new(menu, name, texture, mode)
    local o = spiff.radialcommand.new(self, menu, name, texture, nil)
    o.mode = mode
    return o
end

local function getBestClock(player)
    local watch = nil

    local items = player:getInventory():getAllEval(function(item)
        return instanceof(item, "AlarmClock") or instanceof(item, "AlarmClockClothing")
    end)

    if items and items:size() > 0 then
        for i = 0, items:size()-1 do
            local item = items:get(i)
            if not watch then
                watch = item
            else
                -- Check to always get best clock in inventory
                if (not watch:isDigital() or instanceof(item, "AlarmClock")) and (item:isDigital() and instanceof(item, "AlarmClockClothing")) then
                    watch = item
                end
            end
            if player:isEquipped(item) then
                watch = item
                break
            end
        end
    end
    return watch
end

function SpiffUIOneRadial:show()
    spiff.radialmenu.show(self)
    self.rmenu:setClock(getBestClock(self.player))
end

function SpiffUIOneRadial:start()

    -- Crafting
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Crafting"), getTexture("media/radialicons/craftiing_hermit.png"), 0))
    -- Drink
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Drink"), getTexture("media/radialicons/water_hermit.png"), 1))
    -- Eat
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Eat"), getTexture("media/radialicons/food_hermit.png"), 2))
    -- Equipment
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Equipment"), getTexture("media/radialicons/inventory_hermit.png"), 3))
    -- First Aid Craft
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_FirstAidCraft"), getTexture("media/radialicons/bandage_hermit.png"), 4))
    -- Pills
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Pills"), getTexture("media/radialicons/pills_hermit.png"), 5))
    -- Repair
    self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Repair"), getTexture("media/radialicons/hammer_hermit.png"), 6))

    if spiff.config.showSmokeCraftRadial then
        local icon = nil
        if getActivatedMods():contains('jiggasGreenfireMod') then
            icon = getTexture("media/radialicons/smokecraft_hermit.png")
        elseif getActivatedMods():contains('Smoker') then
            icon = getTexture("media/radialicons/smokecraft_hermit.png")
        elseif getActivatedMods():contains('MoreCigsMod') then
            icon = getTexture("media/radialicons/smokecraft_hermit.png")
        else
            icon = getTexture("media/radialicons/smokecraft_hermit.png")
        end
        -- Smoke Craft
        self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_SmokeCraft"), icon, 7))
    end

    if spiff.config.showSmokeRadial then
        -- Smoke
        self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_Smoke"), getTexture("media/radialicons/smoke_hermit.png"), 8))
    end

    if spiff.radials[9] then
        self:AddCommand(SpiffUIOneRadialCommand:new(self, "Clothing Action Radial Menu", getTexture("media/radialicons/clothing_hermit.png"), 9))
    end

    if UIManager.getSpeedControls() and not isClient() then
        self:AddCommand(SpiffUIOneRadialCommand:new(self, getText("UI_SpiffUI_Radial_GameSpeed"), getTexture("media/radialicons/SleepClock1.png"), 10))
    end
end

function SpiffUIOneRadial:new(player)
    local o = spiff.radialmenu.new(self, player)

    o.icons = {
        ["mid"] = getTexture("media/radialicons/clock/mid.png"),
        ["date"] = getTexture("media/radialicons/clock/slash.png"),
        ["dot"] = getTexture("media/radialicons/clock/dot.png"),
        ["F"] = getTexture("media/radialicons/clock/F.png"),
        ["C"] = getTexture("media/radialicons/clock/C.png"),
        ["silence"] = getTexture("media/ui/ClockAssets/ClockAlarmLargeSet.png"),
        ["enable"] = getTexture("media/ui/ClockAssets/ClockAlarmLargeSound.png"),
    }
    for i=0,9 do
        o.icons[i] =  getTexture(string.format("media/radialicons/clock/%d.png", i))
    end

    return o
end

local function OneDown(player)
    SpiffUI.onKeyDown(player)
    -- if we're not ready, then we're doing an action.
    ---- do it now
    if not SpiffUI.action.ready then
        if UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then
            if not isClient() then
                spiff.radials[10]:new(player):display()
            else
                return
            end
        else
            SpiffUIOneRadial:new(player):display()
        end
        -- Ready for another action
        SpiffUI.action.ready = true
    end
end

------------------------------------------
--- For the DPad
local function showRadialMenu(player)
    if not player or player:isDead() then
        return
    end

    if UIManager.getSpeedControls() and (UIManager.getSpeedControls():getCurrentGameSpeed() == 0) then
        if not isClient() then
            spiff.radials[10]:new(player):display()
        end
        return
    end

    SpiffUIOneRadial:new(player):display()
end

---- Show the Radial Menu on the Up DPad when there's not a car around
local _ISDPadWheels_onDisplayUp = ISDPadWheels.onDisplayUp
function ISDPadWheels.onDisplayUp(joypadData)
    local player = getSpecificPlayer(joypadData.player)
    if not player:getVehicle() and not ISVehicleMenu.getVehicleToInteractWith(player) then
        showRadialMenu(player)
    else
        _ISDPadWheels_onDisplayUp(joypadData)
    end
end

local function actionInit()
    local bind = {
        name = 'SpiffUIOneWheel',
        key = Keyboard.KEY_NONE, -- ;
        queue = true,
        allowPause = true,
        Down = OneDown
    }
    SpiffUI:AddKeyBind(bind)
end

actionInit()