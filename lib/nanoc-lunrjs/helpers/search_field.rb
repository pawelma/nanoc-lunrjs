require 'haml'
require 'fileutils'

module NanocLunrjs
  module Helpers
    module SearchField
      def nanoc_lunrjs_search
        template = File.read(template_path(__method__))
        ::Haml::Engine.new(template).render(Object.new)
      end

      def nanoc_lunrjs_init nanoc_root_dir
        template = File.read(template_path(__method__))
        js_in_path = File.join(NanocLunrjs.assets_path, 'javascripts')
        js_out_path = File.join(nanoc_root_dir, @site.config[:output_dir], 'assets', 'js')
        unless File.directory? js_out_path
          FileUtils.mkdir_p js_out_path
        end

        required_js_dependencies = ['jquery.min.js', 'lunr.min.js', 'nanoc-lunr.js']
        required_js_dependencies.each do |script|
          FileUtils.cp(File.join(js_in_path, script), js_out_path)
        end

        ::Haml::Engine.new(template).render(Object.new, path: js_out_path, scripts: required_js_dependencies)
      end

      def search_field
        nanoc_lunrjs_search
      end

      private

      def template_path method_name
        # module_name = 'SearchField'.gsub(/(.)([A-Z])/,'\1_\2').downcase
        File.join(NanocLunrjs.templates_path, 'search_field', "#{method_name}.haml")
      end
    end
  end
end
