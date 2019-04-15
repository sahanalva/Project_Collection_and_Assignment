# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join("config/app.yml")
  # Setting are year, semester, and professor.
  #
  # TODO: Make Validation Work #
  # validate do
  #   unless Setting.professor.present? && Setting.professor.is_a?(String)
  #     puts "YOLO~"
  #     errors.add("Professor name is missing")
  #   end
  # end
  # When config/app.yml has changed, you need change this prefix to v2, v3 ... to expires caches
  # cache_prefix { "v1" }
end
