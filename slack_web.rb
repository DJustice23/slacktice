class SlackWEB
  def initialize(username)
    @username = username
  end

  def log_in
    Driver.get 'https://slack.com/signin'
    @wait = Selenium::WebDriver::Wait.new timeout: 15
    sleep(3)
    Driver.find_element(:link_text, 'Sign in').click
    # Select team domain
    sleep(2)
    team_input = Driver.find_element :id, 'domain'
    team_input.send_keys 'tiy-boomtown'

    Driver.find_element(:id, 'submit_team_domain').click

    # Fill in username and password
    email = Driver.find_element :name, 'email'
    email.send_keys ENV.fetch "#{@username.upcase}_EMAIL"

    password = Driver.find_element :name, 'password'
    password.send_keys ENV.fetch "#{@username.upcase}_PASSWORD"

    buttons = Driver.find_elements :css, 'button'
    # buttons.find { ... }
    sign_in = buttons.select { |b| b.text == 'Sign in' }.first
    # sign_in.visible?
    sign_in.click
  end

  def open_channel(channel)
    # On the home page
    headers = Driver.find_elements :css, 'button.channel_list_header_label'
    channel_link = @wait.until do
      el = headers.find { |b| b.text.start_with? 'CHANNELS' }
      el if el && el.displayed?
    end
    channel_link.click

    # Filter down to see the channel
    Driver.find_element(:id, 'channel_browser_filter').send_keys channel

    # the link we need to click on doesn't appear until we mouse over the position
    link = Driver.find_element(:css, '.channel_link')
    Driver.mouse.move_to link
    overlay = Driver.find_element :css, '#channel_browser'
    overlay.click
  end

  def sign_out
    team_link = Driver.find_element(:id, 'team_menu')
    team_link.click
    sign_out_link = Driver.find_element(:id, 'logout')
    sign_out_link.click
  end

  def sign_back_in
    sleep(5)
    Driver.find_element(:link, 'Sign in').click
    sleep(2)
    log_in
  end

end