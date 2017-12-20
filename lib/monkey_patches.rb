
# -----------------------------------------------------------------------------
# Monkey patches

# Modify `Object`
#
#  original from (https://gist.github.com/Integralist/9503099)
#
# None of the above solutions work with a multi-level hash
# They only work on the first level: {:foo=>"bar", :level1=>{"level2"=>"baz"}}
# The following two variations solve the problem in the same way
# transform hash keys to symbols
#
# @example
#    multi_hash = { 'foo' => 'bar', 'level1' => { 'level2' => 'baz' } }
#    multi_hash = multi_hash.deep_string_keys
#
class Object

  def deep_symbolize_keys
    if( is_a?( Hash ) )
      return inject({}) do |memo, (k, v)|
        memo.tap { |m| m[k.to_sym] = v.deep_string_keys }
      end
    elsif( is_a?( Array ) )
      return map(&:deep_string_keys)
    end

    self
  end

  def deep_string_keys
    if( is_a?( Hash ) )
      return inject({}) do |memo, (k, v)|
        memo.tap { |m| m[k.to_s] = v.deep_string_keys }
      end
    elsif( is_a?( Array ) )
      return map(&:deep_string_keys)
    end

    self
  end

end

# -----------------------------------------------------------------------------

# Monkey Patch for Array
#
class Array

  # add a compare function to Array class
  #
  # @example
  #    a = ['aaa','bbb']
  #    b = ['ccc','xxx']
  #    a.compare(b)
  #
  # @return [Bool]
  #
  def compare( comparate )
    to_set == comparate.to_set
  end
end

# -----------------------------------------------------------------------------

# Monkey Patch for Hash
#
class Hash

  # add a filter function to Hash Class
  #
  # @example
  #    tags = [ 'foo', 'bar', 'fii' ]
  #    useableTags = tags.filter( 'fii' )
  #
  # @return [Hash]
  #
  def filter( *args )
    if( args.size == 1 )
      args[0] = args[0].to_s if  args[0].is_a?( Symbol )
      select { |key| key.to_s.match( args.first ) }
    else
      select { |key| args.include?( key ) }
    end
  end
end

# -----------------------------------------------------------------------------

# Monkey Patch for Time
#
class Time

  # add function add_minutes to Time Class
  #
  # @example
  #    time = Time.now
  #    time = time.add_minutes(10)
  #
  # @return [Time]
  #
  def add_minutes(m)
    self + (60 * m)
  end
end

# -----------------------------------------------------------------------------

# Monkey Patch to implement an Boolean Check
# original from: https://stackoverflow.com/questions/3028243/check-if-ruby-object-is-a-boolean/3028378#3028378
#
#
module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

true.is_a?(Boolean) #=> true
false.is_a?(Boolean) #=> true

# -----------------------------------------------------------------------------

# Monkey Patch for String Class
#
class String

  # get the first character in a string
  #
  # original from  https://stackoverflow.com/a/2730984
  #
  # @example
  #    'foo'.initial
  #
  # @return [String]
  #
  def initial
    self[0,1]
  end
end

# -----------------------------------------------------------------------------
