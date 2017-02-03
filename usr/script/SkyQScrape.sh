#!/bin/bash
# SCRIPT: SkyQScrape.sh
#
# Scrapes multiple public websites for film and TV image resource links.
# Parse and rewrite image URLS to files as rsz.io links for SkyQPicks.sh
# to query and download random images for SkyQ show bouquet screen.
#
# Script may be called with no args to download all, or with one or more
# filenames as args, in which case only those specified are downloaded.
# (Allows invocation via SkyQPicks.sh for out-of-date file updating).
#
# TODO: .  Due to the specific nature of the regex used to pull out the image
#          links from each site, a minor change to a source site could result
#          in empty files being created until this script is updated to
#          reflect the source site changes.
#          It could be better for this script to be run in a central location
#          so that this change is only made once by a single maintainer, and
#          for SkyQPicks.sh to pull the lists down from that central location
#          instead of relying on the local output of this script. File 'ages'
#          could be used in SkyQPicks.sh in order to prevent excessive d/ls.
#       .  Although /usr/script/scrapes seems to have become the facto standard
#          location for the image URL lists this doesn't fit with the purpose
#          of this dir. A dir within the '/usr/share/...' structure, ideally
#          within skin folder's 'Toppicks' dir itself is preferable.

# IF WGET SUPPORTS IT WE CAN UNCOMMENT EITHER OR BOTH OF THE FOLLOWING OPTIONS
# TO MAKE TRAFFIC FROM SITE SCRAPING LOOK LIKE 'NORMAL' WEB TRAFFIC
#referer='--referer="https://www.google.com/"'
#agent='--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36"'

workdir="/usr/script/scrapes"		# PREFER: /usr/share/enigma2/SkyQ/Toppicks/scrapes
image_lists="new.txt store.txt premieres.txt living.txt one.txt atlantic.txt cinema.txt sports.txt"

