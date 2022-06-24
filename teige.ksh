#!/bin/ksh
USERVAR="$HOME/.teige.conf" 	#path to default config file. If it doesn't exist
				#running teige for the first time will create it.

DATE=$(date "+%Y-%m-%d") #date shows up underneath a picture on its individual site
			 #choose any format you'd like. Default is YYYY-MM-DD
DATE2="$(date -u "+%a, %d %b %Y %H:%M:%S +0000")" #date for RSS feeds in UTC
LANG="en-US" #Used in html header. Change to whatever language you want post in.

#FUNCTIONS
#ID generator

#Each image has a unique ID that is generated here.
#B default, teige uses only $(date +%s) for its generation of post IDs.
#This is a personal choice and a silly habit, where using Unix time is an easy
#method of sorting posts. Since teige does currently sort posts by IDs, see
#FORCE REBUILD section, if you choose to change the ID generation method.

#Every post gets a unique ID.
rando() {
print $(date +%s)
}

#my particularly vintage method
#rando() {
#REM=$(print -n $(date +%s))
#IDTR=$(print -n "$(head -n15 /dev/urandom | tr -dc "123456abcdef" | tail -c2)")
#ID=$(print -n $REM$IDTR)
#print $ID
#}

FIRSTRUN() {
#generate configuration file
touch $USERVAR || print "Can't create configuration file!"
cat <<.> $USERVAR
#Path to the root of web. YOU MOST PROBABLY WANT TO CHANGE THIS 
#leave it to test teige offline
WROOT=/home/$USER/site	 

#Web directory of teige in \$WROOT. By default, teige places itself 
#in \$WROOT/teige. user running teige must have write and read 
#access to this directory.
WEB=teige	

#Local directory where teige stores data for 
#rebuilding the site.
#note that changing this after you've began using teige
#will cause issues unless you move its contents as well
LOCAL=/home/$USER/.teige 

#After posting an image, teige will print its URL in the format:
#\$WEBSITE/\$ID.
WEBSITE="http://website.cz"	

#path to a profile picture. either a full path from \$WROOT or "URL".
PROFILOVKA=

#css style sheet to use for html generation. either a full path from \$WROOT or URL.
CSS=/gal.css	

NAME="My Name"		#h1 in \$WEB/index.html
MOTTO="A heading"	#h2 in \$WEB/index.html
BIO="This is a bio"	#single paragraph on \$WEB/index.html
EDITOR="vi"	#editor to use for editing posts

#PROFILOVKA=/img/profile.png #Profile picture is in website.cz/img/profile.png
#CSS=/gal.css		#style sheet is in website.cz/gal.css
#WEB=teige	#teige gallery is in website.cz/teige
.
print "You can find your configuration in $USERVAR"
print "That's where you can change everything."
print "Edit the file, then run teige without any arguments,"
print "it will generate the gallery in  \$WROOT/\$WEB"
}

HELP() {
cat <<.
$USAGE

Running teige without any flags or arguments refreshes index.html.

-h		Display this help text.

-v		Displays version information.

-c file 	Load different configuration file.

-b		Blur preview of a posted image.

-e ID		Edit by ID.

-F		Force rebuild of entire gallery.

-r ID		Remove image by ID. This removes the post
		from both the \$WROOT/\$WEB and \$LOCAL

-U		Teige will expect a URL instead of a 'file'
.
}

USAGE="usage: teige [-h] [-v] [-bFU] [-c config] [-e ID] [-r ID] file|url"

VERSION() {
print "teige is a simple pure html image gallery manager."
print "teige 1"
print "Written by Tomáš Rodr in 2022." 
print "https://triapul.cz/teige"
}

while getopts :hvDbc:e:Fp:r:U FLAG; do
	case $FLAG in
	h) HELP;exit;;
	v) VERSION;exit;;
	D) DEBUG=1;;
	b) BLUR=1;;
	c) FCONF=1;CONF=$OPTARG;;
	e) FEDIT=1;ID=$OPTARG;;
	F) FBUILD=1;;
	p) FPRE=1;PREVFILE=$OPTARG;;
	r) FREMOVE=1;ID=$OPTARG;;
	U) FURL=1;;
	\?) print "Invalid flag";print $USAGE;exit;;
	:) print "Invalid flag.";
	   print "$USAGE";;
	esac
