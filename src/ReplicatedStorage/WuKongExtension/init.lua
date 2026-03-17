local module = {}

setmetatable(module, {
    __index = function(self, key)
        return require(script:FindFirstChild(key))
    end
})

return module