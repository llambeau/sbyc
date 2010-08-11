require 'time'
require 'date'
require 'sbyc/r/robustness'
require 'sbyc/r/system'
require 'sbyc/r/factory'
require 'sbyc/r/operator'
require 'sbyc/r/domains'
module SByC
  module R
    extend R::Robustness
    extend R::System
    extend R::Factory
    
    def domains
      @__domains__ ||= []
    end
    
    # Creates a domain
    def CreateDomain(name, class_methods, instance_methods = nil)
      
      # Create the domain
      c = Class.new
      
      # Build the class
      [ AbstractDomain::Domain, 
        class_methods ].flatten.each{|mod| c.extend(mod)}
      c.const_set(:Operators, R::AbstractDomain::OperatorSet.factor(c))
      
      # Build the instances
      if instance_methods
        [ instance_methods ].flatten.each{|mod|
          c.instance_eval{ include(mod) }
        }
      end
        
      # Trace it
      domains << c
      
      # Install the selector
      if const_defined?(:Alpha)
        op = R::Operator.new{|op|
          op.description = %Q{ Selector for #{name} }
          op.signature   = [SByC::R::Alpha]
          op.argnames    = [:operand]
          op.returns     = c
          op.aliases     = [name]
          op.method      = lambda{|x| c.coerce(x)}
        }
        R::Alpha::Operators.add_operator(op)
      end
      
      # Returns it
      c
    end
    
    # Creates a domain by reusing a ruby class
    def CreateReuseDomain(name, ruby_class)
      c = CreateDomain(name, AbstractDomain::Reuse::ClassMethods, 
                             AbstractDomain::Reuse::InstanceMethods)
      c.reused_class = ruby_class
      c
    end
    
    def CreateUnionDomain(name, class_methods)
      c = CreateDomain(name, [ AbstractDomain::Union, class_methods ])
      unless name == :Alpha
        R::Alpha.add_sub_domain(c)
        c.add_super_domain(R::Alpha)
      end
      c
    end
    
    def RefineUnionDomain(name, union_domain, class_methods)
      c = CreateDomain(name, class_methods)
      union_domain.add_sub_domain(c)
      c.add_super_domain(union_domain)
      c
    end
    
    extend(R)
  end # module R
end # module SByC

require 'sbyc/r/system/install_domains'
require 'sbyc/r/structures'
require 'sbyc/r/system/alpha'
require 'sbyc/r/system/boolean'
require 'sbyc/r/system/string'
require 'sbyc/r/system/numeric'
require 'sbyc/r/system/integer'
require 'sbyc/r/system/float'
