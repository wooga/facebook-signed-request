$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), "..", "lib") )

require 'test/unit'
require 'facebook-signed-request'

class Test::Unit::TestCase

  unless defined?(Spec)
    # test "verify something" do
    #   ...
    # end
    def self.test(name, &block)
      test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
      defined = instance_method(test_name) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{name}"
        end
      end
    end
  end

end
