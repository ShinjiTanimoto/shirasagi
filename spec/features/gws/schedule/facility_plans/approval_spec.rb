require 'spec_helper'

describe "gws_schedule_facility_plans", type: :feature, dbscope: :example, js: true do
  let(:site) { gws_site }
  let(:user) { gws_user }
  let(:facility1) { create :gws_facility_item, approval_check_state: "enabled", user_ids: [ user.id ] }
  let(:facility2) { create :gws_facility_item, approval_check_state: "enabled", user_ids: [ user.id ] }
  let(:facility3) { create :gws_facility_item, approval_check_state: "enabled", user_ids: [ user.id ] }

  before do
    login_user user
  end

  context "with single facility" do
    let!(:item) { create :gws_schedule_facility_plan, facility_ids: [ facility1.id ] }
    let(:comment_text1) { "comment-#{unique_id}" }

    it do
      expect(item.current_approval_state).to eq "request"
      expect(item.approvals).to be_blank

      visit gws_schedule_facilities_path(site: site)
      within ".fc-event:not(.fc-holiday)" do
        first(".fc-title").click
      end
      within "#addon-gws-agents-addons-schedule-approval" do
        within "span[data-facility-id='#{facility1.id}']" do
          wait_cbox_open { first("input[value='approve']").click }
        end
      end
      wait_for_cbox do
        within "#ajax-box form#item-form" do
          fill_in "comment[text]", with: comment_text1
          click_on I18n.t("ss.buttons.save")
        end
      end
      wait_for_notice I18n.t('ss.notice.saved')

      item.reload
      expect(item.current_approval_state).to eq "approve"
      expect(item.approvals.length).to eq 1
      item.approvals.first.tap do |approval|
        expect(approval.approval_state).to eq "approve"
        expect(approval.user_id).to eq user.id
        expect(approval.facility_id).to eq facility1.id
      end
      expect(item.comments.count).to eq 1
      item.comments.first.tap do |comment|
        expect(comment.site_id).to eq site.id
        expect(comment.user_id).to eq user.id
        expect(comment.schedule_id).to eq item.id
        expect(comment.text_type).to eq "plain"
        expect(comment.text).to eq comment_text1
      end
    end
  end

  context "with triple facilities" do
    let!(:item) { create :gws_schedule_facility_plan, facility_ids: [ facility1.id, facility2.id, facility3.id ] }
    let(:comment_text1) { "comment-#{unique_id}" }
    let(:comment_text2) { "comment-#{unique_id}" }
    let(:comment_text3) { "comment-#{unique_id}" }

    it do
      expect(item.current_approval_state).to eq "request"
      expect(item.approvals).to be_blank

      visit gws_schedule_facilities_path(site: site)
      within first(".fc-event") do
        # click_on item.name
        first(".fc-title").click
      end
      # within ".gws-popup" do
      #   click_on I18n.t("ss.links.show")
      # end
      within "#addon-gws-agents-addons-schedule-approval" do
        within "span[data-facility-id='#{facility1.id}']" do
          wait_cbox_open { first("input[value='approve']").click }
        end
      end
      wait_for_cbox do
        within "#ajax-box form#item-form" do
          fill_in "comment[text]", with: comment_text1
          click_on I18n.t("ss.buttons.save")
        end
      end
      wait_for_notice I18n.t('ss.notice.saved')

      within "#addon-gws-agents-addons-schedule-comments" do
        expect(page).to have_css(".list-item", text: comment_text1)
      end

      item.reload
      expect(item.current_approval_state).to eq "request"
      expect(item.approvals.length).to eq 1
      expect(item.comments.count).to eq 1

      within "#addon-gws-agents-addons-schedule-approval" do
        within "span[data-facility-id='#{facility2.id}']" do
          wait_cbox_open { first("input[value='approve']").click }
        end
      end
      wait_for_cbox do
        within "#ajax-box form#item-form" do
          fill_in "comment[text]", with: comment_text2
          click_on I18n.t("ss.buttons.save")
        end
      end
      wait_for_notice I18n.t('ss.notice.saved')

      within "#addon-gws-agents-addons-schedule-comments" do
        expect(page).to have_content(comment_text2)
      end

      item.reload
      expect(item.current_approval_state).to eq "request"
      expect(item.approvals.length).to eq 2
      expect(item.comments.count).to eq 2

      within "#addon-gws-agents-addons-schedule-approval" do
        within "span[data-facility-id='#{facility3.id}']" do
          wait_cbox_open { first("input[value='approve']").click }
        end
      end
      wait_for_cbox do
        within "#ajax-box form#item-form" do
          fill_in "comment[text]", with: comment_text3
          click_on I18n.t("ss.buttons.save")
        end
      end
      wait_for_notice I18n.t('ss.notice.saved')

      within "#addon-gws-agents-addons-schedule-comments" do
        expect(page).to have_content(comment_text3)
      end

      item.reload
      expect(item.current_approval_state).to eq "approve"
      expect(item.approvals.length).to eq 3
      expect(item.comments.count).to eq 3
    end
  end

  context "ss-5106" do
    let!(:user2) { create :gws_user, group_ids: user.group_ids, gws_role_ids: user.gws_role_ids }
    let!(:item) do
      create(
        :gws_schedule_facility_plan, cur_user: user2, facility_ids: [ facility1.id ], readable_setting_range: "public",
        member_ids: [ user2.id ], member_group_ids: [], member_custom_group_ids: [], user_ids: [ user2.id ], group_ids: [])
    end
    let(:comment_text1) { "comment-#{unique_id}" }

    it do
      expect(item.current_approval_state).to eq "request"
      expect(item.approvals).to be_blank

      visit gws_schedule_facilities_path(site: site)
      within ".fc-event:not(.fc-holiday)" do
        first(".fc-title").click
      end
      within "#addon-gws-agents-addons-schedule-approval" do
        within "span[data-facility-id='#{facility1.id}']" do
          wait_cbox_open { first("input[value='approve']").click }
        end
      end
      wait_for_cbox do
        within "#ajax-box form#item-form" do
          fill_in "comment[text]", with: comment_text1
          click_on I18n.t("ss.buttons.save")
        end
      end
      wait_for_notice I18n.t('ss.notice.saved')

      item.reload
      expect(item.current_approval_state).to eq "approve"
      expect(item.approvals.length).to eq 1
      item.approvals.first.tap do |approval|
        expect(approval.approval_state).to eq "approve"
        expect(approval.user_id).to eq user.id
        expect(approval.facility_id).to eq facility1.id
      end
      expect(item.comments.count).to eq 1
      item.comments.first.tap do |comment|
        expect(comment.site_id).to eq site.id
        expect(comment.user_id).to eq user.id
        expect(comment.schedule_id).to eq item.id
        expect(comment.text_type).to eq "plain"
        expect(comment.text).to eq comment_text1
      end
    end
  end
end
