module ApplicationHelper

  def use_globalize?
    Rails.env.development?
  end

  def page_entries_info(collection, options = {})
    entry_name = options[:entry_name] || collection.entry_name

    if collection.total_pages < 2
      if collection.total_pages == 0
        tr("No #{entry_name.pluralize} were found")
      else
        tr("Displaying <b>{count}</b> {count | #{entry_name}}", count: 1)
      end
    else
      first = collection.offset_value + 1
      last = collection.last_page? ? collection.total_count : collection.offset_value + collection.limit_value
      tr("Displaying <b>{first} - {last}</b> of <b>{total}</b> {total | #{entry_name}}", first: first, last: last, total: collection.total_count)
    end
  end

end
