class Item
  attr_accessor :link, :pid, :title, :price, :condition, :location, :postingbody, :make, :model, :size, :timeago,
                :other_ads, :VIN, :fuel, :paint, :title, :transmission, :drive, :year, :number, :cylinders, :odometer, :venue,
                :type
  @@all = []

  def initialize(item_hash)
    item_hash.each{|key,value| self.send("#{key}=", value)}
    @@all << self
  end

  def self.merge_item(pid, item_details)
    item = Item.all.select{|item| item.pid == pid.to_s}
    item_details[0].each_pair{|key,value| item[0].send("#{key}=", value)}
    binding.pry
  end

  def self.create_from_collection(site_hash)
    site_hash.each{|hash| Item.new(hash)}
  end

  def self.all
    @@all
  end

end
