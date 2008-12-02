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

  def cute_datetime(time = Time.now)
    time ? l(time, :format => :medium) : nil
  end

  def cute_time(time = Time.now)
    time ? l(time, :format => :time_only) : nil
  end

  def cute_date(date = Date.today)
    date ? l(date) : nil
  end

  def cute_boolean(boolean)
    t("#{boolean}".to_sym, :default => "#{boolean}", :scope => [:railties, :scaffold])
  end

  def booleans_for_select
    [[t(:all, :default => '[ all ]', :scope => [:railties, :scaffold]), nil], [cute_boolean(true), true], [cute_boolean(false), false]]
  end

  def pagination_links(options = {}, remote = false)
    @added_searchlogic_state = true
    add_remote_defaults!(options) if remote
    links = page_links(options)
    @added_searchlogic_state = nil
    return links
  end

  def remote_pagination_links(options = {})
    pagination_links(options, true)
  end
end