done


if (( FCONF == 1 )); then 
USERVAR="./$CONF"
fi

if [[ ! (-a $USERVAR) ]]; then
FIRSTRUN
exit
fi

#LOAD CONFIG
. $USERVAR

#Paranoid checks 
if [[ ! (-d $WROOT/$WEB) ]]; then 
mkdir -p $WROOT/$WEB || print "Path to website $WROOT/$WEB doesn't exist and I can't create it..";
touch
exit;fi
if [[ ! (-d $LOCAL) ]]; then 
mkdir -p $LOCAL || print "Directory for local data doesn't exist and I can't create it."
touch $LOCAL/feed.txt || exit
fi

#teige needs a local offline directory..
if [[ ! (-d $LOCAL) ]]; then mkdir $LOCAL || print "teige needs an accessible local directory!"; 
touch $LOCAL/feed.txt || exit
fi


#BEGIN
build() {
if (( SWITCH == 0 )); then
MOTTO=$DESC
fi

#  <link rel="alternate" type="application/rss+xml" href="$RSS"/>
# for future versions and integration with rss...

# keep in mind you can edit the build() function however you want to reflect your
# desired html code. Do not uncomment these! 
# <link rel="icon" type="image/x-icon" href="$FAVICON"/>
# <meta name="keywords" content="$TAGS"/>

cat <<.
<!doctype html>
<html lang="$LANG">
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <meta charset="utf-8"/>
  <meta name="description" content="$MOTTO"/>
  <link rel="stylesheet" type="text/css" href="$CSS?v=$RANDOM"/>
<title>$TITLE</title>
</head>
<body>
.
if [[ $SWITCH != 0 ]]; then
# uncomment if you want a link somewhere at the top of teige's index.html.
# for example 
:
#cat <<. 
#<a href="../">go up</a>
#.

else
#change 'back' to whatever you want your back link to say. This returns you from a post
#to teige's root. 
cat <<.
<a href="../#$ID" class="zpet-link">back</a>
.
fi

#$NAME from user config gets put here on /index.html
cat <<.
<h1>$TITLE</h1>
.

if [[ $SWITCH != 0 ]]; then
cat <<.
<img class="profilovka" src="$PROFILOVKA" alt="profile picture">
<h2>$MOTTO</h2>
.
fi
if [[ $SWITCH = 0 ]]; then
print "<p>$DESC</p>"
else
print "<p>$BIO</p>"
fi

if [[ $SWITCH = "0" ]]; then
cat <<.
<img src="$IMG" alt="$IMGALT" class="full-img">
.
elif [[ $SWITCH = "1" ]]; then 
print "<a class=\"gal-link\" href=\"$ID\"><img src=\"$ID/$PREVIEW\" alt=\"$IMGALT\" class=\"preview\" id=\"$ID\"></a>" >> $LOCAL/feed.txt
sort -r $LOCAL/feed.txt

elif [[ $SWITCH = "3" ]]; then
sort -r $LOCAL/feed.txt
fi

if [[ $SWITCH = "0" ]]; then
#The ID beneath $DATE serves as a permanent link to your post. It will probably not work if you're using teige locally offline.
cat <<.
<p class="datum">$DATE</p>
<a href="/$WEB/$ID" class="id">$ID</a>
.
fi

cat <<.
</body>
</html>
.
}
NEWPOST=0

#SWITCH=3 builds /index and changes nothing else
#SWITCH=0 builds a post
#SWITCH=1 updates /index and adds entry to $LOCAL/feed.txt

