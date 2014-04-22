Given(/^I set the (.+) environment variable to the "(.*?)" file in the working directory$/) do |env, file_name|
  set_env(env, File.expand_path(File.join(File.dirname(__FILE__), '../../tmp/aruba', file_name)))
end
