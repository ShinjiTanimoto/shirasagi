require 'spec_helper'

describe "gws_staff_record_public_duties", type: :feature, dbscope: :example do
  let(:site) { gws_site }
  let(:year) { create :gws_staff_record_year }
  let(:section) { create :gws_staff_record_group, year_id: year.id }
  let!(:item) do
    create(
      :gws_staff_record_user, year_id: year.id, section_name: section.name,
      staff_records_view: "show", divide_duties_view: "show"
    )
  end
  let(:index_path) { gws_staff_record_public_duties_path(site) }

  context "with auth", js: true do
    before { login_gws_user }

    it "#index" do
      visit index_path
      expect(current_path).not_to eq sns_login_path

      # show
      click_link item.charge_name
    end
  end
end
