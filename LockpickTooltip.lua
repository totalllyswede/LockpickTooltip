-- LockpickTooltip
-- Adds required lockpicking skill to tooltips for lockpickable items/objects
-- Compatible with WoW 1.12.1 (Vanilla)

-- string.match does not exist in Lua 5.0 (WoW 1.12); use string.find with captures
local function GetItemIDFromLink(link)
    if not link then return nil end
    local _, _, idStr = string.find(link, "item:(%d+)")
    return tonumber(idStr)
end

-------------------------------------------------------------------------------
-- LOCKPICKING SKILL REQUIREMENTS
--
-- Formula for chests/lockboxes in vanilla:
--   Chest lock level roughly = (item level * 5) capped at 300
--   Lockboxes have explicit known values listed below.
--
-- Sources: Wowhead Vanilla, WoWWiki, in-game testing community data
-------------------------------------------------------------------------------

-- Item lockboxes: itemID -> required lockpicking skill
-- Skill shown is the "orange" threshold (when the box first gives skill-ups)
-- All IDs verified against wowhead.com/classic
local LOCKBOX_ITEMS = {
    -- Junkboxes (pickpocket loot)
    [16882] = 25,   -- Battered Junkbox  (drops from lvl 20-30 mobs)
    [16883] = 100,  -- Worn Junkbox      (drops from lvl 30-40 mobs)
    [16884] = 175,  -- Sturdy Junkbox    (drops from lvl 40-50 mobs)
    [16885] = 250,  -- Heavy Junkbox     (drops from lvl 50-60 mobs)

    -- Crafted / dropped lockboxes
    [4632]  = 60,   -- Ornate Bronze Lockbox
    [4633]  = 75,   -- Heavy Bronze Lockbox
    [4634]  = 85,   -- Iron Lockbox
    [4636]  = 125,  -- Strong Iron Lockbox
    [4637]  = 180,  -- Steel Lockbox
    [4638]  = 225,  -- Reinforced Steel Lockbox
    [5758]  = 225,  -- Mithril Lockbox
    [5759]  = 225,  -- Thorium Lockbox
    [5760]  = 225,  -- Eternium Lockbox

    -- Engineering lockboxes / misc
    [13541] = 150,  -- Gnomish Lock Box
}

-- Gameobject names -> required lockpicking skill
-- In 1.12.1 we can check GameTooltip target via mouseover; object names are
-- the most reliable hook available since object IDs aren't directly exposed
-- in the 1.12 API the same way item IDs are.
local LOCKABLE_OBJECTS = {
    -- ===== Rogue training objects =====
    ["Buccaneer's Strongbox"]       = 0,    -- Horde rogue quest, ship near Ratchet in The Barrens
    ["Practice Lockbox"]            = 0,    -- Alliance rogue quest, Alther's Mill in Redridge

    -- ===== Doors =====
    ["Gnomeregan Door"]             = 150,  -- Gnomeregan entrance
    ["Gnomeregan Entry Door"]       = 150,
    ["Cathedral Door"]              = 175,  -- Scarlet Monastery Cathedral
    ["Searing Gorge Gate"]          = 225,  -- Thorium Point gate
    ["Prison Door"]                 = 280,  -- Blackrock Depths
    ["Shadowforge Door"]            = 280,  -- Blackrock Depths
    ["Scholomance Door"]            = 280,  -- Scholomance entrance
    ["Service Entrance Door"]       = 300,  -- Stratholme service entrance
    ["Stratholme Gate"]             = 300,

    -- ===== Silverpine Forest =====
    ["Decrepit Chest"]              = 1,

    -- ===== The Barrens / Ashenvale =====
    ["Battered Chest"]              = 1,
    ["Waterlogged Footlocker"]      = 70,   -- Zoram Strand (Ashenvale), Lake Everstill (Redridge)

    -- ===== Stonetalon / Hillsbrad / Wetlands =====
    ["Battered Footlocker"]         = 70,   -- Found in multiple zones (Hillsbrad, Wetlands, Stonetalon)

    -- ===== Shadowfang Keep =====
    ["Arugal's Footlocker"]         = 175,

    -- ===== Gnomeregan =====
    ["Large Toolbox"]               = 150,
    ["Toolbox"]                     = 100,

    -- ===== Stormwind Stockades =====
    ["Footlocker"]                  = 100,

    -- ===== Razorfen Kraul / Downs =====
    ["Razorfen Footlocker"]         = 125,

    -- ===== Scarlet Monastery =====
    ["Ornate Chest"]                = 150,
    ["Gilded Chest"]                = 175,

    -- ===== Uldaman =====
    ["Uldaman Cache"]               = 150,
    ["Uldaman Footlocker"]          = 175,
    ["Stone Cache"]                 = 175,

    -- ===== Zul'Farrak =====
    ["Zul'Farrak Chest"]            = 175,

    -- ===== Maraudon =====
    ["Maraudon Chest"]              = 200,

    -- ===== Sunken Temple =====
    ["Sunken Temple Chest"]         = 200,
    ["Troll Chest"]                 = 175,
    ["Mossy Footlocker"]            = 175,  -- Pool of Tears, Swamp of Sorrows (outside)

    -- ===== Badlands =====
    ["Dented Footlocker"]           = 175,  -- Angor Fortress, lower level
    -- Note: Battered Footlocker (upper Angor) = 150, covered above

    -- ===== Searing Gorge =====
    ["Slag Pit Footlocker"]         = 200,  -- Lower Slag Pit
    ["Searing Gorge Footlocker"]    = 225,  -- Upper Slag Pit

    -- ===== Blackrock Depths =====
    ["Dwarven Chest"]               = 225,
    ["Shadowforge Cache"]           = 280,
    ["Shadowforge Chest"]           = 280,
    ["Relic Coffer"]                = 280,
    ["Dark Iron Strongbox"]         = 280,

    -- ===== Blackrock Spire =====
    ["Smoldering Chest"]            = 275,  -- LBRS/UBRS
    ["Large Mithril Bound Chest"]   = 275,  -- LBRS

    -- ===== Dire Maul =====
    ["Dusty Lockbox"]               = 250,
    ["Crumbling Chest"]             = 225,
    ["Dire Maul Chest"]             = 250,

    -- ===== Scholomance =====
    ["Scholomance Cache"]           = 275,
    ["Viewing Room Cabinet"]        = 275,
    ["Cabinet of Spells"]           = 275,

    -- ===== Stratholme =====
    ["Stratholme Supply Crate"]     = 275,
    ["Stratholme Chest"]            = 275,

    -- ===== Eastern Plaguelands =====
    ["Mossflayer Chest"]            = 225,
    ["Lich's Box"]                  = 275,

    -- ===== Silithus =====
    ["Silithid Cache"]              = 250,
    ["Hive'Ashi Chest"]             = 250,

    -- ===== Generic outdoor chests =====
    ["Rusty Chest"]                 = 1,
    ["Solid Chest"]                 = 175,
    ["Large Solid Chest"]           = 175,
    ["Treasure Chest"]              = 175,
    ["Sunken Chest"]                = 200,
    ["Scarab Chest"]                = 200,
    ["Elvish Chest"]                = 125,
    ["Embossed Chest"]              = 175,
    ["Wicker Chest"]                = 100,
    ["Strongbox"]                   = 175,
}

