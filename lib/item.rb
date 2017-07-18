class Item
  attr_accessor :link, :pid, :title, :price, :condition, :location
  @@all = []

  def initialize(item_hash)
    item_hash.each{|key,value| self.send("#{key}=", value)}
    @@all << self
  end

  def self.create_from_collection(site_hash)
    # CL_Scraper.all.each{|hash| Item.new(hash)}
    site_hash.each{|hash| Item.new(hash)}
  end

  def self.all
    @@all
  end

end
