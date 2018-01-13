class KGET
  require 'open-uri'
  require 'nokogiri'
  require 'fileutils'

  def scrape
    rss_links = []
    doc = Nokogiri::HTML(open('http://www.kerngoldenempire.com/local-news'))
    doc_links = doc.search('section.mod-headline-list ul.list li a.headline')
    doc_links.each do |link|
      rss_link = {
        'url' => link['href'],
        'text' => link.text
      }
      rss_links.push(rss_link)
    end

    formatted_items = ''

    rss_links.each do |link|
      formatted_items << <<~HEREDOC
        <item>
          <title>#{link['text']}</title>
          <link>http://www.kerngoldenempire.com#{link['url']}</link>
          <description>description...</description>
        </item>
      HEREDOC
    end

    rss_file = Rails.public_path.join('rss').to_s + '/kget.rss'
    rss_file_contents = File.read(rss_file)
    rss_file_contents.gsub!('<items></items>', formatted_items)

    File.write(rss_file, rss_file_contents)
  end

end
