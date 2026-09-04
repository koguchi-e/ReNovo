# frozen_string_literal: true

class PrivacyController < ApplicationController
  layout "public", only: :show

  skip_before_action :require_login, only: %i[show]

  def show
  end
end
