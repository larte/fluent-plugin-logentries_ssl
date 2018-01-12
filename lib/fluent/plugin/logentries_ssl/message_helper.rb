module Fluent
  module Plugin
    module LogentriesSSL
      # logentries 'We have an ingestion limit of 64k per logevent'
      # better go with the lower 64k for safety
      class MessageHelper
        MAX_SIZE = 60_000
        MIN_SIZE = 100

        # Do splitting ad-hoc instead of fancy
        def self.split_record(token, payload, max_size = MAX_SIZE)
          max_size = [max_size, MIN_SIZE].max
          return [payload] if payload.nil? || payload.bytesize < max_size
          splitsize = payload.bytesize
          splitsize /= 2 while splitsize > max_size
          parts = payload.scan(/.{1,#{splitsize}}/)
          parts.collect { |x| "#{token} #{x} \n" }
        end
      end
    end
  end
end
