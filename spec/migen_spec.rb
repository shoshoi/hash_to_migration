test_data = { 
    title: "タイトル",
    view: 10000,
    liked: true,
    display: false,
    date: "2019-10-16",
    comments: [
      { name: "匿名", comment: "いいね"},
      { name: "匿名2", comment: "いいね2"},
    ],  
    user: {
      user_name: "namae",
      age: 23
    }   
  }
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
  end

  describe '#mig' do
    context 'ハッシュが設定されていない場合' do
      before do
        @hash = Migen::Mighash.new
      end
      it "空の配列となること" do
        expect(@hash.mig).to eq([])
      end
    end
    context 'ハッシュが設定されている場合' do
      before do
        @hash = Migen::Mighash.new({title: "タイトル"}, "movie")
      end
      it "migrationファイルのテキストが表示されること" do
        expect(@hash.mig.count).to eq(1)
        expect(@hash.mig.first).to eq(%Q(class Movies < ActiveRecord::Migration[5.0]\n  def change\n    create_table :movies do |t|\n      t.string :title \n\n      t.timestamps\n    end\n  end\nend\n))
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
