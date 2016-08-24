class CreateAll < ActiveRecord::Migration
  def change
  	create_table :posts do |t|
  		t.text :content
  		t.text :author
  		t.timestamps
  	end

  	create_table :comment do |t|
  		t.belongs_to :post, index: true
  		t.text :commtext
  		t.text :cauthor
  		t.timestamps
  	end
  end
end
