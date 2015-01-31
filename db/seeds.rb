require 'csv'

oldTestament = Testament.create!(name: 'Old')
newTestament = Testament.create!(name: 'New')

prefix = File.join(Rails.root, 'public', 'bible_databases', 'csv')
biblesFile = File.join(prefix, 'bible_version_key.csv')
booksFile = File.join(prefix, 'key_english.csv')
# versesFile = File.join(prefix, '')

# Keeping everything in memory due to the internal IDs. Oh well.
bibles = {}
books = {}

first = true
print "Loading bible types..."
CSV.open(biblesFile).each do |row|
	if first
		first = false
		next
	end
	bible = Bible.create!(name: row[4], abbreviation: row[2])
	bibles[row[1]] = bible
end
puts " #{bibles.length}"


otCount = 0
ntCount = 0
first = true
print "Loading book names..."
CSV.open(booksFile).each do |row|
	if first
		first = false
		next
	end
	testament = oldTestament
	count = -1
	if row[2] == 'OT'
		otCount += 1
		count = otCount
	else
		testament = newTestament
		ntCount += 1
		count = ntCount
	end
	book = Book.create!(name: row[1], testament: testament, ordinal: count)
	books[row[0]] = book
end
puts " #{books.length}"

def loadVerses(bibleCode, bible, books, file)
	print "\t#{bible.name}..."
	count = 0
	first = true
	ActiveRecord::Base.transaction do
		CSV.open(file).each do |row|
			if first
				first = false
				next
			end
			book = books[row[1]]
			verse = Verse.new(bible: bible, book: book, chapter: row[2].to_i, ordinal: row[3].to_i, text: row[4])
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
# The Webster's Bible data contains a number of duplicate verses that don't pass our integrity validations, so we'll skip that bible.
# BIBLE_CODES = [:asv, :bbe, :dby, :kjv, :wbt, :web, :ylt]
BIBLE_CODES = [:asv, :bbe, :dby, :kjv, :web, :ylt]
BIBLE_CODES.each do |bibleCode|
	loadVerses(bibleCode, bibles["t_#{bibleCode}"], books, File.join(prefix, "t_#{bibleCode}.csv"))
end

puts "Done!"

