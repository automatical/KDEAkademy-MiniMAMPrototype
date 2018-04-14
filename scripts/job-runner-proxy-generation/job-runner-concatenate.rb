require 'rethinkdb'
include RethinkDB::Shortcuts

conn = r.connect(:db => 'video')

while true do
	items = r.table('jobs').filter{ |job|
	    job.has_fields('processing').not()
	    job['type'].eq('concatenate')
	}.distinct().run(conn)

	if items.length == 0
		# No jobs found, nothing to see here
		sleep(1)
		next
	end

	activeJob = items.first

	locations = {
		"final" => "/Users/kcoyle/Development/VideoProcessing/dropfolders/final/video_proxy/*.m3u8",
		"2017-07-22" => "/Users/kcoyle/Development/VideoProcessing/dropfolders/2017-07-22/video_proxy/*.m3u8"
	}

	completeLocation = {
		"final" => "/Users/kcoyle/Development/VideoProcessing/dropfolders/final/video_proxy/all.m3u8",
		"2017-07-22" => "/Users/kcoyle/Development/VideoProcessing/dropfolders/2017-07-22/video_proxy/all.m3u8"
	}

	r.table('jobs').get(activeJob['id']).update({ :processing => true }).run(conn)

	puts "Processing Job #{activeJob['id']}. Bucket: #{activeJob['data']['bucket']}"

	lines = []

	lines << "#EXTM3U"
	lines << "#EXT-X-VERSION:3"
	lines << "#EXT-X-TARGETDURATION:20"
	lines << "#EXT-X-MEDIA-SEQUENCE:0"

	Dir[ locations[ activeJob['data']['bucket'] ] ].each do |m3u8|
		if m3u8.include? "all.m3u8"
			next
		end
		
		File.readlines(m3u8).each do |line|
			if line.include? "EXTINF"
			   lines << line.sub("\r", "").sub("\n", "")
			end
			if line.include? "ts"
			   lines << line.sub("\r", "").sub("\n", "")
			end
		end

		lines << "#EXT-X-DISCONTINUITY"
	end	

	lines << "#EXT-X-ENDLIST"

	puts "Job Complete"

	if File.file?(completeLocation[ activeJob['data']['bucket'] ])
		File.truncate(completeLocation[ activeJob['data']['bucket'] ], 0)
	end

	File.open(completeLocation[ activeJob['data']['bucket'] ], 'w') { |file| file.write( lines.join("\r\n") ) }

	r.table('jobs').get(activeJob['id']).delete().run(conn)
end

sleep (5)

conn.close