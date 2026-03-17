local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
local GameEntry = require(game.ReplicatedStorage.Battle.Game.GameEntry)
GameEntry.ClientStart()
