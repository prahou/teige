teige 
html image gallery written in ksh
==================================
Create and maintain an image gallery on your website.

teige [-h] [-v] [-bDFU] [-c config] [-e ID] [-r ID] file|url

Dependencies
============
teige needs ksh and ImageMagick to work as intended. It also
uses ftp to grab remote images with -U.

Options
=======
$ ksh teige -h

Anatomy of teige
================
teige exists on your website as a directory. In this directory
it keeps an index.html file and subdirectories for each posted
image with their image files and index.html.

ImageMagick currently does three things. Checks that the input
file is an image, resizes posted images to create a preview and
optionally blurs the preview if flag -b is supplied.


Initialization
==============
Before running the script for the first time (see Run section,)
you can edit it with your favorite editor. Notably this is where
you can change a path to where teige looks for its config.

USERVAR		Path to a configuration file.
		Default: $HOME/.teige.conf

But you do not need to edit anything inside the script for it to
work. Run teige for the first time without any arguments. This 
will generate a configuration file.

Configuration
=============
Before going any further, open this file with your favorite editor
and fill in the required variables. The file itself is commented
and contains examples: 

WROOT		Full path to a website's root directory.
		ie: /var/www/htdocs/www.website.cz or
		/home/marek/public_html

WEB		Relative path to teige's directory inside $WROOT.
		Default: teige.

WEBSITE		Url of your website. This is only printed after using
		teige to get a quick link to the post in the form
		$WEBSITE/$ID. 

teige will create new posts in $WROOT/$WEB. The user running teige
needs write and read permissions on $WEB.

PROFILOVKA	Path to a profile picture.

CSS		Path to a css style sheet. teige comes with
		a default style sheet gal.css. By default 
		it expects it in $WROOT/ (you have to put it 
		there yourself.)

WEB		Root of teige's gallery. 'teige' by default. teige
		needs write and read permissions on this directory.
		ie: teige #which would be website.cz/teige

NAME		String. Title of your gallery.

MOTTO		String. Subtitle of your gallery.

BIO		String. A single paragraph description.

TAGS		OPTIONAL string of html keywords.
		These are used for $WEB/index.html
EDITOR		Your prefered program for editing.

The configuration file serves both as a takeoff point for teige
and an easy way to modify one's profile picture, bio and subtitle 
(MOTTO). Anytime you change any of these variables, run teige without
any arguments and it will update the the index of your gallery. 

If everything went well, after running teige for the second time 
(after modifying the $USERVAR) you should find its index file in
$WROOT/$WEB.

Run
===
run teige with:

	ksh teige

The rest of this README suggests you run teige with ksh teige, or
place it in your $PATH.

Options
=======
usage: teige [-h] [-v] [-bDF] [-c config] [-r ID] [-a] [file]

-h              Display this help text.

-v              Displays version information.

-c file         Load different configuration file.

-b              Blur preview of a posted image.

-D              Display debugging messages.

-e ID           Edit by ID.

-F              Force rebuild of entire gallery.

-r ID           Remove image by ID. This removes the post
                from both the $WROOT/$WEB and $LOCAL 

Usage
=====
If everything goes smooth, all you ever need to do is run

	$ teige file (where file is an image file)

This checks that the file exists and if it does, proceeds to
ask the user for a TITLE, which is the h1 of the new post,
IMGALT, which is the alt= option of the img, and DESC, which 
is a paragraph description of your post. 

Next it creates a resized copy to use for a preview image
and copies the original to $WROOT/$WEB/$ID.

If you find yourself editting the html part of teige and want
to apply it to every previously posted image, use the -b flag.

The -b option blurs the preview of your post.
