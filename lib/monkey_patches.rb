
# -----------------------------------------------------------------------------
# Monkey patches

# Modify `Object` (https://gist.github.com/Integralist/9503099)

# None of the above solutions work with a multi-level hash
# They only work on the first level: {:foo=>"bar", :level1=>{"level2"=>"baz"}}
# The following two variations solve the problem in the same way
# transform hash keys to symbols
# multi_hash = { 'foo' => 'bar', 'level1' => { 'level2' => 'baz' } }
# multi_hash = multi_hash.deep_string_keys

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

class Array
  def compare( comparate )
    to_set == comparate.to_set
  end
end

# -----------------------------------------------------------------------------

# filter hash
# example:
# tags = [ 'foo', 'bar', 'fii' ]
# useableTags = tags.filter( 'fii' )

class Hash
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

class Time
  def add_minutes(m)
    self + (60 * m)
  end
end

# -----------------------------------------------------------------------------
