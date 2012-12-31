class CreateUserMessageContents < ActiveRecord::Migration
  def change
    create_table :user_message_contents do |t|
      t.integer :user_id
      t.string :from_name
      t.string :subject
      t.text :content

      t.timestamps
    end
  end
end
