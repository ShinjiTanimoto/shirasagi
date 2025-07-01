puts "# guide2"

@item = Guide2::Importer.new(cur_user: @user, cur_site: @site, cur_node: @guide2_node)
@item.in_file = Fs::UploadedFile.create_from_file("#{Rails.root}/spec/fixtures/guide/templates/procedures.csv")
@item.import_procedures

@item.in_file = Fs::UploadedFile.create_from_file("#{Rails.root}/spec/fixtures/guide/templates/questions.csv")
@item.import_questions

@item.in_file = Fs::UploadedFile.create_from_file("#{Rails.root}/spec/fixtures/guide/templates/transitions.csv")
@item.import_transitions
