class KGET
  require 'open-uri'
  require 'nokogiri'
  require 'fileutils'

  def scrape
    doc = Nokogiri::HTML(open('http://www.kerngoldenempire.com/local-news'))
    end_date = (Date.today + 2.days).strftime('%Y%m%d')

    # pagination
    1.upto(5) do |num|
      page = Nokogiri::HTML(open("http://www.kerngoldenempire.com/local-news?p_p_id=refresharticle_WAR_epwcmportlet&p_p_lifecycle=2&p_p_cacheability=cacheLevelPage&_refresharticle_WAR_epwcmportlet_groupId=118809186&_refresharticle_WAR_epwcmportlet_articleId=CONVS-TABBED_HEADLINE_LIST-TABBED_HEADLINE_LIST_2_0-124631607&_refresharticle_WAR_epwcmportlet_templateId=HEADLINE_LIST_PAGINATION_2.0&pageNum=#{num}&tabNumber=1&endDate=#{end_date}"))
      page_links = page.search('li')
      doc.at('section.mod-headline-list ul.list') << page_links
    end

    list_items = doc.search('section.mod-headline-list ul.list li')
    formatted_items = format_items(list_items)

    rss_file_contents = template
    rss_file_contents.gsub!('<!--items-->', formatted_items)

    # rss_file = Rails.public_path.to_s + '/kget.rss'
    # File.write(rss_file, rss_file_contents)

    s3_obj = $s3.bucket(ENV['AWS_BUCKET_NAME']).object('kget.rss')
    s3_obj.put(body: rss_file_contents, acl: 'public-read')
  end

  def template
    <<~HEREDOC
      <?xml version="1.0" encoding="utf-8" ?>
      <rss version="2.0">
        <channel>
          <title>KGET Local News</title>
          <link>http://www.kerngoldenempire.com/local-news</link>
          <description>Local news from KGET</description>
          <!--items-->
        </channel>
      </rss>
    HEREDOC
  end

  def format_items(list_items)
    items = ''

    list_items.each do |li|
      link = li.at('a.headline')
      paragraph = li.at('p')

      next if !link || !paragraph

      items << <<~HEREDOC
        <item>
          <title>#{link.text.strip.gsub('&', '&amp;amp;')}</title>
          <link>http://www.kerngoldenempire.com#{link.attributes['href'].value}</link>
          <description>#{paragraph.text.gsub('&', '&amp;amp;')}</description>
        </item>
      HEREDOC
    end

    return items
  end

end
