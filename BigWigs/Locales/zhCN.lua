local L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs", "zhCN")
if not L then return end

-- Core.lua
L["%s has been defeated"] = "%s被击败了！"
L.bosskill = "首领死亡"
L.bosskill_desc = "首领被击杀时显示提示信息。"
L.berserk = "狂暴"
L.berserk_desc = "当首领进入狂暴状态时发出警报。"
L.already_registered = "|cffff0000警告：|r |cff00ff00%s|r（|cffffff00%s|r）在 Big Wigs 中已经存在模块，但存在模块仍试图重新注册。可能由于更新失败的原因，通常表示您有两份模块拷贝在您插件的文件夹中。建议删除所有 Big Wigs 文件夹并重新安装。"

-- Loader / Options.lua
L["You are running an official release of Big Wigs %s (revision %d)"] = "你所使用的 Big Wigs %s 为官方正式版（修订号%d）"
L["You are running an ALPHA RELEASE of Big Wigs %s (revision %d)"] = "你所使用的 Big Wigs %s 为“α测试版”（修订号%d）"
L["You are running a source checkout of Big Wigs %s directly from the repository."] = "你所使用的 Big Wigs %s 为从源直接检出的。"
L["There is a new release of Big Wigs available. You can visit curse.com, wowinterface.com, wowace.com or use the Curse Updater to get the new release."] = "有新的 Big Wigs 正式版可用。你可以访问 Curse.com，wowinterface.com，wowace.com 或使用 Curse 更新器来更新到新的正式版。"
L.tooltipHint = "|cffeda55f点击|r图标重置所有运行中的模块。|cffeda55fAlt-点击|r可以禁用所有首领模块。"
L["Active boss modules:"] = "激活首领模块："
L["All running modules have been reset."] = "所有运行中的模块都已重置。"
L["All running modules have been disabled."] = "所有运行中的模块都已禁用。"
L["There are people in your group with older versions or without Big Wigs. You can get more details with /bwv."] = "在你队伍里使用旧版本或没有使用 Big Wigs。你可以用 /bwv 获得详细内容。"
L["Up to date:"] = "已更新："
L["Out of date:"] = "过期："
L["No Big Wigs 3.x:"] = "没有 Big Wigs 3.x："

