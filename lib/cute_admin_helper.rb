module CuteAdminHelper
  def cute_admin_ordered_full_class(order_by, options = {})
    add_searchlogic_defaults!(options)
    if searchlogic_ordering_by?(order_by, options)
      if options[:search_obj].desc?
        return " ordered-by-desc"
      else
        return " ordered-by"
      end
    end
    return nil
  end

  def cute_admin_ordered_class(order_by, options = {})
    add_searchlogic_defaults!(options)
    return " column-ordered" if searchlogic_ordering_by?(order_by, options)
    return nil
  end

  def nice_boolean(boolean)
    I18n.t("#{boolean}".to_sym, :default => "#{boolean}", :scope => [:railties, :scaffold])
  end

  def pagination_links(options = {})
    @added_searchlogic_state = true
    links = page_links(options)
    @added_searchlogic_state = nil
    if links
      "<div class=\"pagination\">#{links}</div>"
    else
      return nil
    end
  end
end
