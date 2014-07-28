# TheFriendlyId

```ruby
class Post < ActiveRecord::Base
  include TheFriendlyId::Base
end

post = Post.new
post.title = "Привет"
post.save


post.title        # => "Привет"
post.slug         # => "privet"
post.short_id     # => "pt1263"
post.friendly_id  # => "pt1263+privet"

Post.friendly_where(:privet) # => [post ...]
Post.friendly_first(:privet) # => post
```

### MIT

zykin-ilya@ya.ru 2014
