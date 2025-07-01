class Guide2::Node
  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^guide2\//) }
  end

  class Guide
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include ::Guide2::Addon::ProcedureSetting
    include ::Guide2::Addon::GuideList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup
    include Cms::Lgwan::Node

    default_scope ->{ where(route: "guide2/guide") }
  end
end
