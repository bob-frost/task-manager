# encoding: utf-8

class BaseUploader < CarrierWave::Uploader::Base
  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  process :save_model_attributes

  def image?(target_file = file)
    content_type = model[content_type_attribute_name]
    content_type.present? && content_type.starts_with?('image')
  end

  protected

  def save_model_attributes
    model[content_type_attribute_name] = file.content_type
  end

  def content_type_attribute_name
    "#{mounted_as}_content_type"
  end
end
