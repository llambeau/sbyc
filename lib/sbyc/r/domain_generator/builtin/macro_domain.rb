class SByC::R::DomainGenerator::Builtin
  module MacroDomain
    module ClassMethods
    
      def exemplars
        [ '(Macro (Array $0 $1))' ].collect{|src|
          system.evaluate(system.parse(src))
        }
      end
    
      def is_value?(value)
        value.class == self
      end

      def parse_literal(str)
        __not_a_literal__!(self, str)
      end

      def to_literal(value)
        value.to_s
      end
    
      def works_on_ast?
        true
      end
      
      def call_signature(runner, args, binding)
        @call_signature ||= [ [ CodeTree::AstNode ] ]
      end
      
      def coerce(runner, args, binding)
        case f = args.first
          when CodeTree::AstNode
            self.new(f)
          else
            call_error(runner, args, binding)
        end
      end
      
    end
    module InstanceMethods
      include SByC::R::Callable::AstBased
      
      # Creates a macro instance
      def initialize(ast)
        @ast = ast
      end
      
      def expand(args, runner = self.class.system)
        result = ast.visit{|node, collected|
          case node.function
            when :_
              node
            when :'?'
              if looks_an_unbounded_variable?(node.literal)
                node.literal.to_s =~ /^\$(\d+)$/
                arg = args[$1.to_i]
                if arg.kind_of?(CodeTree::AstNode)
                  arg
                else
                  CodeTree::AstNode.new(:_, [ arg ])
                end
              else
                node
              end
            else
              CodeTree::AstNode.new(node.function, collected)
          end
        }
        runner.fed(:Expression).new(result)
      end
      
      def works_on_ast?
        true
      end
      
      def sbyc_call(runner, args, binding)
        runner.make_call(expand(args, runner), [], binding)
      end
      
      def to_s
        "(Macro #{ast.to_s})"
      end
      alias :inspect :to_s
      
      def ==(other)
        other.kind_of?(self.class) and other.ast == self.ast
      end
      
    end
  end # module MacroDomain
end # class SByC::R::DomainGenerator::Builtin