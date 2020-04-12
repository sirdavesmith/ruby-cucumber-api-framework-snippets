Given(/^I create property (\w+) for (mobile|web)$/) do |propName, platform|
  propertyName = TestData[propName.to_sym] || propName
  platform == "web" ? domains = "domains: ['acme.com', 'local.host']" : domains = "domains: ['']"
  steps %Q{
    Given I create a #{propName} property with the body:
    """
    {
      "data": {
        "attributes": {
          "domains": ["acme.com", "local.host"],
          "platform": "#{platform}",
          "name": "#{propertyName}"
        },
        "type": "properties"
      }
    }
    """
  }
  puts "HTTP Response body : #{Specr.client.last_body}"
  if Specr.client.last_code == 409
    removeExistingProperty(propName)
    puts "Creating the property #{propertyName} anew"
    step "I create property #{propName} for #{platform}"
  else
    step "Assign id to property_id"
    Local.client.storage["prop_#{propertyName}_id"] = Specr.client['id'] if Specr.client.last_code == 201
  end
end


When(/^I create a (\w+) property with the body:$/) do |propName, body|
  json = JSON.parse(body)
  propertyName = TestData[propName.to_sym] || propName
  json["data"]["attributes"]["name"] = propertyName
  Specr.client.post('/companies/:company_id/properties', json)
end

And(/^I have created property ([^"]*) for (mobile|web)$/) do |_propName, platform|
  company_id = Specr.client.storage['company_id'].nil? ? Local.client.storage['company_id'] : Specr.client.storage['company_id']
  propertyName = TestData[_propName.to_sym] || _propName
  if Local.client.storage["prop_#{propertyName}_id"].nil?
    Specr.client.get("/companies/:company_id/properties?filter[name]=EQ #{propertyName}")
    if Specr.client.last_body['data'].empty?
      step "I create property #{_propName} for web"
      puts "DEBUG: #{propertyName} created" if DEBUG
    else
      step 'Assign id to property_id'
      Local.client.storage["prop_#{propertyName}_id"] = Specr.client['data'][0]['id']
      puts "DEBUG: #{propertyName} (#{Specr.client.storage['property_id']}) Exists" if DEBUG
    end
  else
    puts "The Property already exists. #{propertyName} =  #{Local.client.storage["prop_#{propertyName}_id"]}" if DEBUG
    Specr.client.storage["property_id"] = Local.client.storage["prop_#{propertyName}_id"]
  end
  Specr.client.storage["property_id"] = Local.client.storage["prop_#{propertyName}_id"]
end

And(/^I have created property ([^ "]*)$/) do |_propName|
  step "I have created property #{_propName} for web"
end

When(/^I delete all properties in storage$/) do
  propsToDelete = Local.client.storage.keys.grep /^prop_(.*)_id/
  propsToDelete.each do |prop_id|
    puts "Here is the prop_id = #{prop_id}:#{Local.client.storage["#{prop_id}"]}" if DEBUG
    property_id = Local.client.storage["#{prop_id}"]
    Specr.client.delete("/properties/#{property_id}")
    Local.client.storage.delete("#{prop_id}")
    puts "(#{prop_id} (#{property_id}) was susscessfully deleted"
  end
end

When(/^I delete the property ([^"]*)$/) do |_propName|
  propertyName = TestData[_propName.to_sym] || _propName
  step "I have created property #{_propName} for web"
  property_id = Specr.client.storage['property_id']
  Specr.client.delete('/properties/:property_id')
  puts "(#{propertyName} (#{property_id}) was susscessfully deleted"
  Local.client.storage.delete("prop_#{propertyName}_id")
end

Given(/^I remove ALL Test Properties$/) do
  Specr.client.get('/companies/:company_id/properties?page[size]=99&page[number]=1')
  response_is_valid?
  Specr.client.last_body['data'].each do |prop|
    remove_property prop if prop['attributes']['name'] =~ /#{Regexp.quote("#{ENV['USERNAME']} - Auto:")}/
    remove_property prop if prop['attributes']['name'] =~ /#{Regexp.quote("Extension Test Property -")}/
    remove_property prop if prop['attributes']['name'] =~ /#{Regexp.quote("Auto - ")}/
  end
end

Given(/^I remove Test Properties over (\d*) hours old$/) do |hours|
  counter = 0
  numDeleted = 1
  minusHours = (Time.now - (hours.to_i*3600)).utc
  url = "/companies/:company_id/properties?filter[created_at]=LT #{minusHours}&page[size]=50"
  puts "URL String:  /companies/#{url}"
  Specr.client.get(url)
  loop do
    propertyList = Specr.client.last_body
    counter += 1
    response_is_valid?
    puts "\nRemoving properties for company: #{Specr.client.storage['company_name']}"
    propertyList['data'].each do |prop|
      remove_property prop, numDeleted if prop['attributes']['name'] =~ /#{Regexp.quote("#{ENV['USERNAME']} - Auto:")}/
      remove_property prop, numDeleted if prop['attributes']['name'] =~ /#{Regexp.quote("Extension Test Property -")}/
      remove_property prop, numDeleted if prop['attributes']['name'] =~ /#{Regexp.quote("Auto - ")}/
      remove_property prop, numDeleted if prop['attributes']['name'] =~ /#{Regexp.quote("LoadProperty")}/
      remove_property prop, numDeleted if prop['attributes']['name'] =~ /#{Regexp.new("New Relic Synthetic Check [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")}/
      numDeleted += 1
    end
    puts "Total Pages of (50) Remaining: #{propertyList['meta']['pagination']['total_pages']}"
    break if propertyList['meta']['pagination']['total_pages'] <= 1 || counter == 20
    Specr.client.get(url)
  end
end

Given(/^I GET all Properties for my company$/) do
  Specr.client.get('/companies/:company_id/properties?page[size]=99&page[number]=1')
  response_is_valid?
  step "Assign id to property_id"
end

Given(/^I update the property ([^"]*)$/) do |_propName|
  propertyName = TestData[_propName.to_sym] || _propName
  step "I have created property #{_propName} for web"
  Specr.client.patch('/properties/:property_id',
    data: {
      attributes: {
        domains: ['acme.com'],
        name: "#{propertyName}-Updated"
      },
      type: 'properties',
      id: ":property_id"
    })
    response_is_valid?
end

def remove_property(prop, num)
  puts ".. Deleting #{num}: #{prop['attributes']['name']} - '#{prop['id']}' - Created at: '#{prop['attributes']['created_at']}'"
  Specr.client.delete("/properties/#{prop['id']}")
  if Specr.client.last_code != 204
    puts "#{Specr.client.last_body}"
  end
end

def removeExistingProperty(propName)
  puts "\nThe Property already exists !\n"
  step "I delete the property #{propName}"
end
