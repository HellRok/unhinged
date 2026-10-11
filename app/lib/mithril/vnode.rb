module Mithril
  module Vnode
    class State
      def initialize(native_vnode)
        @_native_vnode = native_vnode
      end

      def [](key)
        `#{@_native_vnode}.state[#{key}]`
      end

      def []=(key, value)
        `#{@_native_vnode}.state[#{key}] = #{value}`
      end
    end

    def vnode = @_vnode
    def native_vnode = @_native_vnode

    def vnode=(val)
      @_native_vnode = val
      @_vnode = Hash.new(val)
    end

    def attrs
      vnode[:attrs]
    end

    def state
      State.new(native_vnode)
    end
  end
end
