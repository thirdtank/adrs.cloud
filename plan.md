# Plan

## App

* Tags
* Search by tag
* Search by keyword
* Save draft async w/out leaving the page

## Framework

* How to deploy
* Asset hashing
* Centralize configuration and boot-up sequence
  - requiring the framework's rubygem should not perform any
    action

# Docs/Notes


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

