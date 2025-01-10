require 'spec_helper'

describe Opendata::Dataset::ResourceDownloadHistoriesController, type: :feature, dbscope: :example, js: true do
  let(:site) { cms_site }
  let(:node) { create_once :opendata_node_dataset, name: "opendata_dataset" }
  let(:now) { Time.zone.now.beginning_of_minute }
  let!(:history1) { create(:opendata_resource_download_history, downloaded: now) }
  let!(:history2) { create(:opendata_resource_download_history, downloaded: now - 1.day) }
  let!(:history3) { create(:opendata_resource_download_history, downloaded: now - 2.days) }

  before { login_cms_user }

  describe "date navigation" do
    it do
      visit opendata_dataset_history_downloads_main_path(site: site, cid: node)
      expect(page).to have_css(".list-item .dataset", text: history1.dataset_name)
      expect(page).to have_css(".list-item .resource", text: history1.resource_name)
      expect(page).to have_no_css(".list-item .dataset", text: history2.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history2.resource_name)
      expect(page).to have_no_css(".list-item .dataset", text: history3.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history3.resource_name)

      within ".list-head-action" do
        click_on I18n.t('gws.history.days.prev_day')
      end
      wait_for_js_ready
      expect(page).to have_no_css(".list-item .dataset", text: history1.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history1.resource_name)
      expect(page).to have_css(".list-item .dataset", text: history2.dataset_name)
      expect(page).to have_css(".list-item .resource", text: history2.resource_name)
      expect(page).to have_no_css(".list-item .dataset", text: history3.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history3.resource_name)

      within ".list-head-action" do
        click_on I18n.t('gws.history.days.prev_day')
      end
      wait_for_js_ready
      expect(page).to have_no_css(".list-item .dataset", text: history1.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history1.resource_name)
      expect(page).to have_no_css(".list-item .dataset", text: history2.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history2.resource_name)
      expect(page).to have_css(".list-item .dataset", text: history3.dataset_name)
      expect(page).to have_css(".list-item .resource", text: history3.resource_name)

      within ".list-head-action" do
        click_on I18n.t('gws.history.days.next_day')
      end
      wait_for_js_ready
      expect(page).to have_no_css(".list-item .dataset", text: history1.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history1.resource_name)
      expect(page).to have_css(".list-item .dataset", text: history2.dataset_name)
      expect(page).to have_css(".list-item .resource", text: history2.resource_name)
      expect(page).to have_no_css(".list-item .dataset", text: history3.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history3.resource_name)

      within ".list-head-action" do
        click_on I18n.t('gws.history.days.today')
      end
      wait_for_js_ready
      expect(page).to have_css(".list-item .dataset", text: history1.dataset_name)
      expect(page).to have_css(".list-item .resource", text: history1.resource_name)
      expect(page).to have_no_css(".list-item .dataset", text: history2.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history2.resource_name)
      expect(page).to have_no_css(".list-item .dataset", text: history3.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history3.resource_name)

      within ".list-head-action" do
        fill_in_date "ymd", with: now - 1.day
      end
      wait_for_js_ready
      expect(page).to have_no_css(".list-item .dataset", text: history1.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history1.resource_name)
      expect(page).to have_css(".list-item .dataset", text: history2.dataset_name)
      expect(page).to have_css(".list-item .resource", text: history2.resource_name)
      expect(page).to have_no_css(".list-item .dataset", text: history3.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history3.resource_name)
    end
  end

  describe "csv download" do
    it do
      visit opendata_dataset_history_downloads_main_path(site: site, cid: node)
      within ".list-head-action" do
        click_on "CSV"
      end

      wait_for_download

      table = ::CSV.read(downloads.first, headers: true, encoding: 'SJIS:UTF-8')
      expect(table.length).to eq 1

      expected_headers = Opendata::ResourceDownloadHistory::HistoryCsv.csv_headers.map do |k|
        Opendata::ResourceDownloadHistory.t(k)
      end
      expect(table.headers.length).to eq expected_headers.length
      expect(table.headers).to include(*expected_headers)

      expect(table[0][Opendata::ResourceDownloadHistory.t(:downloaded)]).to eq I18n.l(history1.downloaded, format: :picker)
      expect(table[0][Opendata::ResourceDownloadHistory.t(:downloaded_by)]).to eq history1.label(:downloaded_by)
      expect(table[0][Opendata::ResourceDownloadHistory.t(:full_url)]).to eq history1.full_url
      expect(table[0][Opendata::ResourceDownloadHistory.t(:dataset_id)]).to eq history1.dataset_id.to_s
      expect(table[0][Opendata::ResourceDownloadHistory.t(:dataset_name)]).to eq history1.dataset_name
      expect(table[0][Opendata::ResourceDownloadHistory.t(:dataset_areas)]).to eq history1.dataset_areas.join("\n")
      expect(table[0][Opendata::ResourceDownloadHistory.t(:dataset_categories)]).to \
        eq history1.dataset_categories.join("\n")
      expect(table[0][Opendata::ResourceDownloadHistory.t(:dataset_estat_categories)]).to \
        eq history1.dataset_estat_categories.join("\n")
      expect(table[0][Opendata::ResourceDownloadHistory.t(:resource_id)]).to eq history1.resource_id.to_s
      expect(table[0][Opendata::ResourceDownloadHistory.t(:resource_name)]).to eq history1.resource_name
      expect(table[0][Opendata::ResourceDownloadHistory.t(:resource_filename)]).to eq history1.resource_filename
      expect(table[0][Opendata::ResourceDownloadHistory.t(:resource_source_url)]).to eq history1.resource_source_url
      expect(table[0][Opendata::ResourceDownloadHistory.t(:remote_addr)]).to eq history1.remote_addr
      expect(table[0][Opendata::ResourceDownloadHistory.t(:user_agent)]).to eq history1.user_agent
    end
  end

  describe "keyword search" do
    it do
      visit opendata_dataset_history_downloads_main_path(site: site, cid: node)
      within ".index-search" do
        fill_in "s[keyword]", with: history1.resource_name
        click_on I18n.t("ss.buttons.search")
      end
      wait_for_js_ready
      expect(page).to have_css(".list-item .dataset", text: history1.dataset_name)
      expect(page).to have_css(".list-item .resource", text: history1.resource_name)

      within ".index-search" do
        fill_in "s[keyword]", with: history1.dataset_name
        click_on I18n.t("ss.buttons.search")
      end
      wait_for_js_ready
      expect(page).to have_css(".list-item .dataset", text: history1.dataset_name)
      expect(page).to have_css(".list-item .resource", text: history1.resource_name)

      within ".index-search" do
        fill_in "s[keyword]", with: history1.dataset_areas.first
        click_on I18n.t("ss.buttons.search")
      end
      wait_for_js_ready
      expect(page).to have_no_css(".list-item .dataset", text: history1.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history1.resource_name)

      within ".index-search" do
        fill_in "s[keyword]", with: unique_id
        click_on I18n.t("ss.buttons.search")
      end
      wait_for_js_ready
      expect(page).to have_no_css(".list-item .dataset", text: history1.dataset_name)
      expect(page).to have_no_css(".list-item .resource", text: history1.resource_name)
    end
  end
end
