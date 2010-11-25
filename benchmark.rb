require 'rubygems'
require 'hpricot'
require 'nokogiri'
require 'benchmark'

def hpricot
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
  contacts
end

def nokogiri_css
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
  contacts
end

def nokogiri_xpath
  doc = Nokogiri::HTML(File.open('people.html'))
  
  contacts = []
  
  doc.xpath('//div[@class="contact vcard"]/div[@class="body"]').each do |vcard|
  
    vc = {}
    
    vc['Name'] = vcard.at_xpath('h3').text
    
    if email_link = vcard.at_xpath('a[@class="email"]')
      vc['Email'] = email_link.text
    end
    
    vcard.xpath('span[@class="label tel"]').each do |span|
      
      abbr = span.at_xpath('abbr')
      name = (abbr['title'] == 'msg' ? abbr.text : abbr['title'])
      
      value = span.at_xpath('span[@class="value"]').text
      
      if %w( Home Mobile Office Fax ).include?(name)
        value = value.gsub(/[^\d\+]/, '').gsub(/^8/, '+7').gsub(/^2/, '+78432')
      end
      
      vc[name] = value
    end
    contacts << vc
  end
  contacts
end


f = File.open('people.html')
Benchmark.bm(10) do |x|
  x.report("nokogiri (xpath)  :") { nokogiri_xpath }
  x.report("nokogiri (css)    :") { nokogiri_css }
  x.report("hpicot            :") { hpricot }
end
