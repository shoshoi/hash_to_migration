RSpec.describe Migen do
  it "has a version number" do
    expect(Migen::VERSION).not_to be nil
  end
  describe '#initialize' do
    context '引数なしの場合' do
      before do
        @hash = Migen::Mighash.new
      end
      it "名前が'parent'であること" do
        expect(@hash.name).to eq("parent")
      end
      it "ハッシュが空であること" do
        expect(@hash).to eq({})
      end
    end
    context '引数ありの場合' do
      before do
        @hash = Migen::Mighash.new({title: "タイトル"}, "movie")
      end 
      it "名前が設定されること" do
        expect(@hash.name).to eq("movie")
      end 
      it "ハッシュが設定されること" do
        expect(@hash).to eq({title: "タイトル"})
      end 
    end
  end

  describe '#get_models' do
    context 'ハッシュが設定されていない場合' do
      before do
        @hash = Migen::Mighash.new
      end 
      it "空の配列が返ること" do
        expect(@hash.get_models).to eq([])
      end 
    end 
    context 'ハッシュが設定されている場合' do
      before do
        @hash = Migen::Mighash.new({title: "タイトル"}, "movie")
      end 
      it "名前が設定されること" do
        expect(@hash.get_models.count).to eq(1)
      end 
    end
    context '子がハッシュの場合' do
      before do
        @hash = Migen::Mighash.new({title: "タイトル", author: { name: "作成者" }}, "movie")
      end 
      it "名前が設定されること" do
        expect(@hash.get_models.count).to eq(2)
        expect(@hash.get_models.count).to eq(2)
      end 
    end
    context '子が配列の場合' do
      before do
        @hash = Migen::Mighash.new({title: "タイトル", tags: ["tag1", "tag2"]}, "movie")
      end 
      it "名前が設定されること" do
        expect(@hash.get_models.count).to eq(1)
      end 
    end
    context '子が配列で、配列の中身がハッシュの場合' do
      before do
        @hash = Migen::Mighash.new({title: "タイトル", comments: [{comment: "コメント", name: "名前"}]}, "movie")
      end 
      it "名前が設定されること" do
        expect(@hash.get_models.count).to eq(2)
      end 
    end 
  end

  describe '#mig' do
    context 'ハッシュが設定されていない場合' do
      before do
        @hash = Migen::Mighash.new
      end
      it "空の配列となること" do
        expect(@hash.get_models.mig).to eq([])
      end
    end
    context 'ハッシュが設定されている場合' do
      before do
        @hash = Migen::Mighash.new({title: "タイトル"}, "movie")
      end
      it "migrationファイルのテキストが表示されること" do
        expect(@hash.get_models.mig.count).to eq(1)
        expect(@hash.get_models.mig.first).to eq(%Q(class Movies < ActiveRecord::Migration[5.0]\n  def change\n    create_table :movies do |t|\n      t.string :title \n\n      t.timestamps\n    end\n  end\nend\n))
      end
    end 
  end

  describe '#inspect' do
    context 'ハッシュが設定されている場合' do
      before do
        @hash = Migen::Mighash.new({title: "タイトル"}, "movie")
      end
      it "名前とhashの中身が表示されること" do
        expect(@hash.inspect).to eq("name: movie, hash: {:title=>\"タイトル\"}")
      end
    end
  end
end
