CarrierWave.configure do |config|
  config.cache_dir = "#{Rails.root}/tmp/uploads" # To let CarrierWave work on heroku
  if Rails.env.production?
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV['S3_KEY'],
      aws_secret_access_key: ENV['S3_SECRET'],
      region:                ENV['S3_REGION']
    }
    config.fog_directory = ENV['S3_BUCKET_NAME']
  elsif Rails.env.test?
    config.root = "#{Rails.root}/tmp"
  else
    config.root = "#{Rails.root}/public"
  end
end