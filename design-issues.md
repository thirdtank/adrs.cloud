# Design Issues

## Framework stuff missing

X Better route definition
X Build out remaining HTML5 validations etc. - wait until use-cases arise?
X Set up Rack::Attack - need a cache and this is out of scope for now
X Something with CSP
X Fix chokidar/foreman
X Zeitwerk issues

## Second app ideas

- Med reminder - you enter in meds and times of day and it reminds you via SMS
  - Pros - very simple
  - Cons - Twilio integration is annoying

- Alimento TRES - dinner time only, but refocused on recurring meals
  - Pros - generally know what it needs to do
  - Cons - possibly complex?

- Cross-poster - monitors your mastodon account and x-posts to BlueSky
  - Pros - useful, has legs?
  - Cons - difficult to operate, API integration could be annoying

- Drum Machine - "analog" drum machine in browser that can save patches and patterns
  - Pros - fun to build, would be a good demo of front-end stuff
  - Cons - the most work

## Summarized Other Stuff

- How can I run Playwright in headed mode and reap its benefits?
- Import Maps for JS?  This won't eliminate need for building
- Instrumentation needs to be better thought through:
  - Nested spans
  - Reporting to some system
  - Ergonomic API
- Deployment is heroku-specific and very slow
  - build a somewhat canonical dockerfile?  No idea how to test that.
- Logging is inconsistent and maybe overlaps with instrumentation
- Beef up form validation in general. It feels alpha
- Can page/component testing be more ergonomic?
- Can test failures be made more ergonomic?
- Type conversions between DB and app?
- Authorization and Authentication - is there a way to make this better without forcing an implementation?

