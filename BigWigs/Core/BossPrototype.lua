-------------------------------------------------------------------------------
-- Prototype
--

local debug = true -- Set to true to get (very spammy) debug messages.
local dbgStr = "[DBG:%s] %s"
local function dbg(self, msg)
	print(dbgStr:format(self.displayName, msg))
end

local AL = LibStub("AceLocale-3.0")
local core = BigWigs
local C = core.C
local metaMap = {__index = function(t, k)
	t[k] = {}
	return t[k]
end}
local combatLogMap = setmetatable({}, metaMap)
local yellMap = setmetatable({}, metaMap)
local emoteMap = setmetatable({}, metaMap)
local deathMap = setmetatable({}, metaMap)

local iconString = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d.blp:15:-5\124t %s"

local boss = {}
core.bossCore:SetDefaultModulePrototype(boss)
function boss:IsBossModule()
	return true
end
function boss:OnInitialize()
	core:RegisterBossModule(self)
end
function boss:OnEnable()
	if debug then
		dbg(self, "OnEnable()")
	end
	if type(self.OnBossEnable) == "function" then
		self:OnBossEnable()
	end
	self:SendMessage("BigWigs_OnBossEnable", self)
	self.class = select(2, UnitClass("player"))
end
function boss:OnDisable()
	if debug then
		dbg(self, "OnDisable()")
	end
	if type(self.OnBossDisable) == "function" then
		self:OnBossDisable()
	end

	wipe(combatLogMap[self])
	wipe(yellMap[self])
	wipe(emoteMap[self])
	wipe(deathMap[self])

	self:SendMessage("BigWigs_OnBossDisable", self)
end
function boss:GetOption(spellId)
	return self.db.profile[(GetSpellInfo(spellId))]
end
function boss:Reboot()
	if debug then
		dbg(self, ":Reboot()")
	end
	self:Disable()
	self:Enable()
end

function boss:NewLocale(locale, default)
	return AL:NewLocale(self.name, locale, default)
end
function boss:GetLocale()
	return AL:GetLocale(self.name)
end

-------------------------------------------------------------------------------
-- Enable triggers
--

function boss:RegisterEnableMob(...)
	core:RegisterEnableMob(self, ...)
end
function boss:RegisterEnableYell(...)
	core:RegisterEnableYell(self, ...)
end

-------------------------------------------------------------------------------
-- Locals
--

local L = AL:GetLocale("Big Wigs: Common")
local UnitExists = UnitExists
local UnitAffectingCombat = UnitAffectingCombat
local UnitName = UnitName
local GetSpellInfo = GetSpellInfo
local fmt = string.format

-------------------------------------------------------------------------------
-- Combat log related code
--

