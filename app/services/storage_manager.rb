class StorageManager
    attr_reader :bucket, :s3

    AWS_REGION = 'us-west-1'.freeze

    def initialize
      unless Rails.env.development?
        @s3     = Aws::S3::Resource.new(region: AWS_REGION)
        @bucket = ENV['AWS_BUCKET']
      end
    end

    def store_url(user, url)
      return url if Rails.env.development?

      obj = s3.bucket(bucket).object("avatars/#{user.id}.png")
      download = nil
      open(url) do |file|
        download = file.read
      end
      obj.put(body: download) if download.present?

      obj.public_url
    end
  end
