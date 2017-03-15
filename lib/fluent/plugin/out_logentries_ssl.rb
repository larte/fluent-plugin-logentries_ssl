#
# Copyright 2017- larte
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fluent/plugin/output'
require 'yaml'

module Fluent::Plugin
  class LogentriesSSL < Fluent::Plugin::Output
    include Fluent::PluginHelper::Socket

    Fluent::Plugin.register_output('logentries_ssl', self)

    config_param :max_retries, :integer, default: 3
    config_param :le_host, :string, default: 'data.logentries.com'
    config_param :le_port, :integer, default: 443
    config_param :token_path, :string
    config_param :json, :bool, default: true
    config_param :verify_fqdn, :bool, default: true

    def configure(conf)
      super
      begin
        @apptokens = YAML.load_file(@token_path)
      rescue StandardErrro => e
        raise Fluent::ConfigError, "Could not load #{@token_path}: #{e.message}"
      end
    end

    def start
      super
      log.trace "Creating connection to #{@le_host}"
      @_client = create_client
    end

    # apparently needed for msgpack_each in :write fluent Issue-1342
    def formatted_to_msgpack_binary
      true
    end

    def format(tag, _time, record)
      [tag, record].to_msgpack
    end

    def tag_token(tag)
      @apptokens.each do |name, token|
        return token if tag.casecmp(name).zero?
      end
      nil
    end

    def write(chunk)
      log.debug 'Writing records to logentries'
      chunk.msgpack_each do |tag, record|
        token = tag_token(tag)
        log.trace "Got token #{token} for tag #{tag}"
        log.trace "Record is #{record.inspect}"
        next unless token
        data = @json ? record.to_json : record
        with_retries do
          log.trace "writing: #{token} #{data}"
          client.write("#{token} #{data} \n")
        end
      end
    end

    private

    def create_client
      socket_create(:tls, @le_host, @le_port, verify_fqdn: @verify_fqdn)
    end

    def close_client
      @_client.close if @_client
      @_client = nil
    end

    def client
      @_client ||= create_client
    end

    def retry?(n)
      n < @max_retries
    end

    def with_retries
      tries = 0
      begin
        yield
      rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ECONNABORTED,
             Errno::ENETUNREACH, Errno::ETIMEDOUT, Errno::EPIPE => e
        if retry?(tries += 1)
          log.warn 'Clould not push to logentries, reset and retry'\
                   "in #{2**tries} seconds. #{e.message}"
          sleep(2**tries) if retry?(tries + 1)
          close_client
          retry
        end
        raise 'Could not push logs to Logentries'
      end
    end
  end
end