-- Options.lua
L["Big Wigs Encounters"] = "Big Wigs 战斗"
L["Customize ..."] = "自定义…"
L["Profiles"] = "配置文件"
L.introduction = "欢迎使用 Big Wigs 戏弄各个首领。请系好安全带，吃吃花生并享受这次旅行。它不会吃了你的孩子，但会协助你的团队与新的首领进行战斗就如同享受饕餮大餐一样。"
L["Configure ..."] = "配置…"
L.configureDesc = "关闭插件选项窗口并配置显示项，如计时条、信息。\n\n如果需要自定义更多幕后时间，你可以展开左侧 Big Wigs 找到“自定义…”小项进行设置。"
L["Sound"] = "音效"
L.soundDesc = "信息出现时伴随着音效。有些人更容易在听到何种音效后发现何种警报，而不是阅读的实际信息。\n\n|cffff4411即使被关闭，默认的团队警报音效可能会随其它玩家的团队警报出现，那些声音与这里用的不同。|r"
L["Show Blizzard warnings"] = "暴雪警报"
L.blizzardDesc = "暴雪提供了他们自己的警报信息。我们认为，这些信息太长和复杂。我们试着简化这些消息而不打扰游戏的乐趣，并不需要你做什么。\n\n|cffff4411当关闭时，暴雪警报将不会再屏幕中间显示，但是仍将显示在聊天框体内。|r"
L["Show addon warnings"] = "显示插件警报"
L.addonwarningDesc = "Big Wigs 与其它首领战斗插件可以使用团队警报频道广播信息。这些消息通常包含三星号（***），Big Wigs 以此查找和判断是否屏蔽此消息。\n\n|cffff4411开启此选项将造成大量的垃圾信息所以并不推荐。|r"
L["Flash and shake"] = "闪屏/震动"
L["Flash"] = "闪屏"
L["Shake"] = "震动"
L.fnsDesc = "某些重要的技能需要你相当的注意力。当这些技能出现时 Big Wigs 可以闪烁和震动屏幕。\n\n|cffff4411如果开启了暴雪的姓名板选项，屏幕只会闪烁而震动功能将不会工作。|r"
L["Raid icons"] = "团队标记"
L.raidiconDesc = "团队中有些首领模块使用团队标记来为某些中了特定技能的队员打上标记。例如类似“炸弹”类或心灵控制的技能。如果你关闭此功能，你将不会给队员打标记。\n\n|cffff4411只有团队领袖或被提升为助理时才可以这么做！|r"
L["Whisper warnings"] = "密语警报"
L.whisperDesc = "发送给其它队员的首领战斗技能密语警报功能，例如类似“炸弹”类的技能。\n\n|cffff4411只有团队领袖或被提升为助理时才可以这么做！|r"
L["Broadcast"] = "广播"
L.broadcastDesc = "Big Wigs 广播所有信息到团队警报频道。\n\n|cffff4411在团队时只有获得权限时才可用，小队时不受限制。|r"
L["Raid channel"] = "团队频道"
L["Use the raid channel instead of raid warning for broadcasting messages."] = "使用团队频道而不是团队警报广播信息。"
L["Minimap icon"] = "迷你地图图标"
L["Toggle show/hide of the minimap icon."] = "打开或关闭迷你地图图标。"
L["Configure"] = "配置"
L["Test"] = "测试"
L["Reset positions"] = "重置位置"
L["Options for %s."] = "%s选项。"
L["Colors"] = "颜色"
L["Select encounter"] = "选择战斗"
L["BAR"] = "计时条"
L["MESSAGE"] = "信息"
L["ICON"] = "标记"
L["WHISPER"] = "密语"
L["SAY"] = "说"
L["FLASHSHAKE"] = "闪屏/震动"
L["PING"] = "点击地图"
L["EMPHASIZE"] = "醒目"
L["MESSAGE_desc"] = "大多数遇到技能出现一个或多个信息时 Big Wigs 将在屏幕上显示。如果禁用此选项，没有信息附加选项，如果有，将会被显示。"
L["BAR_desc"] = "当遇到某些技能时计时条将会适当显示。如果这个功能伴随着你想要隐藏的计时条，禁用此选项。"
L["FLASHSHAKE_desc"] = "一些技能可能比其它更加重要。如果想这些技能即将出现或发动时闪屏和震动，选中此选项。"
L["ICON_desc"] = "Big Wigs 可以根据技能用图标标记人物。这将使他们更容易被辨认。"
L["WHISPER_desc"] = "当一些技能足够重要时 Big Wigs 将发送密语给受到影响的人。"
L["SAY_desc"] = "聊天泡泡容易辨认。Big Wigs 将使用说的信息方式通知给附近的人告诉他们你中了什么技能。"
L["PING_desc"] = "有时所在位置也很重要，Big Wigs 将点击迷你地图通知大家你位于何处。"
L["EMPHASIZE_desc"] = "启用这些将特别醒目所相关遇到技能的任何信息或计时条。信息将被放大，计时条将会闪烁并有不同的颜色，技能即将出现时会使用计时音效，基本上你会发现它。"
L["Advanced options"] = "高级选项"
L["<< Back"] = "<< 返回"
L["About"] = "关于"
L["Main Developers"] = "主要开发者"
L["Maintainers"] = "维护"
L["License"] = "许可"
L["Website"] = "网站"
L["Contact"] = "联系方式"
L["See license.txt in the main Big Wigs folder."] = "查看 license.txt 位于 Big Wigs 主文件夹。"
L["irc.freenode.net in the #wowace channel"] = "#wowace 频道位于 irc.freenode.net"
L["Thanks to the following for all their help in various fields of development"] = "感谢他们在各个领域的开发与帮助"

-----------------------------------------------------------------------
-- Plugins
-----------------------------------------------------------------------