# If no filename passed on commmand line, then run for all files
if [ $# == 0 ]; then
  /bin/bash ${0} ${image_lists}
  exit 0
fi

if [ ! -d "${workdir}" ]; then
  mkdir -p "${workdir}" || exit 1
fi

while [[ $# -gt 0 ]]; do
  case ${1} in
    new.txt)       echo -n "Scraping Sky Coming-soon... "
                   wget -q ${agent} ${referer} "http://www.sky.com/tv/channel/skycinema/gallery/coming-soon-to-sky-cinema-premiere" -O -| \
                   grep -Eo "http://www.asset1.net/tv/pictures/movie/[a-zA-Z0-9./?=_-]*.jpg" | uniq | grep -ve "LB" -ve "do-not-publish" | \
                   sed 's/asset1.net/asset1.net.rsz.io/g' > ${workdir}/${1}
                   [ -s ${workdir}/${1} ] && echo " -> ${1} OK" || echo " -> ${1} no valid links"
                   ;;
    store.txt)     echo -n "Scraping DVD Chart... "
                   wget -q ${agent} ${referer} "http://www.officialcharts.com/charts/dvd-chart/" -O -| \
                   grep -Eo "//ecx.images-amazon.com/images/I/[a-zA-Z0-9./?=_-]*.jpg" | uniq | \
                   sed 's_^//ecx.images-amazon.com_http://ecx.images-amazon.com.rsz.io_g' > ${workdir}/${1}
                   #echo -n "Scraping DVD Releases... "
                   #wget -q ${agent} ${referer} "http://www.zavvi.com/dvd/latest-releases.list" -O -| \
                   #grep -Eo "//[a-zA-Z0-9./?=_-]*.thcdn.com/productimg/[a-zA-Z0-9./?=_-]*.jpg" | uniq | \
                   #sed 's/thecdn.com/thecdn.com.rsz.io/g;s_^//_http://_g' > ${workdir}/${1}
                   [ -s ${workdir}/${1} ] && echo " -> ${1} OK" || echo " -> ${1} no valid links"
                   ;;
    premieres.txt) echo -n "Scraping Sky New Premieres... "
                   wget -q ${agent} ${referer} --no-check-certificate "https://www.sky.com/watch/channel/sky-cinema/new-premieres" -O -| \
                   grep -Eo "https://images.metadata.sky.com/pd-image/[a-zA-Z0-9./?=_-]*" | uniq | \
                   sed 's_https://images.metadata.sky.com_http://images.metadata.sky.com.rsz.io_g' > ${workdir}/${1}
                   [ -s ${workdir}/${1} ] && echo " -> ${1} OK" || echo " -> ${1} no valid links"
                   ;;
    living.txt)    echo -n "Scraping Sky Living... "
                   wget -q ${agent} ${referer} --no-check-certificate "https://www.sky.com/watch/channel/sky-living" -O -| \
                   grep -Eo "(https://www.sky.com/assets2/[a-zA-Z0-9./?=_-]*(jpg|png))|(https://dm8eklel4s62k.cloudfront.net/images/small/[a-zA-Z0-9./?=_-]*(jpg|png))" | uniq | \
                   sed 's_https://www.sky.com_http://www.sky.com.rsz.io_g;s_https://dm8eklel4s62k.cloudfront.net_http://dm8eklel4s62k.cloudfront.net.rsz.io_g' > ${workdir}/${1}
                   [ -s ${workdir}/${1} ] && echo " -> ${1} OK" || echo " -> ${1} no valid links"
                   ;;
    one.txt)       echo -n "Scraping Sky One... "
                   wget -q ${agent} ${referer} --no-check-certificate "https://www.sky.com/watch/channel/sky-1" -O -| \
                   grep -Eo "(https://www.sky.com/assets2/[a-zA-Z0-9./?=_-]*(jpg|png))|(https://dm8eklel4s62k.cloudfront.net/images/small/[a-zA-Z0-9./?=_-]*.(jpg|png))" | uniq | \
                   sed 's_https://www.sky.com_http://www.sky.com.rsz.io_g;s_https://dm8eklel4s62k.cloudfront.net_http://dm8eklel4s62k.cloudfront.net.rsz.io_g' > ${workdir}/${1}
                   [ -s ${workdir}/${1} ] && echo " -> ${1} OK" || echo " -> ${1} no valid links"
                   ;;
    atlantic.txt)  echo -n "Scraping Sky Atlantic... "
                   wget -q ${agent} ${referer} --no-check-certificate "https://www.sky.com/watch/channel/sky-atlantic" -O -| \
                   grep -Eo "(https://www.sky.com/assets2/[a-zA-Z0-9./?=_-]*(jpg|png))|(https://dm8eklel4s62k.cloudfront.net/images/small/[a-zA-Z0-9./?=_-]*.(jpg|png))" | uniq | \
                   sed 's_https://www.sky.com_http://www.sky.com.rsz.io_g;s_https://dm8eklel4s62k.cloudfront.net_http://dm8eklel4s62k.cloudfront.net.rsz.io_g' > ${workdir}/${1}
                   [ -s ${workdir}/${1} ] && echo " -> ${1} OK" || echo " -> ${1} no valid links"
                   ;;
    cinema.txt)    echo -n "Scraping Sky Cinema... "
                   wget -q ${agent} ${referer} "http://www.sky.com/shop/tv/cinema/" -O -| \
                   grep -Eo "/shop/export/sites/www.sky.com/shop/__12ColImages/Cinema/WhatsOn/[a-zA-Z0-9./?=_-]*.jpg" | uniq | \
                   sed 's_^/shop/export_http://www.sky.com.rsz.io/shop/export_g' > ${workdir}/${1}
                   [ -s ${workdir}/${1} ] && echo " -> ${1} OK" || echo " -> ${1} no valid links"
                   ;;
    sports.txt)    echo -n "Scraping Sky Sports Football... "
                   # Same regex also works with http://www.skysports.com/watch/tv-shows to include non-Football images
                   wget -q  ${agent} ${referer} "http://www.skysports.com/watch/tv-shows" -O -| \
                   grep -Eo "http://e[0-9].365dm.com/[a-zA-Z0-9./?=_-]*/([a-z]|[A-Z]){4}[a-zA-Z0-9_-]*.jpg" | uniq | \
                   sed 's/365dm.com/365dm.com.rsz.io/g' > ${workdir}/${1}
                   [ -s ${workdir}/${1} ] && echo " -> ${1} OK" || echo " -> ${1} no valid links"
                   ;;
    *)             echo -e "${1} not valid.\nValid files are: ${image_lists}"
                   ;;
  esac
  shift
done

exit 0
