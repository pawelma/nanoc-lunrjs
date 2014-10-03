require 'json'
require 'nokogiri'

module NanocLunrjs
  module Filters
    class SearchIndex < Nanoc::Filter
      identifier :nanoc_lunrjs_search_index
      type :text

      @@nanoc_lunrjs_search_index_file_name = 'search.json'

      attr_reader :index_file

      SELECTORS = {
        title: [:h1, :h2],
        subtitle: [:h3, :h4, :h5],
        body: [],
        code: [:code]
      }

      SKIP_IN_INDEX = [
        "\r", "\n", "\t",
        /<[\w"=]+>/, /<\/\w+>/
        "<", ">"
      ]

      def initialize(hash={})
        super

        index_name = @site[:nanoc_lunrjs_search_index_file_name] || @@nanoc_lunrjs_search_index_file_name
        self.index_file = File.join(@site.config[:output_dir], index_name)
      end

      def run(content, params={})
        case params[:type]
          when :raw
            process_raw(content, params)
          when :html
            process_html(content, params)
        end

        content
      end

      protected

      def process_raw(content, params)
        index = load_index_file

        item = SELECTORS.dup
        item[:title] = item_file_name
        item[:code] = extract_text content
        item[:subtitle] = ""
        item[:body] = ""

        add_to_index(index, item)
      end

      def process_html(content, params)
        index = load_index_file

        html = Nokogiri::HTML(content)

        item = SELECTORS.dup
        item.each do |item_key, selectors|
          item[item_key] = extract_text(html_content(html, selectors))
        end

        add_to_index(index, item)
      end

      def html_content(html, selectors)
        selectors_xpath = ""
        selectors.each do |selector|
          selectors_xpath << " or " unless selectors_xpath.empty?
          selectors_xpath << "self::#{selector}"
        end
        selectors_xpath = "[#{selectors_xpath}]" unless selectors_xpath.empty?

        html.xpath("//*#{selectors_xpath}/text()").to_a.join(' ')
      end

      def extract_text(content)
        SKIP_IN_INDEX.each do |skip|
          content.gsub!(skip, ' ')
        end
        content.squeeze(' ').strip
      end

      def add_to_idex(index, item)
        index[item_path] = item
        store_index_file index
      end

      def load_index_file
        {} unless File.exist?(@search_file)
        JSON.parse(File.read(index_file))
      end

      def store_index_file(hash)
        File.open(index_file, 'w') do |file|
          file.write hash.to_json
        end
      end

      def item_file_name
        item_path.split('/').last
      end

      def item_path
        assigns[:item_rep].path
      end
    end
  end
end
