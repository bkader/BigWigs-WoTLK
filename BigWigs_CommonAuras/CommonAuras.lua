--[[
--
-- BigWigs Strategy Module - Common Auras
--
-- Gives timer bars and raid messages about common
-- buffs and debuffs.
--
--]]
local name = "Common Auras"

------------------------------
--      Localization        --
------------------------------
local L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs: Common Auras", "enUS", true)
if L then
	L.fw_cast = "%s fearwarded %s."
	L.fw_bar = "%s: Fearwarded"

	L.usedon_cast = "%s: %s on %s"
	L.used_cast = "%s used %s."
	L.used_bar = "%s: %s"

	L.portal = "Portal"
	L.portal_desc = "Toggle showing of mage portals."
	L.portal_cast = "%s opened a %s!" --Player opened a Portal: Destination

	L.repair = "Repair Bot"
	L.repair_desc = "Toggle showing when repair bots are available."

	L.feast = "Feasts"
	L.feast_desc = "Toggle showing when feasts get prepared."
	L.feast_cast = "%s prepared a %s!"

	L["Common Auras"] = true
	L["Group utility"] = true
	L["Tanking cooldowns"] = true
	L["Healing cooldowns"] = true
end

L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs: Common Auras", "ruRU")
if L then
	L.fw_cast = "%s защитил от страха |3-3(%s)."
	L.fw_bar = "%s: восстановление антистраха"

	L.usedon_cast = "%s: %s на %s"
	L.used_cast = "%s использовал %s."
	L.used_bar = "%s: %s"

	L.portal = "Портал"
	L.portal_desc = "Переключение отображения порталов мага."
	L.portal_cast = "%s открыл %s!" --Player opened a Portal: Destination

	L.repair = "Ремонтный робот"
	L.repair_desc = "Вкл/выкл оповещение о доступности ремонтного робота."

	L["Common Auras"] = "Основные ауры"
	L["Group utility"] = "Полезность группы"
	L["Tanking cooldowns"] = "Восстоновления танка"
	L["Healing cooldowns"] = "Восстоновления лекаря"
end

L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs: Common Auras", "zhCN")
if L then
	L.fw_cast = "%s：防护恐惧结界于%s"
	L.fw_bar = "<%s：防护恐惧结界>"

	L.usedon_cast = "%s：%s于%s"
	L.used_cast = " %s使用：%s。"
	L.used_bar = "<%s：%s>"

	L.portal = "传送门"
	L.portal_desc = "打开或关闭显示法师传送门时提示。"
	L.portal_cast = "%s施放了一道%s！"

	L.repair = "修理机器人"
	L.repair_desc = "打开或关闭显示修理机器人可用时提示。"

	L["Common Auras"] = "普通光环"
	L["Group utility"] = "组效果"
	L["Tanking cooldowns"] = "坦克冷却"
	L["Healing cooldowns"] = "治疗冷却"
end

L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs: Common Auras", "zhTW")
if L then
	L.fw_cast = "%s：防護恐懼結界於%s"
	L.fw_bar = "<%s：防護恐懼結界>"

	L.usedon_cast = "%s：%s於%s"
	L.used_cast = " %s使用：%s。"
	L.used_bar = "<%s：%s>"

	L.portal = "傳送門"
	L.portal_desc = "打開或關閉顯示法師傳送門時提示。"
	L.portal_cast = "%s施放了一道%s！"

	L.repair = "修理機器人"
	L.repair_desc = "打開或關閉顯示修理機器人可用時提示。"

	L["Common Auras"] = "共同光環"
	L["Group utility"] = "組效果"
	L["Tanking cooldowns"] = "坦克冷卻"
	L["Healing cooldowns"] = "治療冷卻"
end

L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs: Common Auras", "koKR")
if L then
	L.fw_cast = "%s: %s에게 공포의 수호물"
	L.fw_bar = "%s: 공수 대기시간"

	L.usedon_cast = "%1$s: %3$s에게 %2$s"
	L.used_cast = "%s: %s 사용"
	L.used_bar = "%s: %s"

	L.portal = "차원문"
	L.portal_desc = "마법사의 차원문 표시합니다."
	L.portal_cast = "%s: %s 차원문!"

	L.repair = "수리 로봇"
	L.repair_desc = "수리 로봇 사용시 표시합니다."

	L["Common Auras"] = "공통 버프"
	L["Group utility"] = "그룹에 유용한 것"
	L["Tanking cooldowns"] = "탱킹 재사용 대기시간"
	L["Healing cooldowns"] = "힐링 재사용 대기시간"
end

