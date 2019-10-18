# *** УДАЛЕНИЕ ДУБЛИКАТОВ ИЗ CSV-ФАЙЛА ***

# frozen_string_literal: true

require 'csv'

adr = {}

Dir.mkdir('results') unless Dir.exist?('results')
CSV.open('results/all-dedouble.csv', 'wb') do |csv|
  CSV.foreach('results/all.csv') do |row|
    unless adr[row[2]]
      adr[row[2]] = row[1]
      csv << [row[0], row[1], row[2]]
    end
  end
end
