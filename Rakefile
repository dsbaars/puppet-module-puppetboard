# encoding: utf-8

require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'yamllint/rake_task'

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
    config.pattern = 'manifests/**/*.pp'

    config.disable_checks = [
        '80chars',
        'class_parameter_defaults',
        'class_inherits_from_params_class',
        'autoloader_layout'
    ]
    config.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
    config.fail_on_warnings = true
    #config.relative = true

    config.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp", "modules/**/*", "vagrant/**"]
end

task :test => [
     :syntax,
     :lint,
]

task :lint_output do
      puts '---> puppet-lint'
end

task :lint => :lint_output

task :metadata do
  sh "metadata-json-lint metadata.json --no-strict-license"
end

YamlLint::RakeTask.new do |t|
    t.paths = %w(
    **.yaml
    )
end
