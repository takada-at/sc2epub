class Sc2epub::Main
    require 'optparse'
    def main
        opts = OptionParser.new("Usage: #{File::basename($0)} SOURCE_DIR [OUTPUT_DIR] [PROJECT_NAME]")
        opts.on("-v", "--version", "show version") do
            puts "%s %s" %[File.basename($0), Sc2epub::VERSION]
            puts "ruby %s" % RUBY_VERSION
            exit
        end
        opts.on("-u", "--user", "set user name") do |v|
            user = v
        end
        lang = 'ja'
        opts.on('-l', '--lang', 'set language') do |v|
            lang = v
        end
        opts.on_tail("-h", "--help", "show this message") do
            puts opts
            exit
        end
	opts.parse!
        if ARGV.size < 1
            puts opts
            exit
        end
        input = ARGV[0]
        if ARGV.size < 2
            output = File::basename(input) + '-epub'
        else
            output = ARGV[1]
        end
        if ARGV.size < 3
            project = File::basename(input)
        else
            project = ARGV[2]
        end
        user = ENV['USER']
        env = {
            :author => user,
            :lang => lang
        }
        Dir::mkdir(output) unless FileTest::exists? output
        @converter = Sc2epub::Converter::new(env, input, output)
        @converter.doroot(input)
        @converter.dogenerate(project)
    end
end