do
	local modMissingFunction = "Module %q got the event %q (%d), but it doesn't know how to handle it."
	local missingArgument = "Missing required argument when adding a listener to %q."
	local missingFunction = "%q tried to register a listener to method %q, but it doesn't exist in the module."

	function boss:CHAT_MSG_MONSTER_YELL(_, msg, ...)
		if yellMap[self][msg] then
			self[yellMap[self][msg]](self, msg, ...)
		else
			for yell, func in pairs(yellMap[self]) do
				if msg:find(yell) then
					self[func](self, msg, ...)
				end
			end
		end
	end
	function boss:CHAT_MSG_RAID_BOSS_EMOTE(_, msg, ...)
		if emoteMap[self][msg] then
			self[emoteMap[self][msg]](self, msg, ...)
		else
			for yell, func in pairs(emoteMap[self]) do
				if msg:find(yell) then
					self[func](self, msg, ...)
				end
			end
		end
	end

	function boss:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, sGUID, source, sFlags, dGUID, player, dFlags, spellId, spellName, _, secSpellId, buffStack)
		if event == "UNIT_DIED" then
			local numericId = tonumber(dGUID:sub(-12, -7), 16)
			local d = deathMap[self][numericId]
			if not d then return end
			if type(d) == "function" then
				d(numericId, dGUID, player, dFlags)
			else
				self[d](self, numericId, dGUID, player, dFlags)
			end
		else
			local m = combatLogMap[self][event]
			if m and m[spellId] then
				local func = m[spellId]
				if type(func) == "function" then
					func(player, spellId, source, secSpellId, spellName, buffStack, event, sFlags, dFlags, dGUID, sGUID)
				else
					self[func](self, player, spellId, source, secSpellId, spellName, buffStack, event, sFlags, dFlags, dGUID, sGUID)
				end
			end
		end
	end

	function boss:Emote(func, ...)
		if not func then
			error(missingArgument:format(self.moduleName))
		end
		if not self[func] then
			error(missingFunction:format(self.moduleName, func))
		end
		for i = 1, select("#", ...) do
			emoteMap[self][(select(i, ...))] = func
		end
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	end
	function boss:Yell(func, ...)
		if not func then
			error(missingArgument:format(self.moduleName))
		end
		if not self[func] then
			error(missingFunction:format(self.moduleName, func))
		end
		for i = 1, select("#", ...) do
			yellMap[self][(select(i, ...))] = func
		end
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end
	function boss:Log(event, func, ...)
		if not event or not func then
			error(missingArgument:format(self.moduleName))
		end
		if type(func) ~= "function" and not self[func] then
			error(missingFunction:format(self.moduleName, func))
		end
		if not combatLogMap[self][event] then
			combatLogMap[self][event] = {}
		end
		for i = 1, select("#", ...) do
			combatLogMap[self][event][(select(i, ...))] = func
		end
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
	function boss:Death(func, ...)
		if not func then
			error(missingArgument:format(self.moduleName))
		end
		if type(func) ~= "function" and not self[func] then
			error(missingFunction:format(self.moduleName, func))
		end
		for i = 1, select("#", ...) do
			deathMap[self][(select(i, ...))] = func
		end
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

-------------------------------------------------------------------------------
-- Engage / phase / wipe checking + unit scanning
--

