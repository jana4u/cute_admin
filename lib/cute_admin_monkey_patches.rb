class String
  def to_plain
    self.mb_chars.normalize(:kd).to_s.gsub(/[^\x00-\x7F]/, '')
  end

  def to_slug
    self.to_plain.tr(' ', '-').downcase.gsub(/[^0-9a-z-]/, '')
  end
end

module Searchgasm
  module Helpers
    module ControlTypes
      module Links
        def pagination_links(options = {})
          @added_searchgasm_state = true
          links = page_links(options)
          @added_searchgasm_state = nil
          if links
            "<div class=\"pagination\">#{links}</div>"
          else
            return nil
          end
        end

        def span_or_page_link(name, options, span)
          options[:html][:class] = ""
          text = ""
          page = 0
          case name
          when Fixnum
            text = name
            page = name
            searchgasm_add_class!(options[:html], "current") if span
          else
            text = options[name]
            page = options[:search_obj].send("#{name}_page")
            #searchgasm_add_class!(options[:html], "#{name}_page")
            searchgasm_add_class!(options[:html], "disabled") if span
          end

          options[:html][:class] = nil if options[:html][:class].blank?
          options[:text] = text
          span ? content_tag(:span, text, options[:html]) : page_link(page, options)
        end
      end

      module Link
        def page_link(page, options = {})
          add_page_link_defaults!(page, options)
          options[:html][:class] = nil
          html = ""

          if !options[:is_remote]
            html += link_to(options[:text], options[:url], options[:html])
          else
            html += link_to_remote(options[:text], options[:remote].merge(:url => options[:url]), options[:html])
          end

          html
        end
      end
    end
  end
end