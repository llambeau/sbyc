module SByC
  module Typing
    module R
      class Date < R::Domain
        
        class << self
          
          # Returns true if a given value belongs to this domain,
          # false otherwise
          def is_value?(value)
            value.kind_of?(::Date)
          end
      
          # Parses a literal from the domain and returns
          # a value
          def parse_literal(str)
            str = str.to_s.strip
            if str =~ /^Date\((.*)\)$/
              R::Date($1)
            else
              __not_a_literal__!(self, str)
            end
          end
      
          # Converts a value to a literal
          def to_literal(value)
            "Date(#{value.to_s.inspect})"
          end
          
          # Coerces a string to a time
          def str_coerce(str)
            R::Date(str)
          end
      
        end # class << self
        
      end # class Date
    end # module R
  end # module Typing
end # module SByC