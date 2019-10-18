# *** ИЗВЛЕЧЕНИЕ ИНФОРМАЦИИ ИЗ МНОЖЕСТВА WEB-СТРАНИЦ ***

# frozen_string_literal: true

require 'net/http'
require 'uri'

# стартовый идентификатор страницы
START_ID = 700
# сколько страниц следует рассмотреть
STEP = 100

# получение ответа от целевой страницы
def get_responce(id)
  uri = URI.parse("https://allkharkov.ua/reference/firm/#{id}.html")
  Net::HTTP.get_response(uri)
end

# извлечение информации об объекте в хэш
def extract_info(text)
  a = {}
  a[:name] = extract_name(text)
  a[:email] = extract_email(text)
  a[:activity] = extract_activity(text)
  a
end

# замена эскейп последовательностей HTML соответствующими символами
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

# извлечение имени
def extract_name(text)
  text =~ %r{<div class="firm_title"> *?<h1>(.*?)</h1>} ? unescape_html(Regexp.last_match[1]) : nil
end

# извлечение почты
def extract_email(text)
  text =~ %r{E-mail:</div> *?<div class="info_value">(.*?@.*?\..*?)</div>} ? Regexp.last_match[1].strip : nil
end

# извлечение рубрики
def extract_activity(text)
  headings = 'Рубрики'.force_encoding('ASCII-8BIT')
  text =~ %r{#{headings}:</div> *?<div class="info_value">(.*?)[,<]} ? Regexp.last_match[1] : nil
end

end_id = START_ID + STEP
# результат сохраняется в поддиректорию /results
Dir.mkdir('results') unless Dir.exist?('results')
input = File.open("results/res-vh-#{START_ID}-#{end_id}.txt", 'w')
(START_ID..end_id).each do |id|
  responce = get_responce(id)
  # если страница существует, она анализируется
  if responce.code == '200'
    firm_info = extract_info(responce.body)
    input.puts "#{id};#{firm_info[:name]};#{firm_info[:email]};#{firm_info[:activity]}"
    puts "-------------------->id=#{id}"
  else
    puts "-id=#{id}"
  end
end
