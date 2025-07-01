class Guide2::ProceduresController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Guide2::Procedure
  navi_view "cms/node/main/navi"

  private

  def set_crumbs
    @crumbs << [t("guide2.procedure"), action: :index]
  end

  def fix_params
    { cur_site: @cur_site, cur_node: @cur_node }
  end

  public

  def index
    @items = @model.site(@cur_site).
      node(@cur_node).
      search(params[:s]).
      allow(:read, @cur_user, site: @cur_site)
  end
end
