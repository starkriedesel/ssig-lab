class CreateUserMessages < ActiveRecord::Migration
  def change
    create_table :user_messages do |t|
      t.integer :user_message_content_id
      t.integer :user_id
      t.boolean :read

      t.timestamps
    end
  end
end
