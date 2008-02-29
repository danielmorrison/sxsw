require 'rubygems'
require 'activesupport'
require 'hpricot'
require 'open-uri'

BASE_URL = 'http://2008.sxsw.com/music/showcases/alpha/0.html'

@bands = {}

listing = Hpricot(open(BASE_URL))
@uris = (listing/"a[@href]").map{|s| s.attributes['href']}.select{|s| s =~ /showcases\/alpha/}
puts "Fetched #{@uris.size} listing pages."

@uris.each do |uri|
  band_page = Hpricot(open(uri))
  (band_page/"table tr").each do |row|
    if row.at("td img[@src='/img/mp3_icon.gif']")
      band = row.at("td .artist_name a")
      @bands[band.inner_html] = band.attributes['href']
    end
  end
end

@bands.each do |band_name, uri|
  path = File.join(File.dirname(__FILE__), 'downloads', band_name)
  unless File.exist?(path)
    FileUtils.mkdir_p(path)
    page = Hpricot(open(uri))
    track = page.at("a.mp3_download")['href']
    puts "Found a track by #{band_name}."
    File.open(File.join(path, track.split('/').last),"w"){|f| f.write(open(track).read)}
  else
    puts "Already have a track by #{band_name}."
  end
end

