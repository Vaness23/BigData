box.cfg {listen = 3301}

sp = box.schema.space.create('dts_space', {if_not_exists = true})

sp:format({
	{name = 'day', type = 'number'},
	{name = 'ticktime', type = 'number'},
	{name = 'speed', type = 'number'}
	})

sp:create_index('primary',{
		parts = {'day', 'ticktime', 'speed'},
		if_not_exists = true
})


local mqtt = require('mqtt')

connection = mqtt.new('id_vaness23', true)

connection:login_set('Hans', 'Test')

connection:connect({host='194.67.112.161', port=1883})

local json = require('json')

connection:on_message(
	function(message_id, topic, payload, gos, retain)
		local data = json.decode(payload)
		print(payload)
		sp:insert({data["Day"], data["TickTime"], data["Speed"]})
	end
)

connection:subscribe('v4')