L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs: Common Auras", "deDE")
if L then
	L.fw_cast = "%s: Furchtschutz auf %s"
	L.fw_bar = "%s: Furchtschutz"

	L.usedon_cast = "%s: %s auf %s"
	L.used_cast = "%s benutzt %s"
	L.used_bar = "%s: %s"

	L.portal = "Portale"
	L.portal_desc = "Zeigt die Portale der Magier an."
	L.portal_cast = "%s öffnet ein %s!"

	L.repair = "Reparaturbots"
	L.repair_desc = "Zeigt Reparaturbots an, sobald sie aufgestellt wurden."

	L.feast = "Festmähler"
	L.feast_desc = "Zeigt Festmähler an, sobald sie zubereitet wurden."
	L.feast_cast = "%s hat ein %s zubereitet!"

	--L["Common Auras"] = true
	L["Group utility"] = "Gruppenwerkzeuge"
	L["Tanking cooldowns"] = "Tank-Cooldowns"
	L["Healing cooldowns"] = "Heil-Cooldowns"
end

L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs: Common Auras", "frFR")
if L then
	L.fw_cast = "%s a protégé %s contre la peur ."
	L.fw_bar = "%s : Recharge Gardien"

	L.usedon_cast = "%s : %s sur %s"
	L.used_cast = "%s a utilisé %s."
	L.used_bar = "%s : %s"

	L.portal = "Portail"
	L.portal_desc = "Prévient ou non quand un mage ouvre un portail."
	L.portal_cast = "%s a ouvert un %s !"

	L.repair = "Robot réparateur"
	L.repair_desc = "Prévient ou non quand un robot réparateur est déployé."

	L["Common Auras"] = "Auras habituelles"
	L["Group utility"] = "Utilité de groupe"
	L["Tanking cooldowns"] = "Temps de recharge de tank"
	L["Healing cooldowns"] = "Temps de recharge de soigneur"
end
L = LibStub("AceLocale-3.0"):GetLocale("Big Wigs: Common Auras")

------------------------------
--      Module              --
------------------------------

local mod = BigWigs:NewPlugin(L[name])
if not mod then
	return
end
mod.toggleOptions = {
	"portal",
	"repair",
	"feast",
	64205,
	32182,
	2825,
	6346,
	871,
	498,
	31850,
	48792,
	61336,
	33206,
	47788,
	29166,
	6940,
	20484
}
mod.optionHeaders = {
	portal = L["Group utility"],
	[871] = L["Tanking cooldowns"],
	[33206] = L["Healing cooldowns"]
}

function mod:GetLocale()
	return L
end

------------------------------
--      Initialization      --
------------------------------

local combatLogMap = {}
function mod:OnRegister()
	combatLogMap.SPELL_CAST_START = {
		[57426] = "Feasts", -- Fish Feast
		[57301] = "Feasts", -- Great Feast
		[66476] = "Feasts" -- Bountiful Feast
	}
	combatLogMap.SPELL_CAST_SUCCESS = {
		[22700] = "Repair",
		[44389] = "Repair",
		[54711] = "Repair",
		[67826] = "Repair",
		[6346] = "FearWard",
		[871] = "ShieldWall",
		[29166] = "Innervate",
		[2825] = "Bloodlust",
		[32182] = "Bloodlust",
		[33206] = "Suppression",
		[47788] = "Guardian",
		[6940] = "Sacrifice",
		[64205] = "DivineSacrifice",
		[498] = "DivineProtection",
		[31850] = "ArdentDefender",
		[48792] = "IceboundFortitude",
		[61336] = "SurvivalInstincts"
	}
	combatLogMap.SPELL_AURA_REMOVED = {
		[6346] = "FearWardOff",
		[47788] = "GuardianOff"
	}
	combatLogMap.SPELL_CREATE = {
		[11419] = "Portals",
		[32266] = "Portals",
		[11416] = "Portals",
		[11417] = "Portals",
		[33691] = "Portals",
		[35717] = "Portals",
		[32267] = "Portals",
		[10059] = "Portals",
		[11420] = "Portals",
		[11418] = "Portals",
		[49360] = "Portals",
		[49361] = "Portals",
		[53142] = "Portals"
	}
	combatLogMap.SPELL_RESURRECT = {
		[20484] = "Rebirth"
	}
end
function mod:OnPluginEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

local durModified = {}
local glyphDuration = {
	-- Format: [glyphSId] = {SId, Unmodified duration, Reduction}
	[55678] = {6346, 180, 60} -- Fear Ward
}

local function getDuration(spellId)
	return durModified[spellId]
end

function mod:UpdateDurModifiers()
	wipe(durModified)
	for i = 1, GetNumGlyphSockets() do
		local enabled, _, _, gspellId = GetGlyphSocketInfo(i)
		if enabled and gspellId and glyphDuration[gspellId] then
			local info = glyphDuration[gspellId]
			durModified[info[1]] = info[2] - info[3]
		end
	end
end

local registered = nil
function mod:PLAYER_ENTERING_WORLD()
	local inInstance, instanceType = IsInInstance()
	if inInstance and (instanceType == "raid" or instanceType == "party") then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:UpdateDurModifiers()
		registered = true
	elseif registered then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		registered = nil
	end
end

function mod:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, _, source, _, _, player, _, spellId, spellName)
	local f = combatLogMap[event] and combatLogMap[event][spellId] or nil
	if f then
		self[f](self, player, spellId, source, spellName)
	end
