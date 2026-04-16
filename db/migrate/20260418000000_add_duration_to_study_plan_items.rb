class AddDurationToStudyPlanItems < ActiveRecord::Migration[8.0]
  def change
    add_column :study_plan_items, :duration, :integer
  end
end
