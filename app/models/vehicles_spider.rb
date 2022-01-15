class VehiclesSpider < Kimurai::Base
  @name = 'vehicles_spider'
  @engine = :mechanize

  def self.process(url)
    @start_urls = [url]
    self.crawl!
  end

  def parse(response, url:, data:{})
    response.xpath("//div[@class='vehicle-card   vehicle-card-with-reviews']").each do |vehicle|
      item = {}
      puts item
      item[:title]      = vehicle.xpath(".//h2[@class='title']")&.text
      item[:price]      = vehicle.xpath(".//span[@class='primary-price']")&.text.delete('^0-9').to_i
      item[:stock_type] = vehicle.xpath(".//p[@class='stock-type']")&.text&.squish
      item[:miles]      = vehicle.xpath(".//div[@class='mileage']")&.text.delete('^0-9').to_i
      vehicle_features = vehicle.xpath(".//div[@class='vehicle-features']").xpath(".//div[@class='vehicle-feature']")
      if vehicle_features.length() == 4       
        item[:exterior_color] = vehicle_features[0]&.text&.squish.gsub('Ext. color: ', '')
        item[:transmission] = vehicle_features[1]&.text&.squish.gsub('Transmission: ', '')
        item[:interior_color] = vehicle_features[2]&.text&.squish.gsub('Int. color: ', '')
        item[:drivetrain] = vehicle_features[3]&.text&.squish.gsub('Drivetrain: ', '')
      else
        item[:exterior_color] = vehicle_features[0]&.text&.squish.gsub('Ext. color: ', '')
        item[:transmission] = vehicle_features[1]&.text&.squish.gsub('Transmission: ', '')
        item[:interior_color] = "N/A"
        item[:drivetrain] = vehicle_features[2]&.text&.squish.gsub('Drivetrain: ', '')
      end
      puts JSON.pretty_generate(item)
      Vehicle.where(item).first_or_create
    end
  end
end