# frozen_string_literal: true

Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore if defined?(Rack::MiniProfiler)
