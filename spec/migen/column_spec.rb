RSpec.describe Migen::Column do
  describe '#set_options' do
    context 'オプションを設定した場合' do
      before do
        @column = Migen::Column.new("name", String)
        @column.set_options({null: true})
      end 
      it "オプションが反映されていること" do
        expect(@column.mig).to eq("t.string :name , null: true")
      end 
    end
  end
end 
