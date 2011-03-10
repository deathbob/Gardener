module Gardener
  

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    attr_accessor :infinite_choice


    # Dump every instance of a class (every record in the database for a model) into a file
    # to be reconstituted later.
    def sow
      c = self.to_s.underscore.pluralize
      dir = File.join [Rails.root, 'db', 'garden']
      Dir.mkdir(dir) unless File.exists?(dir)

      File.open(File.join([Rails.root, 'db', 'garden', "#{c}.yml"] ), 'w') do |file|
        self.find_each{ |x| file << x.to_yaml }
      end
    end

    def garden_path
      File.join([Rails.root, 'db', 'garden', "#{self.to_s.underscore.pluralize}.yml"] )
    end
    
    # Loads each yaml representation of an object up into an array, so you can play with them individually.
    def secret_garden
      instance_eval "attr_accessor :abra"
      @abra = []
      str = ''
      File.open(garden_path, 'r').each_line do |line|
        if line.match /^---/
          @abra << str
          str = ''
        end
        str << line
      end
      @abra << str unless str.blank?      
    end

    # Take the things that were dumped to a file and put them in the database.
    def reap
      str = ''
      File.open(garden_path, 'r').each_line do |line|
        if line.match /^---/
          sprout(str)
          str = ''
        end
        str << line
      end
      sprout(str) unless str.blank?
    end


    # Helper function to reconstitute a record from it's yaml representation.
    def sprout(str)
      return false if str.blank?
#      puts str.inspect

      foo = YAML.load(str)
      return unless foo # YAML.load('') == false
      bob = self.new(foo.attributes)
      bob.id = foo.id

      # Grr, have to check to see if anything in the inheritance hierarchy has the id.
      base_class = self.base_class
      scott = base_class.find_by_id(bob.id)

      if scott
        puts "\n\n#{bob.class.name} with id #{bob.id} already exists, differences are"
        bar = scott.diff(bob)
        if bar.blank?
          puts "\tActually, there are no differences, even the ids are the same #{bob.id} == #{scott.id}.\n\tLooks like you're trying to bring in the exact same object that already exists in the db."
        else
          pp bar
        end

        if @infinite_choice
          res = @infinite_choice
        else
          print "\n\nAdd a 'z' to your selection to apply it to everything\nOverwrite (y), do nothing (n), give a new ID (i), or abort (a) ?  "
          res = gets
          @infinite_choice = res if res.match(/z/i)
        end

        if res.match(/y/i)
          scott = bob
          scott.save
        elsif res.match(/a/i)
          raise "Salting the earth.  Nothing will grow here for some time ..."
        elsif res.match(/i/i)
          bob.id = nil
          bob.save
        else
          puts "#{bob.class.name} with id #{bob.id} already exists, doing nothing."
        end
      else
        bob.save
      end
    end

  end  # End ClassMethods




##### Instance Methods #####

  def diff(obj)
    buff = {}
    self.attributes.each do |k, v|
      tmp = obj.send(k) if obj.respond_to?(k)
      if tmp.eql?(v)
        # they're the same, do nothing
      else
        buff[k] = {:original => v, :new => tmp}
      end
    end # end self.attributes.each
    buff
  end


  # Called on an particular instance of a class to render it down into a file, from which it can be
  # _reaped_ later.
  def plant_seed(options = {})
    c = self.class.to_s.underscore.pluralize
    # Code to render down associated items exists, but nothing has been done to pull those objects back out.
    # Not automatically at least, but of course reaping the correct model will pull them up no problem.


    # TODO
    # need to load the file up and see if the thing i'm trying to add is in it
    # or just overwrite the whole file every time.
    # Do something to prevent duplicates from slipping in.
    dir = File.join [Rails.root, 'db', 'garden']
    Dir.mkdir(dir) unless File.exists?(dir)


    File.open(File.join([Rails.root, 'db', 'garden', "#{c}.yml"] ), 'a') do |file|
      file << self.to_yaml
    end

    includes = things_to_include(options)
#    puts includes
    includes.each do |k, v|
      tom = self.send(k) if self.respond_to?(k)
      [*tom].each{|y| y.plant_seed({:include => v})}
    end

  end


  def things_to_include(options)
    # [*THING] is so that THING can be an array or a single instance of a class.
    # .each will blow up if THING is just an instance, not an array, unless we explode and re-array it.
    return [] unless options[:include]
    case options[:include]
    when Hash
      options[:include].inject({}){|memo, v| memo[v[0]] = v[1] if self.respond_to?(v[0]); memo}
    else
      [*options[:include]]
    end
  end

  def to_fixture
    {"#{self.class.to_s.underscore}_#{self.id}" => self.attributes}.to_yaml
  end



end

ActiveRecord::Base.class_eval{ include Gardener }
