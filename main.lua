--scoresheet cool--

local mod = RegisterMod("Scoresheet in Vanilla", 1)
local game = Game()

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

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if Game():GetHUD():IsVisible() and shouldRenderScoreSheet then
		funnyFont:DrawStringScaledUTF8("Stage bonus: "..tostring(ss.GetStageBonus()), 124, 124, 0.5, 0.5, KColor(1,1,1,1))
		funnyFont:DrawStringScaledUTF8("Exploration bonus: "..tostring(ss.GetExplorationBonus()), 124, 134, 0.5, 0.5, KColor(1,1,1,1))
		funnyFont:DrawStringScaledUTF8("Schwag bonus: "..tostring(ss.GetSchwagBonus()), 124, 144, 0.5, 0.5, KColor(1,1,1,1))
		funnyFont:DrawStringScaledUTF8("TOTAL: "..tostring(ss.GetTotalScore()), 124, 154, 0.5, 0.5, KColor(1,1,1,1))
	end
end)