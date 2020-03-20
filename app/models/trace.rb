# frozen_string_literal: true

class Trace < ApplicationRecord
  self.primary_key = 'id'

  extend Model::Range
  include Model::Duration

  attribute :id, :uuid
  attribute :origin_id, :uuid
  attribute :platform_id, :uuid
  attribute :application_id, :uuid
  attribute :activity_id, :uuid

  has_many :spans, -> { order('start') }
  has_many :failures

  belongs_to :application
  belongs_to :platform
  belongs_to :origin, class_name: 'Span', optional: true

  class << self
    def after(time)
      where t[:stop].gteq(time)
    end

    def retention(period, time = Time.zone.now)
      period = ::Server::Types::Duration.new.cast_value(period)
      tlimit = time - period

      where t[:stop].lt(tlimit).and(t[:store].eq(false))
    end

    alias t arel_table
  end
end
