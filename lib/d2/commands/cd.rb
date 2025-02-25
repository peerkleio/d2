# TODO: Test
require 'd2'

module D2
  module Commands
    class Cd < D2::Command
      def call(args, _name)
        query = args.shift

        path = if exact = D2::Config.get('cd', query)
          exact
        else
          # This find command will enumerate the src_path directory for all repos
          # Assumes src_path/PROVIDER.com/OWNER/REPO
          # Will return all `REPO` entries relative to the src path
          base_path = File.expand_path(D2::Config.get('src_path', 'default'))
          options = D2::Helpers::Fzy.fuzzy_match(
            "find #{base_path}/*/* -type d -maxdepth 1 -mindepth 1 | sed -n 's|^#{base_path}||p'",
            query: query,
            num_matches: 1
          )

          if options.empty?
            logger.info "Nothing found for #{args.first}"
            return
          end
          File.join(base_path, options.first)
        end

        D2::FILE_DESCRIPTOR.write("cd #{path}")
      end

      def self.help
        <<~EOF
          Change Directory to Repository. Uses Fuzzy Matching.

          {{bold:Pro-tip:}}
            Does the fuzzy matching not do what you want?
            Run {{command:d2 config cd.[QUERY] [PATH]}}
            This will make {{command:d2 cd [QUERY]}} go to {{info:[PATH]}},
              just like you wanted.


          Usage: {{command:#{D2::TOOL_NAME} cd d2}}
        EOF
      end
    end
  end
end
