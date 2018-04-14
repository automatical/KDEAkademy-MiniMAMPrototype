require 'rethinkdb'
include RethinkDB::Shortcuts
require 'streamio-ffmpeg'

FFMPEG.ffmpeg_binary = '/usr/local/bin/ffmpeg'

conn = r.connect(:db => 'video')

def buildConcatenated(eventId, startTime, endTime, m3u8, directory)

	startFile = false
	startFileCut = 0
	endFile = false
	endFileCut = 0

	totalDuration = 0

	completeDuration = endTime - startTime

	tsCollection = []

	File.readlines(m3u8).each do |line|
	  if(!line.include? ".ts")
	    next
	  end

	  if endFile
	    next
	  end

	  filename = [directory, line].join().strip!

	  movie = FFMPEG::Movie.new(filename)
	  
	  totalDuration += movie.duration
	  puts "Segment Duration: #{movie.duration}, Total Duration: #{totalDuration}"

	  if !startFile && totalDuration > startTime
	    startFile = line.strip!
	    startFileCut = totalDuration - startTime
	  end

	  if !endFile && totalDuration > endTime
	    endFile = line.strip!
	    endFileCut = totalDuration - endTime
	  end

	  if(startFile)
	    tsCollection << [directory, line].join().strip
	  end

	end

	startTimestamp = Time.at(startFileCut).utc.strftime("%H:%M:%S") + ".000"
	endtimestamp = Time.at(completeDuration).utc.strftime("%H:%M:%S") + ".000"
	puts "Start Segment: #{startFile}, Location: #{startFileCut}, End Segment: #{endFile}, Location: #{endFileCut}"

	puts `#{"/usr/local/bin/ffmpeg -i \"concat:" + tsCollection.join("|") + "\" -c copy -ss #{startTimestamp} -t #{endtimestamp} ~/Desktop/#{eventId}.ts"}`

	puts "Complete!"
end

# Job Spec:
# ---------
# {
# 	"data": {
# 		"bucket":  "final" ,
# 		"end":  "1106.656452" ,
# 		"event": 382 ,
# 		"start":  "191.225603"
# 	} ,
# 	"id":  "1f2d32cf-5033-446b-9cf3-42764e4b47d6" ,
# 	"type":  "create-final"
# }

buckets = {
	'final' => {
		:m3u8 => '/Users/kcoyle/Development/VideoProcessing/dropfolders/final/video_proxy/all.m3u8',
		:directory => '/Users/kcoyle/Development/VideoProcessing/dropfolders/final/video_proxy/'
	}
}

while true do
	items = r.table('jobs').filter{ |job|
	    job.has_fields('processing').not()
	    job['type'].eq('create-final')
	}.distinct().run(conn)

	if items.length == 0
		# No jobs found, nothing to see here
		sleep(1)
		next
	end

	activeJob = items.first

	r.table('jobs').get(activeJob['id']).update({ :processing => true }).run(conn)

	puts "Processing Job #{activeJob['id']}. Event ID: #{activeJob['data']['event']}"

	buildConcatenated(
		activeJob['data']['event'],
		activeJob['data']['start'].to_f,
		activeJob['data']['end'].to_f,
		buckets[activeJob['data']['bucket']][:m3u8],
		buckets[activeJob['data']['bucket']][:directory]
	)
	
	puts "Job Complete"

	r.table('jobs').get(activeJob['id']).delete().run(conn)
end

sleep (5)

conn.close