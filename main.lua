--scoresheet cool--

local mod = RegisterMod("Scoresheet in Vanilla", 1)

if not REPENTOGON then
	mod:AddCallback(ModCallbacks.MC_POST_RENDER, function ()
		
	end)
	return
end

local game = Game()
local ss = ScoreSheet
local imgui = ImGui

local currentDestination = 1

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

		currentDestination = rng:RandomInt(0, 3)

		imgui.UpdateData("ScoresheetMenuSettingsDestination", ImGuiData.Value, currentDestination)
	end
end)

local shouldRenderScoreSheet = false
mod:AddCallback(ModCallbacks.MC_PRE_COMPLETION_EVENT, function(_, compType, player)
	local level = Game():GetLevel()
	print("hey hey hey")
	if compType > 0 and compType ~= CompletionType.BOSS_RUSH then
		print("heyo")
		ss.SetRunEnding(7)
		ss.AddFinishedStage(level:GetStage(), level:GetStageType(), Game().TimeCounter)
		ss.Calculate()
		Game():ShowGenericLeaderboard()
		shouldRenderScoreSheet = true
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
	"ScoresheetMenu", "ScoresheetMenuItemSettings", ImGuiElement.MenuItem, "Settings"
)

imgui.CreateWindow("ScoresheetMenuSettings", "Destination Settings")
imgui.LinkWindowToElement("ScoresheetMenuSettings", "ScoresheetMenuItemSettings")

createElement(
	"ScoresheetMenuSettingsDestination",
	imgui.AddCombobox,
	"ScoresheetMenuSettings", "ScoresheetMenuSettingsDestination", "Destination", function (index, val)
		currentDestination = index
	end, {
		"Mom", "Mom's Heart", "Deez", "Nuts"
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
	print("that button was clicked")
	imgui.UpdateData("ScoresheetMenuSettingsDestination", ImGuiData.Value, math.random(0, 3))
end)