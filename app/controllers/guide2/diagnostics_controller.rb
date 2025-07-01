class Guide2::DiagnosticsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Guide2::Question
  navi_view "cms/node/main/navi"

  private

  def set_crumbs
    @crumbs << [t("guide2.diagnostic"), url_for(action: :show)]
  end

  def set_item
  end

  public

  def show
    raise "403" unless Guide2::Question.allowed?(:read, @cur_user, site: @cur_site, node: @cur_node)
    render
  end
end
