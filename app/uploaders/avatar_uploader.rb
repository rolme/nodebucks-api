class AvatarUploader < CarrierWave::Uploader::Base
  def store_dir
    "avatars"
  end

  def filename
    "#{model.id}.#{file.extension}" if original_filename.present?
  end
end
