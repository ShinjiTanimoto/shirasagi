require 'spec_helper'

describe Gws::Tabular::Gws::ColumnsController, type: :feature, dbscope: :example, js: true do
  let(:now) { Time.zone.now.change(sec: 0) }
  let!(:site) { gws_site }
  let!(:admin) { gws_user }

  let!(:space) { create :gws_tabular_space, cur_site: site, state: "public", readable_setting_range: "public" }
  let!(:form) do
    create :gws_tabular_form, cur_site: site, cur_space: space, state: 'closed', workflow_state: 'disabled'
  end

  context "with gws/tabular/column/file_upload_field" do
    let(:name1) { "name-#{unique_id}" }
    let(:required1) { %w(required optional).sample }
    let(:required_label1) { I18n.t("ss.options.state.#{required1}") }
    let(:index_state1) { %w(none asc desc).sample }
    let(:index_state_label1) { I18n.t("gws/tabular.options.order_direction.#{index_state1}") }
    let(:export_state1) { %w(none public).sample }
    let(:export_state_label1) { I18n.t("gws/tabular.options.export_state.#{export_state1}") }
    let(:allowed_extensions1) { Array.new(rand(0..2)) { ".#{unique_id[0, rand(1..3)]}" }.uniq }

    let(:name2) { "name-#{unique_id}" }
    let(:required2) { %w(required optional).sample }
    let(:required_label2) { I18n.t("ss.options.state.#{required2}") }
    let(:index_state2) { %w(none asc desc).sample }
    let(:index_state_label2) { I18n.t("gws/tabular.options.order_direction.#{index_state2}") }
    let(:export_state2) { %w(none public).sample }
    let(:export_state_label2) { I18n.t("gws/tabular.options.export_state.#{export_state2}") }
    let(:allowed_extensions2) { Array.new(rand(0..2)) { ".#{unique_id[0, rand(1..3)]}" }.uniq }

    let(:name3) { "name-#{unique_id}" }
    let(:order3) { rand(10..20) }
    let(:required3) { %w(required optional).sample }
    let(:required_label3) { I18n.t("ss.options.state.#{required3}") }
    let(:tooltips3) { "tooltip-#{unique_id}" }
    let(:prefix_label3) { "pre-#{unique_id}"[0, 10] }
    let(:postfix_label3) { "pos-#{unique_id}"[0, 10] }
    let(:prefix_explanation3) { "<b>prefix-#{unique_id}</b>" }
    let(:postfix_explanation3) { "<b>postfix-#{unique_id}</b>" }
    let(:export_state3) { %w(none public).sample }
    let(:export_state_label3) { I18n.t("gws/tabular.options.export_state.#{export_state3}") }
    let(:allowed_extensions3) { Array.new(rand(0..2)) { ".#{unique_id[0, rand(1..3)]}" }.uniq }
    let(:index_state3) { %w(none asc desc).sample }
    let(:index_state_label3) { I18n.t("gws/tabular.options.order_direction.#{index_state3}") }

    it do
      login_user admin, to: gws_tabular_gws_main_path(site: site)
      click_on space.i18n_name
      click_on form.i18n_name
      click_on I18n.t("gws/workflow.columns.index")
      wait_for_all_turbo_frames

      #
      # Create with default setting
      #
      within ".gws-column-list-toolbar[data-placement='top']" do
        wait_event_to_fire("gws:column:added") { click_on I18n.t("mongoid.models.gws/tabular/column/file_upload_field") }
      end

      form.reload
      expect(form.columns.count).to eq 1

      #
      # Edit
      #
      within first(".gws-column-item") do
        # basic_info
        fill_in "item[name]", with: name1
        # オプション設定
        within ".gws-column-form-input-group[data-field-name='required']" do
          choose required_label1
        end
        within ".gws-column-form-input-group[data-field-name='index_state']" do
          choose index_state_label1
        end
        within ".gws-column-form-input-group[data-field-name='export_state']" do
          choose export_state_label1
        end
        fill_in "item[allowed_extensions]", with: allowed_extensions1.join(" ")

        wait_event_to_fire("turbo:frame-load") { click_on I18n.t("ss.buttons.save") }
      end
      wait_for_notice I18n.t('ss.notice.saved')
      clear_notice

      form.reload
      expect(form.columns.count).to eq 1

      column = form.columns.first
      expect(column).to be_a(Gws::Tabular::Column::FileUploadField)
      expect(column.name).to eq name1
      expect(column.required).to eq required1
      expect(column.index_state).to eq index_state1
      expect(column.export_state).to eq export_state1
      expect(column.allowed_extensions).to eq allowed_extensions1

      #
      # Edit again
      #
      within first(".gws-column-item") do
        wait_event_to_fire("turbo:frame-load") { click_on "edit" }
      end
      within first(".gws-column-item") do
        # basic_info
        fill_in "item[name]", with: name2
        # オプション設定
        within ".gws-column-form-input-group[data-field-name='required']" do
          choose required_label2
        end
        within ".gws-column-form-input-group[data-field-name='index_state']" do
          choose index_state_label2
        end
        within ".gws-column-form-input-group[data-field-name='export_state']" do
          choose export_state_label2
        end
        fill_in "item[allowed_extensions]", with: allowed_extensions2.join(" ")

        wait_event_to_fire("turbo:frame-load") { click_on I18n.t("ss.buttons.save") }
      end
      wait_for_notice I18n.t('ss.notice.saved')
      clear_notice

      form.reload
      expect(form.columns.count).to eq 1

      column = form.columns.first
      expect(column).to be_a(Gws::Tabular::Column::FileUploadField)
      expect(column.name).to eq name2
      expect(column.required).to eq required2
      expect(column.index_state).to eq index_state2
      expect(column.export_state).to eq export_state2
      expect(column.allowed_extensions).to eq allowed_extensions2

      #
      # Edit in detail dialog
      #
      within first(".gws-column-item") do
        open_dialog "open_in_new"
      end
      within_dialog do
        within "form#item-form" do
          # basic_info
          fill_in "item[name]", with: name3
          fill_in "item[order]", with: order3
          select required_label3, from: "item[required]"
          fill_in "item[tooltips]", with: tooltips3
          fill_in "item[prefix_label]", with: prefix_label3
          fill_in "item[postfix_label]", with: postfix_label3
          fill_in "item[prefix_explanation]", with: prefix_explanation3
          fill_in "item[postfix_explanation]", with: postfix_explanation3
          # file_upload_field
          select export_state_label3, from: "item[export_state]"
          fill_in "item[allowed_extensions]", with: allowed_extensions3.join(" ")
          # tabular common
          select index_state_label3, from: "item[index_state]"

          click_on I18n.t("ss.buttons.save")
        end
      end
      wait_for_notice I18n.t('ss.notice.saved')
      clear_notice

      form.reload
      expect(form.columns.count).to eq 1

      column = form.columns.first
      expect(column).to be_a(Gws::Tabular::Column::FileUploadField)
      # basic
      expect(column.name).to eq name3
      expect(column.order).to eq order3
      expect(column.required).to eq required3
      expect(column.tooltips.first).to eq tooltips3
      expect(column.prefix_label).to eq prefix_label3
      expect(column.postfix_label).to eq postfix_label3
      expect(column.prefix_explanation).to eq prefix_explanation3
      expect(column.postfix_explanation).to eq postfix_explanation3
      # file_upload_field
      expect(column.export_state).to eq export_state3
      expect(column.allowed_extensions).to eq allowed_extensions3
      # tabular common
      expect(column.index_state).to eq index_state3
    end
  end
end
