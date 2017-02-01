require_relative '../../slack_web'

Given(/^I am (\w+)/) do |username|
  @username = username
  puts "You are #{username}"
  token = ENV.fetch "#{username.upcase}_TOKEN"
  unless token # if !token
    raise 'Slack token not set'
  end
  @api = SlackAPI.new token
  @web = SlackWEB.new username
end

When(/^I send a message to \#(\w+)$/) do |channel|
  @message = Faker::Company.catch_phrase
  step "I send \"#{@message}\" to ##{channel}"
end

When(/^I send "([^"]*)" to \#(\w+)$/) do |message, channel|
  puts "Sending '#{message}' to ##{channel}"

  # Look up ID for channel
  data = @api.post 'channels.list'
  channels = data['channels']
  channel = channels.select { |c| c['name'] == channel }.first
  channel_id = channel['id']

  puts "channel_id=#{channel_id}"

  # Send message
  @api.post 'chat.postMessage', {
      text: message,
      channel: channel_id
  }
end

Then(/^I should see that message on the \#(\w+) page$/) do |channel|
  step "I should see \"#{@message}\" on the ##{channel} page"
end

Then(/^I should see "([^"]*)" on the \#(\w+) page$/) do |message, channel|
  @web.log_in
  @web.open_channel channel

  # Look for the last message
  Selenium::WebDriver::Wait.new timeout: 15
  messages = Driver.find_elements(:css, '.message')
  last_message = messages.last

  expect(last_message.text).to include message

  # TODO: instead of grabbing the last message
  #   look for a message by this user, with the right text, posted "recently"
end


When(/^I send a message from the \#(\w+) page$/) do |channel|

  # log in to slack
  @web.log_in

  # open a channel
  @web.open_channel channel

  # Add text to the text input field
  Selenium::WebDriver::Wait.new timeout: 15
  text_input = Driver.find_element(:id, 'msg_input')
  text_input.send_keys (Faker::Company.catch_phrase)
  text_input.submit

  # sign out of slack
  @web.sign_out

end