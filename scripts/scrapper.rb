# encoding: utf-8
require_relative "script_helper"

require "mechanize"

# Dla testów
if %w(development test).include? ENV['RACK_ENV']
  require "fakeweb"

  FakeWeb.allow_net_connect = false
  FakeWeb.register_uri(:get, "http://lo2.m.win.pl", :response => File.read("scripts/home_response"))
  FakeWeb.register_uri(:any, "http://lo2.m.win.pl/index.php", :body => "Elo")
  FakeWeb.register_uri(:get, "http://lo2.m.win.pl/zastepstwa.php", :body => File.read("scripts/zastepstwa_response"))
  FakeWeb.register_uri(:get, "http://lo2.m.win.pl/numerki_wylosowane.php", :body => File.read("scripts/numerki_response"))
end

Mechanize::AGENT_ALIASES["Linux Firefox 3"] = "Mozilla/5.0 (X11; U; Linux i686; pl-PL; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8"

agent = Mechanize.new do |agent|
  agent.user_agent_alias = 'Linux Firefox 3'
end

login_page = agent.get('http://lo2.m.win.pl')

login_form = login_page.form_with(:action => 'index.php') do |form|
  form.login = $config['dziennik_user']
  form.haslo = $config['dziennik_pass']
end.click_button

# Pobierz zastępstwa

replacements_page = agent.get('http://lo2.m.win.pl/zastepstwa.php')
replacements = Nokogiri::HTML(replacements_page.body).at_css('#content').inner_text

Replacement.create(:body => replacements.remove_empty_spaces)

# Pobierz numerek

number_page = agent.get('http://lo2.m.win.pl/numerki_wylosowane.php')
number = Nokogiri::HTML(number_page.body).at_css('#losik').inner_text.to_i

DrawnNumber.create(:value => number)
