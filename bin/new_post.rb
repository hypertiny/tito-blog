#!/usr/bin/env ruby

require 'date'
require 'optparse'
require 'highline/import'

options = {
  :title => nil,
  :date => Date.today.strftime("%Y-%m-%d"),
  :author => ENV['USER']
}
OptionParser.new do |opts|
  opts.banner = 'Usage: new_post.rb --title "Hello World"'

  opts.on("-t", "--title [TITLE]", "Title") do |title|
    options[:title] = title
  end

  opts.on("-d", "--date [DATE]", "Date") do |date|
    options[:date] = date
  end

  opts.on("-u", "--user [USER]", "User") do |user|
    options[:user] = user
  end
end.parse!

if options[:title].to_s.strip == ''
  options[:title] = ask("Title: ") { |q| q.echo = true }
end

filename = "#{options[:date]}-#{options[:title].downcase.gsub(' ', '-')}.markdown"
path = "_posts/#{filename}"

File.open(path, 'w') do |file|
  file.write %Q[---
layout: post
title:  #{options[:title]}
date:   #{options[:date]}
author: #{options[:author]}
readingtime: 3
tags:
---
]
end

p path