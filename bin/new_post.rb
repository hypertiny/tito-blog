#!/usr/bin/env ruby

require 'date'
require 'optparse'
require 'highline/import'

options = {
  :title => nil,
  :date => Date.today.strftime("%Y-%m-%d")
}
OptionParser.new do |opts|
  opts.banner = 'Usage: new_post.rb --title "Hello World"'

  opts.on("-t", "--title [TITLE]", "Title") do |title|
    options[:title] = title
  end

  opts.on("-d", "--date [DATE]", "Date") do |date|
    options[:date] = date
  end

  opts.on("-a", "--author [AUTHOR]", "Author") do |author|
    options[:author] = author
  end
end.parse!

if options[:title].to_s.strip == ''
  options[:title] = ask("Title: ") { |q| q.echo = true }
end

if options[:tags].to_s.strip == ''
  options[:tags] = ask("Tags: ") { |q| q.echo = true }
end

if options[:author].to_s.strip == ''
  options[:author] = ask("Author: ") { |q| q.echo = true }
end

if options['author-img'].to_s.strip == ''
  options['author-img'] = ask("Author Image: ") { |q| q.echo = true }
end

filename = "#{options[:date]}-#{options[:title].downcase.gsub(' ', '-')}.markdown"
path = "_posts/#{filename}"

File.open(path, 'w') do |file|
  file.write %Q[---
layout: post
title:  "#{options[:title].gsub('"', '\"')}"
date:   #{options[:date]}
author: #{options[:author]}
author-img: #{options['author-img']}
tags: #{options[:tags]}
readingtime: 3
tags:
---
]
end

p path