# encoding: utf-8

class Task::AttachmentUploader < BaseUploader
  include CarrierWave::MiniMagick
  
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb, if: :image? do
    process resize_to_fit: [200, 200]
  end
end
