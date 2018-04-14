class EventsController < ApplicationController
  def index
    
  	@events = r.table('events')
  		.distinct()
  		.order_by{ |event| event['start'] }
  		.order_by{ |event| event['room'] }
  		.run(conn)

    @buckets = r.table('assets')
      .pluck('bucket')
      .distinct()
      .order_by{ |event| event['bucket'] }
      .run(conn)

  end
end
