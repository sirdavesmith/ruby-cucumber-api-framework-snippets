require 'cucumber/rake/task'

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = "--format progress --tags ~@failing"
end

Cucumber::Rake::Task.new(:focus) do |t|
  t.cucumber_opts = "--format progress --tags @focus"
end

Cucumber::Rake::Task.new(:smoke) do |t|
  t.cucumber_opts = "--format progress --tags @smoke"
end

namespace :features do
  desc "Run all features"
  Cucumber::Rake::Task.new(:all) do |t|
    t.cucumber_opts = "--format progress"
  end
end
