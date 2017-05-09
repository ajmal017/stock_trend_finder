module WebScraper
  attr_accessor :session

  delegate :visit, :save_screenshot, to: :session

  def start_session
    @session ||= Capybara::Session.new(:poltergeist, Rails.application)
  end

  def end_session
    @session.driver.quit
    @session = nil
  end
end