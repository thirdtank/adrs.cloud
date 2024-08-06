# Bootstrapping

Two needs:

* Require (or make require-able) all app classes and config, without starting the app
* Do the same, but also start the app

## Boot Stages

* Require all ruby gems
* Require Brut
* Require the app code
* Configure the app
* start the app [ optional ]

### Require RubyGems

Use bundler in the normal way

### Require Brut

Until Brut is extracted, this must be done via

```ruby
$LOAD_PATH << File.join(__dir__,"lib") # or wherever points to the lib dir
require "brut"
```

### Require the app code

To do this, we must know the app root.  This must be derivable from any context and without the app itself having been
configured.


TBD


### Configure the app

```ruby
require "app"
App.new.configure_only!
```

### Start the app

TBD

