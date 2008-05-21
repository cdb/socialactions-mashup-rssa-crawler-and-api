xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Social Actions: Results for #{@search.to_s}"
    xml.description "Results for #{@search.to_s} on http://mashup.socialactions.com"
    xml.link feed_url

    @actions.each do |action|
      xml.item do
        xml.title       action.title
        xml.category    action.action_type
        xml.description shorten_and_clean(action.description)
        xml.pubDate     action.created_at.strftime("%Y-%m-%dT%H:%M:%SZ")
        xml.link        action_url(action)
        xml.guid        action_url(action)
      end
    end

    if @actions.empty?
      xml.item do
        xml.title  'There are no matching actions at this time.'
        xml.description "type" => "html" do
          xml.text! 'There are no matching actions at this time.'
        end
      end
    end
    
  end
end