-- Bars.lua
L["Clickable Bars"] = "可点击计时条"
L.clickableBarsDesc = "Big Wigs 计时条预设是点击穿越的。这样可以选择目标或使用 AoE 法术攻击物体，更改镜头角度等等，当滑鼠指针划过计时条。|cffff4411如果启用可点击计时条，这些将不能实现。|r计时条将拦截任何鼠标点击并阻止相应功能。\n"
L["Enables bars to receive mouse clicks."] = "启用计时条接受点击。"
L["Temporarily Super Emphasizes the bar and any messages associated with it for the duration."] = "临时超级醒目计时条及任何讯息的持续时间。"
L["Report"] = "报告"
L["Reports the current bars status to the active group chat; either battleground, raid, party or guild, as appropriate."] = "报告当前计时条状态到适当的队伍聊天；无论战场，团队，队伍或公会。 "
L["Remove"] = "移除"
L["Temporarily removes the bar and all associated messages."] = "临时移除计时条和全部相关信息。"
L["Remove other"] = "移除其它"
L["Temporarily removes all other bars (except this one) and associated messages."] = "临时移除所有计时条（除此之外）和全部相关信息。"
L["Disable"] = "禁用"
L["Permanently disables the boss encounter ability option that spawned this bar."] = "永久禁用此首领战斗技能计时条选项。"
L["Scale"] = "缩放"
L["Grow upwards"] = "向上成长"
L["Toggle bars grow upwards/downwards from anchor."] = "切换计时条在锚点向上或向下成长。"
L["Texture"] = "材质"
L["Emphasize"] = "醒目"
L["Enable"] = "启用"
L["Move"] = "移动"
L["Moves emphasized bars to the Emphasize anchor. If this option is off, emphasized bars will simply change scale and color, and maybe start flashing."] = "移动醒目计时条到醒目锚点。如果此选项关闭，醒目计时条将只改变缩放与颜色以及可能开始闪烁。"
L["Flash"] = "闪烁"
L["Flashes the background of emphasized bars, which could make it easier for you to spot them."] = "醒目计时条背景闪烁，方便你留意它。"
L["Regular bars"] = "常规计时条"
L["Emphasized bars"] = "醒目计时条"
L["Align"] = "对齐"
L["Left"] = "左"
L["Center"] = "中"
L["Right"] = "右"
L["Time"] = "时间"
L["Whether to show or hide the time left on the bars."] = "在计时条上显示或隐藏时间。"
L["Icon"] = "图标"
L["Shows or hides the bar icons."] = "显示或隐藏计时条图标。"
L["Font"] = "字体"
L["Local"] = "本地"
L["%s: Timer [%s] finished."] = "%s：计时条[%s]到时间。"
L["Invalid time (|cffff0000%q|r) or missing bar text in a custom bar started by |cffd9d919%s|r. <time> can be either a number in seconds, a M:S pair, or Mm. For example 5, 1:20 or 2m."] = "无效记时条（|cffff0000%q|r）或 |cffd9d919%s|r 上的记时条文字错误，<time> 输入一个数字单位默认为秒，可以为 M:S 或者 Mm。例如 5, 1:20 或 2m。"

-- Colors.lua
L["Messages"] = "信息"
L["Bars"] = "计时条"
L["Background"] = "背景"
L["Text"] = "文本"
L["Flash and shake"] = "闪屏和震动"
L["Normal"] = "标准"
L["Emphasized"] = "醒目"
L["Reset"] = "重置"
L["Resets the above colors to their defaults."] = "重置以上颜色为默认。"
L["Reset all"] = "重置所有"
L["If you've customized colors for any boss encounter settings, this button will reset ALL of them so the colors defined here will be used instead."] = "如果为首领战斗自定义了颜色设置，这个按钮将重置替换“所有”颜色为默认。"
L["Important"] = "重要"
L["Personal"] = "个人"
L["Urgent"] = "紧急"
L["Attention"] = "注意"
L["Positive"] = "醒目"

