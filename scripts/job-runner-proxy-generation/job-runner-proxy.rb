require 'rethinkdb'
include RethinkDB::Shortcuts

conn = r.connect(:db => 'video')

def generateConcatenateJob(bucket, conn)
  puts "Inserting Concatenate Job into Queue"

  encodeJob = {
    :type => "concatenate",
    :data => {
      :bucket => bucket
    }
  }

  puts r.table('jobs').insert(encodeJob).run(conn)
  
  puts "Concatenate Encode Job Requested: #{bucket}"
end

while true do
	items = r.table('jobs').filter{ |job|
	    job.has_fields('processing').not()
	    job['type'].eq('proxy')
	}.distinct().run(conn)

	if items.length == 0
		# No jobs found, nothing to see here
		sleep(1)
		next
	end

	activeJob = items.first

	r.table('jobs').get(activeJob['id']).update({ :processing => true }).run(conn)

	puts "Processing Job #{activeJob['id']}. Filename: #{activeJob['data']['filename']}"

	startFilename = activeJob['data']['filename']
	
	puts "Creating Proxy File #{activeJob['data']['targetFilename']}"
	
	puts `#{"/usr/local/bin/ffmpeg -i #{startFilename} -t 20 -profile:v baseline -level 3.0 -start_number 0 -hls_time 10 -hls_list_size 0 -f hls #{activeJob['data']['targetFilename']}"}`

	puts "Job Complete"

	r.table('jobs').get(activeJob['id']).delete().run(conn)

	generateConcatenateJob(activeJob['data']['bucket'], conn)
end

sleep (1)

conn.close