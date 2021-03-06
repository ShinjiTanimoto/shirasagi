class Gws::Presence::UserSettingsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter
  include Gws::UserSettingFilter

  def set_item
    @item = @cur_user.user_presence(@cur_site)
  end

  def fix_params
    { cur_site: @cur_site, cur_user: @cur_user }
  end

  def permit_fields
    [ :sync_available_state, :sync_unavailable_state, :sync_timecard_state ]
  end

  def update
    @item.attributes = get_params
    render_update @item.update
  end
end
