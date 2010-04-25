module CuteAdminHelper
  def cute_admin_ordered_full_class(search, column)
    if search.order == "ascend_by_#{column}"
      return " ordered-by"
    elsif search.order == "descend_by_#{column}"
      return " ordered-by-desc"
    end
    return nil
  end

  def cute_admin_ordered_class(search, column)
    if search.order == "ascend_by_#{column}" || search.order == "descend_by_#{column}"
      return " column-ordered"
    end
    return nil
  end

  def per_page_select_remote(collection, form_id = "search-form")
    select_tag(:per_page,
      options_for_select(per_page_select_options, per_page_from_collection(collection)),
      { :onchange => "$('#{form_id}').request();" } )
  end

  def per_page_select(collection, form_id = "search-form")
    select_tag(:per_page,
      options_for_select(per_page_select_options, per_page_from_collection(collection)),
      { :onchange => "document.getElementById('#{form_id}').submit();" } )
  end

  def per_page_from_collection(collection)
    collection.is_a?(WillPaginate::Collection) ? collection.per_page.to_s : ""
  end

  def per_page_select_options
    ["10", "20", "30", "50", "100", [t(:all, :default => '[ all ]', :scope => [:railties, :scaffold]), ""]]
  end

  def total_entries(collection)
    collection.is_a?(WillPaginate::Collection) ? collection.total_entries : collection.size
  end

  def cute_admin_will_paginate_options
    {
      :previous_label => "&lt; #{I18n.t(:prev_page, :default => 'Prev', :scope => [:railties, :scaffold])}",
      :next_label => "#{I18n.t(:next_page, :default => 'Next', :scope => [:railties, :scaffold])} &gt;"
    }
  end

  def cute_for_select(collection)
    collection.map{ |record| [record.display_name, record.id] }
  end

  def cute_localized_time_or_date(value, format)
    value ? l(value, :format => format) : nil
  end

  def cute_datetime(time = Time.now, format = :default)
    cute_localized_time_or_date(time, format)
  end

  def cute_time(time = Time.now, format = :time_only)
    cute_localized_time_or_date(time, format)
  end

  def cute_date(date = Date.today, format = :default)
    cute_localized_time_or_date(date, format)
  end

  def cute_boolean(boolean)
    return nil if boolean.nil?
    t("#{boolean}".to_sym, :default => "#{boolean}", :scope => [:railties, :scaffold])
  end

  def booleans_for_select
    [[t(:all, :default => '[ all ]', :scope => [:railties, :scaffold]), nil], [cute_boolean(true), true], [cute_boolean(false), false]]
  end

  def will_paginate_remote(collection = nil, options = {})
    options[:renderer] ||= 'RemoteLinkRenderer'
    will_paginate(collection, options)
  end

end
