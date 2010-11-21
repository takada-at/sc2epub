require 'rubygems'
require 'lib/sc2epub'
GEMSPEC = Gem::Specification::new do |s|
    s.name = 'sc2epub'
    s.version = Sc2epub::VERSION
    s.author = 'takada-at'
    s.email = 'nightly@at-akada.org'
    s.date = '2010-11-21'
    s.summary = 'sourcecode to epub'
    s.platform = Gem::Platform::RUBY
    s.required_ruby_version = '>= 1.8.6'
    s.executables = ['sc2epub']
    s.default_executable = 'sc2epub'

    s.files = Dir::glob("{lib,bin,test}/**/*") + ['sc2epub.gemspec', 'README', 'CHANGES']
    s.has_rdoc = false
    s.homepage = 'https://github.com/takada-at/sc2epub'
    s.rubyforge_project = 'sc2epub'
    s.description = <<EOF
convert sourcecode to epub
EOF
end
