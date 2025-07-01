class Guide2::GuidesController < ApplicationController
  include Cms::BaseFilter

  def index
    redirect_to guide2_procedures_path
  end
end
