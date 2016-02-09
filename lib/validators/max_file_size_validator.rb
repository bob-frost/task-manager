class MaxFileSizeValidator < ActiveModel::EachValidator
  include ActionView::Helpers::NumberHelper

  def validate_each(record, attribute, value)
    if value.file.present? && value.file.size > limit
      record.errors.add attribute, :file_size_limit, limit: number_to_human_size(limit)
    end
  end

  private

  def limit
    options[:with]
  end
end