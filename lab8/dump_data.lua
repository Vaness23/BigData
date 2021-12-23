csv = require('csv')

print('Connecting to space')
box.cfg {listen = 3301}
sp = box.schema.space.create('dts_space', {if_not_exists = true})

for day = 1, 7, 1 do
    local filename = 'day' .. day .. '.csv'
    print('Opening file ' .. filename)
    local file = io.open(filename, 'w')

    print('Selecting data for day ' .. day)
    local day_data = sp:select{day}
    print('Dumping data...')
    for key, value in pairs(day_data) do
        csv.dump(value:totable(), nil, file)
    end
    print('Day ' .. day .. ' dumped to ' .. filename)
end
print('Dumped all data')