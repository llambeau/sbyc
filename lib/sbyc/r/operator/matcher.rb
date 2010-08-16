module SByC
  module R
    class Operator
      class Matcher
      
        # Coerces to a matcher
        def self.coerce(domain_or_matcher)
          case domain_or_matcher
            when ::Class
              DomainMatcher.new(domain_or_matcher)
            when Matcher
              domain_or_matcher
            when ::String
              system.evaluate({}, str)
            when ::Array
              collected = domain_or_matcher.collect{|arg| coerce(arg)}
              case collected.size
                when 0
                  EmptyMatcher.new
                when 1
                  collected[0]
                else
                  SeqMatcher.new(collected)
              end
            else
              __not_a_literal__!(self, domain_or_matcher)
          end
        end
      
        #
        # Compiles expressions to matchers
        #
        # (plus (seq Symbol Alpha))
        #
        def self.compile(expr = nil, &block)
          ast = SByC::CodeTree::coerce(expr || block)
          ast.visit{|node, collected|
            case node.function
              when :_
                if (n = node.literal).nil?
                  EmptyMatcher.new
                else
                  DomainMatcher.new(node.literal)
                end
              when :seq
                SeqMatcher.new(collected)
              when :plus
                if collected.size == 1
                  PlusMatcher.new(collected[0])
                else
                  PlusMatcher.new(SeqMatcher.new(collected))
                end
              when :star
                if collected.size == 1
                  StarMatcher.new(collected[0])
                else
                  StarMatcher.new(SeqMatcher.new(collected))
                end
              else
                raise "Unexpected expression #{node.function}"
            end
          }
        end
      
        def call_with_star?
          true
        end
      
        def domain_matches?(domains, requester = nil)
          !prepare_signature_for_type_checking(domains.dup, requester).nil?
        end

        def prepare_signature_for_type_checking(sign, requester = nil)
          x = eat_signature(sign, requester)
          (x.nil? || !sign.empty?) ? nil : x
        end
        
        def args_matches?(args, requester = nil)
          !prepare_args_for_call(args.dup, requester).nil?
        end

        def prepare_args_for_call(args, requester = nil)
          x = eat_args(args, requester)
          (x.nil? || !args.empty?) ? nil : x
        end
        
        def +(other)
          SeqMatcher.new([self, other])
        end
      
      end # class Matcher
    end # class Operator
  end # module R
end # module SByC
require 'sbyc/r/operator/matcher/empty_matcher'
require 'sbyc/r/operator/matcher/domain_matcher'
require 'sbyc/r/operator/matcher/plus_matcher'
require 'sbyc/r/operator/matcher/star_matcher'
require 'sbyc/r/operator/matcher/seq_matcher'
