Then(/^I debug$/) do
  puts "HTTP Headers : #{Specr.client.headers}"
  puts "HTTP status code: #{Specr.client.last_code}"
  begin
    puts "HTTP body: #{Specr.client.last_body}"
  rescue => e
    puts "Exception caught in #{e.class}: #{e.message}"
  end
  puts "Storage: #{Specr.client.storage}"
end

Then(/^the (\S*) is set$/) do |component_id|
  assert_not_nil Specr.client.storage["#{component_id}"]
  puts "#{component_id} is #{Specr.client.storage["#{component_id}"]}"
end

And(/^Assign (\w+) to (\w+)$/) do |id, element|
  response_is_valid?
  if Specr.client.last_code <= 204
    if Specr.client['data'].kind_of?(Array)
      Specr.client.storage[element] = Specr.client['data'][0][id]
    else
      Specr.client.storage[element] = Specr.client[id]
    end
    puts "DEBUG: Assigned #{element} = #{Specr.client.storage[element].to_s}" if DEBUG
  end

end

And(/^Assign attributes (\w+) to (\w+)$/) do |attr, element|
  response_is_valid?
  if Specr.client['data'].kind_of?(Array)
    Specr.client.storage[element] = Specr.client['data'][0]['attributes'][attr]
  else
    Specr.client.storage[element] = Specr.client['data']['attributes'][attr]
  end
  puts "DEBUG: Assigned #{element} = #{Specr.client.storage[element].to_s}" if DEBUG
end

Then(/^I should get a (.+) or (.+) status code$/) do |code1, code2|
  message = Specr.client.last_body.fetch('errors', '') if Specr.client.last_body
  assert (Specr.client.last_code == code1.to_i || Specr.client.last_code == code2.to_i), message
end

And(/^I wait for the request to (fail|succeed)$/) do |status|
  # Assume this gets called after a POST or PATCH has been called,
  # Get the link from the last response
  link = Specr.client['links']['self']
  puts "DEBUG: Here is the link we are getting status from: #{link}" if DEBUG
  step "I await processing for #{link} with the condition \"data.attributes.status\" \"==\" \"#{status}ed\" LOCAL"
end

def response_is_valid?
  begin
    if Specr.client.last_code >= 404 then
      puts "HTTP status code : #{Specr.client.last_code}"
      puts "HTTP Headers : #{Specr.client.headers}"
      puts "HTTP Response body : #{Specr.client.last_body}"
      raise StandardError, "The response returned an error"
    end
    if Specr.client.last_body['errors'] || Specr.client.last_body['error_code'] then
      puts "HTTP status code : #{Specr.client.last_code}" if DEBUG
      puts "HTTP Headers : #{Specr.client.headers}" if DEBUG
      puts "HTTP Response body : #{Specr.client.last_body}" if DEBUG
    end
  rescue StandardError => e
    raise e
  end
end

Given(/^I add a host and all environments to property (\S*)$/) do |property|
  steps %{
    Given I have created property #{property} for web
    Given I have created host Cdnhost
    Given I have created a production environment named production on property #{property}
    Given I have created a staging environment named staging on property #{property}
    Given I have created a development environment named development on property #{property}
  }
end

# Can use this for Coloring output if desired.
# puts "string".red.bold
class String
def black;          "\e[30m#{self}\e[0m" end
def red;            "\e[31m#{self}\e[0m" end
def green;          "\e[32m#{self}\e[0m" end
def brown;          "\e[33m#{self}\e[0m" end
def blue;           "\e[34m#{self}\e[0m" end
def magenta;        "\e[35m#{self}\e[0m" end
def cyan;           "\e[36m#{self}\e[0m" end
def gray;           "\e[37m#{self}\e[0m" end

def bg_black;       "\e[40m#{self}\e[0m" end
def bg_red;         "\e[41m#{self}\e[0m" end
def bg_green;       "\e[42m#{self}\e[0m" end
def bg_brown;       "\e[43m#{self}\e[0m" end
def bg_blue;        "\e[44m#{self}\e[0m" end
def bg_magenta;     "\e[45m#{self}\e[0m" end
def bg_cyan;        "\e[46m#{self}\e[0m" end
def bg_gray;        "\e[47m#{self}\e[0m" end

def bold;           "\e[1m#{self}\e[22m" end
def italic;         "\e[3m#{self}\e[23m" end
def underline;      "\e[4m#{self}\e[24m" end
def blink;          "\e[5m#{self}\e[25m" end
def reverse_color;  "\e[7m#{self}\e[27m" end
end
