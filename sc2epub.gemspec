require 'rubygems'

GEMSPEC = Gem::Specification::new do |s|
    s.name = 'sc2epub'
    s.version = '0.0.1'
    s.author = 'takada-at'
    s.email = 'takada-at@klab.jp'
    s.date = '2010-11-21'
    s.summary = 'sourcecode to epub'
    s.platform = Gem::Platform::RUBY
    s.required_ruby_version = '>= 1.8.6'
    s.executables = ['sc2epub']
    s.default_executable = 'sc2epub'

    s.files = Dir::glob("*")
    s.has_rdoc = false
    s.homepage = 'https://github.com/takada-at/sc2epub'
    s.rubyforge_project = 'sc2epub'
    s.description = <<EOF
convert sourcecode to epub
EOF
end
