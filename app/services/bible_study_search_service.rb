# frozen_string_literal: true

# Author: Preston Lee
# Executes verse text searches against Postgres only (pg_search). No invented text.
class BibleStudySearchService
  MAX_PER_QUERY = 25
  MAX_TOTAL_VERSES = 100
  MAX_TEXT_CHARS = 800

  # searches: array of hashes with keys: bible_uuid (required), text (required), limit (optional)
  def self.call(searches:)
    return { verses: [], errors: [] } if searches.blank?

    list = Array(searches)
    errors = []
    verses_out = []
    total = 0

    list.each do |s|
      break if total >= MAX_TOTAL_VERSES

      s = s.symbolize_keys
      bible = resolve_bible(s[:bible_uuid])
      unless bible
        errors << "Unknown bible: #{s[:bible_uuid]}"
        next
      end

      text = s[:text].to_s.strip
      if text.blank?
        errors << 'Search text is blank.'
        next
      end

      limit = s[:limit].present? ? s[:limit].to_i : MAX_PER_QUERY
      limit = limit.clamp(1, MAX_PER_QUERY)
      remaining = MAX_TOTAL_VERSES - total
      limit = [limit, remaining].min

      found = Verse.where(bible: bible).search_by_text(text).includes(:book).limit(limit)
      found.each do |v|
        verses_out << verse_row(bible, v)
        total += 1
        break if total >= MAX_TOTAL_VERSES
      end
    end

    { verses: verses_out, errors: errors }
  end

  def self.resolve_bible(uuid)
    return if uuid.blank?

    Bible.find_by(uuid: uuid.to_s)
  end

  def self.verse_row(bible, verse)
    text = verse.text.to_s
    text = "#{text[0...MAX_TEXT_CHARS]}... [truncated]" if text.length > MAX_TEXT_CHARS
    {
      bible_uuid: bible.uuid,
      book_uuid: verse.book.uuid,
      book_name: verse.book.name,
      chapter: verse.chapter,
      ordinal: verse.ordinal,
      verse_uuid: verse.uuid,
      text: text
    }
  end
end