do
	local t = {"target", "targettarget", "focus", "focustarget", "mouseover", "mouseovertarget"}
	for i = 1, 4 do
		t[#t + 1] = fmt("boss%d", i)
	end
	for i = 1, 4 do
		t[#t + 1] = fmt("party%dtarget", i)
	end
	for i = 1, 40 do
		t[#t + 1] = fmt("raid%dtarget", i)
	end
	local function findTargetByGUID(id)
		local idType = type(id)
		for i, unit in next, t do
			if UnitExists(unit) and not UnitIsPlayer(unit) then
				local unitId = UnitGUID(unit)
				if idType == "number" then
					unitId = tonumber(unitId:sub(-12, -7), 16)
				end
				if unitId == id then
					return unit
				end
			end
		end
	end
	function boss:GetUnitIdByGUID(mob)
		return findTargetByGUID(mob)
	end

	local scan = nil
	if debug then
		function scan(self)
			local mobs = {}
			local found = nil
			for mobId, entry in pairs(core:GetEnableMobs()) do
				if type(entry) == "table" then
					for i, module in next, entry do
						if module == self.moduleName then
							local unit = findTargetByGUID(mobId)
							if unit and UnitAffectingCombat(unit) then
								mobs[#mobs + 1] = tostring(mobId) .. ":" .. unit
								found = true
							else
								mobs[#mobs + 1] = tostring(mobId) .. ":no target"
								mobs[mobId] = "no target"
							end
						end
					end
				elseif entry == self.moduleName then
					local unit = findTargetByGUID(mobId)
					if unit and UnitAffectingCombat(unit) then
						mobs[#mobs + 1] = tostring(mobId) .. ":" .. unit
						found = true
					else
						mobs[#mobs + 1] = tostring(mobId) .. ":no target"
					end
				end
			end
			dbg(self, "scan data: " .. table.concat(mobs, ","))
			mobs = nil
			return found
		end
	else
		function scan(self)
			for mobId, entry in pairs(core:GetEnableMobs()) do
				if type(entry) == "table" then
					for i, module in next, entry do
						if module == self.moduleName then
							local unit = findTargetByGUID(mobId)
							if unit and UnitAffectingCombat(unit) then
								return unit
							end
							break
						end
					end
				elseif entry == self.moduleName then
					local unit = findTargetByGUID(mobId)
					if unit and UnitAffectingCombat(unit) then
						return unit
					end
				end
			end
		end
	end

	function boss:CheckForEngage()
		if debug then
			dbg(self, ":CheckForEngage initiated.")
		end
		local go = scan(self)
		if go then
			if debug then
				dbg(self, "Engage scan found active boss entities, transmitting engage sync.")
			end
			self:SendMessage("BigWigs_OnBossEngage", self, self.moduleName)
			self:Sync("BossEngaged", self.moduleName)
		else
			if debug then
				dbg(self, "Engage scan did NOT find any active boss entities. Re-scheduling another engage check in 0.5 seconds.")
			end
			self:ScheduleTimer("CheckForEngage", .5)
		end
	end

	-- XXX What if we die and then get battleressed?
	-- XXX First of all, the CheckForWipe every 2 seconds would continue scanning.
	-- XXX Secondly, if the boss module registers for PLAYER_REGEN_DISABLED, it would
	-- XXX trigger again, and CheckForEngage (possibly) invoked, which results in
	-- XXX a new BossEngaged sync -> :Engage -> :OnEngage on the module.
	-- XXX Possibly a concern?
	function boss:CheckForWipe()
		if debug then
			dbg(self, ":CheckForWipe initiated.")
		end
		local go = scan(self)
		if not go then
			if debug then
				dbg(self, "Wipe scan found no active boss entities, rebooting module.")
			end
			if self.OnWipe then
				self:OnWipe()
			end
			self:SendMessage("BigWigs_OnBossWipe", self)
			self:Reboot()
		else
			if debug then
				dbg(self, "Wipe scan found active boss entities (" .. tostring(go) .. "). Re-scheduling another wipe check in 2 seconds.")
			end
			self:ScheduleTimer("CheckForWipe", 2)
		end
	end

	--XXX BIG ASS HACK BECAUSE BLIZZ SCREWED UP
	--XXX GetRaidDifficulty() doesn't update when changing difficulty whilst inside the zone
	function boss:GetInstanceDifficulty()
		local _, instanceType, diff, _, _, heroic, dynamic = GetInstanceInfo()
		if instanceType == "raid" and dynamic and heroic == 1 and diff <= 2 then
			diff = diff + 2
		end
		return type(diff) == "number" and diff or 1
	end

	function boss:Engage()
		if debug then
			dbg(self, ":Engage")
		end
		CombatLogClearEntries()
		if self.OnEngage then
			self:OnEngage(self:GetInstanceDifficulty())
		end
	end

	function boss:Win()
		if debug then
			dbg(self, ":Win")
		end
		if self.OnWin then
			self:OnWin()
		end
		self:SendMessage("BigWigs_OnBossWin", self)
		self:Sync("Death", self.moduleName)
	end

	function boss:SetPhase(phase, voice)
		if (phase or 0) == 0 then
			self.phase = (self.phase or 0) + 1
		else
			self.phase = phase
		end
		if debug then
			dbg(self, ":SetPhase " .. (self.phase or 1))
		end
		self:Voice(voice or ("phase" .. self.phase))
		self:SendMessage("BigWigs_SetStage", self, self.phase)
	end
end

-------------------------------------------------------------------------------
-- Delayed message handling
--

do
	local scheduledMessages = {}
	local function wrapper(module, _, ...)
		module:Message(...)
	end
	-- This should've been a local function, but if we do it this way then AceTimer passes in the correct module for us.
	function boss:ProcessDelayedMessage(text)
		wrapper(self, unpack(scheduledMessages[text]))
		scheduledMessages[text] = nil
	end

	function boss:CancelDelayedMessage(text)
		if scheduledMessages[text] then
			self:CancelTimer(scheduledMessages[text][1], true)
			scheduledMessages[text] = nil
			return true
		end
	end

	-- ... = color, icon, sound, noraidsay, broadcastonly
	function boss:DelayedMessage(key, delay, text, ...)
		if type(delay) ~= "number" then
			error(string.format("Module %s tried to schedule a delayed message with delay as type %q, but it must be a number.", self.moduleName, type(delay)))
		end
		self:CancelDelayedMessage(text)

		local id = self:ScheduleTimer("ProcessDelayedMessage", delay, text)
		scheduledMessages[text] = {id, key, text, ...}
		return id
	end
end

-------------------------------------------------------------------------------
-- Boss module APIs for messages, bars, icons, etc.
--
local silencedOptions = {}
do
	local bwOptionSilencer = CreateFrame("Frame")
	bwOptionSilencer:Hide()
	LibStub("AceEvent-3.0"):Embed(bwOptionSilencer)
	bwOptionSilencer:RegisterMessage("BigWigs_SilenceOption", function(event, key, time)
		if key ~= nil then -- custom bars have a nil key
			silencedOptions[key] = time
			bwOptionSilencer:Show()
		end
	end)
	local total = 0
	bwOptionSilencer:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed
		if total >= 0.5 then
			for k, t in pairs(silencedOptions) do
				local newT = t - total
				if newT < 0 then
					silencedOptions[k] = nil
				else
					silencedOptions[k] = newT
				end
			end
			if not next(silencedOptions) then
				self:Hide()
			end
			total = 0
		end
	end)
end

local function checkFlag(self, key, flag)
	if silencedOptions[key] then return end
	if type(key) == "number" then
		key = GetSpellInfo(key)
	end
	if type(self.db.profile[key]) ~= "number" then
		if debug then
			dbg(self, ("Tried to access %q, but in the database it's a %s."):format(key, type(self.db.profile[key])))
		else
			self.db.profile[key] = self.toggleDefaults[key]
		end
	end
	return bit.band(self.db.profile[key], flag) == flag
end

function boss:OpenProximity(range)
	if not checkFlag(self, "proximity", C.PROXIMITY) then
		return
	end
	self:SendMessage("BigWigs_ShowProximity", self, range)
end
function boss:CloseProximity()
	if not checkFlag(self, "proximity", C.PROXIMITY) then
		return
	end
	self:SendMessage("BigWigs_HideProximity")
end

function boss:Message(key, text, color, icon, sound, noraidsay, broadcastonly)
	if not checkFlag(self, key, C.MESSAGE) then return end
	self:SendMessage("BigWigs_Message", self, key, text, color, noraidsay, sound, broadcastonly, icon)
end

-- Outputs a local message only, no raid warning.
function boss:LocalMessage(key, text, color, icon, sound)
	if not checkFlag(self, key, C.MESSAGE) then
		return
	end
	self:SendMessage("BigWigs_Message", self, key, text, color, true, sound, nil, icon)
end

do
	local hexColors = {}
	for k, v in pairs(RAID_CLASS_COLORS) do
		hexColors[k] = "|cff" .. string.format("%02x%02x%02x", v.r * 255, v.g * 255, v.b * 255)
	end
	local coloredNames = setmetatable({}, {__index = function(self, key)
		if type(key) == "nil" then
			return nil
		end

		local name, icon, class
		if type(key) == "table" then
			name, icon, class = key[1], key[2], key[3]
		else
			name, icon, class = key, nil, nil
		end

		class = class or select(2, UnitClass(name))
		if class then
			self[name] = hexColors[class] .. name .. "|r"
			return icon and fmt(iconString, icon, self[name]) or self[name]
		end

		return icon and fmt(iconString, icon, name) or name
	end})

	local mt = {__newindex = function(self, key, value)
		rawset(self, key, coloredNames[value])
	end}
	function boss:NewTargetList()
		return setmetatable({}, mt)
	end

	function boss:TargetMessage(key, spellName, player, color, icon, sound, ...)
		if not checkFlag(self, key, C.MESSAGE) then return end
		if type(player) == "table" then
			local text = fmt(L["other"], spellName, table.concat(player, ", "))
			wipe(player)
			self:SendMessage("BigWigs_Message", self, key, text, color, nil, sound, nil, icon)
		else
			if UnitIsUnit(player, "player") then
				if ... then
					local text = fmt(spellName, coloredNames[player], ...)
					self:SendMessage("BigWigs_Message", self, key, text, color, true, sound, nil, icon)
					self:SendMessage("BigWigs_Message", self, key, text, nil, nil, nil, true)
				else
					self:SendMessage("BigWigs_Message", self, key, fmt(L["you"], spellName), color, true, sound, nil, icon)
					self:SendMessage("BigWigs_Message", self, key, fmt(L["other"], spellName, player), nil, nil, nil, true)
				end
			else
				-- Change color and remove sound when warning about effects on other players
				if color == "Personal" then
					color = "Important"
				end
				local text = nil
				if ... then
					text = fmt(spellName, coloredNames[player], ...)
				else
					text = fmt(L["other"], spellName, coloredNames[player])
				end
				self:SendMessage("BigWigs_Message", self, key, text, color, nil, nil, nil, icon)
			end
		end
	end
end

function boss:FlashShake(key, r, g, b)
	if not checkFlag(self, key, C.FLASHSHAKE) then
		return
	end
	self:SendMessage("BigWigs_FlashShake", self, key)
end

function boss:Say(key, msg)
	if not checkFlag(self, key, C.SAY) then
		return
	end
	SendChatMessage(msg, "SAY")
end

do
	local icons = setmetatable({}, {__index = function(self, key)
		if not key then return end
		local value = nil
		if type(key) == "number" then
			value = select(3, GetSpellInfo(key))
		else
			value = "Interface\\Icons\\" .. key
		end
		self[key] = value
		return value
	end})

	function boss:Bar(key, text, length, icon, barColor, barEmphasized, barText, barBackground, ...)
		if checkFlag(self, key, C.BAR) then
			self:SendMessage("BigWigs_StartBar", self, key, text, length, icons[icon], ...)
		end
	end

	function boss:StopBar(key)
		if checkFlag(self, key, C.BAR) then
			self:SendMessage("BigWigs_StopBar", self, key)
		end
	end
end

function boss:Voice(key, onYou, delay)
	local filepath
	if onYou == -1 or onYou == "soon" then
		filepath = fmt([[Interface\AddOns\BigWigs\Media\Voices\%ss.mp3]], tostring(key))
	elseif onYou == 0 or onYou == "count" then
		filepath = fmt([[Interface\AddOns\BigWigs\Media\Voices\%sc.mp3]], tostring(key))
	elseif onYou == true or onYou == "you" then
		filepath = fmt([[Interface\AddOns\BigWigs\Media\Voices\%sy.mp3]], tostring(key))
	else
		filepath = fmt([[Interface\AddOns\BigWigs\Media\Voices\%s.mp3]], tostring(key))
	end

	if (delay or 0) > 0 then
		self:ScheduleTimer("SendMessage", delay, self, "BigWigs_Voice", self, filepath)
	else
		self:SendMessage("BigWigs_Voice", self, filepath)
	end
end

function boss:Sync(...)
	core:Transmit(...)
end

do
	local sentWhispers = {}
	local function filter(self, event, msg)
		if sentWhispers[msg] or msg:find("^<BW>") or msg:find("^<DBM>") then
			return true
		end
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)

	function boss:Whisper(key, player, spellName, noName)
		if not checkFlag(self, key, C.WHISPER) then return end
		local msg = noName and spellName or fmt(L["you"], spellName)
		self:SendMessage("BigWigs_Whisper", self, key, player, msg, spellName, noName)
		sentWhispers[msg] = true
		if UnitIsUnit(player, "player") or not UnitIsPlayer(player) or not core.db.profile.whisper then
			return
		end
		if UnitInRaid("player") and not IsRaidLeader() and not IsRaidOfficer() then
			return
		end
		SendChatMessage("<BW> " .. msg, "WHISPER", nil, player)
	end
end

function boss:PrependIcon(num, name)
	return fmt(iconString, num, name)
end

function boss:PrimaryIcon(key, player)
	if key and not checkFlag(self, key, C.ICON) then
		return
	end
	if not player then
		self:SendMessage("BigWigs_RemoveRaidIcon", 1)
	else
		self:SendMessage("BigWigs_SetRaidIcon", player, 1)
	end
end

function boss:SecondaryIcon(key, player)
	if key and not checkFlag(self, key, C.ICON) then return end
	if not player then
		self:SendMessage("BigWigs_RemoveRaidIcon", 2)
	else
		self:SendMessage("BigWigs_SetRaidIcon", player, 2)
	end
end

function boss:AddSyncListener(sync)
	core:AddSyncListener(self, sync)
end

function boss:Berserk(seconds, noEngageMessage, customBoss)
	local boss = customBoss or self.displayName
	if not noEngageMessage then
		-- Engage warning with minutes to enrage
		self:Message("berserk", fmt(L["berserk_start"], boss, seconds / 60), "Attention")
	end

	-- Half-way to enrage warning.
	local half = seconds / 2
	local m = half % 60
	local halfMin = (half - m) / 60
	self:DelayedMessage("berserk", half + m, fmt(L["berserk_min"], halfMin), "Positive")

	self:DelayedMessage("berserk", seconds - 60, L["berserk_min"]:format(1), "Positive")
	self:DelayedMessage("berserk", seconds - 30, L["berserk_sec"]:format(30), "Urgent")
	self:DelayedMessage("berserk", seconds - 10, L["berserk_sec"]:format(10), "Urgent")
	self:DelayedMessage("berserk", seconds - 5, L["berserk_sec"]:format(5), "Important")
	self:DelayedMessage("berserk", seconds, L["berserk_end"]:format(boss), "Important", nil, "Alarm")

	-- There are many Berserks, but we use 26662 because Brutallus uses this one.
	-- Brutallus is da bomb.
	local berserk = GetSpellInfo(26662)
	self:Bar("berserk", berserk, seconds, 26662)
end

-------------------------------------------------------------------------------
-- Extra functions
--

do
	local function raidIterator(groupMembers, uId)
		local a, b = uId:byte(-2, -1)
		local i = (a >= 0x30 and a <= 0x39 and (a - 0x30) * 10 or 0) + b - 0x30
		if i < groupMembers then
			return "raid" .. i + 1, i + 1
		end
	end

	local function partyIterator(groupMembers, uId)
		if not uId then
			return "player", 0
		elseif uId == "player" then
			if groupMembers > 0 then
				return "party1", 1
			end
		else
			local i = uId:byte(-1) - 0x30
			if i < groupMembers then
				return "party" .. i + 1, i + 1
			end
		end
	end

	local function soloIterator(_, state)
		if not state then -- no state == first call
			return "player", 0
		end
	end

	function boss:GetGroupMembers()
		if GetNumRaidMembers() > 0 then
			return raidIterator, GetNumRaidMembers(), "raid0"
		elseif GetNumPartyMembers() then
			return partyIterator, GetNumPartyMembers(), nil
		else
			return soloIterator, nil, nil
		end
	end
end

function boss:GroupInfo()
	local prefix, min, max = "raid", 1, GetNumRaidMembers()
	if max == 0 then
		prefix, min, max = "party", 0, GetNumPartyMembers()
	end
	return prefix, min, max
end

function boss:RaidMode(m10n, m25n, m10h, m25h)
	local mode = GetInstanceDifficulty()
	return mode == 1 and m10n or mode == 2 and m25n or mode == 3 and m10h or mode == 4 and m25h
end

function boss:IsNormal()
	return self:RaidMode(true, true, false, false)
end

function boss:IsHeroic()
	return self:RaidMode(false, false, true, true)
end

function boss:Is10Man()
	return self:RaidMode(true, false, true, false)
end

function boss:Is25Man()
	return self:RaidMode(false, true, false, true)
end

-------------------------------------------------------------------------------
-- Spec
--

do
	function boss:IsMelee()
		return self.class == "ROGUE" or self.class == "WARRIOR" or self.class == "DEATHKNIGHT" or
			(self.class == "PALADIN" and select(3, GetTalentTabInfo(1)) < 51) or
			(self.class == "SHAMAN" and select(3, GetTalentTabInfo(2)) >= 51) or
			(self.class == "DRUID" and select(3, GetTalentTabInfo(2)) >= 51)
	end

	function boss:IsRanged()
		return self.class == "MAGE" or self.class == "HUNTER" or self.class == "WARLOCK" or self.class == "PRIEST" or
			(self.class == "PALADIN" and select(3, GetTalentTabInfo(1)) >= 51) or
			(self.class == "SHAMAN" and select(3, GetTalentTabInfo(2)) < 51) or
			(self.class == "DRUID" and select(3, GetTalentTabInfo(2)) < 51)
	end

	local function getTalentpointsSpent(spellID)
		local spellName = GetSpellInfo(spellID)
		for tabIndex = 1, GetNumTalentTabs() do
			for talentID = 1, GetNumTalents(tabIndex) do
				local name, _, _, _, spent = GetTalentInfo(tabIndex, talentID)
				if (name == spellName) then
					return spent
				end
			end
		end
		return 0
	end

	local function IsDeathKnightTank()
		-- idea taken from addon 'ElitistJerks'
		local tankTalents =
			(getTalentpointsSpent(16271) >= 5 and 1 or 0) + -- Anticipation
			(getTalentpointsSpent(49042) >= 5 and 1 or 0) + -- Toughness
			(getTalentpointsSpent(55225) >= 5 and 1 or 0) -- Blade Barrier
		return tankTalents >= 2
	end

	local function IsDruidTank()
		-- idea taken from addon 'ElitistJerks'
		local tankTalents =
			(getTalentpointsSpent(57881) >= 2 and 1 or 0) + -- Natural Reaction
			(getTalentpointsSpent(16929) >= 3 and 1 or 0) + -- Thick Hide
			(getTalentpointsSpent(61336) >= 1 and 1 or 0) + -- Survival Instincts
			(getTalentpointsSpent(57877) >= 3 and 1 or 0) -- Protector of the Pack
		return tankTalents >= 3
	end

	function boss:IsTank()
		return (self.class == "WARRIOR" and select(3, GetTalentTabInfo(3)) >= 51) or
			(self.class == "DEATHKNIGHT" and IsDeathKnightTank()) or
			(self.class == "PALADIN" and select(3, GetTalentTabInfo(2)) >= 51) or
			(self.class == "DRUID" and select(3, GetTalentTabInfo(2)) >= 51 and IsDruidTank())
	end

	function boss:IsHealer()
		return (self.class == "PALADIN" and select(3, GetTalentTabInfo(1)) >= 51) or
			(self.class == "SHAMAN" and select(3, GetTalentTabInfo(3)) >= 51) or
			(self.class == "DRUID" and select(3, GetTalentTabInfo(3)) >= 51) or
			(self.class == "PRIEST" and select(3, GetTalentTabInfo(3)) < 51)
	end
end