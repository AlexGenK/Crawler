# frozen_string_literal: true

require 'net/http'
require 'uri'

def g_p_responce(id, type)
  uri = URI.parse("https://www.goldenpages.ua/details/#{id}/#{type}/")
  Net::HTTP.get_response(uri)
end

def extract_info(text)
  a = {}
  a[:name] = extract_name(text)
  a[:email] = extract_email(text)
  a
end

def unescape_html(text)
  text.gsub(/&\w*;/) do |item|
    case item
    when '&laquo;'
      '"'
    when '&raquo;'
      '"'
    when '&quot;'
      '"'
    when '&amp;'
      '&'
    when '&mdash;'
      '-'
    end
  end
end

def extract_name(text)
  text =~ /<h1 class="header">(.*)</ ? unescape_html(Regexp.last_match[1]) : nil
end

def extract_email(text)
  text =~ /<a href="mailto:(.*)" target="_blank"/ ? Regexp.last_match[1] : nil
end

@type = 4308
start_id = 110_000
end_id = start_id + 10_000
input = File.open("res-#{start_id}-#{end_id}.txt", 'w')
(start_id..end_id).each do |id|
  responce = g_p_responce(id, @type)
  if responce.code == '200'
    firm_info = extract_info(responce.body)
    input.puts "#{id};#{firm_info[:name]};#{firm_info[:email]}"
    puts "-------------------->id=#{id}"
  else
    puts "-id=#{id}"
  end
end
