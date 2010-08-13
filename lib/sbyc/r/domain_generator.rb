module SByC
  module R
    class DomainGenerator
      
      # Creates a generator instance
      def initialize
        @domains_hash = {}
      end
      
      # Factors a class with class methods and instance methods
      def factor_class(class_methods = [], instance_methods = [])
        clazz = Class.new
        class_methods.flatten.each{|mod| 
          clazz.extend(mod)
        }
        instance_methods.flatten.each{|mod|
          clazz.instance_eval{ include(mod) }
        }
        clazz
      end
      
      # Split domain modules against ClassMethods/InstanceMethods
      # separation.
      def split_domain_modules(modules)
        # split against ClassMethods/InstanceMethods distinction
        class_modules, instance_modules = [], []
        modules.flatten.each{|mod|
          if mod.const_defined?(:ClassMethods)
            class_modules << mod.const_get(:ClassMethods)
            if mod.const_defined?(:InstanceMethods)
              instance_modules << mod.const_get(:InstanceMethods)
            end
          else
            class_modules << mod
          end
        }
        [class_modules, instance_modules]
      end
      
      # Factors a domain class
      def factor_domain_class(modules)
        clazz = factor_class(*split_domain_modules([R::AbstractDomain]+modules))
        clazz.domain_generator = self
        clazz.const_set(:Operators, R::Operator::Set.factor)
        clazz
      end
      
      def refine(domain, *args)
        if args.size==1 and args[0].kind_of?(::Class)
          #
          # first case: the subdomain has already been created. Domain 
          # is probably a union domain ...
          #
          sub_domain = args[0]
          domain.add_immediate_sub_domain(sub_domain)
          sub_domain.add_immediate_super_domain(domain)
          sub_domain
        else
          #
          # Second case: a name and modules. Modules are split against
          # ClassMethods and InstanceMethods submodules. Module that do
          # not make the distinction are considered class modules.
          #
          refine(domain, generate(args.shift, args))
        end
      end
        
      #
      # Returns the name of a domain generated by this generator.
      #
      # @param [Class] a domain previously generated by this generator.
      # @return [String] domain's name
      #
      def domain_name_of(domain)
        raise NotImplementedError
      end
        
      # Returns known domains
      def domains
        @domains_hash.values
      end
      
      # Tracks creation of domains
      def domain_created(name, domain)
        @domains_hash[name] = domain
        if name.to_s =~ /^[A-Z][a-z]+$/
          SByC::R::const_set(name, domain)
        end
        domain
      end
        
    end # class DomainGenerator
  end # module R
end # module SByc
require 'sbyc/r/domain_generator/builtin'
require 'sbyc/r/domain_generator/array'
require 'sbyc/r/domain_generator/tools'