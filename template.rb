class ${class_name} < ActiveRecord::Migration[5.0]
  def change
    create_table :${table_name} do |t|
${columns}

      t.timestamps
    end
  end
end