#REMOVE A POST
if (( FREMOVE == 1 )); then
if [[ ! ( -d $WROOT/$WEB/$ID) ]]; then print "bad ID";exit; else
SWITCH=3
read x?"Delete this? $WROOT/$WEB/$ID (y?)"
if [[ $x = [yY] ]]; then
rm $WROOT/$WEB/$ID/*
rm -r $WROOT/$WEB/$ID
sed -i /$ID/d $LOCAL/feed.txt 
if [[ ! ( -a $LOCAL/$ID.var) ]]; then print "Local file $ID doesn't exist.";exit; else
rm $LOCAL/$ID.var
print "Post is removed."
. $USERVAR
build > $WROOT/$WEB/index.html
fi
fi
exit
fi
fi

#FORCE REBUILD OF ENTIRE TEIGE GALLERY
if (( FBUILD == 1 )); then
:> $LOCAL/feed.txt
#this is where you might run into unforeseen consequences if you use a custom ID generator.
#Here teige will by default use sort -br on your posts to regenerate its index.html
#change accordingly, if you use a custom ID gen!
for i in $(ls $LOCAL | sort -br); do
if [[ $i = "feed.txt" ]]; then :; else
SWITCH=0
. $LOCAL/$i
print "rebuilding $ID $TITLE"
build > $WROOT/$WEB/$ID/index.html
print "<a class=\"gal-link\" href=\"$ID\"><img src=\"$ID/$PREVIEW\" alt=\"$IMGALT\" class=\"preview\" id=\"$ID\"></a>" >> $LOCAL/feed.txt
fi
done
SWITCH=3
. $USERVAR
TITLE="$NAME"
build > $WROOT/$WEB/index.html
exit
fi

#EDIT A POST
if (( FEDIT == 1 )); then
$EDITOR $LOCAL/$ID.var
SWITCH=0
. $LOCAL/$ID.var
build > $WROOT/$WEB/$ID/index.html
exit
fi

SWITCH=0
(( START = OPTIND - 1 ))
shift $START

if (( DEBUG == 1 )); then
print "$START"
print "OPTIND: $OPTIND $*"
print "flag 1: $1"
read
fi

if [[ $* = "" ]]; then
SWITCH=3
. $USERVAR
TITLE="$NAME"
build > $WROOT/$WEB/index.html
exit
fi

PROCK="$*"
ID=$(rando)

if (( FURL == 1 )); then
ftp -o .temp$ID "$PROCK"
PROCK=.temp$ID
fi

if [[ ! (-a $PROCK ) ]]; then print "Image $PROCK does not exist."; exit; fi
identify $PROCK 1>/dev/null || print "Not an image."
NEWPOST=1
read TITLE?"Title of your post? "
read IMGALT?"Desctiption of image? (img alt=)  "
read DESC?"Text on your post? "


mkdir $WROOT/$WEB/$ID

#IMG IS A GIF
if [[ $PROCK = *[Gg][iI][fF] ]]; then
convert -resize 150x150 $PROCK $WROOT/$WEB/$ID/$ID-preview.gif #GIFS are currently... not much cared for.
cp $PROCK $WROOT/$WEB/$ID/$ID.gif
IMG="$ID.gif"
PREVIEW="$ID-preview.gif"
else

#IMG IS NOT A GIF
if (( BLUR == 1 )); then
#BLUR
convert $PROCK -resize 150x150^ \
 -blur 0x3 \
 -gravity Center  \
 -crop 150x150+0+0 +repage \
 $WROOT/$WEB/$ID/$ID-preview.png #OUTPUT

cp $PROCK $WROOT/$WEB/$ID/$ID.png
IMG="$ID.png"
PREVIEW="$ID-preview.png"

else
#NOBLUR
convert $PROCK -resize 150x150^ \
 -gravity Center  \
 -crop 150x150+0+0 +repage \
 $WROOT/$WEB/$ID/$ID-preview.png #OUTPUT
cp $PROCK $WROOT/$WEB/$ID/$ID.png
IMG="$ID.png"
PREVIEW="$ID-preview.png"
fi
fi

build > $WROOT/$WEB/$ID/index.html
#store vars locally for rebuilding the gallery
if (( NEWPOST == 1 ));then
cat <<.> $LOCAL/$ID.var
ID="$ID"
IMG="$IMG"
PREVIEW="$PREVIEW"
IMGALT="$IMGALT"
TITLE="$TITLE"
DESC="$DESC"
DATE="$DATE"
DATE2="$DATE2"
.
NEWPOST=0
fi

SWITCH=1
. $USERVAR
TITLE="$NAME"
build > $WROOT/$WEB/index.html

if (( FURL == 1 )); then
rm $PROCK
fi


print $WEBSITE/$WEB/$ID