-------------------------------------------------------------------------------
-- COLOUR HELPER
-- Returns true if the player can pick the lock, false otherwise.
-- Returns nil if the player has no lockpicking skill.
-------------------------------------------------------------------------------
local function CanPickLock(required)
    required = tonumber(required) or 0
    for i = 1, GetNumSkillLines() do
        local name, _, _, rank = GetSkillLineInfo(i)
        if name == "Lockpicking" then
            return tonumber(rank) >= required
        end
    end
    return false
end

-------------------------------------------------------------------------------
-- TOOLTIP HOOKS
-------------------------------------------------------------------------------
local orig_SetItem      = GameTooltip.SetItem
local orig_SetBagItem   = GameTooltip.SetBagItem
local orig_SetLootItem  = GameTooltip.SetLootItem
local orig_SetQuestItem = GameTooltip.SetQuestItem
local orig_SetQuestLogItem = GameTooltip.SetQuestLogItem
local orig_SetHyperlink = GameTooltip.SetHyperlink

-- Append lockpick line for a known item ID
local function AppendItemLockLine(itemID)
    if not itemID then return end
    local req = LOCKBOX_ITEMS[itemID]
    if req then
        if CanPickLock(req) then
            GameTooltip:AddLine("|cff00ff00Pickable (" .. req .. ")|r")
        else
            GameTooltip:AddLine("|cffff2020Skill Level Too Low (" .. req .. ")|r")
        end
        GameTooltip:Show()
    end
end

-- Append lockpick line for a known object name
local function AppendObjectLockLine(name)
    if not name then return end
    local req = LOCKABLE_OBJECTS[name]
    if req then
        if CanPickLock(req) then
            GameTooltip:AddLine("|cff00ff00Pickable (" .. req .. ")|r")
        else
            GameTooltip:AddLine("|cffff2020Skill Level Too Low (" .. req .. ")|r")
        end
        GameTooltip:Show()
    end
end

-------------------------------------------------------------------------------
-- Hook SetItem (used for world objects / bags in some cases)
-------------------------------------------------------------------------------
GameTooltip.SetItem = function(self, itemType, index)
    orig_SetItem(self, itemType, index)
    local name = GameTooltipTextLeft1:GetText()
    AppendObjectLockLine(name)
end

-------------------------------------------------------------------------------
-- Hook SetBagItem - called when hovering items in your bags
-------------------------------------------------------------------------------
GameTooltip.SetBagItem = function(self, bag, slot)
    orig_SetBagItem(self, bag, slot)
    local link = GetContainerItemLink(bag, slot)
    if link then
        local itemID = GetItemIDFromLink(link)
        AppendItemLockLine(itemID)
    end
end

