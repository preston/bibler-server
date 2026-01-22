# frozen_string_literal: true

require 'csv'
require 'set'

module Bibler
  # Author: Preston Lee
  module Data
    def create_testaments
      Testament.find_or_create_by!(name: 'Old')
      Testament.find_or_create_by!(name: 'New')
    end

    def parse_translation_manifest(base_path)
      manifest_file = File.join(base_path, 'docs', 'main_readme', 'translation_list.md')
      return {} unless File.exist?(manifest_file)

      translations = {}
      File.readlines(manifest_file).each do |line|
        # Parse format: - **ASV (en)**: ASV: American Standard Version (1901)
        match = line.match(/^-\s+\*\*(\w+)\s+\(([^)]+)\)\*\*:\s+(.+)$/)
        next unless match

        abbreviation = match[1]
        language = match[2]
        name = match[3].strip
        translations[abbreviation] = { language:, name: }
      end
      translations
    end

    def extract_license(base_path, abbreviation)
      readme_file = File.join(base_path, 'sources', abbreviation, 'README.md')
      return '' unless File.exist?(readme_file)

      File.readlines(readme_file).each do |line|
        match = line.match(/^\*\*License:\*\*\s*(.+)$/)
        return match[1].strip if match
      end
      ''
    end

    def normalize_book_name(name)
      # Convert Roman numerals to Arabic numerals
      normalized = name.dup
      # Handle common patterns: "I Chronicles" -> "1 Chronicles", "II Corinthians" -> "2 Corinthians", etc.
      normalized.gsub!(/\bI\s+([A-Z])/, '1 \1')
      normalized.gsub!(/\bII\s+([A-Z])/, '2 \1')
      normalized.gsub!(/\bIII\s+([A-Z])/, '3 \1')
      # Handle "Song of Solomon" vs "Song of Songs" - standardize to "Song of Solomon"
      normalized.gsub!(/\bSong of Songs\b/, 'Song of Solomon')
      normalized
    end

    def create_bibles(base_path)
      translations = parse_translation_manifest(base_path)
      return if translations.empty?

      translations.each do |abbreviation, metadata|
        license = extract_license(base_path, abbreviation)
        # Use where to avoid FriendlyId's finder override
        bible = Bible.where(abbreviation:).first_or_initialize
        bible.name = metadata[:name]
        bible.language = metadata[:language]
        bible.license = license
        bible.save!
      end
    end

    def determine_testament(book_name, position, total_books)
      # Known OT books (standard 39 books)
      ot_books = %w[
        Genesis Exodus Leviticus Numbers Deuteronomy
        Joshua Judges Ruth 1\ Samuel 2\ Samuel
        1\ Kings 2\ Kings 1\ Chronicles 2\ Chronicles
        Ezra Nehemiah Esther
        Job Psalms Proverbs Ecclesiastes Song\ of\ Solomon
        Isaiah Jeremiah Lamentations Ezekiel Daniel
        Hosea Joel Amos Obadiah Jonah Micah Nahum
        Habakkuk Zephaniah Haggai Zechariah Malachi
      ]

      # Known NT books (standard 27 books)
      nt_books = %w[
        Matthew Mark Luke John
        Acts
        Romans 1\ Corinthians 2\ Corinthians Galatians Ephesians
        Philippians Colossians 1\ Thessalonians 2\ Thessalonians
        1\ Timothy 2\ Timothy Titus Philemon
        Hebrews James 1\ Peter 2\ Peter 1\ John 2\ John 3\ John Jude
        Revelation
      ]

      # Check for known OT books
      return Testament.find_by(name: 'Old') if ot_books.include?(book_name)

      # Check for known NT books
      return Testament.find_by(name: 'New') if nt_books.include?(book_name)

      # Apocryphal/Deuterocanonical books are OT-era (using normalized names)
      apocryphal_books = %w[
        Tobit Judith Wisdom Sirach Baruch
        1\ Maccabees 2\ Maccabees 3\ Maccabees 4\ Maccabees
        1\ Esdras 2\ Esdras
        Bel\ and\ the\ Dragon Susanna
        Prayer\ of\ Azariah Prayer\ of\ Manasses
        Additions\ to\ Esther
        1\ Enoch
        Odes
      ]
      return Testament.find_by(name: 'Old') if apocryphal_books.include?(book_name)

      # Fallback: use position (first ~40% likely OT, rest NT)
      # Default to OT if uncertain (safer assumption)
      if position <= (total_books * 0.4)
        Testament.find_by(name: 'Old')
      else
        Testament.find_by(name: 'New')
      end
    end

    def bootstrap!(base_path)
      puts 'Creating testaments...'
      create_testaments

      print 'Loading bible types...'
      create_bibles(base_path)
      puts " #{Bible.count}"
    end
  end
end
