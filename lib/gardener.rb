module Gardener
	def self.included(base)
		base.extend(ClassMethods)
	end
	
	module ClassMethods
			
			def reap
				c = self.to_s.underscore.pluralize
				str = ''
			  File.open(File.join([Rails.root, 'db', 'fixtures', "#{c}.yml"] ), 'r').each_line do |line|
					if line.match /^---.*/
						sprout(str)
						str = ''
					end
					str << line
				end
				sprout(str)
			end

			def sow
				c = self.to_s.underscore.pluralize
				File.open(File.join([Rails.root, 'db', 'fixtures', "#{c}.yml"] ), 'w') do |file|		
					self.find_each{ |x| file << x.to_yaml }
				end
			end

			def sprout(str)
				bob = YAML.load(str)
				return unless bob # YAML.load('') == false 
				scott = self.find_by_id(bob.id)
				if scott
					scott = bob
					scott.save
				else
					bob.save
				end
			end

			include Gardener::InstanceMethods

	end


	module InstanceMethods

		def plant_seed(options = {})
			c = self.class.to_s.underscore.pluralize
			puts c
			# Code to render down associated items exists, 
			if options[:include]
				puts options[:include].inspect
				[*options[:include]].each do |x|
					tom = self.send(x)
					[*tom].each{|y| y.plant_seed}
				end
			end
			# TODO
			# need to load the file up and see if the thing i'm trying to add is in it
			# or just overwrite the whole file every time.
			# Do something to prevent duplicates from slipping in. 
			File.open(File.join([Rails.root, 'db', 'fixtures', "#{c}.yml"] ), 'a') do |file|
	#			file << self.to_fixture
				file << self.to_yaml
			end
		end
	
		def to_fixture
			{"#{self.class.to_s.underscore}_#{self.id}" => self.attributes}.to_yaml
		end

	end
	
	
end

ActiveRecord::Base.class_eval{ include Gardener }