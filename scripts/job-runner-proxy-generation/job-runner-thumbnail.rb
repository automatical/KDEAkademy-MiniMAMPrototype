require 'rethinkdb'
include RethinkDB::Shortcuts

conn = r.connect(:db => 'video')

while true do
	items = r.table('jobs').filter{ |job|
	    job.has_fields('processing').not()
	    job['type'].eq('thumbnail')
	}.distinct().run(conn)

	if items.length == 0
		# No jobs found, nothing to see here
		sleep(1)
		next
	end

	activeJob = items.first

	r.table('jobs').get(activeJob['id']).update({ :processing => true }).run(conn)

	puts "Processing Job #{activeJob['id']}. Filename: #{activeJob['data']['filename']}"

	startFilename = activeJob['data']['filename'];

	puts "Creating Proxy File #{activeJob['data']['targetFilename']}"
	
	puts `#{"/usr/local/bin/ffmpeg -i #{startFilename} -ss 00:00:14.435 -vframes 1  #{activeJob['data']['targetFilename']}"}`
	
	puts "Job Complete"

	r.table('jobs').get(activeJob['id']).delete().run(conn)
end

sleep (5)

conn.close