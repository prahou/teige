# teige
pure html web gallery manager written in ksh

*teige [-h] [-v] [-bDFU] [-c config] [-e ID] [-r ID] file|url*

## Dependencies
teige needs ksh and ImageMagick to work as intended. It also
uses ftp to grab remote images with -U.

## Anatomy of teige
teige exists on your website as a directory. In this directory
it keeps an index.html file and subdirectories for each post
with their image files and index.html.

ImageMagick currently does three things. Checks that the input
file is an image, resizes posted images to create a preview and
optionally blurs the preview if flag -b is supplied.

## Initialization
run: **$ ksh teige.ksh**

Run teige for the first time without any arguments. This
will generate a configuration file.

## Configuration
By default, teige creates its configuration file in $HOME/.teige.conf

Before you can use teige, you must edit this file. If it does not
exist, run teige without any arguments. 

The configuration file is generated with commented sections and parts
to guide you. Consult the file README.txt for more information.

The configuration file serves both as a takeoff point for teige
and an easy way to modify one's profile picture, bio and subtitle
(MOTTO). Anytime you change any of these variables, run teige without
any arguments and it will update the the index of your gallery.

## Usage
If everything goes smooth, all you ever need to do is run:

**$ teige file** (where file is an image file)

This checks that the file exists and if it does, proceeds to
ask the user for a TITLE, which is the h1 of the new post,
IMGALT, which is the alt= option of the img, and DESC, which
is a paragraph description of your post. 

Next it creates a resized copy to use for a preview image
and copies the original to $WROOT/$WEB/$ID.

If you find yourself editting the html part of teige and want
to apply it to every previously posted image, use the -b flag.

[triapul.cz/teige](https://triapul.cz/teige)
