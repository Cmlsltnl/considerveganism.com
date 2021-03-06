###
# General settings
###

activate :directory_indexes

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript
end

page "data/*", :layout => :data_layout

# Used for generating absolute URLs
set :protocol, "https://"
set :host, "considerveganism.com"

configure :development do
  (activate :livereload, :host => '127.0.0.1') if defined? Middleman::PreviewServer
  set :protocol, "http://"
  set :host, "localhost"
end

# Allow nesting markdown within html
set :markdown, parse_block_html: true

###
# Blog settings
###

# Time.zone = "UTC"

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "blog_article"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "blog/tag.html"
  blog.calendar_template = "blog/calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/{num}"
end

page "/feed.xml", layout: false

set :feed_url, "http://feeds.feedburner.com/ConsiderVeganism"

configure :development do
  set :feed_url, "/feed.xml"
end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
helpers do
  def host_with_port
    [config[:host], optional_port].compact.join(':')
  end

  def optional_port
    config[:port] unless (config[:port].to_i == 80 or config[:port].to_i == 443)
  end

  def absolute_url(relative_url)
    config[:protocol] + host_with_port + "/" + (relative_url[0] == '/' ? relative_url[1..-1] : relative_url)
  end

  def share_image_to(external_url, internal_url, title, description)
    share_links = {
      :twitter => "https://twitter.com/intent/tweet?url=#{CGI.escape(external_url)}&text=#{CGI.escape(title)}",
      :googleplus => "https://plus.google.com/share?url=#{CGI.escape(external_url)}",
      :tumblr => "https://www.tumblr.com/widgets/share/tool?posttype=photo&content=#{CGI.escape(external_url)}&caption=#{CGI.escape(title)}&canonicalUrl=#{CGI.escape(absolute_url("/"))}",
      :reddit => "https://www.reddit.com/submit?url=#{CGI.escape(external_url)}&title=#{CGI.escape(title)}",
      :vk => "http://vk.com/share.php?url=#{CGI.escape(external_url)}"
      # facebook doesn't have support for plain link image sharing via URL
    }
  end

  def share_link_to(url, title, description)
    share_links = {
      :facebook => "https://www.facebook.com/sharer/sharer.php?u=#{CGI.escape(url)}",
      :twitter => "https://twitter.com/intent/tweet?url=#{CGI.escape(url)}&text=#{CGI.escape(title)}",
      :googleplus => "https://plus.google.com/share?url=#{CGI.escape(url)}",
      :tumblr => "https://www.tumblr.com/widgets/share/tool?posttype=link&content=#{CGI.escape(url)}&canonicalUrl=#{CGI.escape(url)}&title=#{CGI.escape(title)}&caption=#{CGI.escape(description)}",
      :reddit => "https://www.reddit.com/submit?url=#{CGI.escape(url)}&title=#{CGI.escape(title)}",
      :vk => "http://vk.com/share.php?url=#{CGI.escape(url)}"
    }
  end

  @should_include_googlechart = false

  def needs_googlechart()
    return @should_include_googlechart
  end

  def uses_googlechart()
    @should_include_googlechart = true
  end

  def as_erb(string=nil)
    if block_given?
      (Tilt['erb'].new {yield}).render self
    else
      (Tilt['erb'].new {string}).render self
    end
  end

  def relative_to_root(source_file)
    source_path = Pathname.new source_file
    root_path = Pathname.new root
    source_path.relative_path_from root_path
  end

  def git_history(source_file)
    "https://github.com/squeek502/considerveganism.com/commits/master/#{relative_to_root source_file}"
  end

  def last_modified(source_file)
    Date.parse(`git log -1 --format="%ad" -- #{relative_to_root source_file}`.strip)
  end
end
