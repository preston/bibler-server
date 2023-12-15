# frozen_string_literal: true

require 'csv'

module Bibler
  # Author: Preston Lee
  module Data
    PREFIX = File.join(Rails.root, 'public', 'bible_databases', 'csv')

    def create_testaments
      Testament.create!(name: 'Old')
      Testament.create!(name: 'New')
    end

    def create_bibles
      bibles_file = File.join(PREFIX, 'bible_version_key.csv')
      CSV.open(bibles_file, headers: true).each do |row|
        Bible.create!(name: row[4], abbreviation: row[2])
      end
    end

    def create_books
      ot_count = 0
      nt_count = 0
      old_testament = Testament.where(name: 'Old').first
      new_testament = Testament.where(name: 'New').first
      books_file = File.join(PREFIX, 'key_english.csv')
      CSV.open(books_file, headers: true).each do |row|
        testament = old_testament
        count = -1
        if row[2] == 'OT'
          testament = old_testament
          ot_count += 1
          count = ot_count
        else
          testament = new_testament
          nt_count += 1
          count = nt_count
        end
        Book.create!(name: row[1], testament:, ordinal: count)
      end
    end

    def bootstrap!
      puts 'Creating testaments...'
      create_testaments

      print 'Loading bible types...'
      create_bibles
      puts " #{Bible.count}"

      print 'Loading book names...'
      create_books
      puts " #{Book.count}"
    end
  end
end
