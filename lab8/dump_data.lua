csv = require('csv')

print('Connecting to space')
box.cfg {listen = 3301}
sp = box.schema.space.create('dts_space', {if_not_exists = true})
sp:create_index('primary',{
    parts = {'day', 'ticktime', 'speed'},
    if_not_exists = true
})

for day = 1, 7, 1 do
    local filename = 'day' .. day .. '.csv'
    print('Opening file ' .. filename)
    local file = io.open(filename, 'w')

    print('Dumping data...')
    for _, tuple in sp.index.primary:pairs(day, {iterator = box.index.ALL}) do
        csv.dump(tuple:totable(), nil, file)
    end
    print('Day ' .. day .. ' dumped to ' .. filename)
    file:close()
end
print('Dumped all data')