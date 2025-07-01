module Guide2::Addon
  module ProcedureSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      embeds_ids :procedures, class_name: "Guide2::Procedure"
      permit_params procedure_ids: []
    end
  end
end
