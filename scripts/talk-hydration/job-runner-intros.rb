require 'rethinkdb'
include RethinkDB::Shortcuts

conn = r.connect(:db => 'video')

while true do
	items = r.table('jobs').filter{ |job|
	    job.has_fields('processing').not()
	    job['type'].eq('intro')
	}.distinct().run(conn)

	if items.length == 0
		# No jobs found, nothing to see here
		sleep(1)
		next
	end

	activeJob = items.first

	r.table('jobs').get(activeJob['id']).update({
		:processing => true
	}).run(conn)

	puts "Processing Job #{activeJob['id']}. Talk Id: #{activeJob['assetId']}"

	# runCommand = "python /Users/kcoyle/Development/VideoProcessing/talk-hydration/intro-outro-generator/make.py wikidatacon --id #{activeJob['assetId']}"
	# `runCommand`
	sleep (10)

	puts "Job Complete"

	r.table('jobs').get(activeJob['id']).delete().run(conn)
end

sleep (5)

conn.close