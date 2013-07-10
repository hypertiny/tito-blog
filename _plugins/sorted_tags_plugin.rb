module Jekyll
  class SortedTagsBuilder < Generator
  
    safe true
    priority :high
 
    def generate(site)
      site.config['sorted_tags'] = site.tags.map { |tag, posts|
        [ tag, posts.size, posts ] }.sort { |a,b| b[1] <=> a[1] }
    end
 
  end
end