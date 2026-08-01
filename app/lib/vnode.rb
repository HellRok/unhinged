module Vnode
  class State
    def initialize(native_vnode)
      @native_vnode = native_vnode
    end

    def [](key)
      `#{@native_vnode}.state[#{key}]`
    end

    def []=(key, value)
      `#{@native_vnode}.state[#{key}] = #{value}`
    end
  end

  def vnode
    Hash.new(@native_vnode)
  end

  def attrs
    vnode[:attrs]
  end

  def state
    State.new(@native_vnode)
  end
end
