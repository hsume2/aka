Given(/^I set the AKA environment variable to the "(.*?)" file in the working directory$/) do |file_name|
  set_env('AKA', File.expand_path(File.join(File.dirname(__FILE__), '../../tmp/aruba', file_name)))
end
