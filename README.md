sacredheartsc.com
=================

This repository contains the source for [www.sacredheartsc.com](https://www.sacredheartsc.com).
It consists of Markdown files and a custom static site generator using pandoc and BSD make.

# Requirements

- coreutils
- python3
- pandoc
- BSD make

# Instructions

First, install the `pip` requirements:

    make deps

You'll want to edit the [Makefile](Makefile) to set your site URL,
RSS feed title, etc.

Then, start writing markdown documents in the `src` directory. You can use
whatever naming convention and directory structure you like. Files ending in
`.md` will be converted to `.html` with the same path.

The `src/blog` directory is special. Markdown files in this directory are
used to populate the front-page blog listing in [index.md](src/index.md).
Before pandoc converts this file to HTML, the special string `__BLOG_LIST__`
is replaced with the output of [bloglist.py](scripts/bloglist.py).
This Python script produces a date-sorted markdown list of all your blog posts.

Each markdown file can have YAML frontmatter with the following metadata:

    ---
    title: A boring blog post
    date: YYYY-MM-DD
    subtitle: an optional subtitle
    heading: optional, if you want the first <h1> to be different from <title>
    description: optional, short description for <head> and the blog listing
    draft: if set, hides the post from the blog listing
    ---

You can change the resulting HTML by modifying the [template](templates/default.html).
Changing the format of the blog listing requires modifying the Python script.

Build the website by using the default target:

    make

This will create a directory called `public` containing all your markdown files
rendered to HTML.

You also can run a local webserver, which listens on port 8000, using:

    make serve
