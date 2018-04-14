# Live Creation Script:
# ffmpeg -y -i tcp://localhost:11000 -f image2 -vf fps=fps=4 -updatefirst 1 room1.jpg

class LiveController < ApplicationController
  def index
  end

  def room
  	@room = params[:roomId]
  end
end
