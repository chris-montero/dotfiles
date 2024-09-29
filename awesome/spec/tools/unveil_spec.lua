
local unveil = require("tools.unveil")

describe("unveil", function()
    describe("dump", function()
        it("should simply print values if the value is not a table", function()
            assert.is_same(unveil._create_output(10), "\n10\n")
        end)
        it("should print values correctly given a table where all keys are contiguous", function()
            local output = "\ntable = {\n    [1] = 10\n    [2] = 20\n    [3] = 30\n    [4] = 40\n}\n"
            assert.is_same(unveil._create_output({10, 20, 30, 40}), output)
        end)
        it("should print values correctly given a table where all keys are contiguous and there's a key value pair", function()
            local output = "\ntable = {\n    [1] = 10\n    [2] = 20\n    [3] = 30\n    [4] = 40\n    key = \"secret\"\n}\n"
            assert.is_same(unveil._create_output({10, 20, 30, 40, key="secret"}), output)
        end)
        it("should print values correctly if given nested tables in the array side of the table", function()
            local output = "\ntable = {\n    [1] = {\n        [1] = {\n        }\n    }\n}\n"
            assert.is_same(unveil._create_output({{{}}}), output)
        end)
        it("should print values correctly if given nested tables in the array side of the table, and additional key value pairs", function()
            local output = "\ntable = {\n    [1] = {\n        [1] = {\n        }\n        key = \"secret\"\n    }\n}\n"
            assert.is_same(unveil._create_output({{{}, key = "secret"}}), output)
        end)
        it("should print values correctly if given an array of values, with one 'nil' gap", function()
            local output = "\ntable = {\n    [1] = 10\n    [2] = 20\n    [3] = 30\n    [4] = nil\n    [5] = 9000\n}\n"
            assert.is_same(unveil._create_output({10, 20, 30, nil, 9000}), output)
        end)
        it("should print values correctly if given an array of values, with three 'nil' gaps", function()
            local output = "\ntable = {\n    [1] = 10\n    [2] = 20\n    [3] = 30\n    [4] = nil\n    [5] = nil\n    [6] = nil\n    [7] = 9000\n}\n"
            assert.is_same(unveil._create_output({10, 20, 30, nil, nil, nil, 9000}), output)
        end)

        it("should print values correctly if given an array of values, with six 'nil' gaps", function()
            local output = "\ntable = {\n    [1] = 10\n    [2] = 20\n    [3] = nil\n    .\n    .\n    .\n    [8] = nil\n    [9] = 9000\n}\n"
            assert.is_same(unveil._create_output({10, 20, nil, nil, nil, nil, nil, nil, 9000}), output)
        end)
    end)
end)
