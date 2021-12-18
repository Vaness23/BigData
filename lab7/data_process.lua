box.cfg {listen = 3301}

sp = box.schema.space.create('dts_space', {if_not_exists = true})

sp:create_index('primary',{
    parts = {'day', 'ticktime', 'speed'},
    if_not_exists = true
})

function median (numlist)
    if type(numlist) ~= 'table' then return numlist end
    table.sort(numlist)
    if #numlist %2 == 0 then return (numlist[#numlist/2] + numlist[#numlist/2+1]) / 2 end
    return numlist[math.ceil(#numlist/2)]
end

function count_data(day)

    local ticktime = {}
    local speed = {}

    i = 0

    for _, tuple in sp.index.primary:pairs(day, {iterator = box.index.ALL}) do
        i = i + 1
        ticktime[i] = tuple[2]
        speed[i] = tuple[3]
    end

    print("Day:", day)
    print("Speed Median:", median(speed))
    print("Max Time:", sp.index.primary:max({day})[2])
    print("Min Time:", sp.index.primary:min({day})[2])

end

local day = 1
local number_of_days = 7

while (day <= number_of_days) do
    count_data(day)
    day = day + 1
end
