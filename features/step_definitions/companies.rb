require 'securerandom'

Given(/^I create the default company$/) do
  Specr.client.get("/companies?filter[name]=CONTAINS #{TestData[:name]}")
  if (Specr.client.last_body['data'].empty?)
    Specr.client.post('/companies',
      {
        data: {
          attributes: {
            name: TestData[:name],
            org_id: "#{SecureRandom.hex}@Acme"
          },
          type: "companies"
        }
      }
    )
    steps %Q{
      Then I should get a 201 Created status code
      Then the response is valid according to the "company" schema
    }
  end
  step "Assign id to company_id"
  step "Assign attributes org_id to company_org_id"

end

Given(/^I create a company named "(\w.*)"$$/) do |name|
  Specr.client.post('/companies',
    {
      data: {
        attributes: {
          name: name.to_s,
          org_id: "#{SecureRandom.hex}@Acme"
        },
        type: "companies"
      }
    }
  )
  if (Specr.client.last_body['data'])
    step "Assign id to company_id"
    step "Assign attributes org_id to company_org_id"
  end
end

Given(/^I have a unique org id generated$/) do
  Specr.client.storage['generated_org_id'] = "#{SecureRandom.hex}@Acme"
end

Given(/^Default Company Exists$/) do
  if Local.client.storage['company_id'].nil?
    Specr.client.get("/companies?filter[name]=CONTAINS #{TestData[:name]}")
    step "Assign id to company_id"
    step "Assign attributes org_id to company_org_id"
    Local.client.storage['company_id'] = Specr.client.storage['company_id']
    Local.client.storage['company_org_id'] = Specr.client.storage['company_org_id']
    puts "DEBUG: Local.client.storage company_id and company_org_id = #{Local.client.storage['company_id']} and #{Local.client.storage['company_org_id']}" if DEBUG
  else
    Specr.client.storage['company_id'] = Local.client.storage['company_id']
    Specr.client.storage['company_org_id'] = Local.client.storage['company_org_id']
    puts "DEBUG: Specr.client.storage company_id and company_org_id = #{Specr.client.storage['company_id']} and #{Specr.client.storage['company_org_id']}" if DEBUG
  end
end

Given(/^I update the company name to "(\w.*)"$/) do |newName|
  @new_name = newName.to_s
  step "Default Company Exists"
  puts "Attempting to update the company name to #{newName.to_s}"
  Specr.client.patch('/companies/:company_id',
    {
      data: {
        attributes: {
          name: @new_name
        },
      type: "companies",
      id: ":company_id"
      }
    }
  )
end

Given(/^I GET all the companies$/) do
  counter = 0
  Specr.client.get('/companies?page[size]=99&page[number]=1')
  response_is_valid?
  data = Specr.client['data']
  res = data.each { |ep|
    puts "Name: #{ep['attributes']['name']}"
    puts "ORG ID: #{ep['attributes']['org_id']}"
    puts ""
    counter += 1
  }
end

Given(/^I get the id for company "(\w.*)"$/) do |name|
  paddedName = name.gsub! " ", "%20"
  Specr.client.get("/companies?filter[name]=EQ#{paddedName}")
  puts "/companies?filter[name]=EQ#{paddedName}"
  puts Specr.client.last_body
  if (Specr.client.last_body['data'])
    step "Assign id to company_id"
    step "Assign attributes org_id to company_org_id"
    step "Assign attributes name to company_name"
  end
end
