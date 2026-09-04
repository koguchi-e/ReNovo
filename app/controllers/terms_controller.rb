# frozen_string_literal: true

class TermsController < ApplicationController
  layout "public", only: :show

  skip_before_action :require_login, only: [ :show ]

  def show
  end
end