-- Messages.lua
L.sinkDescription = "向外通过 Big Wigs 插件信息显示。这些包含了图标，颜色和在同一时间在屏幕上的显示4条信息。新的信息将再一次快速的放大和缩小来提醒用户。新插入的信息将增大并立即缩小提醒用户注意。"
L.emphasizedSinkDescription = "通过此插件输出到 Big Wigs 醒目信息显示。此显示支持文本和颜色，每次只可显示一条信息。"
L["Normal messages"] = "一般信息"
L["Emphasized messages"] = "醒目信息"
L["Output"] = "输出"
L["Use colors"] = "使用彩色信息"
L["Toggles white only messages ignoring coloring."] = "选择是否只发送单色信息。"
L["Use icons"] = "使用图标"
L["Show icons next to messages, only works for Raid Warning."] = "显示图标，只能使用在团队警告频道。"
L["Class colors"] = "职业颜色"
L["Colors player names in messages by their class."] = "使用职业颜色来染色信息内玩家颜色。"
L["Chat frame"] = "聊天框体"
L["Outputs all BigWigs messages to the default chat frame in addition to the display setting."] = "除了显示设置，输出所有 Big Wigs 信息到默认聊天框体。"

-- RaidIcon.lua
L["Icons"] = "图标"
L.raidIconsDesc = [=[团队中有些首领模块使用团队标记来为某些中了特定技能的队员打上标记。例如类似“炸弹”类或心灵控制的技能。如果你关闭此功能，你将不会给队员打标记。
|cffff4411只有团队领袖或被提升为助理时才可以这么做！|r]=]
L.raidIconDescription = "可能遇到包含例如炸弹类型的技能指向特定的玩家，玩家被追，或是特定玩家可能有兴趣在其他方面。这里可以自定义团队标记来标记这些玩家。\n\n如果只遇到一种技能，很好，只有第一个图标会被使用。在某些战斗中一个图标不会使用在两个不同的技能上，任何特定技能在下次总是使用相同图标。\n\n|cffff4411注意：如果玩家已经被手动标记，Big Wigs 将不会改变他的图标。|r"
L["Primary"] = "主要"
L["The first raid target icon that a encounter script should use."] = "战斗时使用的第一个团队标记。"
L["Secondary"] = "次要"
L["The second raid target icon that a encounter script should use."] = "战斗时使用的第二个团队标记。"
L["|cffff0000Disable|r"] = "|cffff0000禁用|r"

-- Sound.lua
L.soundDefaultDescription = "根据这些选项设置，Big Wigs 将只使用暴雪默认团队信息警报音效。注意：只有一些信息通过遇到脚本时才会出发音效警报。"
L["Sounds"] = "音效"
L["Alarm"] = "警报"
L["Info"] = "信息"
L["Alert"] = "报警"
L["Long"] = "长计时"
L["Victory"] = "胜利"
L["Set the sound to use for %q.\n\nCtrl-Click a sound to preview."] = "设置使用%q音效（Ctrl-点击可以预览效果）。"
L["Default only"] = "只用预设"

-- Proximity.lua
L["%d yards"] = "%d码"
L["Proximity"] = "近距离"
L["Disabled"] = "禁用"
L["Disable the proximity display for all modules that use it."] = "禁止所有首领模块使用近距离。"
L["The proximity display will show next time. To disable it completely for this encounter, you need to toggle it off in the encounter options."] = "近距离显示将在下次显示。要完全禁用此功能，需要关闭此功能选项。"
L.proximity = "近距离显示"
L.proximity_desc = "显示近距离显示窗口，列出距离你很近的玩家。"
L.proximityfont = "Fonts\\ZYKai_T.TTF"
L["Close"] = "关闭"
L["Closes the proximity display.\n\nTo disable it completely for any encounter, you have to go into the options for the relevant boss module and toggle the 'Proximity' option off."] = "关闭近距离显示。\n\n要完全禁用此任一功能，需进入相对应首领模块选项关闭“近距离”功能。"
L["Lock"] = "锁定"
L["Locks the display in place, preventing moving and resizing."] = "锁定显示窗口，防止被移动和缩放。"
L["Title"] = "标题"
L["Shows or hides the title."] = "显示或隐藏标题。"
L["Shows or hides the background."] = "显示或隐藏背景。"
L["Toggle sound"] = "切换音效"
L["Toggle whether or not the proximity window should beep when you're too close to another player."] = "当近距离窗口有其他过近玩家时切换任一或关闭音效。"
L["Sound button"] = "音效按钮"
L["Shows or hides the sound button."] = "显示或隐藏音效按钮。"
L["Close button"] = "关闭按钮"
L["Shows or hides the close button."] = "显示或隐藏关闭按钮。"
L["Show/hide"] = "显示/隐藏"

