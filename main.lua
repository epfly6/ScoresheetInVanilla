--scoresheet cool--
local mod = RegisterMod("Scoresheet in Vanilla", 1)

local isRepentance, isRepentogon =  REPENTANCE, (REPENTOGON or _G._VERSION == "Lua 5.4")
local errMessage = ""
if not isRepentance or not isRepentogon then
    if not isRepentance then
        errMessage = "Scoresheet in Vanilla mod requires Repentance DLC to work"
    elseif not isRepentogon then
        errMessage = "Scoresheet in Vanilla mod requires Repentogon Script Extender to work. Head to https://repentogon.com/"
    end

    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function ()
        Isaac.RenderScaledText(errMessage, 200, 50, 0.5, 0.5, 1, 0, 0, 1)
    end)
    return
end

local game = Game()
local ss = ScoreSheet
local imgui = ImGui

local currentDestination = 1

local destinationsConf = {
	{CompletionType.ISAAC, Ending.ISAAC},
	{CompletionType.SATAN, Ending.SATAN},
	{CompletionType.BLUE_BABY,Ending.BLUE_BABY},
	{CompletionType.LAMB, Ending.LAMB},
	{CompletionType.MEGA_SATAN, Ending.MEGA_SATAN},
}

--wrapper by catinsurance
---@param elementId string
---@param createFunc function
local function createElement(elementId, createFunc, ...)
    if imgui.ElementExists(elementId) then
        imgui.RemoveElement(elementId)
    end

    createFunc(...)
end

---@param continued boolean
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
	if not continued then
		local rng = RNG()
		rng:SetSeed(game:GetSeeds():GetStartSeed(), 66)

		currentDestination = rng:RandomInt(1, 5)

		imgui.UpdateData("ScoresheetMenuSettingsDestination", ImGuiData.Value, currentDestination - 1)
	end
end)

local shouldRenderScoreSheet = false
mod:AddCallback(ModCallbacks.MC_PRE_COMPLETION_EVENT, function(_, compType, player)
	local level = game:GetLevel()
	--print("hey hey hey", compType, destinationsConf[currentDestination][1]) 
	if not game:IsGreedMode() and compType > 0 and compType ~= CompletionType.BOSS_RUSH then
		if compType == destinationsConf[currentDestination][1] then
			--print("heyo")
			ss.SetRunEnding(destinationsConf[currentDestination][2])
			ss.AddFinishedStage(level:GetStage(), level:GetStageType(), game.TimeCounter)
			ss.Calculate()
			game:ShowGenericLeaderboard()
			--shouldRenderScoreSheet = true
		end
	end
end)

--[[mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if Game():GetHUD():IsVisible() and shouldRenderScoreSheet then
		funnyFont:DrawStringScaledUTF8("Stage bonus: "..tostring(ss.GetStageBonus()), 124, 124, 0.5, 0.5, KColor(1,1,1,1))
		funnyFont:DrawStringScaledUTF8("Exploration bonus: "..tostring(ss.GetExplorationBonus()), 124, 134, 0.5, 0.5, KColor(1,1,1,1))
		funnyFont:DrawStringScaledUTF8("Schwag bonus: "..tostring(ss.GetSchwagBonus()), 124, 144, 0.5, 0.5, KColor(1,1,1,1))
		funnyFont:DrawStringScaledUTF8("TOTAL: "..tostring(ss.GetTotalScore()), 124, 154, 0.5, 0.5, KColor(1,1,1,1))
	end
end)]]

if not imgui.ElementExists("ScoresheetMenu") then
	imgui.CreateMenu("ScoresheetMenu", "\u{f03a} Scoresheet")
end

createElement(
	"ScoresheetMenuItemSettings",
	imgui.AddElement,
	"ScoresheetMenu", "ScoresheetMenuItemSettings", ImGuiElement.MenuItem, " \u{f013}Settings"
)

imgui.CreateWindow("ScoresheetMenuSettings", "Destination Settings")
imgui.LinkWindowToElement("ScoresheetMenuSettings", "ScoresheetMenuItemSettings")

createElement(
	"ScoresheetMenuSettingsDestination",
	imgui.AddCombobox,
	"ScoresheetMenuSettings", "ScoresheetMenuSettingsDestination", "Destination", function (index, val)
		--print("that label changed", index, val)
		currentDestination = index + 1
		--print(currentDestination, index)
	end, {
		"Isaac",
		"Satan",
		"Blue Baby",
		"Lamb",
		"Mega Satan",
	},
	0
)

createElement(
	"",
	imgui.AddElement,
	"ScoresheetMenuSettings", "", ImGuiElement.SameLine
)

createElement(
	"ScoresheetMenuDestinationRandom",
	imgui.AddButton,
	"ScoresheetMenuSettings", "ScoresheetMenuDestinationRandom", "\u{f522}", nil
)

--[[imgui.AddCallback("ScoresheetMenuSettingsDestination", ImGuiCallback.Edited, function ()
	print("that label changed")
end)]]

imgui.AddCallback("ScoresheetMenuDestinationRandom", ImGuiCallback.Clicked, function (a)
	local targetDestination = math.random(0,4)
	imgui.UpdateData("ScoresheetMenuSettingsDestination", ImGuiData.Value, targetDestination)
	currentDestination = targetDestination + 1
end)