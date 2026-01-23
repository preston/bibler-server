# frozen_string_literal: true

# Author: Preston Lee
module Mcp
  module Tools
    class ListBooks < BaseTool
      def tool_definition
        {
          name: 'list_books',
          description: 'List books in a bible translation',
          inputSchema: {
            type: 'object',
            properties: {
              bible: {
                type: 'string',
                description: 'Bible identifier (slug or ID, optional - lists all books if omitted)'
              }
            },
            required: []
          }
        }
      end

      protected

      def validate_arguments(_arguments)
        # No required arguments
      end

      def execute(arguments)
        if arguments['bible'].present?
          bible = find_bible(arguments['bible'])
          books = bible.books.includes(:testament).order('testament_id ASC', 'ordinal ASC')
        else
          books = Book.includes(:bible, :testament).order('bible_id ASC', 'testament_id ASC', 'ordinal ASC')
        end

        {
          content: [
            {
              type: 'text',
              text: JSON.pretty_generate(
                books.map do |book|
                  {
                    id: book.id,
                    name: book.name,
                    slug: book.slug,
                    ordinal: book.ordinal,
                    testament: book.testament.name,
                    bible: book.bible.name
                  }
                end
              )
            }
          ]
        }
      end
    end
  end
end
