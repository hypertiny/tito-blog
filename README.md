# The Tito Blog

## Setup
The tito blog is powered by Siteleaf so if you need to run it locally to update the theme you should install their gem.

```
gem install siteleaf
```

Once this is done you can run in the tito-blog repo
```
siteleaf config blog.tito.io
```

## Making changes to the theme

If you need to change or update the theme you can do so easily. The procedure should be   

1. Make changes
2. Commit and push to GitHub
3. Push to Siteleaf

To push to Siteleaf type
```
siteleaf push theme
```

### Ignoring Files
Siteleaf pushes whatever changes you have made in the directory but sometimes you may have added things that the theme doesn't need for it to render correctly such as readme's, sass files or 


## Posts
There are some advanced things you can do with the posts to extend the basic functionality

### Add guest author
Currently the theme pulls from the defined authors from within Siteleaf but this doesn't allow for guest authors to be added without granting them full access and then needing to revoke their access later.  

The solution to this is to add the meta field "guest-author" to the post where you can set the authors name.

To add an avatar, upload a 100px x 100px image in the assets section of the post. Then hover over the uploaded image and click on the "i". It will bring up the asset properties modal.

Add an asset meta field called "avatar-url" and set the value to the path at the top of the modal (this is probably a stupid way of doing it but it works for now).