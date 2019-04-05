class ${class_name} < ActiveRecord::Migration[5.0]
  def change
    create_table :${table_name} do |t|
${attributes}

      t.timestamps
    end
  end
end
