class CL_Scraper
  USER_AGENT = ["Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36",
                "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1"]
  PER_PAGE = 120 #CL is broken into 120 items per page.  #USER_AGENT pool to pretend we are different browsers on a subnet.

  attr_accessor :menu_hash, :submenu_hash, :all

  def initialize(url)
    @all = []
    @url = url if url
    @menu_hash = {}
    @submenu_hash = {}
  end

  def scrape_for_sale_categories
    sss = noko_page.search("#center #sss a")
    sss.each{|category| @menu_hash[category.children.text] = @url + category.attribute("href").text}
    @menu_hash
  end

  def scrape_second_level_menus(main_category)
    @submenu_hash.clear
    sub_page = noko_page(main_category)
    sub_lists = sub_page.search(".ul")
    sub_headers = sub_page.search("h3")
    sub_headers.each do |header|
      @submenu_hash[header.text.downcase] = {}
      sub_lists.each do |item|
        info = item.search("a")
        @submenu_hash[header.text.downcase][info[0].text] = info.attribute("href").text
      end
    end
    @submenu_hash
  end

  def scrape_category(category)
    listings = noko_page(category)
    num_listings = listings.search(".totalcount").first.text.to_i
    page_count = 1
    while page_count <= (num_listings/PER_PAGE).floor + 1
      page_url = category + "?s=" + "#{page_count*PER_PAGE}"
      scrape_page(page_url)
      sleep rand(5..8)           #Sleep to help avoid CL API from banning IP!
      page_count += 1
    end
  end

  def scrape_page(page_url)
    puts "Scraping #{page_url}"
    listings = noko_page(page_url)
    item_list = listings.search(".rows .result-row")
    item_list.each do |item|
      item_info = {}
      item_info[:pid] = item.attribute("data-pid").text
      item_info[:link] = item.search("a")[1].attribute("href").text
      item_info[:price] = item.search(".result-price").first.text.gsub(/\$/, "").to_i if item.search(".result-price").first != nil
      item_info[:title] = item.search(".result-title").text.downcase
      item_info[:location] = item.search(".result-info .result-meta .result-hood").text if item.search(".result-info .result-meta .result-hood").text != ""
      @all << item_info
    end
  end

  def scrape_by_pid(pid_link)
    puts "Scraping #{pid_link}"
    listing = noko_page(pid_link)
    listing.search(".rows .result-row")
    item_info = {}
    item_info[:postingbody] = listing.search("#postingbody").text
    attrgroup = listing.search(".attrgroup span")
    attrgroup.each do |attribute|
      if attribute.children[1] == nil
        item_info[:year] = attribute.children[0].text  #special case, has no associated attrgroup identifier
      else
        if attribute.children[1].text == "\nmore ads  by this user        "
          item_info[:other_ads] = attrgroup.search("a").attribute("href").text
        elsif  attribute.children[0].text == "\n                        "
          item_info[:venue_date] = attribute.children[1].text
        else
          item_info[info_to_sym(attribute)] = attribute.children[1].text
        end
      end
    end
    item_info[:timeago] = listing.search(".timeago").first.text
    item_info
  end

  def info_to_sym(attribute)
    base = attribute.children[0].text.split(" ")[0]
    base.include?(":") ? base.gsub(/:/, "").to_sym : base.to_sym
  end

  def noko_page(page=@url)
    Nokogiri::HTML(open(page, 'User-Agent' => USER_AGENT[rand(0..USER_AGENT.length-1)]))
  end

end
