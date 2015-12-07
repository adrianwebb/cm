# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: cm 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "cm"
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Adrian Webb"]
  s.date = "2015-12-07"
  s.description = "\nPluggable cloud management framework that provides a simple foundation for\ndeploying and destroying enterprise ready cloud environments and components\nthat integrate; cloud provider components and services, cloud orchestration\nand configuration management tools, and continuous integration and delivery\npipelines.\n"
  s.email = "adrian.webb@gsa.gov"
  s.executables = ["cm"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".gitignore",
    "Gemfile",
    "Gemfile.lock",
    "Rakefile",
    "VERSION",
    "bin/cm",
    "cm.gemspec",
    "lib/CM/batch/celluloid.rb",
    "lib/CM/configuration/directory.rb",
    "lib/CM/configuration/file.rb",
    "lib/CM/job/AWS.rb",
    "lib/CM/job/BOSH.rb",
    "lib/CM/job/concourse.rb",
    "lib/CM/job/keypair.rb",
    "lib/CM/job/variables.rb",
    "lib/CM/plan/default.rb",
    "lib/CM/sequence/default.rb",
    "lib/cm.rb",
    "lib/core/errors.rb",
    "lib/core/facade.rb",
    "lib/core/mixin/action/config.rb",
    "lib/core/mixin/action/registration.rb",
    "lib/core/overrides.rb",
    "lib/core/plugin/batch.rb",
    "lib/core/plugin/cm_action.rb",
    "lib/core/plugin/configuration.rb",
    "lib/core/plugin/disk_configuration.rb",
    "lib/core/plugin/job.rb",
    "lib/core/plugin/parallel_base.rb",
    "lib/core/plugin/plan.rb",
    "lib/core/plugin/plan_action.rb",
    "lib/core/plugin/sequence.rb",
    "lib/nucleon/action/plan/deploy.rb",
    "lib/nucleon/action/plan/destroy.rb",
    "locales/en.yml",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/adrianwebb/cm"
  s.licenses = ["Apache License, Version 2.0"]
  s.rdoc_options = ["--title", "CM (Cloud Manager)", "--main", "README.rdoc", "--line-numbers"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.1")
  s.rubygems_version = "2.4.8"
  s.summary = "Pluggable cloud management framework that provides a simple foundation for deploying and destroying enterprise ready cloud environments and components"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nucleon>, ["~> 0.2"])
      s.add_development_dependency(%q<bundler>, ["~> 1.10"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.4"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.2"])
    else
      s.add_dependency(%q<nucleon>, ["~> 0.2"])
      s.add_dependency(%q<bundler>, ["~> 1.10"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_dependency(%q<rspec>, ["~> 3.4"])
      s.add_dependency(%q<rdoc>, ["~> 4.2"])
    end
  else
    s.add_dependency(%q<nucleon>, ["~> 0.2"])
    s.add_dependency(%q<bundler>, ["~> 1.10"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
    s.add_dependency(%q<rspec>, ["~> 3.4"])
    s.add_dependency(%q<rdoc>, ["~> 4.2"])
  end
end

