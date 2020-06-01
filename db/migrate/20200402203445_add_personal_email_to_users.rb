class AddPersonalEmailToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :personal_email, :string
  end
end
