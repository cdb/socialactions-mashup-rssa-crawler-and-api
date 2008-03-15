module TagsHelper
  def tag_cloud(tags, classes)
    return if tags.empty?
    
    max_count = tags.sort_by(&:count).last.count.to_f
    
    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end
  
  def page_entries_info_with_tag(collection, tag)
    %{Displaying entries <b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b> in total that match the tag <b>%s</b>} % [
      collection.offset + 1,
      collection.offset + collection.length,
      collection.total_entries,
      tag.name
    ]
  end
end
