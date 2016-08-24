class CreatePosts < ActiveRecord::Migration
  def change
  	create_table :posts do |t|
  		t.text :content
  		t.text :author
  		t.timestamps
  	end
  end
end