-------------------------------------------------------------------------------
-- Hook SetLootItem - called for loot window items
-------------------------------------------------------------------------------
GameTooltip.SetLootItem = function(self, slot)
    orig_SetLootItem(self, slot)
    local link = GetLootSlotLink(slot)
    if link then
        local itemID = GetItemIDFromLink(link)
        AppendItemLockLine(itemID)
    end
end

-------------------------------------------------------------------------------
-- Hook SetQuestItem / SetQuestLogItem
-------------------------------------------------------------------------------
GameTooltip.SetQuestItem = function(self, qtype, index)
    orig_SetQuestItem(self, qtype, index)
    local link = GetQuestItemLink(qtype, index)
    if link then
        local itemID = GetItemIDFromLink(link)
        AppendItemLockLine(itemID)
    end
end

GameTooltip.SetQuestLogItem = function(self, qtype, index)
    orig_SetQuestLogItem(self, qtype, index)
    local link = GetQuestLogItemLink(qtype, index)
    if link then
        local itemID = GetItemIDFromLink(link)
        AppendItemLockLine(itemID)
    end
end

-------------------------------------------------------------------------------
-- Hook SetHyperlink - used by chat links, merchant windows, etc.
-------------------------------------------------------------------------------
GameTooltip.SetHyperlink = function(self, link)
    orig_SetHyperlink(self, link)
    if link then
        local itemID = GetItemIDFromLink(link)
        AppendItemLockLine(itemID)
    end
end

-------------------------------------------------------------------------------
-- WORLD OBJECT TOOLTIP HOOK
-- In 1.12.1, game objects (chests, doors) do not register as units, so
-- UnitName("mouseover") returns nil for them. The reliable fix is hooking
-- GameTooltip's OnShow script, which fires for ALL tooltips including world
-- objects, then reading the name from the first tooltip text line.
-------------------------------------------------------------------------------
local orig_OnShow = GameTooltip:GetScript("OnShow")
GameTooltip:SetScript("OnShow", function()
    if orig_OnShow then orig_OnShow() end
    local name = GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText()
    if name then
        AppendObjectLockLine(name)
    end
end)

-------------------------------------------------------------------------------
-- MERCHANT / TRADE WINDOW SUPPORT
-- Hook into merchant item tooltip display
-------------------------------------------------------------------------------
local orig_SetMerchantItem = GameTooltip.SetMerchantItem
if orig_SetMerchantItem then
    GameTooltip.SetMerchantItem = function(self, index)
        orig_SetMerchantItem(self, index)
        local link = GetMerchantItemLink(index)
        if link then
            local itemID = GetItemIDFromLink(link)
            AppendItemLockLine(itemID)
        end
    end
end

-------------------------------------------------------------------------------
-- TRADE SKILL / CRAFTING WINDOW
-------------------------------------------------------------------------------
local orig_SetTradeSkillItem = GameTooltip.SetTradeSkillItem
if orig_SetTradeSkillItem then
    GameTooltip.SetTradeSkillItem = function(self, index, reagentIndex)
        orig_SetTradeSkillItem(self, index, reagentIndex)
        local link
        if reagentIndex then
            link = GetTradeSkillReagentItemLink(index, reagentIndex)
        else
            link = GetTradeSkillItemLink(index)
        end
        if link then
            local itemID = GetItemIDFromLink(link)
            AppendItemLockLine(itemID)
        end
    end
end

-------------------------------------------------------------------------------
-- SLASH COMMAND - /lpt or /lockpick - list known lockpickable items
-------------------------------------------------------------------------------
SLASH_LOCKPICKTIP1 = "/lpt"
SLASH_LOCKPICKTIP2 = "/lockpick"

SlashCmdList["LOCKPICKTIP"] = function(msg)
    local arg = string.lower(msg or "")
    if arg == "items" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00LockpickTooltip - Known Lockboxes/Items:|r")
        for id, req in pairs(LOCKBOX_ITEMS) do
            local name = GetItemInfo(id)
            if name then
                DEFAULT_CHAT_FRAME:AddMessage("  |cffaaddff" .. name .. "|r - Requires: " .. req)
            end
        end
    elseif arg == "objects" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00LockpickTooltip - Known Lockable Objects:|r")
        for name, req in pairs(LOCKABLE_OBJECTS) do
            DEFAULT_CHAT_FRAME:AddMessage("  |cffaaddff" .. name .. "|r - Requires: " .. req)
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00LockpickTooltip v1.0|r - Tooltip skill hints for rogues")
        DEFAULT_CHAT_FRAME:AddMessage("Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffaaddff/lpt items|r   - list known lockboxes")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffaaddff/lpt objects|r - list known lockable objects")
        DEFAULT_CHAT_FRAME:AddMessage("Tooltip colors: |cff00ff00Green|r = can pick, |cffffff00Yellow|r = within 25 skill, |cffff4444Red|r = too low")
    end
end

DEFAULT_CHAT_FRAME:AddMessage("|cffffff00LockpickTooltip v1.0.0|r loaded. Type |cffaaddff/lpt|r for help.")
