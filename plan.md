# Plan

## App

* Tags
* Search by tag
* Search by keyword
* Save draft async w/out leaving the page

## Framework

* How to deploy
  - Assume a docker-based set up
  - Use multi-stage build to end up with only prod gems and generated assets
X Asset hashing
X Centralize configuration and boot-up sequence

# Docs/Notes

## Deployment

* Process is generally:
  1. Get source code
  2. Bring in third party deps
  3. Generate any code needing generating
  4. Run any database migrations
  5. Start up the app

* Assumed to be using Docker
* Framework support for deployment/docker will be somewhat abstracted

## Testing

* It must be easy to write tests
* Testing library must be simple
* Test results must be useful
* Tests must not be a DSL
* It must be possible to organize tests as follows:
  - Class
  - Method
  - Test cases per method
* Mocks and Stubs must be possible
* Tests must be taggable for arbitrary organization

## Documentation

* YARD


## Asset Pipeline

Other than generating HTML, a web page needs *assets*, which include CSS, JavaScript, images, and more.

The asset pipeline for Brut is based around several scripts:

* `bin/build` will process and bundle all assets. Generally, this defers to `build-css` and `build-js`.
* `bin/build-css` takes any source CSS and produces CSS bundles.  In addition, it writes an entry into `app/view/asset_metadata.json` for each bundle.  The entries will map the logical name of the bundle, e.g. `/css/styles.css` to the actual name that may include a content hash, like `/css/styles-987245iuhgsd.css`.
* `bin/build-js` takes any source JS and produces JS bundles.  In addition, it writes an entry into `app/view/asset_metadata.json` for each bundle.  The entries will map the logical name of the bundle, e.g. `/js/app.js` to the actual name that may include a content hash, like `/js/app-987245iuhgsd.js`.

### `app/view/asset_metadata.json`

This file stores the mappings of logical asset names to their actual names.  This file should not be checked into version
control.  It's format is as follows:

```javascript
{
    asset_metadata: {
        ".js": {
            «logical_name»: «actual_name»,
        },
        ".css": {
        },
        # etc.
    }
}
```

`build-css` owns and manages `".css"`.  `build-js` owns and manages `".js"`.

