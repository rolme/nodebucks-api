class VerificationImageUploader < CarrierWave::Uploader::Base
  def store_dir
    "ids"
  end
end
