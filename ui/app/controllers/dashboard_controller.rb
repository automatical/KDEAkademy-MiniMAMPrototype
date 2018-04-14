class DashboardController < ApplicationController
  def index

  	@statistics = {
  		:totalAssets => { :key => "Total Assets", :value => 0 },
  		:availableBuckets => { :key => "Available Buckets", :value => 0 },
  		:runningJobs => { :key => "Queued/ Running Jobs", :value => 0 }
  	}

  	@statistics[:totalAssets][:value] = r.table('assets')
  		.count()
  		.run(conn)

  	@statistics[:availableBuckets][:value] = r.table('assets')
      .pluck('bucket')
      .distinct()
      .count()
      .run(conn)

  	@statistics[:runningJobs][:value] = r.table('jobs')
      .count()
      .run(conn)

  end
end
