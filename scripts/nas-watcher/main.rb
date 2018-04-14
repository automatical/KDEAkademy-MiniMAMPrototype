require 'inifile'
require 'filewatcher'
require 'rethinkdb'
include RethinkDB::Shortcuts

conn = r.connect(:db => 'video')

configurationfile = "config.ini"
if ARGV.length > 0 then
	configurationfile = ARGV[0]
end

if !File.file?(configurationfile) then
	puts "Configuration file #{configurationfile} not found."
	exit(1)
end

# read an existing file
config = IniFile.load(configurationfile)

watchtarget = config['watcher']['target']

# Watch Directory for Changes
puts "Watching #{watchtarget}"

def generateEncodeJob(filename, conn)
  encodeJob = {
    :type => "proxy",
    :data => {
      :filename => filename
    }
  }
  
  puts r.table('jobs').insert(encodeJob).run(conn)
  puts "Proxy Encode Job Requested: #{filename}"
end

threads = {}

Filewatcher.new([watchtarget]).watch do |filename, event|
  if !threads.key?(filename) then
    puts "Waiting for changes to complete on file: #{filename}"

    threads[filename] = Thread.new do
      difference = 1
      while difference > 0 do
        filesize1 = File.size(filename)
        sleep(1)
        filesize2 = File.size(filename)
        difference = filesize2 - filesize1
      end

      puts "Changes ended on file: #{filename}"
      generateEncodeJob(filename, conn)

      difference = 0
    end
    threads.delete(filename)
  end
end
