require 'aws-sdk-s3'

Aws.config.update({
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_KEY'], ENV['AWS_SECRET'])
})

$s3 = Aws::S3::Resource.new
