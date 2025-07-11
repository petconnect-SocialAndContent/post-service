# config/puma.rb
port ENV.fetch("PORT") { 3006 }
environment ENV.fetch("RACK_ENV") { "production" }
workers 1
threads 1, 5

preload_app!

# Bind para Docker
bind "tcp://0.0.0.0:#{ENV['PORT'] || 3006}"
