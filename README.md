# Navigation

Generates and edits navigation menus.

## Installation

Install the gem as usual

```ruby
gem "katalyst-navigation"
```

Mount the engine in your `routes.rb` file:

```ruby
mount Katalyst::Navigation::Engine, at: "navigation"
```

Add the Gem's migrations to your application:

```ruby
rake katalyst_navigation:install:migrations
```

Add the Gem's javascript and CSS to your build pipeline. This assumes that
you're using `propshaft` and `importmaps` to manage your assets.

```javascript
// app/javascript/controllers/application.js
import { application } from "controllers/application";
import navigation from "@katalyst/navigation";
application.load(navigation);
```

Import the styles as css:

```css
@import "/katalyst/navigation.css";
```

Or, if you're using `dartsass-rails`:

```scss
// app/assets/stylesheets/application.scss
@use "katalyst/navigation";
```

## Usage

See the dummy app for examples.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katalyst/navigation.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
