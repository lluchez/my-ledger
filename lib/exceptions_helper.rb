module ExceptionsHelper
  class << self
    def create(klass, args, e = nil)
      set_backtrace(klass.new(*args), e)
    end

    def set_backtrace(e1, e2)
      e1.set_backtrace(e2.backtrace) if e2.present?
      e1
    end
  end
end
