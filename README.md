# RecipeRadar Internationalization

Internationalization tools and content for RecipeRadar.

## How it works

The RecipeRadar [frontend](https://github.com/openculinary/frontend) application contains placeholders where human-readable text strings should appear.  For example, the [`search:prompt-get-started`](https://github.com/openculinary/internationalization/blob/7c9068f3ea5072a4e6f49efe7178a345b158b5a9/locales/templates/search.pot#L29-L30) label in the application will be filled by instructions to help users begin using the application.

This repository contains [gettext](https://www.gnu.org/software/gettext/) files that contain the list of placeholder labels (in `.pot` files), and the corresponding machine-or-human-translated strings to fill those slots (in `.po` files).

When developers are working on a feature that requires updated translations, they run a [translation resource scan](https://github.com/openculinary/frontend#internationalization) to regenerate the templates.

Default machine-translated strings for each placeholder in each language are provided by [apertium](https://www.apertium.org/), and human experts can provide improved translations.  Expert-provided translations are stored [arranged by language under the `corrections` directory](https://github.com/openculinary/internationalization/tree/main/locales/corrections).

A script is provided to combine all current human corrections with the latest machine-translated strings:

```sh
$ ./translation-routing.sh
```

Finally, a developer performs a build of the [`frontend`](https://github.com/openculinary/frontend) application -- which includes a copy of this repository as a [git submodule](https://github.com/openculinary/frontend/blob/85cafd48bf5d7bf840aff0a545c969a9eea6e554/.gitmodules) -- and the templates are bundled into the application by the [`webpack` configuration](https://github.com/openculinary/frontend/blob/85cafd48bf5d7bf840aff0a545c969a9eea6e554/webpack.config.js#L21).

## Workflow summary

- A feature or change to the application requires internationalization
- The translation resource scan collects updated placeholders
- Machine translation generates 'default' per-language strings
- Human corrections override specific placeholders
- Updated templates and translations are committed to this repository
- The application is rebuilt using the updated translations

When the feature and translations are ready, pull request(s) are opened to offer the suggested changes for review and merge.
