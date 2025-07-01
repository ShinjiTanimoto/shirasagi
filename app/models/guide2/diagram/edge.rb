class Guide2::Diagram::Edge
  include SS::Document

  attr_accessor :parent

  field :value, type: String
  field :transition, type: String
  field :question_type, type: String
  field :explanation, type: String

  validates :value, presence: true
  validates :transition, presence: true
  validates :question_type, presence: true

  def points
    or_cond = [
      { cond_yes_edge_values: { "$elemMatch" => { question_id: self.parent.id.to_s, edge_value: self.value } } },
      { cond_no_edge_values: { "$elemMatch" => { question_id: self.parent.id.to_s, edge_value: self.value } } },
      { cond_or_edge_values: { "$elemMatch" => { question_id: self.parent.id.to_s, edge_value: self.value } } }
    ]
    Guide2::Diagram::Point.where("$and" => [{ "$or" => or_cond }])
  end

  def applicable_points
    or_cond = [
      { cond_yes_edge_values: { "$elemMatch" => { question_id: self.parent.id.to_s, edge_value: self.value } } },
      { cond_or_edge_values: { "$elemMatch" => { question_id: self.parent.id.to_s, edge_value: self.value } } }
    ]
    Guide2::Diagram::Point.where("$and" => [{ "$or" => or_cond }])
  end

  def not_applicable_points
    or_cond = [
      { cond_no_edge_values: { "$elemMatch" => { question_id: self.parent.id.to_s, edge_value: self.value } } },
    ]
    Guide2::Diagram::Point.where("$and" => [{ "$or" => or_cond }])
  end
  alias not_necessary_points not_applicable_points

  def necessary_points
    or_cond = [
      { cond_yes_edge_values: { "$elemMatch" => { question_id: self.parent.id.to_s, edge_value: self.value } } }
    ]
    Guide2::Diagram::Point.where("$and" => [{ "$or" => or_cond }])
  end

  def optional_necessary_points
    or_cond = [
      { cond_or_edge_values: { "$elemMatch" => { question_id: self.parent.id.to_s, edge_value: self.value } } }
    ]
    Guide2::Diagram::Point.where("$and" => [{ "$or" => or_cond }])
  end

  def export_label
    "[#{I18n.t("guide2.transition")}] #{value}"
  end

  def procedures
    points.where(_type: "Guide2::Procedure")
  end

  def questions
    points.where(_type: "Guide2::Question")
  end

  private

  def validate_points
    points.each do |point|
      next if !point.question?
      errors.add :base, I18n.t("guide2.errors.already_registered", name: point.name)
      break
    end
  end
end
