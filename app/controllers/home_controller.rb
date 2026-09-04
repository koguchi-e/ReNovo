# frozen_string_literal: true

class HomeController < ApplicationController
  layout "public", only: :index

  skip_before_action :require_login, only: :index

  def index
  end
end
