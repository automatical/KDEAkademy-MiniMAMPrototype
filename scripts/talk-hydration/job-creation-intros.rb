require 'rethinkdb'
include RethinkDB::Shortcuts

conn = r.connect(:db => 'video')

# Generate Encode Jobs
# {"date"=>"2017-07-22", "duration"=>"00:10", "id"=>382, "room"=>"Room 1", "start"=>"10:00", "title" => "new title"}
def generateEncodeJob(change, conn)
	puts change
	puts

	if !change.key?("new_val") || change['new_val'].nil? then
		return false
	end

	encodeJob = {
		:type => "intro",
		:assetId => change['new_val']['id'],
		:data => {
			:date => change['new_val']['date'],
			:title => change['new_val']['title']
		}
	}
	
	puts r.table('jobs').insert(encodeJob).run(conn)
end

# Listen for events
r.table('events').changes().run(conn).each{|change| generateEncodeJob(change, conn)}

conn.close