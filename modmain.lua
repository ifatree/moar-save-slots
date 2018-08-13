-- requires
local ImageButton = GLOBAL.require "widgets/imagebutton"
local SlotDetailsScreen = GLOBAL.require "screens/slotdetailsscreen" 
local NewGameScreen = GLOBAL.require "screens/newgamescreen"
local NewIntegratedGameScreen = GLOBAL.require "screens/newintegratedgamescreen"

-- read configured slots amount
local slots = GetModConfigData("Tons_SaveSlots")
GLOBAL.NUM_SAVE_SLOTS = GLOBAL.tonumber(slots)

local function HasDLC()
	return GLOBAL.IsDLCInstalled(GLOBAL.REIGN_OF_GIANTS) or GLOBAL.IsDLCInstalled(GLOBAL.CAPY_DLC)
end

-- new game screen hook
local function LGS_PostConstruct(self)
    self.control_offset = 0

    -- this seems to be the default
    self.controls_per_screen = 4
    if HasDLC() then
        self.controls_per_screen = 5
    end

    -- add up/down buttons
    self.down_button = self.root:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.down_button:SetPosition(275, 0, 0)
    self.down_button:SetOnClick( function() self:Scroll(self.controls_per_screen) end)
    
    self.up_button = self.root:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.up_button:SetPosition(-275, 0, 0)
    self.up_button:SetScale(-1,1,1)
    self.up_button:SetOnClick( function() self:Scroll(-self.controls_per_screen) end)

    function self:OnBecomeActive()
        self:RefreshFiles()
        self._base.OnBecomeActive(self)

        if self.last_slotnum then
            local slotnum = (self.last_slotnum - 1) % self.controls_per_screen
            self.menu.items[slotnum + 1]:SetFocus()
        end
    end

    function self:Scroll(dir)
        self.control_offset = self.control_offset + dir

        if self.control_offset < 0 then
            if GLOBAL.NUM_SAVE_SLOTS % self.controls_per_screen == 0 then
                self.control_offset = GLOBAL.NUM_SAVE_SLOTS - self.controls_per_screen
            else
                self.control_offset = GLOBAL.NUM_SAVE_SLOTS - (GLOBAL.NUM_SAVE_SLOTS % self.controls_per_screen)
            end
        end

        if self.control_offset >= GLOBAL.NUM_SAVE_SLOTS then
            self.control_offset = 0
        end

        self:RefreshFiles()
    end

    function self:RefreshFiles()
        self.menu:Clear()

        local lastIndex = GLOBAL.NUM_SAVE_SLOTS
        if self.control_offset + self.controls_per_screen < GLOBAL.NUM_SAVE_SLOTS then
          lastIndex = self.control_offset + self.controls_per_screen
        end

        for k = self.control_offset + 1, lastIndex do
          local tile = self:MakeSaveTile(k)
          self.menu:AddCustomItem(tile)
        end

        -- fix controller button ordering
        self.menu.items[1]:SetFocusChangeDir(GLOBAL.MOVE_UP, self.up_button)
        self.up_button:SetFocusChangeDir(GLOBAL.MOVE_DOWN, self.menu.items[1])

        self.down_button:SetFocusChangeDir(GLOBAL.MOVE_UP, self.menu.items[#self.menu.items])
        self.menu.items[#self.menu.items]:SetFocusChangeDir(GLOBAL.MOVE_DOWN, self.down_button)

        -- added morgue button
        self.bmenu.items[1]:SetFocusChangeDir(GLOBAL.MOVE_UP, self.down_button)
        self.down_button:SetFocusChangeDir(GLOBAL.MOVE_DOWN, self.bmenu.items[1])

        self.bmenu.items[2]:SetFocusChangeDir(GLOBAL.MOVE_UP, self.bmenu.items[1])
        self.bmenu.items[1]:SetFocusChangeDir(GLOBAL.MOVE_DOWN, self.bmenu.items[2])

        self.up_button:SetFocusChangeDir(GLOBAL.MOVE_UP, self.bmenu.items[2])
        self.bmenu.items[2]:SetFocusChangeDir(GLOBAL.MOVE_DOWN, self.up_button)
    end
    
    function self:OnClickTile(slotnum)
        self.last_slotnum = slotnum
        GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")	
        if not GLOBAL.SaveGameIndex:GetCurrentMode(slotnum) then
            GLOBAL.TheFrontEnd:PushScreen(NewGameScreen(slotnum))
        else
            local DLC = GLOBAL.SaveGameIndex:GetSlotDLC(slotnum)
            local RoG = (DLC ~= nil and DLC.REIGN_OF_GIANTS ~= nil) and DLC.REIGN_OF_GIANTS or false
            local CapyDLC = (DLC ~= nil and DLC.CAPY_DLC ~= nil) and DLC.CAPY_DLC or false
            if RoG == true then
                GLOBAL.EnableDLC(GLOBAL.REIGN_OF_GIANTS)
            elseif RoG == false then
                GLOBAL.DisableDLC(GLOBAL.REIGN_OF_GIANTS)
            end

            if CapyDLC == true then
                GLOBAL.EnableDLC(GLOBAL.CAPY_DLC)
            elseif CapyDLC == false then
                GLOBAL.DisableDLC(GLOBAL.CAPY_DLC)
            end

            if self.menu.items[slotnum - self.control_offset].dlcindicator then
                GLOBAL.TheFrontEnd:PushScreen(SlotDetailsScreen(slotnum, self.menu.items[slotnum - self.control_offset].dlcindicator.texture))
            else
                GLOBAL.TheFrontEnd:PushScreen(SlotDetailsScreen(slotnum))
            end
        end
    end
end

-- glue on LGS hook
AddClassPostConstruct("screens/loadgamescreen", LGS_PostConstruct)

-- save integration screen hook
-- since there is a 'bug' in the SW Merge code, it only merges correctly TO the first 9 slots
-- this is fine, since it leaves one space to re-insert the "NEWWORLD" button,if needed
local function SIS_PostConstruct(self)
    -- someday this can be GLOBAL.NUM_SAVE_SLOTS again
    self.NUM_SAVE_SLOTS = 9
    self.control_offset = 0
    self.controls_per_screen = 5

    -- add up/down buttons
    self.down_button = self.root:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.down_button:SetPosition(275, 0, 0)
    self.down_button:SetOnClick( function() self:Scroll(self.controls_per_screen) end)
    
    self.up_button = self.root:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.up_button:SetPosition(-275, 0, 0)
    self.up_button:SetScale(-1,1,1)
    self.up_button:SetOnClick( function() self:Scroll(-self.controls_per_screen) end)

    function self:OnBecomeActive()
        self:RefreshFiles()
        self._base.OnBecomeActive(self)

        if self.last_slotnum then
            local slotnum = (self.last_slotnum - 1) % self.controls_per_screen
            self.menu.items[slotnum + 1]:SetFocus()
        end
    end

    function self:Scroll(dir)
        self.control_offset = self.control_offset + dir

        if self.control_offset < 0 then
            if self.NUM_SAVE_SLOTS % self.controls_per_screen == 0 then
                self.control_offset = self.NUM_SAVE_SLOTS - self.controls_per_screen
            else
                self.control_offset = self.NUM_SAVE_SLOTS - (self.NUM_SAVE_SLOTS % self.controls_per_screen)
            end
        end

        if self.control_offset >= self.NUM_SAVE_SLOTS then
            self.control_offset = 0
        end

        self:RefreshFiles()
    end

    function self:RefreshFiles()
        self.menu:Clear()

        local lastIndex = self.NUM_SAVE_SLOTS
        if self.control_offset + self.controls_per_screen < self.NUM_SAVE_SLOTS then
          lastIndex = self.control_offset + self.controls_per_screen
        end

        for k = self.control_offset + 1, lastIndex do
          local tile = self:MakeSaveTile(k)
          self.menu:AddCustomItem(tile)
        end

        -- add new world button if missing from list, if needed
        if (self.current_slot > self.NUM_SAVE_SLOTS) and (lastIndex == self.NUM_SAVE_SLOTS) then

            local widget = self:MakeSaveTile(self.NUM_SAVE_SLOTS + 1)
            --self.menu:AddCustomItem(widget)

            local function Control(control, down, cb)
                if control == GLOBAL.CONTROL_ACCEPT then
                    if down then 
                        widget.base:SetPosition(0,-5,0)
                    else
                        widget.base:SetPosition(0,0,0) 
                        cb()
                    end
                    return true
                end
            end

            -- reset properties
            widget.portrait:Hide()
            widget.portraitbg:Hide()

            if HasDLC() then
                widget.bg:SetScale(1,.8,1)
            else
                widget:SetScale(1,1,1)
            end

            if (widget.dlcindicator ~= nil) then
                widget.dlcindicator:Hide()
            end

            widget.text:SetString(GLOBAL.STRINGS.UI.LOADGAMESCREEN.NEWWORLD)
            widget.text:SetPosition(0,0,0)

		    widget.OnControl = function(self, control, down)
				Control(control, down, function()
					local target_mode = "shipwrecked"
					if GLOBAL.SaveGameIndex:IsModeShipwrecked() then
						target_mode = "survival"
					end

					GLOBAL.TheFrontEnd:PushScreen(NewIntegratedGameScreen(target_mode, self.current_slot))
				end)
            end
            
            self.menu:AddCustomItem(widget)
        end

        -- fix controller button ordering
        self.menu.items[1]:SetFocusChangeDir(GLOBAL.MOVE_UP, self.up_button)
        self.up_button:SetFocusChangeDir(GLOBAL.MOVE_DOWN, self.menu.items[1])

        self.down_button:SetFocusChangeDir(GLOBAL.MOVE_UP, self.menu.items[#self.menu.items])
        self.menu.items[#self.menu.items]:SetFocusChangeDir(GLOBAL.MOVE_DOWN, self.down_button)

        self.down_button:SetFocusChangeDir(GLOBAL.MOVE_DOWN, self.bmenu)
        self.bmenu:SetFocusChangeDir(GLOBAL.MOVE_UP, self.down_button)

        self.bmenu:SetFocusChangeDir(GLOBAL.MOVE_DOWN, self.up_button)
        self.up_button:SetFocusChangeDir(GLOBAL.MOVE_UP, self.bmenu)
    end
    
end

-- http://stackoverflow.com/questions/17877224/how-to-prevent-a-lua-script-from-failing-when-a-require-fails-to-find-the-scri
local function prequire(m) 
  local ok, err = GLOBAL.pcall(GLOBAL.require, m) 
  if not ok then return nil, err end
  return err
end

-- only add postconstruct if we're loaded under a DLC that provides it
local script_exists = prequire("screens/saveintegrationscreen")
if script_exists then 
    -- glue on SIS hook
    AddClassPostConstruct("screens/saveintegrationscreen", SIS_PostConstruct)
end
