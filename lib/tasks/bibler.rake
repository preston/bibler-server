# frozen_string_literal: true

require 'csv'

namespace :bibler do
  desc 'Loads the New American Standard Bible'
  task nasb: :environment do
    bible = Bible.find_or_create_by(name: 'New American Standard Bible', abbreviation: 'nasb')
    file = File.join(Rails.root, 'lib', 'tasks', 'bibler_nasb.csv')
    puts "Loading #{file} into database... (will take a while)"
    count = 0
    book = nil
    CSV.open(file, headers: true).each do |r|
      if book && book.slug == r[0]
        # We already have the book loaded.
      else
        book = Book.find(r[0])
      end
      verse = Verse.new(
        bible:,
        book:,
        chapter: r[1],
        ordinal: r[2],
        text: r[3]
      )
      verse.save!
      count += 1
    end
    puts "Loaded #{count} verses."
  end
end
