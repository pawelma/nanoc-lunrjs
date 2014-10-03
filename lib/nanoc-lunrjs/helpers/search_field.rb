require 'haml'

module NanocLunrjs
  module Helpers
    class SearchField
      def nanoc_lunrjs_search
        template = File.read(template_path(__method__))
        ::Haml::Engine.new(template).render(Object.new)
      end

      def search_field
        nanoc_lunrjs_search
      end

      private

      def template_path method_name
        class_name = self.class.name.split('::').last.gsub(/(.)([A-Z])/,'\1_\2').downcase
        File.join(NanocLunrjs.templates_path, class_name, "#{method_name}.haml")
      end
    end
  end
end
