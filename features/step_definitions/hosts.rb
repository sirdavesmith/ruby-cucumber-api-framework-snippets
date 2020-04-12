Given(/^I create an (\w.*) host named (\w.*)$/) do |type, name|
  case type.downcase
  when 'sftp'
    attributes = {
      name: "#{name}",
      type_of: "#{type.downcase}",
      username: "#{TestData[:SftpUsername]}",
      server: "#{TestData[:SftpHost]}",
      port: 22,
      path: "#{TestData[:SftpPath]}",
      encrypted_private_key: "#{TestData[:SftpKey]}"
    }
  else
    attributes = {
      name: "#{name}",
      type_of: "#{type.downcase}"
    }
  end

  puts "HOST DEBUG:" if DEBUG
  puts "name: #{name}" if DEBUG
  puts "type_of: #{type.downcase}" if DEBUG
  puts "username: #{TestData[:SftpUsername]}" if DEBUG
  puts "server: #{TestData[:SftpHost]}" if DEBUG
  puts "port: 22" if DEBUG
  puts "path: #{TestData[:SftpPath]}" if DEBUG
  puts "encrypted_private_key: #{TestData[:SftpKey]}" if DEBUG

  Specr.client.post("/properties/:property_id/hosts",
    {
      data: {
        type: "hosts",
        attributes: attributes
      }
    }
  )
  puts "Request {data: {type: 'hosts', attributes: #{attributes}}}" if DEBUG
  step "Assign id to host_id" if Specr.client.last_code < 202
end

Given(/^I GET all hosts for my Property$/) do
  Specr.client.get('/properties/:property_id/hosts?page[size]=99&page[number]=1&sort=name')
end

And(/^I have created host (\w+)$/) do |host|
  Specr.client.get("/properties/:property_id/hosts?filter[name]=EQ #{host}")
  if (Specr.client['data'].empty?) then
    puts "I have created host #{host} - returned an empty result" if DEBUG
    if (host.include? "SFTP") then
      step "I create an sftp host named #{host}"
    else
      puts "Creating Cdn Host: '#{host}'" if DEBUG
      step "I create an cdn host named #{host}"
    end
  else
    step "Assign id to host_id"
  end
end

Given(/^I create a failed SFTP host named (\w.*)$/) do |hostName|
  Specr.client.storage[:SftpUsername] = TestData[:SftpUsername]

  TestData[:SftpUsername] = "Failed"
  step "I create an SFTP host named #{hostName}"

  # reset data back to Valid Data
  TestData[:SftpUsername] = Specr.client.storage[:SftpUsername]
end
