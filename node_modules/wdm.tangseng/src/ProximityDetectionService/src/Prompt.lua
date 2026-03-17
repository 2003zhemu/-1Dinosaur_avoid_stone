local Config = require(script.Parent.PromptConfig)
local bindableEvent = script.Parent.BindableEvent

return {
    new = function(p, n)
        local prompt = Instance.new("ProximityPrompt")
        for i, v in Config do
            prompt[i] = v
        end
        if p:IsA("Model") then
            prompt.Parent = p.PrimaryPart
        else
            prompt.Parent = p
        end
        prompt.Name = n

        prompt.PromptShown:Connect(function(inputType)
            bindableEvent:Fire(prompt, inputType)
        end)
        prompt.PromptHidden:Connect(function()
            bindableEvent:Fire(prompt)
        end)

        return prompt
    end
}