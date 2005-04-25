###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

module Kwartz

   module Util

      ## a hash which keeps the order of insertion
      class OrderedHash
         include Enumerable

         def initialize
            @keys = []
            @hash = {}
         end

         attr_reader :keys, :hash

         def each(&block)
            keys.each do |key|
               value = @hash[key]
               yield(key, value)
            end
         end

         def [](key)
            return @hash[key]
         end

         def []=(key, value)
            @keys << key unless @hash.key?(key)
            @hash[key] = value
         end

         def delete(key)
            @keys.delete(key)
            @hash.delete(key)
         end

         def default
            return @hash.default
         end

         def default=(value)
            @hash.default = value
         end

         def key?(key)
            return @hash.key?(key)
         end
         
         def empty?
            return @hash.empty?
         end
         
         def include?(key)
            return @hash.include?(key)
         end

      end

   end

end
