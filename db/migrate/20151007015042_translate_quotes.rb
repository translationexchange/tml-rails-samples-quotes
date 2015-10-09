class TranslateQuotes < ActiveRecord::Migration

  def self.up
    Quote.create_translation_table!
  end

  def self.down
    Quote.drop_translation_table!
  end

end
