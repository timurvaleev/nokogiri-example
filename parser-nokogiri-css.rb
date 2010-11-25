require 'rubygems'
require 'nokogiri'
require 'fastercsv'

doc = Nokogiri::HTML(File.open('people.html'))

contacts = []

doc.css('div.contact, div.vcard').each do |vcard|

  vc = {}
  
  vc['Name'] = vcard.at_css('h3').text
  
  if email_link = vcard.at_css('a.email')
    vc['Email'] = email_link.text
  end
  
  vcard.css('span.label, span.tel').each do |span|

    abbr = span.at_css('abbr')
    name = (abbr['title'] == 'msg' ? abbr.text : abbr['title'])
    
    value = span.at_css('span.value').text
    
    if %w( Home Mobile Office Fax ).include?(name)
      value = value.gsub(/[^\d\+]/, '').gsub(/^8/, '+7').gsub(/^2/, '+78432')
    end
    
    vc[name] = value
  end
  contacts << vc
end

FasterCSV.open("contacts-nokogiri-css.csv", "w") do |csv|
  keys = %w( Name Mobile Home Office Fax Email )
  
  contacts.each {|c| keys |= c.keys }

  csv << keys
  
  contacts.each do |contact|
    csv << keys.map{|key| contact[key]}
  end
end
