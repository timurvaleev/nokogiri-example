require 'rubygems'
require 'hpricot'
require 'fastercsv'


doc = Hpricot(File.open('people.html'))

contacts = []

doc.search("//div[@class='contact vcard']/div[@class='body']").each do |vcard|

  vc = {}
  
  vc['Name'] = vcard.at('h3').inner_text
  
  if email_link = vcard.at("a[@class='email']")
    vc['Email'] = email_link.inner_text
  end
  
  vcard.search("span[@class='label tel']").each do |span|

    abbr = span.at('abbr')
    name = ( abbr.attributes['title'] == 'msg' ? abbr.inner_text : abbr.attributes['title'] )
    
    value = span.at("span[@class='value']").inner_text
    
    if %w( Home Mobile Office Fax ).include?(name)
      value = value.gsub(/[^\d\+]/, '').gsub(/^8/, '+7').gsub(/^2/, '+78432')
    end
    
    vc[name] = value
  end
  
  contacts << vc
end

FasterCSV.open("contacts-hpricot.csv", "w") do |csv|
  keys = %w( Name Mobile Home Office Fax Email )
  
  contacts.each {|c| keys |= c.keys }

  csv << keys
  
  contacts.each do |contact|
    csv << keys.map{|key| contact[key]}
  end
end