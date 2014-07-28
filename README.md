# TheFriendlyId

```ruby
class SlugIds < ActiveRecord::Migration
  def change
    [:pages, :posts].each do |table_name|
      change_table table_name do |t|
        t.string :slug
        t.string :short_id
        t.string :friendly_id
      end
    end
  end
end
```

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
