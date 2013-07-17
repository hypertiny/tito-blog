## Deploying

Install `s3cmd`

    brew install s3cmd

Configure s3cmd

    s3cmd --configure

Run the upload script:

    ./upload

Adding a post:



Code Sample:

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