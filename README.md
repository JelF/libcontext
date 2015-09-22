# libContext

libContext is a library for manipulating dynamic variables. 
Contexts are thread local right now, but forking would be implemented

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'libcontext'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install libcontext

## Usage

See `spec/context/context_spec` for more usage examples.

```ruby
  class User < ActiveRecord::Base
    def mutate!
      update! loves: Gem.last
      # TODO: use fetch in this example when it would be implemented
      loves.validate! if Context[:validate_associations]
    end
  end

  result = Context.set(validate_associations: true).pluck(:users_count) do
    User.transaction do
      Context[:users_count] = Users.count
      raise unless Context[:users_count] > 10
      User.last.mutate!
    end
  end
  
  puts result # => Actual users count
```

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `bin/rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jelf/libcontext. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

