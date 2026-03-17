return function()
    local tableUtil = require(script.Parent.TableUtil)

    it("深度补丁成功",function()
        local patch = {
            ["1"] = {
                ["1.1"] = 2
            },
            ["2"] = 3,
            ["3"] = tableUtil.Nil
        }
        
        local target = {
            ["1"] = {
                ["1.2"] = 3
            },
            ["2"] = 4,
            ["3"] = 5
        }
        
        tableUtil.DeepPatch(patch,target)
        
        expect(target["1"]["1.1"]).to.equal(2)
        expect(target["2"]).to.equal(3)
        expect(target["3"]).to.equal(nil)
    end)


end