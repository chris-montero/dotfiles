
local function override_b_to_a(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
end

return {
    override_b_to_a = override_b_to_a,
}
