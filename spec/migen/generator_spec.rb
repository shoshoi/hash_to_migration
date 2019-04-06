RSpec.describe Migen::Generator do
  describe '#generate_migration_file' do
    before do
     FileUtils.rm_rf("migrate")
     Dir.mkdir('migrate', 0755)
    end
    context 'モデルが２つある場合' do
      before do
        @hash = Migen::Mighash.new({title: "タイトル", comments: [{comment: "コメント", name: "名前"}]}, "movie")
      end 
      it "ファイルが２つ出力されること" do
        Migen::Generator.generate_migration_file(@hash)
        count = Pathname.glob("./migrate/*").count
        expect(count).to eq(2)
      end 
    end
    context '引数がModel' do
      before do
        @model = Migen::Mighash.new({title: "タイトル", comments: [{comment: "コメント", name: "名前"}]}, "movie").get_models.first
      end 
      it "ファイルが１つ出力されること" do
        Migen::Generator.generate_migration_file(@model)
        count = Pathname.glob("./migrate/*").count
        expect(count).to eq(1)
      end
    end
    context '引数がHash' do
      before do
        @hash = {title: "タイトル", comments: [{comment: "コメント", name: "名前"}]}
      end 
      it "ファイルが２つ出力されること" do
        Migen::Generator.generate_migration_file(@hash)
        count = Pathname.glob("./migrate/*").count
        expect(count).to eq(2)
      end 
    end
    context 'マイグレーションファイルのテーブル名が重複したとき' do
      before do
        @hash = {title: "タイトル", comments: [{comment: "コメント", name: "名前"}]}
      end 
      it "エラーが出力されること" do
        Migen::Generator.generate_migration_file(@hash)
        Migen::Generator.generate_migration_file(@hash)
        count = Pathname.glob("./migrate/*").count
        expect(count).to eq(2)
      end 
    end
    context 'タイムスタンプが１０回重複したとき' do
      before do
        @hash = {title: "タイトル", comments: [{comment: "コメント", name: "名前"}]}
      end 
      it "例外が発生すること" do
        allow(Migen::Validator).to receive(:timestamp_duplicate?).with(anything).and_return(true)
        expect{ Migen::Generator.generate_migration_file(@hash) }.to raise_error(Exception)
      end 
    end
  end
end
