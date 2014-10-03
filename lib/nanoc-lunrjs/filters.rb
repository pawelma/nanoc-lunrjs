require 'nanoc'

module NanocLunrjs
  module Filters
    autoload "SearchIndex", "nanoc-lunrjs/filters/search_index"

    Nanoc::Filter.register '::NanocLunrjs::Filters::SearchIndex', :nanoc_lunrjs_search_index
  end
end
