require 'csv'

require 'bibler'

include Bibler::Data

bootstrap!

def book_by_ordinal(ordinal)
	testament = nil
	if ordinal > 39
		ordinal = (ordinal % 40) + 1
		testament = Testament.where(slug: 'new').first
	else
		testament = Testament.where(slug: 'old').first
	end
	Book.where(ordinal: ordinal, testament: testament).first
end

def loadVerses(bibleCode, bible, file)
	print "\t#{bible.name}..."
	count = 0
	first = true
	ActiveRecord::Base.transaction do
		CSV.open(file).each do |row|
			if first
				first = false
				next
			end
			book = book_by_ordinal(row[1].to_i)
			# puts "#{bible.name} #{book.name} #{row[2]} #{row[3]}"
			verse = Verse.new(
				bible: bible,
				book: book,
				chapter: row[2].to_i,
				ordinal: row[3].to_i,
				text: row[4]
			)
			if verse.valid?
				verse.save!
				count += 1
			else
				puts verse
				puts verse.errors.messages
			end 
		end
	end
	puts " #{count}"
end

puts "Loading bible verses..."

prefix = File.join(Rails.root, 'public', 'bible_databases', 'csv')
# The Webster's Bible data contains a number of duplicate verses that don't pass our integrity validations, so we'll skip that bible.
# BIBLE_CODES = [:asv, :bbe, :dby, :kjv, :web, :ylt]
BIBLE_CODES = {asv: 'ASV', bbe: 'BBE', dby: 'DARBY', kjv: 'KJV', web: 'WBT', ylt: 'YLT'}
BIBLE_CODES.each do |bibleCode, abbreviation|
	bible = Bible.where(abbreviation: abbreviation).first
	loadVerses(bibleCode, bible, File.join(prefix, "t_#{bibleCode}.csv"))
end

puts "Done!"

