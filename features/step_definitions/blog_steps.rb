Given(/^I am on the "(.*?)" page$/) do |url|
  visit url
end

Then(/^I should see$/) do |text|
  expect(browser.text).to match /#{text}/m
end