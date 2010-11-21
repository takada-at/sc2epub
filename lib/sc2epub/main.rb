class Sc2epub::Main
    require 'optparse'
    def main
        input = ARGV[0]
        output = ARGV[1]
        opts = OptionParser.new("Usage: #{File::basename($0)} SOME_DIR OUTPUT_DIR PROJECT_NAME")
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
        if ARGV.size < 3
            puts opts
            exit
        end
        user = ENV['USER']
        env = {
            :author => user,
            :lang => lang
        }
        Dir::mkdir(output) unless FileTest::exists? output
        @converter = Sc2epub::Converter::new(env, input, output)
        @converter.doroot(input)
        @converter.dogenerate(ARGV[2])
    end
end
