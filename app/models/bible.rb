# frozen_string_literal: true

# Author: Preston Lee
class Bible < ActiveRecord::Base
  has_many :verses, dependent: :destroy
  has_many :books, dependent: :destroy

  extend FriendlyId
  friendly_id :slug_candidates, use: %i[slugged finders]

  validates_presence_of :name
  validates_presence_of :abbreviation
  validates_presence_of :slug
  validates_presence_of :language

  validates_uniqueness_of :name, scope: :language
  validates_uniqueness_of :abbreviation

  # Mapping of language codes to human-readable names
  LANGUAGE_NAMES = {
    'en' => 'English',
    'es' => 'Spanish',
    'fr' => 'French',
    'de' => 'German',
    'pt' => 'Portuguese',
    'it' => 'Italian',
    'ru' => 'Russian',
    'ja' => 'Japanese',
    'ko' => 'Korean',
    'zh-hant' => 'Traditional Chinese',
    'zh' => 'Chinese',
    'ar' => 'Arabic',
    'he' => 'Hebrew',
    'hi' => 'Hindi',
    'th' => 'Thai',
    'vi' => 'Vietnamese',
    'nl' => 'Dutch',
    'pl' => 'Polish',
    'cs' => 'Czech',
    'sv' => 'Swedish',
    'da' => 'Danish',
    'fi' => 'Finnish',
    'no' => 'Norwegian',
    'nb' => 'Norwegian Bokmål',
    'nn' => 'Norwegian Nynorsk',
    'el' => 'Greek',
    'hu' => 'Hungarian',
    'ro' => 'Romanian',
    'uk' => 'Ukrainian',
    'bg' => 'Bulgarian',
    'hr' => 'Croatian',
    'sr' => 'Serbian',
    'sk' => 'Slovak',
    'sl' => 'Slovenian',
    'et' => 'Estonian',
    'lv' => 'Latvian',
    'lt' => 'Lithuanian',
    'sq' => 'Albanian',
    'mt' => 'Maltese',
    'is' => 'Icelandic',
    'ga' => 'Irish',
    'cy' => 'Welsh',
    'eu' => 'Basque',
    'ca' => 'Catalan',
    'gl' => 'Galician',
    'la' => 'Latin',
    'grc' => 'Ancient Greek',
    'got' => 'Gothic',
    'enm' => 'Middle English',
    'cop-sa' => 'Coptic (Sahidic)',
    'syr' => 'Syriac',
    'hbo' => 'Ancient Hebrew',
    'ceb' => 'Cebuano',
    'chr' => 'Cherokee',
    'eo' => 'Esperanto',
    'ht' => 'Haitian Creole',
    'hy' => 'Armenian',
    'lzh' => 'Literary Chinese',
    'mg' => 'Malagasy',
    'mi' => 'Māori',
    'my' => 'Myanmar (Burmese)',
    'pon' => 'Pohnpeian',
    'tl' => 'Tagalog',
    'tlh' => 'Klingon',
    'tpi' => 'Tok Pisin',
    'tsg' => 'Tausug',
    'vls' => 'West Flemish',
    'bea' => 'Beaver',
    'cu' => 'Church Slavonic',
    'gv' => 'Manx',
    'mlf' => 'Malagasy (Merina)',
    'sml' => 'Central Sama'
  }.freeze

  def slug_candidates
    [
      [:name],
      %i[name abbreviation]
    ]
  end
end
