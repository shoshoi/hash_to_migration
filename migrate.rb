require './hash_to_migration'
hash = { 
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
hash = Migen::Mighash.new(hash, "movie")
Migen::Generator.generate_migration_file(hash)
