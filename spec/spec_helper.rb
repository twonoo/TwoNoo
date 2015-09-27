require 'webmock/rspec'
require 'capybara/poltergeist'

# http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random
end

WebMock.disable_net_connect!(allow_localhost: true)

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end

def stub_geocode_with(location = {})
  before :each do
    @_geocode = Geocode.create!(city: location[:city],
                              state: location[:state],
                              latitude: location[:latitude],
                              longitude: location[:longitude])
    allow(Geocode).to receive(:where).and_return(Geocode.where(id: @_geocode.id))
  end

  after :each do
    @_geocode.destroy!
    allow(Geocode).to receive(:where).and_call_original
  end
end

class MockTimezone
  attr_accessor :active_support_time_zone
  def initialize(time_zone)
    self.active_support_time_zone = time_zone
  end
end

def stub_timezone_with(timezone)
  before :each do
    allow(Timezone::Zone).to receive(:new).and_return(MockTimezone.new(timezone))
  end

  after :each do
    allow(Timezone::Zone).to receive(:new).and_call_original
  end
end

def click_text(text)
  # page.find(:xpath, "//*[contains(text(), '#{text}')]").click
  page.execute_script('$("#myModalLabel").click()')
end