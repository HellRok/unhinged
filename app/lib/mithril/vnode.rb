module Mithril
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

    attr_reader :vnode, :native_vnode

    def vnode=(val)
      @native_vnode = val
      @vnode = Hash.new(val)
    end

    def attrs
      vnode[:attrs]
    end

    def state
      State.new(@native_vnode)
    end
  end
end
