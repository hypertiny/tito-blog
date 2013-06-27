---
layout: post
title:  Using Twitter's API to sort friends / followers alphabetically
date:   2009-03-24
author: Paul Campbell
readingtime: 3
tags:   code test
---

One of the reasons I set up this tumble-loggy blog, rather than stick with a regular blog, was so that I could share little snippets of code every so often, related to the stuff I was working on.

That's why I was delighted when [Jon Crawford](http://joncrawford.com/) ([NewMonarch](http://twitter.com/newmonarch)) on Twitter asked me this:

> I need to grab a Twitter user’s followers on the fly. As you probably know, the friends list isn’t returned in alphabetical order. Instead it’s returned in the order of which you started following the user, 100 results as a time. I’d prefer that the results were returned in alphabetical order by screen_name.

I like this kind of request, because it's one I know the answers to!

Since the beginning, Twitter has provided [friends / followers](http://apiwiki.twitter.com/REST+API+Documentation#UserMethods) methods for getting a list of a Twitter user's friends or followers. These methods have been damned to hell though, because they only report back 100 users at a time. Worse, they send back all manner of extra data, such as the latest tweet and in depth profile information. This meant for a lot of wasteful traffic back and forth to the API, and crucially lots of requests, eating up your API limit.

This was a particular bone of contention for an app like [Qwitter](http://useqwitter.com/). For someone like [Gary Vaynerchuk](http://www.twitter.com/garyvee) for example, with tens of thousands of followers, we'd have to make hundreds of requests to the api just to get a list of Twitter follower IDs. A fun programming exercise, no doubt, but seriously inefficient.

At the beginning of February, Twitter released two methods that mark a change in the game for Twitter API developers: their [social graph methods](http://apiwiki.twitter.com/REST+API+Documentation#SocialGraphMethods).

Essentially, these methods let you download an entire friends list or followers list in a single API call:

    curl http://twitter.com/friends/ids.xml?user_id=1401881

It just returns a list of IDs, but it's massively more efficient than making lots and lots of calls to the API, particularly for Qwitter.

For Jon Crawford's problem, it marks the beginnings of a solution. Because Qwitter compares the differences in two lists of IDs, we don't rely on associating usernames with IDs.

Here's a script that returns an array of friends sorted in alphabetical order. I've used [John Nunemaker](http://addictedtonew.com/)'s excellent [Twitter gem](http://github.com/jnunemaker/twitter/tree/master).

{% highlight ruby linenos %}
  require 'twitter'

  # your Twitter credentials
  twitter_username = ''
  twitter_password = ''

  # the user you'd like to check friends / followers for. Set to nil, or omit for your own list
  search_user = ''

  client = Twitter::Base.new(twitter_username,twitter_password)

  sorted_friends = client.friend_ids.map {|id| c.user(id).screen_name}.sort
  sorted_friends = client.follower_ids.map {|id| c.user(id).screen_name}.sort
{% endhighlight %}

The big problem with this script is that it's actually more inefficient than paging through 100 followers at a time, as it makes one API request per user. Perhaps for the first run of a user, something like this would be better:

{% highlight ruby linenos %}
  require 'twitter'
   
  # your Twitter credentials
  twitter_username = ''
  twitter_password = ''
   
  # the user you'd like to check friends / followers for. Set to nil, or omit for your own list
  search_user = ''
   
  client = Twitter::Base.new(twitter_username,twitter_password)
   
  page = 1
  full_friends_list = []
  loop do
    begin
      puts "fetching page #{page}"
      followers = c.followers_for(search_user, :page => page)
      full_friends_list += followers.map { |u| u.screen_name }
      break if followers.empty?
      page = page + 1
    rescue
      break
    end
  end
   
  full_friends_list.sort
{% endhighlight %}

Then keep a cache of usernames and associate them later. It all really depends on your needs.