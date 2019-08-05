require 'filewatcher'
require 'rethinkdb'
include RethinkDB::Shortcuts

sleep(5)

conn = r.connect(:db => 'video')

bucketName = ARGV[0]
watchtarget = ARGV[1]

# Watch Directory for Changes
puts "Watching #{watchtarget}"

# TODO: This should update an existing file record if it exists already
def registerAsset(bucket, filename, proxy, thumbnail, conn)
  puts "Registering #{filename}"
  
  puts bucket

  videoAsset = {
    :id => [bucket, filename.split("/").last()].join("-"),
    :bucket => bucket,
    :filename => filename.split("/").last(),
    :files => {
      :filename => filename.split("/").last,
      :proxy => proxy.split("/").last,
      :thumbnail => thumbnail.split("/").last
    }
  }

  puts r.table('assets').insert(videoAsset).run(conn)
end

def generateEncodeJob(filename, bucket, conn)
  puts "Inserting Proxy Job into Queue"

  proxytarget = [filename.sub("/video/", "/video_proxy/").split(".").first, "m3u8"].join(".")

  encodeJob = {
    :type => "proxy",
    :data => {
      :filename => filename,
      :targetFilename => proxytarget,
      :bucket => bucket
    }
  }

  puts r.table('jobs').insert(encodeJob).run(conn)
  
  puts "Proxy Encode Job Requested: #{filename}"

  return proxytarget
end

def generateThumbnailJob(filename, conn)
  puts "Inserting Thumbnail Job into Queue"

  thumbtarget = filename.sub("/video/", "/video_proxy/").split(".")[0] + ".jpg"

  encodeJob = {
    :type => "thumbnail",
    :data => {
      :filename => filename,
      :targetFilename => thumbtarget
    }
  }

  puts r.table('jobs').insert(encodeJob).run(conn)
  
  puts "Proxy Encode Job Requested: #{filename}"

  return thumbtarget
end

threads = {}

Filewatcher.new([watchtarget + "/video/"]).watch do |filename, event|
  puts threads.keys
  if !threads.key?(filename) then
    puts "Waiting for changes to complete on file: #{filename}"

    threads[filename] = Thread.new do
      difference = 1
      while difference > 0 do
        filesize1 = File.size(filename)
        sleep(5)
        filesize2 = File.size(filename)
        difference = filesize2 - filesize1
      end

      puts "Changes ended on file: #{filename}"

      proxy = generateEncodeJob(filename, bucketName, conn)
      thumbnail = generateThumbnailJob(filename, conn)
      registerAsset(bucketName, filename, proxy, thumbnail, conn)

      difference = 0
      threads.delete(filename)
    end
  end
end
