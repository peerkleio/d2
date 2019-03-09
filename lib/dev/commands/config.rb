# TODO: Test
require 'dev'

module Dev
  module Commands
    class Config < Dev::Command
      def call(args, _name)
        case args.shift
        when 'set'
          set(args)
        when 'unset'
          unset(args)
        when 'get'
          get(args)
        when 'list', nil
          logger.info Dev::Config.to_s
        else
          logger.info "Unrecognized command. Please see usage\n#{self.class.help}"
        end
      end

      def set(args)
        section = args.shift
        key = nil
        val = nil

        # Set requires a key and a value, so first try to see if section
        # has the key embedded inside
        if section.include?('.')
          section, key = section.split('.', 2)
          val = args.shift
        else
          key = args.shift
          val = args.shift
        end

        if key.nil?
          logger.info "Missing key. Please see usage\n#{self.class.help}"
          return
        end

        if val.nil?
          logger.info "Missing value. Please see usage\n#{self.class.help}"
          return
        end

        logger.info "Setting #{section}.#{key} to #{val}"
        Dev::Config.set(section, key, val)
      end

      def unset(args)
        section = args.shift
        key = args.shift

        # If the key is nil and the section has a .
        # then the key is embedded in the section
        if key.nil? && section.include?('.')
          section, key = section.split('.', 2)
        end

        # If the key is still nil, then we need to fail
        if key.nil?
          logger.info "Missing key. Please see usage\n#{self.class.help}"
          return
        end

        if Dev::Config.get(section, key)
          logger.info "Unsetting #{section}.#{key}"
          Dev::Config.unset(section, key)
        else
          logger.info "No value found for #{section}.#{key} to unset"
        end
      end

      def get(args)
        section = args.shift
        key = args.shift

        # If the key is nil and the section has a .
        # then the key is embedded in the section
        if key.nil? && section.include?('.')
          section, key = section.split('.', 2)
        end

        # If the key is still nil, then we are getting a section
        if key.nil?
          if val = Dev::Config.get_section(section)
            logger.info "{{underline:#{section}}}"
            val.each do |k, v|
              logger.info "Value for #{section}.#{k} is #{v}"
            end
          else
            logger.info "No value found for section #{section}"
          end
          return
        end

        # If we make it this far, we have a section and key
        if val = Dev::Config.get(section, key)
          logger.info "Value for #{section}.#{key} is #{val}"
        else
          logger.info "No value found for #{section}.#{key}"
        end
      end

      def self.help
        <<~EOF
          Dev's Config Manipulation.
          Config is located at #{Dev::Config.file}

          Usage:

          List full config
          ===
          {{command:#{Dev::TOOL_NAME} config}}

          Get a value
          ===
          {{command:#{Dev::TOOL_NAME} config get <section> <key>}}
          {{command:#{Dev::TOOL_NAME} config get <section>.<key>}}

          Get a section
          ===
          {{command:#{Dev::TOOL_NAME} config get <section>}}

          Set a value
          ===
          {{command:#{Dev::TOOL_NAME} config set <section> <key> <val>}}
          {{command:#{Dev::TOOL_NAME} config set <section>.<key> <val>}}

          Unset a value
          ===
          {{command:#{Dev::TOOL_NAME} config unset <section> <key>}}
          {{command:#{Dev::TOOL_NAME} config unset <section>.<key>}}
        EOF
      end
    end
  end
end
