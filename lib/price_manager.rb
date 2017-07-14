require 'pry'
require_relative './concerns/concerns.rb'

class PriceManager
  attr_accessor :category, :item, :menu_hash
  attr_reader :url
  include Concerns::Searchable
  MENU = ["Available Actions:",
          "------------------------------------",
          "category -> View and Select Category",
          "item     -> Enter Search Item",
          "price    -> View Price Information",
          "q        -> Quit",
          "------------------------------------",
          "  Please type in your selection",
          "------------------------------------"]

  def initialize(url)
    @url = url
  end

  def call
    puts "OK, we are working with #{url}"
    @site = CL_Scraper.new(@url)
    sleep 2
    run = true
    while run
      case actions_menu
      when "category"
        @category = category_menu #TODO handle nil response
        @site.scrape_page(get_link_from_key)
        Item.create_from_collection
      when "item"
        puts "Please Enter your sale item:"
        @item = gets.chomp.downcase
        Item.search_by_type("table")
      when "price"
        Item.sort_by_price
        Item.basic_stats
      when "q"
        run = false
      end
    end

  end

  def actions_menu
    MENU.each{|message| puts "#{message}"}
    gets.chomp
  end

  def category_menu
    puts "                                     "
    puts "-------------------------------------"
    puts "Available 'for sale' categories are:"
    puts "-------------------------------------"
    CL_Scraper.menu_hash.each_key{|key| puts key}
    puts "Enter the category you want to browse"
    puts "-------------------------------------"
    gets.strip.downcase
  end

end
