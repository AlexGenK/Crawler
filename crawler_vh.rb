require "net/http"
require "uri"

def get_responce(id)
	uri = URI.parse("https://allkharkov.ua/reference/firm/#{id}.html")
	Net::HTTP.get_response(uri)
end

def extract_info(text)
	a = {}
	a[:name] = extract_name(text)
	a[:email] = extract_email(text)
	a[:activity] = extract_activity(text)
	return a
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
	text =~ /<div class="firm_title"> *?<h1>(.*?)<\/h1>/ ? unescape_html(Regexp.last_match[1]) : nil
end

def extract_email(text)
	text =~ /E-mail:<\/div> *?<div class="info_value">(.*?@.*?\..*?)<\/div>/ ? Regexp.last_match[1].strip : nil
end

def extract_activity(text)
	text =~ /#{"Рубрики".force_encoding('ASCII-8BIT')}:<\/div> *?<div class="info_value">(.*?)[,<]/ ? Regexp.last_match[1] : nil
end

start_id = 700
step = 100

end_id = start_id + step
Dir.mkdir('results') unless Dir.exist?('results')
input = File.open("results/res-vh-#{start_id}-#{end_id}.txt", "w")
(start_id..end_id).each do |id|
	responce = get_responce(id)
	if responce.code == '200'
		firm_info = extract_info(responce.body)
		input.puts "#{id};#{firm_info[:name]};#{firm_info[:email]};#{firm_info[:activity]}"
		puts "-------------------->id=#{id}"
	else
		puts "-id=#{id}"
	end
end
