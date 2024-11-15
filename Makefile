### CHANGE ME ######################
DOMAIN             = www.sacredheartsc.com
URL                = https://${DOMAIN}
RSYNC_TARGET       = ${DOMAIN}:/usr/local/www/${DOMAIN}
FEED_TITLE         = Cullum Smith's Blog
FEED_DESCRIPTION   = Dad, southerner, unix wrangler, banjo enjoyer
STATIC_REGEX       = .*\.(html|css|jpg|jpeg|png|ico|xml|txt|asc|webmanifest)
RECENT_POSTS_LIMIT = 5
HIGHLIGHT_STYLE    = pygments


### VARIABLES ######################
SOURCE_DIR         = src
OUTPUT_DIR         = public
SCRIPT_DIR         = scripts
BLOG_DIR           = blog

TEMPLATE           = templates/default.html
CV_TEMPLATE        = templates/cv.html
DEFAULTS           = defaults.yaml

BLOG_LIST_SCRIPT   = ${SCRIPT_DIR}/bloglist.py
BLOG_LIST_REPLACE  = __BLOG_LIST__
BLOG_LIST_FILE     = .bloglist.md

BLOG_RSS_SCRIPT    = ${SCRIPT_DIR}/rss.py
BLOG_RSS_FILE      = ${BLOG_DIR}/feed.xml

SOURCE_DIRS       != find ${SOURCE_DIR} -mindepth 1 -type d
SOURCE_HOMEPAGE   := ${SOURCE_DIR}/index.md
SOURCE_BLOGLIST   := ${SOURCE_DIR}/${BLOG_DIR}/index.md
SOURCE_CV         := ${SOURCE_DIR}/cv/index.md
SOURCE_SPECIAL    := ${SOURCE_HOMEPAGE} ${SOURCE_BLOGLIST} ${SOURCE_CV}
SOURCE_MARKDOWN   != find ${SOURCE_DIR} -type f -name '*.md' ! -name ${BLOG_LIST_FILE} ${SOURCE_SPECIAL:C/^/! -path /}
SOURCE_STATIC     != find -E ${SOURCE_DIR} -type f -iregex ${STATIC_REGEX:Q}

BLOG_POSTS        != find ${SOURCE_DIR}/${BLOG_DIR} -type f -name '*.md' ! -name ${BLOG_LIST_FILE} ! -path ${SOURCE_BLOGLIST}
RECENT_POST_LIST   = ${SOURCE_DIR}/${BLOG_LIST_FILE}
FULL_POST_LIST     = ${SOURCE_DIR}/${BLOG_DIR}/${BLOG_LIST_FILE}

SOURCE2OUTPUT      = S/^${SOURCE_DIR}\//${OUTPUT_DIR}\//
SOURCE2HTML        = ${SOURCE2OUTPUT}:S/.md$$/.html/
OUTPUT2SOURCE      = S/^${OUTPUT_DIR}\//${SOURCE_DIR}\//
HTML2SOURCE        = ${OUTPUT2SOURCE}:S/.html$$/.md/

OUTPUT_DIRS       := ${SOURCE_DIRS:${SOURCE2OUTPUT}}
OUTPUT_HOMEPAGE   := ${SOURCE_HOMEPAGE:${SOURCE2HTML}}
OUTPUT_BLOGLIST   := ${SOURCE_BLOGLIST:${SOURCE2HTML}}
OUTPUT_CV         := ${SOURCE_CV:${SOURCE2HTML}}
OUTPUT_SPECIAL    := ${SOURCE_SPECIAL:${SOURCE2HTML}}
OUTPUT_MARKDOWN   := ${SOURCE_MARKDOWN:${SOURCE2HTML}}
OUTPUT_STATIC     := ${SOURCE_STATIC:${SOURCE2OUTPUT}}
OUTPUT_RSS        := ${OUTPUT_DIR}/${BLOG_RSS_FILE}


### BUILD COMMANDS ######################
COPY                  = cp -p
PANDOC               := pandoc --highlight-style=${HIGHLIGHT_STYLE} --metadata=feed:/${BLOG_RSS_FILE} --defaults=${DEFAULTS}
GENERATE_RSS         := ${BLOG_RSS_SCRIPT} ${SOURCE_DIR}/${BLOG_DIR} --title=${FEED_TITLE:Q} --description=${FEED_DESCRIPTION:Q} --url=${URL:Q} --blog-path=/${BLOG_DIR} --feed-path=/${BLOG_RSS_FILE}
GENERATE_BLOGLIST    := ${BLOG_LIST_SCRIPT} ${SOURCE_DIR}/${BLOG_DIR}
INTERPOLATE_BLOGLIST  = sed -e '/${BLOG_LIST_REPLACE}/{r ${BLOGLIST_HTML}' -e 'd;}'


### TARGETS ######################
.SHELL: name=sh quiet="set -" echo="set -v" filter="set -" hasErrCtl=yes check="set -eo pipefail" ignore="set +e" echoFlag=v errFlag=e path=/bin/sh

public: ${OUTPUT_DIRS} ${OUTPUT_SPECIAL} ${OUTPUT_MARKDOWN} ${OUTPUT_STATIC} ${OUTPUT_RSS}

${OUTPUT_DIRS}:
	mkdir -p $@

# Homepage
${OUTPUT_HOMEPAGE}: ${SOURCE_HOMEPAGE} ${RECENT_POST_LIST} ${TEMPLATE} BLOGLIST_HTML=${RECENT_POST_LIST}
	${INTERPOLATE_BLOGLIST} ${SOURCE_HOMEPAGE} | ${PANDOC} --template=${TEMPLATE} --output=$@

# HTML for partial blog listing
${RECENT_POST_LIST}: ${BLOG_POSTS} ${BLOG_LIST_SCRIPT}
	${GENERATE_BLOGLIST} ${RECENT_POSTS_LIMIT} > $@

# CV
${OUTPUT_CV}: ${SOURCE_CV} ${CV_TEMPLATE}
	${PANDOC} --template=${CV_TEMPLATE} --output=$@ ${SOURCE_CV}

# Main blog page
${OUTPUT_BLOGLIST}: ${SOURCE_BLOGLIST} ${FULL_POST_LIST} ${TEMPLATE} BLOGLIST_HTML=${FULL_POST_LIST}
	${INTERPOLATE_BLOGLIST} ${SOURCE_BLOGLIST} | ${PANDOC} --template=${TEMPLATE} --output=$@

# HTML for full blog listing
${FULL_POST_LIST}: ${BLOG_POSTS} ${BLOG_LIST_SCRIPT}
	${GENERATE_BLOGLIST} > $@

# RSS feed
${OUTPUT_RSS}: ${BLOG_POSTS} ${BLOG_RSS_SCRIPT}
	${GENERATE_RSS} > $@

# Blog posts
${OUTPUT_MARKDOWN}: ${@:${HTML2SOURCE}} ${TEMPLATE}
	${PANDOC} --template=${TEMPLATE} --output=$@ ${@:${HTML2SOURCE}}

# Static assets
${OUTPUT_STATIC}: ${@:${OUTPUT2SOURCE}}
	${COPY} ${@:${OUTPUT2SOURCE}} $@

.PHONY: deps serve rsync clean
deps:
	pip install -r requirements.txt

serve: public
	cd ${OUTPUT_DIR} && python3 -m http.server

rsync: public
	rsync -rlphv --delete ${OUTPUT_DIR}/ ${RSYNC_TARGET}

clean:
	rm -rf ${OUTPUT_DIR}
	find ${SOURCE_DIR} -type f -name ${BLOG_LIST_FILE} -delete
