--------------------------------------------------------------------------------
-- The Beasts of Northrend
--

do
	local mod = BigWigs:NewBoss("The Beasts of Northrend", "Trial of the Crusader")
	if not mod then return end
	mod.toggleOptions = {
		"snobold",
		67477,
		66330,
		{67472, "FLASHSHAKE"},
		"submerge",
		{67641, "FLASHSHAKE"},
		"spew",
		"sprays",
		{67618, "FLASHSHAKE"},
		66869,
		68335,
		"proximity",
		67654,
		{"charge", "ICON", "SAY", "FLASHSHAKE"},
		66758,
		66759,
		"bosses",
		"berserk",
		"bosskill"
	}
	mod.optionHeaders = {
		snobold = "Gormok the Impaler",
		submerge = "Jormungars",
		[67654] = "Icehowl",
		bosses = "general"
	}

	--------------------------------------------------------------------------------
	-- Locals
	--

	local difficulty = 0
	local burn = mod:NewTargetList()
	local toxin = mod:NewTargetList()
	local snobolledWarned = {}
	local snobolled = GetSpellInfo(66406)
	local icehowl, jormungars, gormok = nil, nil, nil
	local sprayTimer = nil
	local handle_Jormungars = nil

	--------------------------------------------------------------------------------
	-- Localization
	--

	local L = mod:NewLocale("enUS", true)
	if L then
		L.enable_trigger = "You have heard the call of the Argent Crusade and you have boldly answered"
		L.wipe_trigger = "Tragic..."

		L.engage_trigger =
			"Hailing from the deepest, darkest caverns of the Storm Peaks, Gormok the Impaler! Battle on, heroes!"
		L.jormungars_trigger =
			"Steel yourselves, heroes, for the twin terrors, Acidmaw and Dreadscale, enter the arena!"
		L.icehowl_trigger =
			"The air itself freezes with the introduction of our next combatant, Icehowl! Kill or be killed, champions!"
		L.boss_incoming = "%s incoming"

		-- Gormok
		L.snobold = "Snobold"
		L.snobold_desc = "Warn who gets a Snobold on their heads."
		L.snobold_message = "Add"
		L.impale_message = "%2$dx Impale on %1$s"
		L.firebomb_message = "Fire on YOU!"

		-- Jormungars
		L.submerge = "Submerge"
		L.submerge_desc = "Show a timer bar for the next time the worms will submerge."
		L.spew = "Acidic/Molten Spew"
		L.spew_desc = "Warn for Acidic/Molten Spew."
		L.sprays = "Sprays"
		L.sprays_desc = "Show timers for the next Paralytic and Burning Sprays."
		L.slime_message = "Slime on YOU!"
		L.burn_spell = "Burn"
		L.toxin_spell = "Toxin"
		L.spray = "~Next Spray"

		-- Icehowl
		L.butt_bar = "~Butt Cooldown"
		L.charge = "Furious Charge"
		L.charge_desc = "Warn about Furious Charge on players."
		L.charge_trigger = "glares at"
		L.charge_say = "Charge on me!"

		L.bosses = "Bosses"
		L.bosses_desc = "Warn about bosses incoming"
	end
	L = mod:GetLocale()

	-- Initialization

	function mod:OnRegister()
		self:RegisterEnableMob(
			34796, -- Gormok
			34799, -- Dreadscale
			35144, -- Acidmaw
			34797 -- Icehowl
		)
		self:RegisterEnableYell(L["enable_trigger"])

		icehowl = BigWigs:Translate("Icehowl")
		jormungars = BigWigs:Translate("Jormungars")
		gormok = BigWigs:Translate("Gormok the Impaler")
	end

	function mod:OnBossEnable()
		-- Gormok
		self:Log("SPELL_DAMAGE", "FireBomb", 67472, 66317, 67475)
		self:Log("SPELL_AURA_APPLIED", "Impale", 67477, 66331, 67478, 67479)
		self:Log("SPELL_AURA_APPLIED_DOSE", "Impale", 67477, 66331, 67478, 67479)
		self:Log("SPELL_CAST_START", "StaggeringStomp", 66330, 67647, 67648, 67649)
		self:RegisterEvent("UNIT_AURA")

		-- Jormungars
		self:Log("SPELL_CAST_SUCCESS", "SlimeCast", 67641, 67642, 67643)
		self:Log("SPELL_DAMAGE", "Slime", 67640)
		-- Acidic, Molten
		self:Log("SPELL_CAST_START", "Spew", 66818, 66821)
		-- First 4 are Paralytic, last 4 are Burning
		self:Log("SPELL_CAST_START", "Spray", 67617, 67616, 67615, 66901, 67629, 67628, 67627, 66902)
		self:Log("SPELL_AURA_APPLIED", "Toxin", 67618, 67619, 67620, 66823)
		self:Log("SPELL_AURA_APPLIED", "Burn", 66869, 66870)
		self:Log("SPELL_AURA_APPLIED", "Enraged", 68335)
		self:Yell("Jormungars", L["jormungars_trigger"])

		-- Icehowl
		self:Log("SPELL_AURA_APPLIED", "Rage", 66759, 67658, 67657, 67659)
		self:Log("SPELL_AURA_APPLIED", "Daze", 66758)
		self:Log("SPELL_AURA_APPLIED", "Butt", 67654, 67655, 66770)
		self:Yell("Icehowl", L["icehowl_trigger"])
		self:Emote("Charge", L["charge_trigger"])

		-- Common
		self:Yell("Engage", L["engage_trigger"])
		self:Yell("Reboot", L["wipe_trigger"])
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Reboot")
		self:Death("Win", 34797)
	end

	function mod:OnEngage(diff)
		difficulty = diff
		self:CloseProximity()
		self:Bar("bosses", L["boss_incoming"]:format(gormok), 20, 67477)
		if diff > 2 then
			self:Bar("bosses", L["boss_incoming"]:format(jormungars), 180, "INV_Misc_MonsterScales_18")
		else
			self:Berserk(900)
		end
		wipe(snobolledWarned)
	end

	function mod:Jormungars()
		local m = L["boss_incoming"]:format(jormungars)
		self:Message("bosses", m, "Positive")
		self:Bar("bosses", m, 15, "INV_Misc_MonsterScales_18")
		if difficulty > 2 then
			self:Bar("bosses", L["boss_incoming"]:format(icehowl), 200, "INV_Misc_MonsterHorn_07")
		end
		self:OpenProximity(10)
		-- The first worm to spray is Acidmaw, he has a 10 second spray timer after emerge
		sprayTimer = 10
		handle_Jormungars = self:ScheduleTimer("Emerge", 15)
	end

	function mod:Icehowl()
		local m = L["boss_incoming"]:format(icehowl)
		self:Message("bosses", m, "Positive")
		self:Bar("bosses", m, 10, "INV_Misc_MonsterHorn_07")
		self:CancelTimer(handle_Jormungars, true)
		handle_Jormungars = nil
		self:SendMessage("BigWigs_StopBar", self, L["spray"])
		self:SendMessage("BigWigs_StopBar", self, L["submerge"])
		if difficulty > 2 then
			self:Berserk(220, true, icehowl)
		end
		self:CloseProximity()
	end

	-- Gormok the Impaler

	function mod:UNIT_AURA(event, unit)
		local name, _, icon = UnitDebuff(unit, snobolled)
		local n = UnitName(unit)
		if snobolledWarned[n] and not name then
			snobolledWarned[n] = nil
		elseif name and not snobolledWarned[n] then
			self:TargetMessage("snobold", L["snobold_message"], n, "Attention", icon)
			snobolledWarned[n] = true
		end
	end

	function mod:Impale(player, spellId, _, _, spellName, stack)
		if stack and stack > 1 then
			self:TargetMessage(67477, L["impale_message"], player, "Urgent", spellId, "Info", stack)
		end
		self:Bar(67477, spellName, 10, spellId)
	end

	function mod:StaggeringStomp(_, spellId, _, _, spellName)
		self:Message(66330, spellName, "Important", spellId)
		self:Bar(66330, spellName, 21, spellId)
	end

	do
		local last = nil
		function mod:FireBomb(player, spellId)
			if UnitIsUnit(player, "player") then
				local t = GetTime()
				if not last or (t > last + 4) then
					self:Voice(67472, true)
					self:LocalMessage(67472, L["firebomb_message"], "Personal", spellId, last and nil or "Alarm")
					self:FlashShake(67472)
					last = t
				end
			end
		end
	end

	-- Jormungars

	do
		local function submerge()
			handle_Jormungars = mod:ScheduleTimer("Emerge", 10)
		end

		function mod:Emerge()
			self:Bar("submerge", L["submerge"], 45, "INV_Misc_MonsterScales_18")
			handle_Jormungars = self:ScheduleTimer(submerge, 45)
			-- Rain of Fire icon as a generic AoE spray icon .. good enough?
			self:Bar("sprays", L["spray"], sprayTimer, 5740)
			sprayTimer = sprayTimer == 10 and 20 or 10
		end

		function mod:Spray(_, spellId, _, _, spellName)
			self:Message("sprays", spellName, "Important", spellId)
			self:Bar("sprays", L["spray"], 20, 5740)
		end
	end

	function mod:SlimeCast(_, spellId, _, _, spellName)
		self:Message(67641, spellName, "Attention", spellId)
	end

	function mod:Spew(_, spellId, _, _, spellName)
		self:Message("spew", spellName, "Attention", spellId)
	end

	do
		local handle = nil
		local dontWarn = nil
		local function toxinWarn(spellId)
			if not dontWarn then
				mod:TargetMessage(67618, L["toxin_spell"], toxin, "Urgent", spellId)
			else
				dontWarn = nil
				wipe(toxin)
			end
			handle = nil
		end
		function mod:Toxin(player, spellId)
			toxin[#toxin + 1] = player
			if handle then
				self:CancelTimer(handle)
			end
			handle = self:ScheduleTimer(toxinWarn, 0.2, spellId)
			if UnitIsUnit(player, "player") then
				dontWarn = true
				self:TargetMessage(67618, L["toxin_spell"], player, "Personal", spellId, "Info")
				self:FlashShake(67618)
			end
		end
	end

	do
		local handle = nil
		local dontWarn = nil
		local function burnWarn(spellId)
			if not dontWarn then
				mod:TargetMessage(66869, L["burn_spell"], burn, "Urgent", spellId)
			else
				dontWarn = nil
				wipe(burn)
			end
			handle = nil
		end
		function mod:Burn(player, spellId)
			burn[#burn + 1] = player
			if handle then
				self:CancelTimer(handle)
			end
			handle = self:ScheduleTimer(burnWarn, 0.2, spellId)
			if UnitIsUnit(player, "player") then
				dontWarn = true
				self:TargetMessage(66869, L["burn_spell"], player, "Important", spellId, "Info")
			end
		end
	end

	function mod:Enraged(_, spellId, _, _, spellName)
		self:Message(68335, spellName, "Important", spellId, "Long")
	end

	do
		local last = nil
		function mod:Slime(player, spellId)
			if UnitIsUnit(player, "player") then
				local t = GetTime()
				if not last or (t > last + 4) then
					self:Voice(67641, true)
					self:LocalMessage(67641, L["slime_message"], "Personal", spellId, last and nil or "Alarm")
					self:FlashShake(67641)
					last = t
				end
			end
		end
	end

	-- Icehowl

	function mod:Rage(_, spellId, _, _, spellName)
		self:Message(66759, spellName, "Important", spellId)
		self:Bar(66759, spellName, 15, spellId)
	end

	function mod:Daze(_, spellId, _, _, spellName)
		self:Message(66758, spellName, "Positive", spellId)
		self:Bar(66758, spellName, 15, spellId)
	end

	function mod:Butt(player, spellId, _, _, spellName)
		self:TargetMessage(67654, spellName, player, "Attention", spellId)
		self:Bar(67654, L["butt_bar"], 12, spellId)
	end

	function mod:Charge(msg, unit, _, _, player)
		if unit ~= icehowl then
			return
		end
		local spellName = GetSpellInfo(52311)
		self:TargetMessage("charge", spellName, player, "Personal", 52311, "Alarm")
		if UnitIsUnit(player, "player") then
			self:Voice(52311, true)
			self:FlashShake("charge")
			self:Say("charge", L["charge_say"])
		end
		self:Bar("charge", spellName, 7.5, 52311)
		self:PrimaryIcon("charge", player)
	end
end

--------------------------------------------------------------------------------
-- Lord Jaraxxus
--

do
	local mod = BigWigs:NewBoss("Lord Jaraxxus", "Trial of the Crusader")
	if not mod then return end
	mod.toggleOptions = {
		{67049, "WHISPER"},
		{68123, "WHISPER", "ICON", "FLASHSHAKE"},
		67106,
		"adds",
		{67905, "FLASHSHAKE"},
		"berserk",
		"bosskill"
	}
	mod.optionHeaders = {[67049] = "normal", [67905] = "heroic", bosskill = "general"}

	-- Localization

	local L = mod:NewLocale("enUS", true)
	if L then
		L.enable_trigger = "Trifling gnome! Your arrogance will be your undoing!"

		L.engage = "Engage"
		L.engage_trigger = "You face Jaraxxus, Eredar Lord of the Burning Legion!"
		L.engage_trigger1 = "But I'm in charge here"

		L.adds = "Portals and volcanos"
		L.adds_desc = "Show a timer and warn for when Jaraxxus summons portals and volcanos."

		L.incinerate_message = "Incinerate"
		L.incinerate_other = "%s goes boom!"
		L.incinerate_bar = "Next Incinerate"
		L.incinerate_safe = "%s is safe, yay :)"

		L.legionflame_message = "Flame"
		L.legionflame_other = "Flame on %s!"
		L.legionflame_bar = "Next Flame"

		L.infernal_bar = "Volcano spawns"
		L.netherportal_bar = "Portal spawns"
		L.netherpower_bar = "~Next Nether Power"

		L.kiss_message = "Kiss on YOU!"
		L.kiss_interrupted = "Interrupted!"
	end
	L = mod:GetLocale()

	-- Initialization

	function mod:OnRegister()
		self:RegisterEnableMob(34780)
		self:RegisterEnableYell(L["enable_trigger"])
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "IncinerateFlesh", 67049, 67050, 67051, 66237)
		self:Log("SPELL_AURA_REMOVED", "IncinerateFleshRemoved", 67049, 67050, 67051, 66237)
		self:Log("SPELL_AURA_APPLIED", "LegionFlame", 68123, 68124, 68125, 66197)
		self:Log("SPELL_AURA_APPLIED", "NetherPower", 67106, 67107, 67108, 66228)
		self:Log("SPELL_CAST_SUCCESS", "NetherPortal", 68404, 68405, 68406, 67898, 67899, 67900, 66269)
		self:Log("SPELL_CAST_SUCCESS", "InfernalEruption", 66258, 67901, 67902, 67903)
		self:Log("SPELL_AURA_APPLIED", "MistressKiss", 67905, 67906, 67907, 66334) -- debuff before getting interrupted
		self:Log("SPELL_AURA_REMOVED", "MistressKissRemoved", 67905, 67906, 67907, 66334)
		self:Log("SPELL_INTERRUPT", "MistressKissInterrupted", 66335, 66359, 67073, 67074, 67075, 67908, 67909, 67910) -- debuff after getting interrupted

		-- Only happens the first time we engage Jaraxxus, still 11 seconds left until he really engages.
		self:Yell("FirstEngage", L["engage_trigger1"])
		self:Yell("Engage", L["engage_trigger"])
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
		self:Death("Win", 34780)
	end

	function mod:FirstEngage()
		self:Bar("adds", L["engage"], 12, "INV_Gizmo_01")
	end

	function mod:OnEngage(diff)
		self:Bar("adds", L["netherportal_bar"], 20, 68404)
		if diff > 2 then
			self:Berserk(600)
		end
	end

	-- Event Handlers

	function mod:IncinerateFlesh(player, spellId)
		self:TargetMessage(67049, L["incinerate_message"], player, "Urgent", spellId, "Info")
		self:Whisper(67049, player, L["incinerate_message"])
		self:Bar(67049, L["incinerate_other"]:format(player), 12, spellId)
	end

	function mod:IncinerateFleshRemoved(player, spellId)
		self:Message(67049, L["incinerate_safe"]:format(player), "Positive", 17) -- Power Word: Shield icon.
		self:SendMessage("BigWigs_StopBar", self, L["incinerate_other"]:format(player))
	end

	function mod:LegionFlame(player, spellId)
		self:TargetMessage(68123, L["legionflame_message"], player, "Personal", spellId, "Alert")
		if UnitIsUnit(player, "player") then
			self:Voice(68123, true)
			self:FlashShake(68123)
		end
		self:Whisper(68123, player, L["legionflame_message"])
		self:Bar(68123, L["legionflame_other"]:format(player), 8, spellId)
		self:PrimaryIcon(68123, player)
	end

	function mod:NetherPower(unit, spellId, _, _, spellName)
		if unit == self.displayName then
			self:Message(67106, spellName, "Attention", spellId)
			self:Voice("dispellboss")
			self:Voice("dispell", 0, 39)
			self:Bar(67106, L["netherpower_bar"], 44, spellId)
		end
	end

	function mod:NetherPortal(_, spellId, _, _, spellName)
		self:Message("adds", spellName, "Urgent", spellId, "Alarm")
		self:Bar("adds", L["infernal_bar"], 60, 66258)
	end

	function mod:InfernalEruption(_, spellId, _, _, spellName)
		self:Message("adds", spellName, "Urgent", spellId, "Alarm")
		self:Bar("adds", L["netherportal_bar"], 60, 68404)
	end

	function mod:MistressKiss(player, spellId)
		if not UnitIsUnit(player, "player") then
			return
		end
		self:LocalMessage(67905, L["kiss_message"], "Personal", spellId)
		self:Bar(67905, L["kiss_message"], 15, spellId)
		self:FlashShake(67905)
	end

	function mod:MistressKissRemoved(player, spellId)
		if not UnitIsUnit(player, "player") then
			return
		end
		self:SendMessage("BigWigs_StopBar", self, L["kiss_message"])
	end

	function mod:MistressKissInterrupted(player, spellId)
		if not UnitIsUnit(player, "player") then
			return
		end
		self:LocalMessage(67905, L["kiss_interrupted"], "Personal", spellId)
	end
end

--------------------------------------------------------------------------------
-- Faction Champions
--

do
	local mod = BigWigs:NewBoss("Faction Champions", "Trial of the Crusader")
	if not mod then return end
	mod.toggleOptions = {
		65960,
		65801,
		65877,
		66010,
		65947,
		{65816, "FLASHSHAKE"},
		67514,
		67777,
		65983,
		65980,
		"bosskill"
	}

	-- Localization

	local L = mod:NewLocale("enUS", true)
	if L then
		L.enable_trigger =
			"The next battle will be against the Argent Crusade's most powerful knights! Only by defeating them will you be deemed worthy..."
		L.defeat_trigger = "A shallow and tragic victory."

		L["Shield on %s!"] = true
		L["Bladestorming!"] = true
		L["Hunter pet up!"] = true
		L["Felhunter up!"] = true
		L["Heroism on champions!"] = true
		L["Bloodlust on champions!"] = true
	end
	L = mod:GetLocale()

	-- Initialization

	function mod:OnRegister()
		self:RegisterEnableMob(
			-- Alliance NPCs
			34460,
			34461,
			34463,
			34465,
			34466,
			34467,
			34468,
			34469,
			34470,
			34471,
			34472,
			34473,
			34474,
			34475,
			-- Horde NPCs
			34441,
			34444,
			34445,
			34447,
			34448,
			34449,
			34450,
			34451,
			34453,
			34454,
			34455,
			34456,
			34458,
			34459
		)
		self:RegisterEnableYell(L["enable_trigger"])
	end

	function mod:OnBossEnable()
		self:Log("SPELL_AURA_APPLIED", "Blind", 65960)
		self:Log("SPELL_AURA_APPLIED", "Polymorph", 65801)
		self:Log("SPELL_AURA_APPLIED", "Wyvern", 65877)
		self:Log("SPELL_AURA_APPLIED", "DivineShield", 66010)
		self:Log("SPELL_CAST_SUCCESS", "Bladestorm", 65947)
		self:Log("SPELL_SUMMON", "Felhunter", 67514)
		self:Log("SPELL_SUMMON", "Cat", 67777)
		self:Log("SPELL_CAST_SUCCESS", "Heroism", 65983)
		self:Log("SPELL_CAST_SUCCESS", "Bloodlust", 65980)
		self:Log("SPELL_AURA_APPLIED", "Hellfire", 65816, 68145, 68146, 68147)
		self:Log("SPELL_AURA_REMOVED", "HellfireStopped", 65816, 68145, 68146, 68147)
		self:Log("SPELL_DAMAGE", "HellfireOnYou", 65817, 68142, 68143, 68144)

		self:Yell("Win", L["defeat_trigger"])
	end

	--------------------------------------------------------------------------------
	-- Event Handlers
	--

	function mod:Hellfire(player, spellId, _, _, spellName)
		self:Message(65816, spellName, "Urgent", spellId)
		self:Bar(65816, spellName, 15, spellId)
	end

	function mod:HellfireStopped(player, spellId, _, _, spellName)
		self:SendMessage("BigWigs_StopBar", self, spellName)
	end

	do
		local last = nil
		function mod:HellfireOnYou(player, spellId, _, _, spellName)
			if UnitIsUnit(player, "player") then
				local t = GetTime()
				if not last or (t > last + 4) then
					self:TargetMessage(65816, spellName, player, "Personal", spellId, last and nil or "Alarm")
					self:FlashShake(65816)
					last = t
				end
			end
		end
	end

	function mod:Wyvern(player, spellId, _, _, spellName)
		self:TargetMessage(65877, spellName, player, "Attention", spellId)
	end

	function mod:Blind(player, spellId, _, _, spellName)
		self:TargetMessage(65960, spellName, player, "Attention", spellId)
	end

	function mod:Polymorph(player, spellId, _, _, spellName)
		self:TargetMessage(65801, spellName, player, "Attention", spellId)
	end

	function mod:DivineShield(player, spellId)
		self:Message(66010, L["Shield on %s!"]:format(player), "Urgent", spellId)
	end

	function mod:Bladestorm(player, spellId)
		self:Message(65947, L["Bladestorming!"], "Important", spellId)
	end

	function mod:Cat(player, spellId)
		self:Message(67777, L["Hunter pet up!"], "Urgent", spellId)
	end

	function mod:Felhunter(player, spellId)
		self:Message(67514, L["Felhunter up!"], "Urgent", spellId)
	end

	function mod:Heroism(player, spellId)
		self:Message(65983, L["Heroism on champions!"], "Important", spellId)
	end

	function mod:Bloodlust(player, spellId)
		self:Message(65980, L["Bloodlust on champions!"], "Important", spellId)
	end
end

--------------------------------------------------------------------------------
-- The Twin Val'kyr
--

do
	local mod = BigWigs:NewBoss("The Twin Val'kyr", "Trial of the Crusader")
	if not mod then return end
	-- 34496 Darkbane, 34497 Lightbane
	mod:RegisterEnableMob(34496, 34497)
	mod.toggleOptions = {
		{"vortex", "FLASHSHAKE"},
		"shield",
		"next",
		{"touch", "WHISPER", "FLASHSHAKE"},
		"berserk",
		"bosskill"
	}

	-- Locals

	local essenceLight = GetSpellInfo(67223)
	local essenceDark = GetSpellInfo(67176)
	local started = nil
	local currentShieldStrength = nil
	local shieldStrengthMap = {
		[67261] = 1200000,
		[67258] = 1200000,
		[67256] = 700000,
		[67259] = 700000,
		[67257] = 300000,
		[67260] = 300000,
		[65858] = 175000,
		[65874] = 175000
	}

	-- Localization

	local L = mod:NewLocale("enUS", true)
	if L then
		L.engage_trigger1 = "In the name of our dark master. For the Lich King. You. Will. Die."

		L.vortex_or_shield_cd = "Next Vortex or Shield"
		L.next = "Next Vortex or Shield"
		L.next_desc = "Warn for next Vortex or Shield"

		L.vortex = "Vortex"
		L.vortex_desc = "Warn when the twins start casting vortexes."

		L.shield = "Shield of Darkness/Light"
		L.shield_desc = "Warn for Shield of Darkness/Light."
		L.shield_half_message = "Shield at 50% strength!"
		L.shield_left_message = "%d%% shield strength left"

		L.touch = "Touch of Darkness/Light"
		L.touch_desc = "Warn for Touch of Darkness/Light"
	end
	L = mod:GetLocale()

	-- Initialization

	function mod:OnBossEnable()
		self:Log("SPELL_CAST_START", "LightVortex", 66046, 67206, 67207, 67208)
		self:Log("SPELL_CAST_START", "DarkVortex", 66058, 67182, 67183, 67184)
		self:Log("SPELL_AURA_APPLIED", "DarkShield", 65874, 67256, 67257, 67258)
		self:Log("SPELL_AURA_APPLIED", "LightShield", 65858, 67259, 67260, 67261)
		self:Log("SPELL_CAST_START", "HealStarted", 67303, 65875, 65876, 67304, 67305, 67306, 67307, 67308)
		self:Log("SPELL_HEAL", "Healed", 67303, 65875, 65876, 67304, 67305, 67306, 67307, 67308)
		-- First 3 are dark, last 3 are light.
		self:Log("SPELL_AURA_APPLIED", "Touch", 67281, 67282, 67283, 67296, 67297, 67298)

		self:Yell("Engage", L["engage_trigger1"])
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
		self:Death("Win", 34496)

		started = nil
	end

	function mod:OnEngage(diff)
		if started then
			return
		end
		started = true
		self:Bar("next", L["vortex_or_shield_cd"], 45, 39089)
		self:Berserk(diff > 2 and 360 or 480)
	end

	-- Event Handlers

	do
		local damageDone = nil
		local halfWarning = nil
		local twin = nil
		local f = nil
		local heals = {
			[67303] = true,
			[65875] = true,
			[65876] = true,
			[67304] = true,
			[67305] = true,
			[67306] = true,
			[67307] = true,
			[67308] = true
		}

		local function stop()
			if f then
				f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			end
			twin = nil
			damageDone = nil
			currentShieldStrength = nil
			halfWarning = nil
		end
		function mod:HealStarted(player, spellId, source)
			if not f then
				f = CreateFrame("Frame")
				f:SetScript(
					"OnEvent",
					function(_, _, _, event, _, _, _, _, dName, _, _, swingDamage, _, healId, damage)
						if healId == "ABSORB" and dName == twin then
							if event == "SWING_MISSED" then -- SWING_MISSED probably happens more often than the others, so catch it first
								damageDone = damageDone + swingDamage
							elseif
								event == "SPELL_PERIODIC_MISSED" or event == "SPELL_MISSED" or event == "RANGE_MISSED"
							 then
								damageDone = damageDone + damage
							end
							if currentShieldStrength and not halfWarning and damageDone >= (currentShieldStrength / 2) then
								mod:Message("shield", L["shield_half_message"], "Positive")
								halfWarning = true
							end
						elseif event == "SPELL_INTERRUPT" and heals[healId] then
							stop()
						end
					end
				)
			end
			damageDone = 0
			twin = source
			f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		function mod:Healed()
			if not currentShieldStrength then
				return
			end
			local missing = math.ceil(100 - (100 * damageDone / currentShieldStrength))
			self:Message("shield", L["shield_left_message"]:format(missing), "Important")
			stop()
		end
	end

	function mod:Touch(player, spellId, _, _, spellName)
		self:TargetMessage("touch", spellName, player, "Personal", spellId, "Info")
		if UnitIsUnit(player, "player") then
			self:Voice(spellId, true)
			self:FlashShake("touch")
		end
		self:Whisper("touch", player, spellName)
	end

	function mod:DarkShield(_, spellId, _, _, spellName)
		currentShieldStrength = shieldStrengthMap[spellId]
		self:Bar("shield", L["vortex_or_shield_cd"], 45, 39089)
		local d = UnitDebuff("player", essenceDark)
		if d then
			self:Message("shield", spellName, "Important", spellId, "Alert")
		else
			self:Message("shield", spellName, "Urgent", spellId)
		end
	end

	function mod:LightShield(_, spellId, _, _, spellName)
		currentShieldStrength = shieldStrengthMap[spellId]
		self:Bar("shield", L["vortex_or_shield_cd"], 45, 39089)
		local d = UnitDebuff("player", essenceLight)
		if d then
			self:Message("shield", spellName, "Important", spellId, "Alert")
		else
			self:Message("shield", spellName, "Urgent", spellId)
		end
	end

	function mod:LightVortex(_, spellId, _, _, spellName)
		self:Bar("vortex", L["vortex_or_shield_cd"], 45, 39089)
		local d = UnitDebuff("player", essenceLight)
		if d then
			self:Message("vortex", spellName, "Positive", spellId)
		else
			self:Message("vortex", spellName, "Personal", spellId, "Alarm")
			self:FlashShake("vortex")
		end
	end

	function mod:DarkVortex(_, spellId, _, _, spellName)
		self:Bar("vortex", L["vortex_or_shield_cd"], 45, 39089)
		local d = UnitDebuff("player", essenceDark)
		if d then
			self:Message("vortex", spellName, "Positive", spellId)
		else
			self:Message("vortex", spellName, "Personal", spellId, "Alarm")
			self:FlashShake("vortex")
		end
	end
end

--------------------------------------------------------------------------------
-- Anub'arak
--

do
	local mod = BigWigs:NewBoss("Anub'arak", "Trial of the Crusader")
	if not mod then return end
	mod.toggleOptions = {
		66012,
		"burrow",
		{67574, "WHISPER", "ICON", "FLASHSHAKE"},
		{68510, "FLASHSHAKE"},
		66118,
		66134,
		"berserk",
		"bosskill"
	}
	mod:RegisterEnableMob(34564, 34607, 34605)
	mod.optionHeaders = {[66012] = "normal", [66134] = "heroic", berserk = "general"}

	-- Locals

	local handle_NextWave = nil
	local handle_NextStrike = nil

	local isBurrowed = nil
	local ssName = GetSpellInfo(66134)
	local difficulty = 0
	local coldTargets = mod:NewTargetList()
	local phase2 = nil

	-- ADDED BY KADER
	local max = nil
	local current = 0

	-- Localization

	local L = mod:NewLocale("enUS", true)
	if L then
		L.engage_message = "Anub'arak engaged, burrow in 80sec!"
		L.engage_trigger = "This place will serve as your tomb!"

		L.unburrow_trigger = "emerges from the ground"
		L.burrow_trigger = "burrows into the ground"
		L.burrow = "Burrow"
		L.burrow_desc = "Shows timers for emerges and submerges, and also add spawn timers."
		L.burrow_cooldown = "Next Burrow"
		L.burrow_soon = "Burrow soon"

		L.nerubian_message = "Adds incoming!"
		L.nerubian_burrower = "More adds"

		L.shadow_soon = "Shadow Strike in ~5sec!"

		L.freeze_bar = "~Next Freezing Slash"
		L.pcold_bar = "~Next Penetrating Cold"

		L.chase = "Pursue"
	end
	L = mod:GetLocale()

	-- Initialization

	-- Freaking Shadow Strike!
	-- 1. On engage, start a 30.5 second shadow strike timer if difficulty > 2.
	-- 2. When the 30.5 second timer is over, restart it.
	-- 3. When an add casts shadow strike, cancel all timers and restart at 30.5 seconds.
	-- 4. When Anub'arak emerges from a burrow, start the timers after 5.5 seconds, so
	--    the time from emerge -> Shadow Strike is 5.5 + 30.5 seconds = 36 seconds.

	local function unscheduleStrike()
		mod:CancelDelayedMessage(L["shadow_soon"])
		mod:CancelTimer(handle_NextStrike, true)
		mod:SendMessage("BigWigs_StopBar", mod, ssName)
	end

	local function scheduleStrike()
		unscheduleStrike()
		mod:Bar(66134, ssName, 30.5, 66134)
		mod:DelayedMessage(66134, 25.5, L["shadow_soon"], "Attention")
		handle_NextStrike = mod:ScheduleTimer(scheduleStrike, 30.5)
	end

	function mod:OnBossEnable()
		local d = GetInstanceDifficulty() -- ADDED BY KADER
		max = (d == 1 or d == 3) and 2 or 5 -- ADDED BY KADER

		self:Log("SPELL_CAST_START", "Swarm", 66118, 67630, 68646, 68647)
		self:Log("SPELL_CAST_SUCCESS", "ColdCooldown", 66013, 67700, 68509, 68510)
		self:Log("SPELL_AURA_APPLIED", "ColdDebuff", 66013, 67700, 68509, 68510)
		self:Log("SPELL_AURA_APPLIED", "Pursue", 67574)

		self:Log("SPELL_AURA_APPLIED", "Penetrated", 66013, 67700, 68509, 68510) -- ADDED BY KADER
		self:Log("SPELL_AURA_REMOVED", "Safe", 66013, 67700, 68509, 68510) -- ADDED BY KADER

		self:Log("SPELL_CAST_START", scheduleStrike, 66134)
		self:Log("SPELL_CAST_SUCCESS", "FreezeCooldown", 66012)
		self:Log("SPELL_MISSED", "FreezeCooldown", 66012)

		self:Emote("Burrow", L["burrow_trigger"])
		self:Emote("Surface", L["unburrow_trigger"])

		self:Yell("Engage", L["engage_trigger"])
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
		self:Death("Win", 34564)
		self:Death("Disable", 34564) -- ADDED BY KADER
	end

	local function scheduleWave()
		if isBurrowed then
			return
		end
		mod:Message("burrow", L["nerubian_message"], "Urgent", 66333)
		mod:Bar("burrow", L["nerubian_burrower"], 45, 66333)
		handle_NextWave = mod:ScheduleTimer(scheduleWave, 45)
	end

	function mod:OnEngage(diff)
		isBurrowed = nil
		difficulty = diff
		self:Message("burrow", L["engage_message"], "Attention", 65919)
		self:Bar("burrow", L["burrow_cooldown"], 80, 65919)
		self:DelayedMessage("burrow", 65, L["burrow_soon"], "Attention")

		self:Bar("burrow", L["nerubian_burrower"], 10, 66333)
		handle_NextWave = self:ScheduleTimer(scheduleWave, 10)

		if self:GetOption(66134) and diff > 2 then
			scheduleStrike()
		end

		self:Berserk(570, true)
		phase2 = nil
	end

	-- Event Handlers

	function mod:FreezeCooldown(player, spellId)
		self:Bar(66012, L["freeze_bar"], 20, spellId)
	end

	do
		local scheduled = nil
		local function coldWarn(spellName)
			mod:TargetMessage(68510, spellName, coldTargets, "Urgent", 68510)
			scheduled = nil
		end
		function mod:ColdDebuff(player, spellId, _, _, spellName)
			if not phase2 then
				return
			end
			coldTargets[#coldTargets + 1] = player
			if not scheduled then
				self:ScheduleTimer(coldWarn, 0.2, spellName)
				scheduled = true
			end
			if UnitIsUnit(player, "player") then
				self:FlashShake(68510)
			end
		end
	end

	function mod:ColdDebuff(player, spellId, _, _, spellName)
		if not UnitIsUnit(player, "player") or not phase2 then
			return
		end
		self:LocalMessage(68510, spellName, "Personal", spellId)
		self:FlashShake(68510)
	end

	function mod:ColdCooldown(_, spellId)
		if not phase2 then
			return
		end
		self:Bar(68510, L["pcold_bar"], 15, spellId)
	end

	function mod:Swarm(player, spellId, _, _, spellName)
		self:Message(66118, spellName, "Important", spellId, "Long")
		phase2 = true
		self:SendMessage("BigWigs_StopBar", self, L["burrow_cooldown"])
		self:CancelDelayedMessage(L["burrow_soon"])
		if difficulty < 3 then -- Normal modes
			self:SendMessage("BigWigs_StopBar", self, L["nerubian_burrower"])
			self:CancelTimer(handle_NextWave, true)
		end
	end

	function mod:Pursue(player, spellId)
		self:TargetMessage(67574, L["chase"], player, "Personal", spellId, "Alert")
		if UnitIsUnit(player, "player") then
			self:Voice(67574, true)
			self:FlashShake(67574)
		end
		self:Whisper(67574, player, L["chase"])
		self:PrimaryIcon(67574, player, "icon")
	end

	function mod:Burrow()
		isBurrowed = true
		unscheduleStrike()
		self:SendMessage("BigWigs_StopBar", self, L["freeze_bar"])
		self:SendMessage("BigWigs_StopBar", self, L["nerubian_burrower"])
		self:CancelTimer(handle_NextWave, true)

		self:Bar("burrow", L["burrow"], 65, 65919)
	end

	function mod:Surface()
		isBurrowed = nil
		self:Bar("burrow", L["burrow_cooldown"], 76, 65919)
		self:DelayedMessage("burrow", 61, L["burrow_soon"], "Attention")

		self:Bar("burrow", L["nerubian_burrower"], 5, 66333)
		handle_NextWave = self:ScheduleTimer(scheduleWave, 5)

		if self:GetOption(66134) and difficulty > 2 then
			unscheduleStrike()
			handle_NextStrike = self:ScheduleTimer(scheduleStrike, 5.5)
		end
	end

	-- ADDED BY KADER
	function mod:Penetrated(player)
		current = current + 1
		SetRaidTarget(player, current)
		if current == max then
			current = 0
		end
	end

	-- ADDED BY KADER
	function mod:Safe(player)
		SetRaidTarget(player, 0)
	end
end