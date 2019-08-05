require 'net/http'
require 'json'

require 'rethinkdb'
include RethinkDB::Shortcuts

conn = r.connect(:db => 'video')

# Fetch schedule data
uri = URI("https://conf.kde.org/en/akademy2018/public/schedule.json")
res = Net::HTTP.get_response(uri)

# Parse response
schedule_data = JSON.parse(res.body)

days = schedule_data['schedule']['conference']['days']

talks = {}

days.each do |day|
	date = day['date']
	
	day['rooms'].each do |room|
 		room_title = room[0]

		room[1].each do |event|			
			talks[event['id']] = {
				:date => date,
				:room => room_title,
				:title => event['title'],
				:start => event['start'],
				:duration => event['duration'],
			}
		end
	end
end

talks.keys.each do |talkid|
	talkData = {
		:id => talkid.to_i,
		:date => talks[talkid][:date],
		:room => talks[talkid][:room],
		:title => talks[talkid][:title],
		:start => talks[talkid][:start],
		:duration => talks[talkid][:duration]
	}
	
	r.table('events').insert(talkData, {:conflict => "replace"}).run(conn)
end

conn.close