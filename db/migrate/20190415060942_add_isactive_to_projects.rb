class AddIsactiveToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :isactive, :boolean, default: true
  end
end
