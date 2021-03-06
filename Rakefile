# encoding: utf-8

require 'rubygems'
require 'rake'
require 'bundler'
require 'jeweler'
require 'rspec/core/rake_task'
require 'rdoc/task'

#-------------------------------------------------------------------------------
# Dependencies

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

#-------------------------------------------------------------------------------
# Gem specification

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name                  = "cm"
  gem.homepage              = "http://github.com/adrianwebb/cm"
  gem.license               = "Apache License, Version 2.0"
  gem.email                 = "adrian.webb@gsa.gov"
  gem.authors               = ["Adrian Webb"]
  gem.summary               = %Q{Pluggable cloud management framework that provides a simple foundation for deploying and destroying enterprise ready cloud environments and components}
  gem.description           = %Q{
Pluggable cloud management framework that provides a simple foundation for
deploying and destroying enterprise ready cloud environments and components
that integrate; cloud provider components and services, cloud orchestration
and configuration management tools, and continuous integration and delivery
pipelines.
}
  gem.required_ruby_version = '>= 1.9.1'
  gem.has_rdoc              = true
  gem.rdoc_options << '--title' << 'CM (Cloud Manager)' <<
                      '--main' << 'README.rdoc' <<
                      '--line-numbers'
  gem.files = [
    Dir.glob('bin/*'),
    Dir.glob('lib/**/*.rb'),
    Dir.glob('spec/**/*.rb'),
    Dir.glob('locales/**/*.yml'),
    Dir.glob('**/*.rdoc'),
    Dir.glob('**/*.txt'),
    Dir.glob('Gemfile*'),
    Dir.glob('*.gemspec'),
    Dir.glob('.git*'),
    'VERSION',
    'Rakefile'
  ]
  # Dependencies defined in Gemfile
end

#-------------------------------------------------------------------------------
# Testing

RSpec::Core::RakeTask.new(:spec, :tag) do |spec, task_args|
  options = []
  options << "--tag #{task_args[:tag]}" if task_args.is_a?(Array) && ! task_args[:tag].to_s.empty?
  spec.rspec_opts = options.join(' ')
end
task :default => :spec

#-------------------------------------------------------------------------------
# Documentation

version   = File.read(File.join(File.dirname(__FILE__), 'VERSION'))
doc_title = "cm #{version}"

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = File.join('rdoc', 'site', version)

  rdoc.title    = doc_title
  rdoc.main     = 'README.rdoc'

  rdoc.options << '--line-numbers'
  rdoc.options << '--all'
  rdoc.options << '-w' << '2'

  rdoc.rdoc_files.include('*.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
