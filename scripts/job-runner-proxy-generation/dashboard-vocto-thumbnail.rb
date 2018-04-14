require 'streamio-ffmpeg'

FFMPEG.ffmpeg_binary = '/usr/local/bin/ffmpeg'

movie = FFMPEG::Movie.new("tcp://localhost:11000")

movie.transcode("test.png")