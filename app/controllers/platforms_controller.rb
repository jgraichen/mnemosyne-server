# frozen_string_literal: true

class PlatformsController < ApplicationController
  before_action :platform, only: %i[show]

  def index
    @platforms = Platform.all

    render layout: 'global'
  end

  def show
    @heatmap = ::Mnemosyne::Heatmap.new(platform.id)
  end

  private

  def platform
    @platform ||= Platform.where(name: params[:id]).take!
  end
end
