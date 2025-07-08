# adrs.cloud - Example Brut App

This is a fully-functioning [Brut](https://brutrb.com)-powered app to manage
Architecture Decision Records.

It demonstrates much of what Brut can do.

## Try It

(Not yet available online)

## Run It Locally

1. Install Docker
2. Pull down this Repo
3. `dx/build` to build an image that will run this code inside Docker
4. `dx/start` to start a container with that image, plus other containers for
   Postgres, Sidekiq, and OTel
5. In another terminal:
   1. `dx/exec bin/setup` - this will install all gems and set the app up inside the
      container.
   2. `dx/exec bin/ci` - run all tests and quality checks.
   3. `dx/exec bin/dev` - then go to http://localhost:6504
   4. Click "Dev Login"
   5. Enter `pat@example.com`
   6. Enjoy!
