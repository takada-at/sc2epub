require 'rubygems'
require 'rake/gempackagetask'

require 'lib/sc2epub'
load 'sc2epub.gemspec'

Rake::GemPackageTask.new(GEMSPEC) do |pkg|
    pkg.need_tar = true
end
