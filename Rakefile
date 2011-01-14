begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "gardener"
    gem.summary = "Simple Seed Data Creation for Ruby on Rails."
		gem.description = "A Ruby on Rails Plugin to help you create seed data.  Useful when you want to move just a few pieces of data \
		from one environment to another.  To my knowledge there is no other gem that will help you move a few records from your development or staging \
		environment to your production environment."
    gem.email = "larrick@gmail.com"
		gem.homepage = 'https://github.com/deathbob/Gardener'
    gem.authors = ["Bob Larrick"]
    gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*", "{public}/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue
  puts "Jeweler or dependency not available."
end