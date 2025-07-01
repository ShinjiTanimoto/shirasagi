module Guide2
  class Initializer
    Cms::Node.plugin "guide2/guide"

    Cms::Role.permission :read_guide2_questions
    Cms::Role.permission :edit_guide2_questions
    Cms::Role.permission :delete_guide2_questions
    Cms::Role.permission :read_guide2_procedures
    Cms::Role.permission :edit_guide2_procedures
    Cms::Role.permission :delete_guide2_procedures
  end
end
