# frozen_string_literal: true

module Mnemosyne
  class Responder < ::ActionController::Responder
    def has_view_rendering?
      return false if format == :json
      super
    end
  end
end
