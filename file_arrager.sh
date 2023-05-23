#!/bin/bash

# Requires inotify-tools package
#
# Authors: oddstap && yetanothergeek
#
# This simple tool takes newly created files in the Downloads directory
# and then organizes them based on file extension.

TARGET=$HOME/Downloads
inotifywait -m -e close_write -e moved_to --format "%f" "$TARGET" \
| while read FILENAME; do

  [ -s "$TARGET/$FILENAME" ] || continue

  EXT=${FILENAME##*.} # Extract file extension
  EXT=${EXT,,} # Convert to lowercase
  DEST_DIR=''

  case "$EXT" in

    # Word processor and text files
    doc|docx|odt|pdf|rtf|tex|txt|wks|wps|wpd)
      DEST_DIR="$HOME/Documents/Word_Processor_And_Text_files"
    ;;

    # Audio files
    mp3|wav|wma|mid|midi|aif|cda|mpa|ogg|wpl)
      DEST_DIR="$HOME/Music"
    ;;

    # Image files
    jpg|jpeg|png|ai|bmp|gif|ico|ps|svg|tif|tiff|psd)
      DEST_DIR="$HOME/Pictures"
    ;;

    # Video files
    avi|wmv|3g2|3gp|flv|h264|m4v|mkv|mov|mp4|mpg|mpeg|rm|swf|vob|wmv)
      DEST_DIR="$HOME/Videos"
    ;;

    # Compressed files
    7z|arj|deb|pkg|rar|rpm|gz|z|zip)
      DEST_DIR="$HOME/Documents/Compressed_Files"
    ;;

    # Disc and media files
    bin|dmg|iso|toast|vcd)
      DEST_DIR="$HOME/Documents/Disk_Images"
    ;;

    # Data and database files
    csv|dat|db|dbf|log|mdb|sav|sql|tar|xml)
      DEST_DIR="$HOME/Documents/Data_Database"
    ;;

    # Executable files
    apk|bat|cgi|pl|com|exe|gadget|jar|py|wsf)
      DEST_DIR="$HOME/Documents/Executable_File"
    ;;

    # Font files
    fnt|fon|otf|ttf)
      DEST_DIR="$HOME/Documents/Fonts"
    ;;

    # Internet related files
    asp|cer|cfm|css|htm|html|js|jsp|php|rss|xhtml)
      DEST_DIR="$HOME/Documents/Internet_files"
    ;;

    # Presentation files
    key|odp|pps|ppt|pptx)
      DEST_DIR="$HOME/Documents/Presentation"
    ;;

    # Programming files
    c|class|cpp|cs|h|java|sh|swift|vb)
      DEST_DIR="$HOME/Documents/Programming_Files"
    ;;

    # Spreadsheet files
    ods|xlr|xls|xlsx)
      DEST_DIR="$HOME/Documents/Spreadsheets"
    ;;

    # Anything else
    *)
      # TODO: handle any unrecognized files here
    ;;
  esac
  if [ "$DEST_DIR" = "" ] ; then
    # If we didn't find a place for this file, just skip it.
    continue
  fi
  # Now we should have our filename and our destination directory
  # So let's do it!
  mkdir -p "$DEST_DIR"
  chmod +w "$TARGET/$FILENAME"
  if ! [ -e "$DEST_DIR/$FILENAME" ] ; then
    mv "$TARGET/$FILENAME" "$DEST_DIR"
  else
    # Don't clobber existing files!
    # If we already have a "foo.txt", try "foo.txt.1.txt",
    # "foo.txt.2.txt", etc. If we can't find a unique name
    # after "foo.txt.99.txt" just give up -- the user can
    # deal with it later.
    N=0
    while [ $N -le 99 ] ; do
      if ! [ -e "$DEST_DIR/$FILENAME.$N.$EXT" ] ; then
        mv "$TARGET/$FILENAME" "$DEST_DIR/$FILENAME.$N.$EXT"
        break # Success!
      fi
      N=$((N+1))
    done
  fi
done
