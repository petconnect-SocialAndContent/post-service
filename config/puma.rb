# config/puma.rb
port ENV.fetch("PORT") { 3006 }
environment ENV.fetch("RACK_ENV") { "production" }
workers 2
threads 1, 5
silence_single_worker_warning  # Opcional: elimina la advertencia

preload_app!