-- Tips.lua
L["|cff%s%s|r says:"] = "|cff%s%s|r说："
L["Cool!"] = "冷静！"
L["Tips"] = "提示"
L["Tip of the Raid"] = "团队提示"
L["Tip of the raid will show by default when you zone in to a raid instance, you are not in combat, and your raid group has more than 9 players in it. Only one tip will be shown per session, typically.\n\nHere you can tweak how to display that tip, either using the pimped out window (default), or outputting it to chat. If you play with officers who overuse the |cffff4411/sendtip command|r, you might want to show them in chat frame instead!"] = "团队提示根据默认显示当你处于团队副本，不能在战斗中以及你的团队超过9个玩家。通常一个提示只会在进程中显示一次。\n\n这里可以调整提示显示，或者使用我们的漂亮窗口（默认），或是输出到聊天。如果团长过度使用 |cffff4411/sendtip command|r，反而会想在聊天窗口显示它们！"
L["If you don't want to see any tips, ever, you can toggle them off here. Tips sent by your raid officers will also be blocked by this, so be careful."] = "如果不想看到任何提示，可以从这里切换关闭它们。团长发送的提示也会被屏蔽，小心使用。"
L["Automatic tips"] = "自动提示"
L["If you don't want to see the awesome tips we have, contributed by some of the best PvE players in the world, pop up when you zone in to a raid instance, you can disable this option."] = "如果不想看到美妙的提示，成为世界上最好的 PvE 玩家，团队副本时弹出窗口，你可以禁用这些选项。"
L["Manual tips"] = "手动提示"
L["Raid officers have the ability to show manual tips with the /sendtip command. If you have an officer who spams these things, or for some other reason you just don't want to see them, you can disable it with this option."] = "团长可以使用手动提示 /sendtip 命令显示给在团队中的玩家。如果有做这些恶心事的团长或其他理由不想看到它们，可以禁用这些选项。"
L["Output to chat frame"] = "输出到聊天框体"
L["By default the tips will be shown in their own, awesome window in the middle of your screen. If you toggle this, however, the tips will ONLY be shown in your chat frame as pure text, and the window will never bother you again."] = "默认的提示将会单独显示一个美妙的窗口于屏幕中间。如果关闭这些，这些提示“只会”以纯文本的形式显示在聊天窗口且提示窗口将不会再打扰你。"
L["Usage: /sendtip <index|\"Custom tip\">"] = "用法：/sendtip <index|\"自定义提示\">"
L["You must be an officer in the raid to broadcast a tip."] = "你必须是团长才能广播提示。"
L["Tip index out of bounds, accepted indexes range from 1 to %d."] = "提示索引超出范围，接受索引范围从1到%d。"

-- Emphasize.lua
L["Super Emphasize"] = "超级醒目"
L.superEmphasizeDesc = "相关信息或特定首领战斗技能计时条增强。\n\n在这里设置当开启超级醒目位于首领战斗技能高级选项时所应该发生的事件。\n\n|cffff4411注意：超级醒目功能默认情况下所有技能关闭。|r\n"
L["UPPERCASE"] = "大写"
L["Uppercases all messages related to a super emphasized option."] = "所有超级醒目选项相关信息大写。"
L["Double size"] = "双倍尺寸"
L["Doubles the size of super emphasized bars and messages."] = "超级醒目计时条和信息双倍尺寸。"
L["Countdown"] = "冷却"
L["If a related timer is longer than 5 seconds, a vocal and visual countdown will be added for the last 5 seconds. Imagine someone counting down \"5... 4... 3... 2... 1... COUNTDOWN!\" and big numbers in the middle of your screen."] = "如果相关的计时器的长度超过5秒，一个声音与视觉将增加倒计时的最后5秒。想象某个倒计时\"5... 4... 3... 2... 1... 冷却！\"和大个数字位于屏幕中间。"
L["Flashes the screen red during the last 3 seconds of any related timer."] = "当任一相关计时器最后3秒时屏幕红色闪烁。"