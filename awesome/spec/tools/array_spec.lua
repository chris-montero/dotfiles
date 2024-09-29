
local tarray = require("tools.array")

describe("tools.array", function() 
    describe("filter", function() 
        it("filters values correctly", function()
            local function predicate(v)
                return v ~= ""
            end
            assert.is_same(tarray.filter({"Hey", "", "sample"}, predicate), {"Hey", "sample"})
        end)
    end)
    describe("concat", function() 
        it("concatenates tables correctly", function()
            assert.is_same(tarray.concat({"first"}, {"second"}), {"first", "second"})
        end)
    end)

    describe("concat_elements", function() 
        it("correctly behaves when only given one element to concatenate", function()
            assert.is_same(tarray.concat_elements({"only"}), "only")
        end)
        it("correctly concatenates multiple values in the table", function()
            assert.is_same(tarray.concat_elements({"a", "b", "c", "d", "e", "f", "g"}), "abcdefg")
        end)
        it("correctly concatenates multiple values in the table with a given separator", function()
            assert.is_same(tarray.concat_elements({"Mary", "had", "a", "little", "lamb"}, " "), "Mary had a little lamb")
        end)
    end)
end)

