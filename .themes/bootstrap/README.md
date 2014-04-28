# Bootstrap theme

## Prerequisites

Please check that you have a recent version of [compass](http://compass-style.org/) installed in octopress' bundle
(see Gemfile.lock in your octopress directory and run bundle update if necessary), otherwise, you might get errors
similar to those reported in issue #7. Compass version 0.12.1 is known to work.

## Installation

     $ git clone git://github.com/bkutil/bootstrap-theme.git bootstrap-theme

Copy the bootstrap-theme into your blog's octopress .theme directory:

     $ cp -R bootstrap-theme $MY_OCTOBLOG/.themes/bootstrap

Currently, version of sass least 3.2 is needed due to requirements of [twitter-bootstrap-sass](https://github.com/jlong/sass-twitter-bootstrap):

     $ gem list| grep sass
     sass (3.2.4)

To update, run ````bundle update sass```` in your octopress directory. Make sure to *remove the older versions of sass*,
as compass might pick one of those up and site generation would fail.

     $ bundle update sass
     $ gem remove sass -v3.1.20

Install the theme and generate site:

     $ rake install['bootstrap'] (rake install[bootstrap] if you are using zsh)
     $ rake generate

## Code snippet colors

Theme utilizes the solarized color scheme for code snippets. By default, the
bootstrap variant is selected, but light/dark colors can be used by setting
the $solarized variable in sass/syntax/\_higlight.scss.

## Patches welcome!

This is a first draft only. Any ideas, suggestions or improvements are welcome.

## Demo

Latest code from master branch is running at this [demo site](http://bootstrap-theme.kutilovi.cz/).
