module Settings
  def self.attributes
    [
      {rb_attr: String, db_attr: "string"},
      {rb_attr: Integer, db_attr: "integer"},
      {rb_attr: Float, db_attr: "float"},
      {rb_attr: BigDecimal, db_attr: "decimal"},
      {rb_attr: Date, db_attr: "date"},
      {rb_attr: DateTime, db_attr: "datetime"},
      {rb_attr: TrueClass, db_attr: "boolean"},
      {rb_attr: FalseClass, db_attr: "boolean"},
      {rb_attr: Array, db_attr: "binary"}
    ]
  end
end
#string : 文字列
#text : 長い文字列
#integer : 整数
#float : 浮動小数
#decimal : 精度の高い小数
#datetime : 日時
#timestamp : タイムスタンプ
#time : 時間
#date : 日付
#binary : バイナリデータ
#boolean : Boolean
