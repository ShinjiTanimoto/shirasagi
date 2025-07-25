require 'spec_helper'

describe 'article_pages', type: :feature, dbscope: :example, js: true do
  let(:site) { cms_site }
  let(:node) { create :article_node_page, cur_site: site, group_ids: [cms_group.id] }
  let!(:form) { create :cms_form, cur_site: site, state: 'public', sub_type: 'entry' }

  let(:node2) { create :article_node_page, cur_site: site, group_ids: [cms_group.id] }
  let!(:selectable_page1) { create :article_page, cur_site: site, cur_node: node2, state: "public" }
  let!(:selectable_page2) { create :article_page, cur_site: site, cur_node: node2, state: "public" }
  let!(:selectable_page3) { create :article_page, cur_site: site, cur_node: node2, state: "public" }
  let!(:selectable_page4) { create :article_page, cur_site: site, cur_node: node2, state: "closed" }

  let!(:column1) do
    create(:cms_column_text_field, cur_site: site, cur_form: form, required: "optional", order: 1, input_type: 'text')
  end
  let!(:column2) do
    create(:cms_column_date_field, cur_site: site, cur_form: form, required: "optional", order: 2)
  end
  let!(:column3) do
    create(:cms_column_url_field2, cur_site: site, cur_form: form, required: "optional", order: 3, html_tag: '')
  end
  let!(:column4) do
    create(:cms_column_text_area, cur_site: site, cur_form: form, required: "optional", order: 4)
  end
  let!(:column5) do
    create(:cms_column_select, cur_site: site, cur_form: form, required: "optional", order: 5)
  end
  let!(:column6) do
    create(:cms_column_radio_button, cur_site: site, cur_form: form, required: "optional", order: 6)
  end
  let!(:column7) do
    create(:cms_column_check_box, cur_site: site, cur_form: form, required: "optional", order: 7)
  end
  let!(:column8) do
    create(:cms_column_file_upload, cur_site: site, cur_form: form, required: "optional", order: 8, file_type: "image")
  end
  let!(:column9) do
    create(:cms_column_free, cur_site: site, cur_form: form, required: "optional", order: 9)
  end
  let!(:column10) do
    create(:cms_column_headline, cur_site: site, cur_form: form, required: "optional", order: 10)
  end
  let!(:column11) do
    create(:cms_column_list, cur_site: site, cur_form: form, required: "optional", order: 11)
  end
  let!(:column12) do
    create(:cms_column_table, cur_site: site, cur_form: form, required: "optional", order: 12)
  end
  let!(:column13) do
    create(:cms_column_youtube, cur_site: site, cur_form: form, required: "optional", order: 13)
  end
  let!(:column14) do
    create(:cms_column_select_page, cur_site: site, cur_form: form, required: "optional", order: 14, node_ids: [node2.id])
  end
  let(:name) { unique_id }
  let(:column1_value1) { unique_id }
  let(:column2_value1) { "#{rand(2000..2050)}/01/01" }
  let(:column3_label1) { unique_id }
  let(:column3_url1) { "http://#{site.domain}/#{unique_id}/" }
  let(:column4_value1) { "#{unique_id}#{unique_id}\n#{unique_id}#{unique_id}#{unique_id}" }
  let(:column5_value1) { column5.select_options.sample }
  let(:column6_value1) { column6.select_options.sample }
  let(:column7_value1) { column7.select_options.sample }
  let(:column8_image_text1) { unique_id }
  let(:column9_value1) { unique_id }
  # let(:column10_head1) { %w(h1 h2 h3 h4 h5).sample }
  let(:column10_head1) { %w(h1 h2).sample }
  let(:column10_text1) { unique_id }
  let(:column11_list1) { unique_id }
  let(:column12_height1) { rand(2..100) }
  let(:column12_width1) { rand(2..100) }
  let(:column12_caption1) { unique_id }
  let(:column13_youtube_id1) { unique_id }
  let(:column13_url1) { "https://www.youtube.com/watch?v=#{column13_youtube_id1}" }
  let(:column13_title1) { unique_id }
  let(:column14_page1) { [ selectable_page1, selectable_page2, selectable_page3 ].sample }

  let(:column1_value2) { unique_id }
  let(:column2_value2) { "#{rand(2000..2050)}/01/01" }
  let(:column3_label2) { unique_id }
  let(:column3_url2) { "http://#{site.domain}/日本語/" }
  let(:column4_value2) { "#{unique_id}#{unique_id}\n#{unique_id}#{unique_id}#{unique_id}" }
  let(:column5_value2) { column5.select_options.sample }
  let(:column6_value2) { column6.select_options.sample }
  let(:column7_value2) { column7.select_options.sample }
  let(:column8_image_text2) { unique_id }
  let(:column9_value2) { unique_id }
  # let(:column10_head2) { %w(h1 h2 h3 h4 h5).sample }
  let(:column10_head2) { (%w(h1 h2) - [column10_head1]).sample }
  let(:column10_text2) { unique_id }
  let(:column11_list2) { unique_id }
  let(:column12_height2) { rand(2..100) }
  let(:column12_width2) { rand(2..100) }
  let(:column12_caption2) { unique_id }
  let(:column13_youtube_id2) { unique_id }
  let(:column13_url2) { "https://www.youtube.com/watch?v=#{column13_youtube_id2}" }
  let(:column13_title2) { unique_id }
  let(:column14_page2) { ([ selectable_page1, selectable_page2, selectable_page3 ] - [ column14_page1 ]).sample }
  let!(:body_layout) { create(:cms_body_layout) }

  def article_pages
    Article::Page.where(filename: /^#{node.filename}\//)
  end

  before do
    cms_role.add_to_set(permissions: %w(read_cms_body_layouts))
    site.set(auto_keywords: 'enabled', auto_description: 'enabled')
    node.st_form_ids = [ form.id ]
    node.save!
  end

  context 'basic crud with form' do
    before { login_cms_user }

    context 'first, create empty pagen and then add columns' do
      it do
        #
        # Create empty page
        #
        visit new_article_page_path(site: site, cid: node)
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        expect(page).to have_selector('#item_body_layout_id')

        within 'form#item-form' do
          fill_in 'item[name]', with: name
          wait_for_event_fired("ss:formActivated") do
            page.accept_confirm(I18n.t("cms.confirm.change_form")) do
              select form.name, from: 'in_form_id'
            end
          end
          ensure_addon_opened('#addon-cms-agents-addons-meta')
          choose "item_description_setting_auto"
          expect(page).to have_css("#addon-cms-agents-addons-form-page .addon-head", text: form.name)
          expect(page).to have_no_selector('#item_body_layout_id', visible: true)
          click_on I18n.t('ss.buttons.draft_save')
        end
        wait_for_notice I18n.t('ss.notice.saved')
        expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames

        expect(article_pages.count).to eq 1
        article_pages.first.tap do |item|
          expect(item.name).to eq name
          expect(item.description_setting).to eq 'auto'
          expect(item.description).to eq form.html
          expect(item.summary).to eq form.html
          expect(item.column_values).to be_blank
          expect(item.backups.count).to eq 1
        end
        expect(SS::File.all.unscoped.count).to eq 0

        #
        # Add columns
        #
        visit article_pages_path(site: site, cid: node)
        click_on name
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames

        click_on I18n.t('ss.links.edit')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        within 'form#item-form' do
          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column1.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-textfield" do
            fill_in "item[column_values][][in_wrap][value]", with: column1_value1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column2.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-datefield" do
            fill_in "item[column_values][][in_wrap][date]", with: column2_value1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column3.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-urlfield2" do
            fill_in "item[column_values][][in_wrap][link_label]", with: column3_label1
            fill_in "item[column_values][][in_wrap][link_url]", with: column3_url1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column4.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-textarea" do
            fill_in "item[column_values][][in_wrap][value]", with: column4_value1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column5.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-select" do
            select column5_value1, from: "item[column_values][][in_wrap][value]"
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column6.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-radiobutton" do
            first(:field, type: "radio", with: column6_value1).click
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column7.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-checkbox" do
            first(:field, name: "item[column_values][][in_wrap][values][]", with: column7_value1).click
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column8.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-fileupload" do
            fill_in "item[column_values][][in_wrap][file_label]", with: column8_image_text1
          end
          ss_upload_file "#{Rails.root}/spec/fixtures/ss/file/keyvisual.gif", addon: ".column-value-cms-column-fileupload"
          within ".column-value-cms-column-fileupload" do
            expect(page).to have_content("keyvisual.gif")
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column9.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-free" do
            fill_in_ckeditor "item[column_values][][in_wrap][value]", with: column9_value1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column10.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-headline" do
            select column10_head1, from: "item[column_values][][in_wrap][head]"
            fill_in "item[column_values][][in_wrap][text]", with: column10_text1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column11.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-list" do
            fill_in "item[column_values][][in_wrap][lists][]", with: column11_list1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column12.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-table" do
            find("input.height").set(column12_height1)
            find("input.width").set(column12_width1)
            find("input.caption").set(column12_caption1)
            click_on I18n.t("cms.column_table.create")
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column13.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-youtube" do
            fill_in "item[column_values][][in_wrap][url]", with: column13_url1
            fill_in "item[column_values][][in_wrap][title]", with: column13_title1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column14.name
            end
          end
          wait_for_cbox_opened { click_on I18n.t("cms.apis.pages.index") }
        end
        within_cbox do
          expect(page).to have_css(".list-item", text: selectable_page1.name)
          expect(page).to have_css(".list-item", text: selectable_page2.name)
          expect(page).to have_css(".list-item", text: selectable_page3.name)
          expect(page).to have_no_css(".list-item", text: selectable_page4.name)
          wait_for_cbox_closed { click_on column14_page1.name }
        end
        within 'form#item-form' do
          within ".column-value-cms-column-selectpage " do
            expect(page).to have_css(".ajax-selected", text: column14_page1.name)
          end

          wait_for_js_ready
          click_on I18n.t('ss.buttons.draft_save')
        end
        wait_for_notice I18n.t('ss.notice.saved')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))

        expect(article_pages.count).to eq 1
        article_pages.first.tap do |item|
          expect(item.name).to eq name
          expect(item.column_values).to have(14).items

          expect(item.column_values.find_by(column_id: column1.id).value).to eq column1_value1
          expect(item.column_values.find_by(column_id: column2.id).date).to eq Time.zone.parse(column2_value1)
          expect(item.column_values.find_by(column_id: column3.id).link_label).to eq column3_label1
          expect(item.column_values.find_by(column_id: column3.id).link_url).to eq column3_url1
          expect(item.column_values.find_by(column_id: column4.id).value).to eq column4_value1.gsub("\n", "\r\n")
          expect(item.column_values.find_by(column_id: column5.id).value).to eq column5_value1
          expect(item.column_values.find_by(column_id: column6.id).value).to eq column6_value1
          expect(item.column_values.find_by(column_id: column7.id).values).to eq [ column7_value1 ]
          expect(item.column_values.find_by(column_id: column8.id).file_label).to eq column8_image_text1
          expect(item.column_values.find_by(column_id: column8.id).file.name).to eq 'keyvisual.gif'
          expect(item.column_values.find_by(column_id: column8.id).file.owner_item_id).to eq item.id
          expect(item.column_values.find_by(column_id: column9.id).value).to include column9_value1
          expect(item.column_values.find_by(column_id: column10.id).head).to eq column10_head1
          expect(item.column_values.find_by(column_id: column10.id).text).to eq column10_text1
          expect(item.column_values.find_by(column_id: column11.id).lists).to include column11_list1
          expect(item.column_values.find_by(column_id: column12.id).value).to be_present
          expect(item.column_values.find_by(column_id: column13.id).youtube_id).to eq column13_youtube_id1
          expect(item.column_values.find_by(column_id: column13.id).title).to eq column13_title1
          expect(item.column_values.find_by(column_id: column14.id).page_id).to eq column14_page1.id

          expect(item.backups.count).to eq 2
        end
        expect(SS::File.all.unscoped.count).to eq 1

        #
        # Update columns
        #
        visit article_pages_path(site: site, cid: node)
        expect(page).to have_no_selector('#item_body_layout_id', visible: true)

        click_on name
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames

        click_on I18n.t('ss.links.edit')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        within 'form#item-form' do
          within ".column-value-cms-column-textfield" do
            fill_in "item[column_values][][in_wrap][value]", with: column1_value2
          end
          within ".column-value-cms-column-datefield" do
            fill_in "item[column_values][][in_wrap][date]", with: column2_value2
          end
          within ".column-value-cms-column-urlfield2" do
            fill_in "item[column_values][][in_wrap][link_label]", with: column3_label2
            fill_in "item[column_values][][in_wrap][link_url]", with: column3_url2
          end
          within ".column-value-cms-column-textarea" do
            fill_in "item[column_values][][in_wrap][value]", with: column4_value2
          end
          within ".column-value-cms-column-select" do
            select column5_value2, from: "item[column_values][][in_wrap][value]"
          end
          within ".column-value-cms-column-radiobutton" do
            first(:field, type: "radio", with: column6_value2).click
          end
          within ".column-value-cms-column-checkbox" do
            first(:field, name: "item[column_values][][in_wrap][values][]", with: column7_value1).click
            first(:field, name: "item[column_values][][in_wrap][values][]", with: column7_value2).click
          end
          within ".column-value-cms-column-fileupload" do
            fill_in "item[column_values][][in_wrap][file_label]", with: column8_image_text2
          end
          ss_upload_file "#{Rails.root}/spec/fixtures/ss/logo.png", addon: ".column-value-cms-column-fileupload"
          within ".column-value-cms-column-fileupload" do
            expect(page).to have_content("logo.png")
          end

          within ".column-value-cms-column-free" do
            fill_in_ckeditor "item[column_values][][in_wrap][value]", with: column9_value2
          end
          within ".column-value-cms-column-headline" do
            select column10_head2, from: "item[column_values][][in_wrap][head]"
            fill_in "item[column_values][][in_wrap][text]", with: column10_text2
          end
          within ".column-value-cms-column-list" do
            fill_in "item[column_values][][in_wrap][lists][]", with: column11_list2
          end
          within ".column-value-cms-column-table" do
            find("input.height").set(column12_height2)
            find("input.width").set(column12_width2)
            find("input.caption").set(column12_caption2)
            click_on I18n.t("cms.column_table.create")
          end
          within ".column-value-cms-column-youtube" do
            fill_in "item[column_values][][in_wrap][url]", with: column13_url2
            fill_in "item[column_values][][in_wrap][title]", with: column13_title2
          end

          within ".column-value-cms-column-selectpage " do
            wait_for_cbox_opened { click_on I18n.t("cms.apis.pages.index") }
          end
        end
        within_cbox do
          expect(page).to have_css(".list-item", text: selectable_page1.name)
          expect(page).to have_css(".list-item", text: selectable_page2.name)
          expect(page).to have_css(".list-item", text: selectable_page3.name)
          expect(page).to have_no_css(".list-item", text: selectable_page4.name)
          wait_for_cbox_closed{ click_on column14_page2.name }
        end
        within 'form#item-form' do
          within ".column-value-cms-column-selectpage " do
            expect(page).to have_css(".ajax-selected", text: column14_page2.name)
          end

          wait_for_js_ready
          click_on I18n.t('ss.buttons.draft_save')
        end
        wait_for_notice I18n.t('ss.notice.saved')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))

        expect(article_pages.count).to eq 1
        article_pages.first.tap do |item|
          expect(item.name).to eq name
          expect(item.column_values).to have(14).items

          expect(item.column_values.find_by(column_id: column1.id).value).to eq column1_value2
          expect(item.column_values.find_by(column_id: column2.id).date).to eq Time.zone.parse(column2_value2)
          expect(item.column_values.find_by(column_id: column3.id).link_label).to eq column3_label2
          expect(item.column_values.find_by(column_id: column3.id).link_url).to eq column3_url2
          expect(item.column_values.find_by(column_id: column4.id).value).to eq column4_value2.gsub("\n", "\r\n")
          expect(item.column_values.find_by(column_id: column5.id).value).to eq column5_value2
          expect(item.column_values.find_by(column_id: column6.id).value).to eq column6_value2
          expect(item.column_values.find_by(column_id: column7.id).values).to eq [ column7_value2 ]
          expect(item.column_values.find_by(column_id: column8.id).file_label).to eq column8_image_text2
          expect(item.column_values.find_by(column_id: column8.id).file.name).to eq 'logo.png'
          expect(item.column_values.find_by(column_id: column8.id).file.owner_item_id).to eq item.id
          expect(item.column_values.find_by(column_id: column9.id).value).to include column9_value2
          expect(item.column_values.find_by(column_id: column10.id).head).to eq column10_head2
          expect(item.column_values.find_by(column_id: column10.id).text).to eq column10_text2
          expect(item.column_values.find_by(column_id: column11.id).lists).to include column11_list2
          expect(item.column_values.find_by(column_id: column12.id).value).to be_present
          expect(item.column_values.find_by(column_id: column13.id).youtube_id).to eq column13_youtube_id2
          expect(item.column_values.find_by(column_id: column13.id).title).to eq column13_title2
          expect(item.column_values.find_by(column_id: column14.id).page_id).to eq column14_page2.id

          expect(item.backups.count).to eq 3
        end
        expect(SS::File.all.unscoped.count).to eq 1

        #
        # Remove columns
        #
        visit article_pages_path(site: site, cid: node)
        click_on name
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames

        click_on I18n.t('ss.links.edit')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        within 'form#item-form' do
          %w(
            textfield datefield urlfield2 textarea select radiobutton checkbox fileupload
            free headline list table youtube selectpage
          ).each do |f|
            within ".column-value-cms-column-#{f} .column-value-header" do
              page.accept_alert do
                click_on I18n.t("ss.buttons.delete")
              end
            end
            # wait animation finished
            expect(page).to have_no_css(".column-value-cms-column-#{f}")
            wait_for_all_ckeditors_ready
            wait_for_all_turbo_frames
          end

          click_on I18n.t('ss.buttons.draft_save')
        end
        wait_for_notice I18n.t('ss.notice.saved')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))

        expect(article_pages.count).to eq 1
        article_pages.first.tap do |item|
          expect(item.name).to eq name
          expect(item.column_values).to have(0).items

          expect(item.backups.count).to eq 4
        end
        expect(SS::File.all.unscoped.count).to eq 0

        #
        # Delete page
        #
        visit article_pages_path(site: site, cid: node)
        click_on name
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        click_on I18n.t('ss.links.delete')
        within 'form' do
          click_on I18n.t('ss.buttons.delete')
        end
        wait_for_notice I18n.t('ss.notice.deleted')
        expect(article_pages.count).to eq 0
        expect(SS::File.all.unscoped.count).to eq 0
      end
    end

    context 'create page with full columns' do
      it do
        #
        # Create page with full columns
        #
        visit new_article_page_path(site: site, cid: node)
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames

        within 'form#item-form' do
          fill_in 'item[name]', with: name
          wait_for_event_fired("ss:formActivated") do
            page.accept_confirm(I18n.t("cms.confirm.change_form")) do
              select form.name, from: 'in_form_id'
            end
          end

          expect(page).to have_css("#addon-cms-agents-addons-form-page .addon-head", text: form.name)
          ensure_addon_opened('#addon-cms-agents-addons-meta')
          choose "item_description_setting_auto"

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column1.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-textfield" do
            fill_in "item[column_values][][in_wrap][value]", with: column1_value1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column2.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-datefield" do
            fill_in "item[column_values][][in_wrap][date]", with: column2_value1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column3.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-urlfield2" do
            fill_in "item[column_values][][in_wrap][link_label]", with: column3_label1
            fill_in "item[column_values][][in_wrap][link_url]", with: column3_url1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column4.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-textarea" do
            fill_in "item[column_values][][in_wrap][value]", with: column4_value1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column5.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-select" do
            select column5_value1, from: "item[column_values][][in_wrap][value]"
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column6.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-radiobutton" do
            first(:field, type: "radio", with: column6_value1).click
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column7.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-checkbox" do
            first(:field, name: "item[column_values][][in_wrap][values][]", with: column7_value1).click
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column8.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-fileupload" do
            fill_in "item[column_values][][in_wrap][file_label]", with: column8_image_text1
          end
          ss_upload_file "#{Rails.root}/spec/fixtures/ss/file/keyvisual.gif", addon: ".column-value-cms-column-fileupload"
          within ".column-value-cms-column-fileupload" do
            expect(page).to have_content("keyvisual.gif")
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column9.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-free" do
            fill_in_ckeditor "item[column_values][][in_wrap][value]", with: column9_value1
          end
          ss_upload_file "#{Rails.root}/spec/fixtures/ss/shirasagi.pdf", addon: ".column-value-cms-column-free"
          within ".column-value-cms-column-free" do
            expect(page).to have_content("shirasagi.pdf")
            click_on I18n.t("sns.file_attach")
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column10.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-headline" do
            select column10_head1, from: "item[column_values][][in_wrap][head]"
            fill_in "item[column_values][][in_wrap][text]", with: column10_text1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column11.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-list" do
            fill_in "item[column_values][][in_wrap][lists][]", with: column11_list1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column12.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-table" do
            find("input.height").set(column12_height1)
            find("input.width").set(column12_width1)
            find("input.caption").set(column12_caption1)
            click_on I18n.t("cms.column_table.create")
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column13.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          within ".column-value-cms-column-youtube" do
            fill_in "item[column_values][][in_wrap][url]", with: column13_url1
            fill_in "item[column_values][][in_wrap][title]", with: column13_title1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column14.name
            end
          end
          wait_for_all_ckeditors_ready
          wait_for_all_turbo_frames
          wait_for_cbox_opened { click_on I18n.t("cms.apis.pages.index") }
        end
        within_cbox do
          expect(page).to have_css(".list-item", text: selectable_page1.name)
          expect(page).to have_css(".list-item", text: selectable_page2.name)
          expect(page).to have_css(".list-item", text: selectable_page3.name)
          expect(page).to have_no_css(".list-item", text: selectable_page4.name)
          wait_for_cbox_closed { click_on column14_page1.name }
        end
        within 'form#item-form' do
          within ".column-value-cms-column-selectpage " do
            expect(page).to have_css(".ajax-selected", text: column14_page1.name)
          end
          click_on I18n.t('ss.buttons.draft_save')
        end
        wait_for_notice I18n.t('ss.notice.saved')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))

        expect(article_pages.count).to eq 1
        article_pages.first.tap do |item|
          expect(item.name).to eq name
          expect(item.description_setting).to eq 'auto'
          expect(item.description).to eq form.html
          expect(item.summary).to eq form.html
          expect(item.column_values).to have(14).items

          item.column_values.find_by(column_id: column1.id).tap do |column_value|
            expect(column_value.value).to eq column1_value1
          end
          item.column_values.find_by(column_id: column2.id).tap do |column_value|
            expect(column_value.date).to eq Time.zone.parse(column2_value1)
          end
          item.column_values.find_by(column_id: column3.id).tap do |column_value|
            expect(column_value.link_label).to eq column3_label1
            expect(column_value.link_url).to eq column3_url1
          end
          item.column_values.find_by(column_id: column4.id).tap do |column_value|
            expect(column_value.value).to eq column4_value1.gsub("\n", "\r\n")
          end
          item.column_values.find_by(column_id: column5.id).tap do |column_value|
            expect(column_value.value).to eq column5_value1
          end
          item.column_values.find_by(column_id: column6.id).tap do |column_value|
            expect(column_value.value).to eq column6_value1
          end
          item.column_values.find_by(column_id: column7.id).tap do |column_value|
            expect(column_value.values).to eq [ column7_value1 ]
          end
          item.column_values.find_by(column_id: column8.id).tap do |column_value|
            expect(column_value.file_label).to eq column8_image_text1
            expect(column_value.file.name).to eq 'keyvisual.gif'
            expect(column_value.file.owner_item_id).to eq item.id
          end
          item.column_values.find_by(column_id: column9.id).tap do |column_value|
            expect(column_value.value).to include column9_value1
            expect(column_value.file_ids).to have(1).items
            column_value.files.first.tap do |file|
              expect(file.name).to eq 'shirasagi.pdf'
              expect(file.owner_item_id).to eq item.id
            end
          end
          item.column_values.find_by(column_id: column10.id).tap do |column_value|
            expect(column_value.head).to eq column10_head1
            expect(column_value.text).to eq column10_text1
          end
          item.column_values.find_by(column_id: column11.id).tap do |column_value|
            expect(column_value.lists).to include column11_list1
          end
          item.column_values.find_by(column_id: column12.id).tap do |column_value|
            expect(column_value.value).to be_present
          end
          item.column_values.find_by(column_id: column13.id).tap do |column_value|
            expect(column_value.youtube_id).to eq column13_youtube_id1
          end
          item.column_values.find_by(column_id: column14.id).tap do |column_value|
            expect(column_value.page_id).to eq column14_page1.id
          end

          expect(item.backups.count).to eq 1
        end
        expect(SS::File.all.unscoped.count).to eq 2

        #
        # Update columns
        #
        visit article_pages_path(site: site, cid: node)
        click_on name
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames

        click_on I18n.t('ss.links.edit')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        within 'form#item-form' do
          within ".column-value-cms-column-textfield" do
            fill_in "item[column_values][][in_wrap][value]", with: column1_value2
          end
          within ".column-value-cms-column-datefield" do
            fill_in "item[column_values][][in_wrap][date]", with: column2_value2
          end
          within ".column-value-cms-column-urlfield2" do
            fill_in "item[column_values][][in_wrap][link_label]", with: column3_label2
            fill_in "item[column_values][][in_wrap][link_url]", with: column3_url2
          end
          within ".column-value-cms-column-textarea" do
            fill_in "item[column_values][][in_wrap][value]", with: column4_value2
          end
          within ".column-value-cms-column-select" do
            select column5_value2, from: "item[column_values][][in_wrap][value]"
          end
          within ".column-value-cms-column-radiobutton" do
            first(:field, type: "radio", with: column6_value2).click
          end
          within ".column-value-cms-column-checkbox" do
            first(:field, name: "item[column_values][][in_wrap][values][]", with: column7_value1).click
            first(:field, name: "item[column_values][][in_wrap][values][]", with: column7_value2).click
          end
          within ".column-value-cms-column-fileupload" do
            fill_in "item[column_values][][in_wrap][file_label]", with: column8_image_text2
          end
          ss_upload_file "#{Rails.root}/spec/fixtures/ss/logo.png", addon: ".column-value-cms-column-fileupload"
          within ".column-value-cms-column-fileupload" do
            expect(page).to have_content("logo.png")
          end

          within ".column-value-cms-column-free" do
            fill_in_ckeditor "item[column_values][][in_wrap][value]", with: column9_value2
          end
          within ".column-value-cms-column-headline" do
            select column10_head2, from: "item[column_values][][in_wrap][head]"
            fill_in "item[column_values][][in_wrap][text]", with: column10_text2
          end
          within ".column-value-cms-column-list" do
            fill_in "item[column_values][][in_wrap][lists][]", with: column11_list2
          end
          within ".column-value-cms-column-table" do
            find("input.height").set(column12_height2)
            find("input.width").set(column12_width2)
            find("input.caption").set(column12_caption2)
            click_on I18n.t("cms.column_table.create")
          end
          within ".column-value-cms-column-youtube" do
            fill_in "item[column_values][][in_wrap][url]", with: column13_url2
          end
          within ".column-value-cms-column-selectpage " do
            wait_for_cbox_opened { click_on I18n.t("cms.apis.pages.index") }
          end
        end
        within_cbox do
          expect(page).to have_css(".list-item", text: selectable_page1.name)
          expect(page).to have_css(".list-item", text: selectable_page2.name)
          expect(page).to have_css(".list-item", text: selectable_page3.name)
          expect(page).to have_no_css(".list-item", text: selectable_page4.name)
          wait_for_cbox_closed { click_on column14_page2.name }
        end
        within 'form#item-form' do
          expect(page).to have_css(".ajax-selected", text: column14_page2.name)
          click_on I18n.t('ss.buttons.draft_save')
        end
        wait_for_notice I18n.t('ss.notice.saved')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))

        expect(article_pages.count).to eq 1
        article_pages.first.tap do |item|
          expect(item.name).to eq name
          expect(item.column_values).to have(14).items

          expect(item.column_values.find_by(column_id: column1.id).value).to eq column1_value2
          expect(item.column_values.find_by(column_id: column2.id).date).to eq Time.zone.parse(column2_value2)
          expect(item.column_values.find_by(column_id: column3.id).link_label).to eq column3_label2
          expect(item.column_values.find_by(column_id: column3.id).link_url).to eq column3_url2
          expect(item.column_values.find_by(column_id: column4.id).value).to eq column4_value2.gsub("\n", "\r\n")
          expect(item.column_values.find_by(column_id: column5.id).value).to eq column5_value2
          expect(item.column_values.find_by(column_id: column6.id).value).to eq column6_value2
          expect(item.column_values.find_by(column_id: column7.id).values).to eq [ column7_value2 ]
          expect(item.column_values.find_by(column_id: column8.id).file_label).to eq column8_image_text2
          expect(item.column_values.find_by(column_id: column8.id).file.name).to eq 'logo.png'
          expect(item.column_values.find_by(column_id: column8.id).file.owner_item_id).to eq item.id
          expect(item.column_values.find_by(column_id: column9.id).value).to include column9_value2
          expect(item.column_values.find_by(column_id: column10.id).head).to eq column10_head2
          expect(item.column_values.find_by(column_id: column10.id).text).to eq column10_text2
          expect(item.column_values.find_by(column_id: column11.id).lists).to include column11_list2
          expect(item.column_values.find_by(column_id: column12.id).value).to be_present
          expect(item.column_values.find_by(column_id: column13.id).youtube_id).to eq column13_youtube_id2
          expect(item.column_values.find_by(column_id: column14.id).page_id).to eq column14_page2.id

          expect(item.backups.count).to eq 2
        end
        expect(SS::File.all.unscoped.count).to eq 2

        #
        # Remove columns
        #
        visit article_pages_path(site: site, cid: node)
        click_on name
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames

        click_on I18n.t('ss.links.edit')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        within 'form#item-form' do
          %w(
            textfield datefield urlfield2 textarea select radiobutton checkbox fileupload
            free headline list table youtube selectpage
          ).each do |f|
            within ".column-value-cms-column-#{f} .column-value-header" do
              page.accept_alert do
                click_on I18n.t("ss.buttons.delete")
              end
            end
            # wait animation finished
            wait_for_all_ckeditors_ready
            wait_for_all_turbo_frames
            expect(page).to have_no_css(".column-value-cms-column-#{f}")
          end

          click_on I18n.t('ss.buttons.draft_save')
        end
        wait_for_notice I18n.t('ss.notice.saved')
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))

        expect(article_pages.count).to eq 1
        article_pages.first.tap do |item|
          expect(item.name).to eq name
          expect(item.column_values).to have(0).items

          expect(item.backups.count).to eq 3
        end
        expect(SS::File.all.unscoped.count).to eq 0

        #
        # Delete page
        #
        visit article_pages_path(site: site, cid: node)
        click_on name
        wait_for_all_ckeditors_ready
        wait_for_all_turbo_frames
        click_on I18n.t('ss.links.delete')
        within 'form' do
          click_on I18n.t('ss.buttons.delete')
        end
        wait_for_notice I18n.t('ss.notice.deleted')
        expect(article_pages.count).to eq 0
        expect(SS::File.all.unscoped.count).to eq 0
      end
    end

    context 'create page with not allowed user' do
      let!(:permissions) { Cms::Role.permission_names.select { |item| item =~ /_private_/ } }
      let!(:role) { create :cms_role, name: "role", permissions: permissions, cur_site: site }
      let(:user2) { create :cms_user, uid: unique_id, name: unique_id, group_ids: [cms_group.id], cms_role_ids: [role.id] }
      let(:form2) { create :cms_form, cur_site: site, state: 'public', sub_type: 'entry', group_ids: [cms_group.id] }

      it do
        login_user(user2, to: new_article_page_path(site: site, cid: node))

        within '#addon-basic' do
          expect(page).to have_no_css('select[name="in_form_id"]')
        end
      end

      it do
        node.st_form_ids = [ form.id, form2.id ]
        node.save!

        login_user(user2, to: new_article_page_path(site: site, cid: node))

        within '#addon-basic' do
          expect(page).to have_css('select[name="in_form_id"]')
          expect(page).to have_no_css('select option', text: form.name)
          expect(page).to have_css('select option', text: form2.name)
        end
      end

      it do
        visit new_article_page_path(site: site, cid: node)

        within 'form#item-form' do
          fill_in 'item[name]', with: name
          wait_for_event_fired("ss:formActivated") do
            page.accept_confirm(I18n.t("cms.confirm.change_form")) do
              select form.name, from: 'in_form_id'
            end
          end

          expect(page).to have_css("#addon-cms-agents-addons-form-page .addon-head", text: form.name)
          click_on I18n.t('ss.buttons.draft_save')
        end
        wait_for_notice I18n.t('ss.notice.saved')
        expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))

        item = Article::Page.last
        login_user(user2, to: edit_article_page_path(site: site, cid: node, id: item))

        within '#addon-basic' do
          expect(page).to have_css('select[name="in_form_id"][disabled]')
        end

        within 'form#item-form' do
          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column1.name
            end
          end
          within ".column-value-cms-column-textfield" do
            fill_in "item[column_values][][in_wrap][value]", with: column1_value1
          end

          within ".column-value-palette" do
            wait_for_event_fired("ss:columnAdded") do
              click_on column2.name
            end
          end
          within ".column-value-cms-column-datefield" do
            fill_in "item[column_values][][in_wrap][date]", with: column2_value1
          end
          click_on I18n.t('ss.buttons.draft_save')
        end
        wait_for_notice I18n.t('ss.notice.saved')
        # wait for completion of "/.s:site/workflow:cid/wizard/:id"
        expect(page).to have_css("#addon-workflow-agents-addons-approver", text: I18n.t("workflow.request"))
        expect(page).to have_css("#workflow_route", text: I18n.t("mongoid.attributes.workflow/model/route.my_group"))
      end
    end
  end
end
