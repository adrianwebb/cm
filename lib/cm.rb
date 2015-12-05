#
# == CM (Cloud Manager)
#
# Framework that provides a simple foundation for deploying and destroying
# enterprise ready cloud environments and components that integrate:
#
# 1. Cloud provider components and services
# 2. Cloud orchestration and configuration management tools
# 3. Continuous integration and delivery pipelines
#
# Author::    Adrian Webb (mailto:adrian.webb@gsa.gov)
# License::   Apache License, version 2

#-------------------------------------------------------------------------------
# Top level properties

lib_dir          = File.dirname(__FILE__)
core_dir         = File.join(lib_dir, 'core')
mod_dir          = File.join(core_dir, 'mod')
mixin_dir        = File.join(core_dir, 'mixin')
mixin_action_dir = File.join(mixin_dir, 'action')
macro_dir        = File.join(mixin_dir, 'macro')
util_dir         = File.join(core_dir, 'util')

#-------------------------------------------------------------------------------
# CM requirements

$:.unshift(lib_dir) unless $:.include?(lib_dir) || $:.include?(File.expand_path(lib_dir))

require 'nucleon_base'

#-------------------------------------------------------------------------------
# Localization

# TODO: Make this dynamically settable

I18n.enforce_available_locales = false
I18n.load_path << File.expand_path(File.join('..', 'locales', 'en.yml'), lib_dir)

#-------------------------------------------------------------------------------
# Include CORL libraries

# Monkey patches (depreciate as fast as possible)
# None right now...

#---

# Mixins for classes
Dir.glob(File.join(mixin_dir, '*.rb')).each do |file|
  require file
end
Dir.glob(File.join(mixin_action_dir, '*.rb')).each do |file|
  require file
end
Dir.glob(File.join(macro_dir, '*.rb')).each do |file|
  require file
end

#---

# Include CM utilities
[].each do |name|
  nucleon_require(util_dir, name)
end

# Special errors
nucleon_require(core_dir, :errors)

#-------------------------------------------------------------------------------
# Include CM plugins

# Include facade
nucleon_require(core_dir, :facade)

#
# CM::Facade extends CM
#
module CM
  extend Facade
end

# Include CM core plugins
nucleon_require(core_dir, :plugin)

#-------------------------------------------------------------------------------
# CM interface

module CM

  def self.VERSION
    File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))
  end

  #-----------------------------------------------------------------------------
  # CM initialization

  def self.lib_path
    File.dirname(__FILE__)
  end

  #---

  Nucleon.reload(true, :cm) do |op, manager|
    if op == :define
      manager.define_types :CM, {

      }
    end
  end
end

#-------------------------------------------------------------------------------
# Load CM action overrides

nucleon_require(core_dir, :overrides)
