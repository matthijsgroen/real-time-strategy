# Be sure to restart your server when you modify this file.

ActiveRecord::Base.send :include, Extensions::Resources
ActiveRecord::Base.send :include, Extensions::TimedEvents