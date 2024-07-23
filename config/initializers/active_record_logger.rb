if Rails.env.development?
  ActiveRecord::Base.logger.level = Logger::WARN
end
