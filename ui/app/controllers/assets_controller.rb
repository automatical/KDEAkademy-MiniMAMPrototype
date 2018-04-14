require "base64"

class AssetsController < ApplicationController

  skip_before_action :verify_authenticity_token

  def index

    @buckets = r.table('assets')
      .pluck('bucket')
      .distinct()
      .order_by{ |event| event['bucket'] }
      .run(conn)

    @assets = {}

    @buckets.each do |bucket|
      @assets[bucket['bucket']] = r.table('assets')
        .filter{ |asset| asset['bucket'].eq(bucket['bucket']) }
        .order_by{ |event| event['filename'] }
        .distinct()
        .run(conn)

    end

  end

  def bucket

    @bucket = params[:bucketName]
    
  end

  def view

    @assetId = Base64.decode64(params[:assetId])

    @asset = r.table('assets')
        .get(@assetId)
        .run(conn)

  end

  def editevent

    @bucket = params[:bucketName]

    @event = r.table('events')
      .get(params[:eventId].to_i)
      .run(conn)

  end

  def editevent_post

    @bucket = params[:bucketName]

    @event = r.table('events')
      .get(params[:eventId].to_i)
      .update({ :processing => true })
      .run(conn)

    encodeJob = {
      :type => "create-final",
      :data => {
        :bucket => bucket,
        :event => params[:eventId].to_i,
        :start => params[:start],
        :end => params[:end]
      }
    }

    r.table('jobs').insert(encodeJob).run(conn)

  end
end
