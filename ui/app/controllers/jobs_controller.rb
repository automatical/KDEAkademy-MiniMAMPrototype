class JobsController < ApplicationController
  def index
 
  	@proxyjobs = r.table('jobs').filter{ |job|
	    job['type'].eq('proxy')
	}.distinct().run(conn)

	@thumbnailjobs = r.table('jobs').filter{ |job|
	    job['type'].eq('thumbnail')
	}.distinct().run(conn)

	@concatenatejobs = r.table('jobs').filter{ |job|
	    job['type'].eq('concatenate')
	}.distinct().run(conn)

	@completejobs = r.table('jobs').filter{ |job|
	    job['type'].eq('create-final')
	}.distinct().run(conn)

	@events = {}
	@completejobs.each do |job|
		@events[job['data']['event']] = r.table('events').get(job['data']['event']).run(conn)
	end
	
  end
end
