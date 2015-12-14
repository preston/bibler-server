require 'csv'

module Bibler

	module Data

		PREFIX = File.join(Rails.root, 'public', 'bible_databases', 'csv')

		def create_testaments
			Testament.create!(name: 'Old')
			Testament.create!(name: 'New')
		end

		def create_bibles
			biblesFile = File.join(PREFIX, 'bible_version_key.csv')
			CSV.open(biblesFile, headers: true).each do |row|
				bible = Bible.create!(name: row[4], abbreviation: row[2])
			end
		end

		def create_books
			otCount = 0
			ntCount = 0
			oldTestament = Testament.where(name: 'Old').first
			newTestament = Testament.where(name: 'New').first
			booksFile = File.join(PREFIX, 'key_english.csv')
			CSV.open(booksFile, headers: true).each do |row|
				testament = oldTestament
				count = -1
				if row[2] == 'OT'
					testament = oldTestament
					otCount += 1
					count = otCount
				else
					testament = newTestament
					ntCount += 1
					count = ntCount
				end
				book = Book.create!(name: row[1], testament: testament, ordinal: count)
			end
		end

		def bootstrap!
			puts "Creating testaments..."
			create_testaments
						
			print "Loading bible types..."
			create_bibles
			puts " #{Bible.count}"

			print "Loading book names..."
			create_books
			puts " #{Book.count}"
		end

	end

end