end

------------------------------
--      Events              --
------------------------------

local green = "Positive"
local blue = "Personal"
local orange = "Urgent"
local yellow = "Attention"
local red = "Important"

local C = BigWigs.C
local function checkFlag(key, flag)
	if type(key) == "number" then
		key = GetSpellInfo(key)
	end
	return bit.band(mod.db.profile[key], flag) == flag
end

local function message(key, text, color, icon)
	if not checkFlag(key, C.MESSAGE) then
		return
	end
	mod:SendMessage("BigWigs_Message", mod, key, text, color, nil, nil, nil, icon)
end
local icons = setmetatable({}, {__index = function(self, key)
	self[key] = select(3, GetSpellInfo(key))
	return self[key]
end})
local function bar(key, text, length, icon)
	if not checkFlag(key, C.BAR) then
		return
	end
	mod:SendMessage("BigWigs_StartBar", mod, key, text, length, icons[icon])
end

function mod:Suppression(target, spellId, nick, spellName)
	message(33206, L["usedon_cast"]:format(nick, spellName, target), yellow, spellId)
	bar(33206, L["used_bar"]:format(target, spellName), 8, spellId)
end

function mod:Bloodlust(_, spellId, nick, spellName)
	message(32182, L["used_cast"]:format(nick, spellName), red, spellId)
	bar(32182, L["used_bar"]:format(nick, spellName), 40, spellId)
end

function mod:Guardian(target, spellId, nick, spellName)
	message(47788, L["usedon_cast"]:format(nick, spellName, target), yellow, spellId)
	bar(47788, L["used_bar"]:format(target, spellName), 10, spellId)
end

function mod:GuardianOff(target, spellId, nick, spellName) --Need to remove if fatal blow received and prevented
	self:SendMessage("BigWigs_StopBar", self, L["used_bar"]:format(target, spellName))
end

function mod:Sacrifice(target, spellId, nick, spellName)
	message(6940, L["usedon_cast"]:format(nick, spellName, target), orange, spellId)
	bar(6940, L["used_bar"]:format(target, spellName), 12, spellId)
end

function mod:DivineSacrifice(_, spellId, nick, spellName)
	message(64205, L["used_cast"]:format(nick, spellName), blue, spellId)
	bar(64205, L["used_bar"]:format(nick, spellName), 10, spellId)
end

function mod:DivineProtection(_, spellId, nick, spellName)
	message(498, L["used_cast"]:format(nick, spellName), blue, spellId)
	bar(498, L["used_bar"]:format(nick, spellName), 10, spellId)
end

function mod:ArdentDefender(_, spellId, nick, spellName)
	message(31850, L["used_cast"]:format(nick, spellName), blue, spellId)
	bar(31850, L["used_bar"]:format(nick, spellName), 10, spellId)
end

function mod:FearWard(target, spellId, nick, spellName)
	message(6346, L["fw_cast"]:format(nick, target), green, spellId)
	bar(6346, L["fw_bar"]:format(nick), getDuration(spellId) == 120 and 120 or 180, spellId)
end

function mod:FearWardOff(target, spellId, nick, spellName)
	self:SendMessage("BigWigs_StopBar", self, L["fw_bar"]:format(nick))
end

function mod:Repair(_, spellId, nick, spellName)
	message("repair", L["used_cast"]:format(nick, spellName), blue, spellId)
	bar("repair", L["used_bar"]:format(nick, spellName), spellId == 54711 and 300 or 600, spellId)
end

function mod:Portals(_, spellId, nick, spellName)
	message("portal", L["portal_cast"]:format(nick, spellName), blue, spellId)
	bar("portal", spellName .. " (" .. nick .. ")", 60, spellId)
end

function mod:Feasts(_, spellId, nick, spellName)
	message("feast", L["feast_cast"]:format(nick, spellName), blue, spellId)
	bar("feast", L["used_bar"]:format(nick, spellName), 300, spellId)
end

function mod:ShieldWall(_, spellId, nick, spellName)
	message(871, L["used_cast"]:format(nick, spellName), blue, spellId)
	bar(871, L["used_bar"]:format(nick, spellName), 12, spellId)
end

function mod:Innervate(target, spellId, nick, spellName)
	message(29166, L["usedon_cast"]:format(nick, spellName, target), green, spellId)
end

function mod:IceboundFortitude(_, spellId, nick, spellName)
	message(48792, L["used_cast"]:format(nick, spellName), blue, spellId)
	bar(48792, L["used_bar"]:format(nick, spellName), 12, spellId)
end

function mod:SurvivalInstincts(_, spellId, nick, spellName)
	message(61336, L["used_cast"]:format(nick, spellName), blue, spellId)
	bar(61336, L["used_bar"]:format(nick, spellName), 12, spellId)
end

function mod:Rebirth(target, spellId, nick, spellName)
	message(20484, L["usedon_cast"]:format(nick, spellName, target), green, spellId)
end