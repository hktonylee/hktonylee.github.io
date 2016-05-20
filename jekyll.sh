#!/bin/bash


# AUTHOR: tonylee (me@tonylee.hk)


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CMD='bundle exec jekyll'


##########################################################################################


DRAFTS_DIR="$BASE_DIR/_drafts"
POSTS_DIR="$BASE_DIR/_posts"


setupColors() {
	export RESET_ALL='\033[0m'
	# export RESET_BOLD='\033[21m' # not working in OSX
	export RESET_DIM='\033[22m'
	export RESET_UNDERLINED='\033[24m'
	export RESET_BLINK='\033[25m'
	export RESET_REVERSE='\033[27m'
	export RESET_HIDDEN='\033[28m'
	export RESET_FG='\033[39m'
	export RESET_BG='\033[49m'

	export BG_Black='\033[40m'
	export BG_Red='\033[41m'
	export BG_Green='\033[42m'
	export BG_Yellow='\033[43m'
	export BG_Blue='\033[44m'
	export BG_Magenta='\033[45m'
	export BG_Cyan='\033[46m'
	export BG_Light_gray='\033[47m'
	export BG_Dark_gray='\033[100m'
	export BG_Light_red='\033[101m'
	export BG_Light_green='\033[102m'
	export BG_Light_yellow='\033[103m'
	export BG_Light_blue='\033[104m'
	export BG_Light_magenta='\033[105m'
	export BG_Light_cyan='\033[106m'
	export BG_White='\033[107m'

	export FG_BLACK='\033[30m'
	export FG_RED='\033[31m'
	export FG_GREEN='\033[32m'
	export FG_YELLOW='\033[33m'
	export FG_BLUE='\033[34m'
	export FG_MAGENTA='\033[35m'
	export FG_CYAN='\033[36m'
	export FG_LIGHT_GRAY='\033[37m'
	export FG_DARK_GRAY='\033[90m'
	export FG_LIGHT_RED='\033[91m'
	export FG_LIGHT_GREEN='\033[92m'
	export FG_LIGHT_YELLOW='\033[93m'
	export FG_LIGHT_BLUE='\033[94m'
	export FG_LIGHT_MAGENTA='\033[95m'
	export FG_LIGHT_CYAN='\033[96m'
	export FG_WHITE='\033[97m'

	export STYLE_BOLD='\033[1m'
	export STYLE_DIM='\033[2m'
	export STYLE_UNDERLINE='\033[4m'
	export STYLE_BLINK='\033[5m'
	export STYLE_REVERSE='\033[7m'
	export STYLE_HIDDEN='\033[8m'

}


setupColors


prompt() {
	promptCustom echo "$@"
}


getScreenSeparator() {
	char=${1:--};
	padding=${2:-1};

	screenLength=`tput cols`;

	if [ "$padding" == "0" ]; then
		head -c "$screenLength" < /dev/zero | tr '\0' "$char";
	else
		screenLength=`echo "$screenLength" - $(( padding * 2 )) | bc`;
		# echo -n " ";
		head -c "$padding" < /dev/zero | tr '\0' " ";
		head -c "$screenLength" < /dev/zero | tr '\0' "$char";
	fi
}


printScreenSeparator() {
	echo -en "$STYLE_DIM$FG_WHITE";
	getScreenSeparator "$1" "$2"
	echo -en "$RESET_ALL";
	echo
}


echoSection() {
	printScreenSeparator '-' 0;
	echo -en "$STYLE_DIM$FG_WHITE";
	echo -en "--- ";
	echo -en "$RESET_ALL";
	echo "$1";
	echo -en "$STYLE_DIM--- $RESET_ALL";
	echo;
}


promptHeader() {
	message="$1"
	choices="$2"

	if [ "$choices" != "" ]; then
		choices="$choices "
	fi

	echo -en "${RESET_ALL}${STYLE_BOLD}${message}${RESET_BOLD} ${FG_LIGHT_MAGENTA}${choices}${FG_DARK_GRAY}>${RESET_ALL} ";
}


promptYesNo() {
	message="$1"
	while [ 1 ]; do
		# >&2 echo -en "${STYLE_BOLD}${message}${RESET_BOLD} ${FG_DARK_GRAY}[y/N] >${RESET_FG} ";
		>&2 promptHeader "$message" "[y/N]"
		>&2 echo -en "${STYLE_BOLD}${FG_GREEN}"
		read yesNo;
		>&2 echo -en "${RESET_ALL}"
		if [ "$yesNo" == "y" ] || [ "$yesNo" == "Y" ]; then
			return 0;
		elif [ "$yesNo" == "n" ] || [ "$yesNo" == "N" ]; then
			return 1;
		fi
	done
}


promptText() {
	message="$@"
	>&2 echo -en "${STYLE_BOLD}${message}${RESET_BOLD} ${FG_DARK_GRAY}>${RESET_FG} ";
	>&2 echo -en "${STYLE_BOLD}${FG_GREEN}";
	read text;
	>&2 echo -en "${RESET_ALL}";
	echo "$text";
}


promptAndRun() {
	if prompt "$@"; then
		"$@";
	fi
}


setupPS3() {
	PS3=`promptHeader "$1" "$2"``echo -en "${STYLE_BOLD}${FG_GREEN}"`;
}


showErrorMessage() {
	echo -e "${FG_RED}${STYLE_BOLD}${1}${RESET_ALL} ${2}";
}


showInfoMessage() {
	echo -e "${FG_DARK_GRAY}${STYLE_BOLD}${1}${RESET_ALL} ${2}";
}


showNoteMessage() {
	echo -e "${FG_YELLOW}${STYLE_UNDERLINE}${STYLE_BOLD}${1}${RESET_ALL} ${2}";
}


##########################################################################################


DRAFTS_DATES=""
DRAFTS_NAMES=""
DRAFTS_LENGTH=0


POSTS_DATES=""
POSTS_NAMES=""
POSTS_LENGTH=0


getLinesCount() {
	array="$1"
	nth="$2"

	if [ "$array" == "" ]; then
		echo 0;
	else
		echo "$files" | wc -l
	fi
}


getNthLine() {
	array="$1"
	nth="$2"

	echo -n "$array" | sed -n "${nth}p" | tr -d '\n'
}


guardDraftsAvailabe() {
	if [ "$DRAFTS_LENGTH" == "0" ]; then
		showInfoMessage '[Info]' 'No draft available.'
		return 1
	else
		return 0
	fi
}


guardPostsAvailabe() {
	if [ "$POSTS_LENGTH" == "0" ]; then
		showInfoMessage '[Info]' 'No post available.'
		return 1
	else
		return 0
	fi
}


listDrafts() {	
	if [ `ls -1 "$DRAFTS_DIR" | wc -l` == "0" ]; then
		DRAFTS_DATES=""
		DRAFTS_NAMES=""
		DRAFTS_LENGTH=0
		showInfoMessage '[Info]' 'No draft available.'
		return 1
	else
		cd "$DRAFTS_DIR";
		files=`stat -f '%m;%Sm;%N' * | sort -nr | head -30`		# only get the newest 30 items
		cd - > /dev/null 2>&1;
		
		DRAFTS_DATES=`echo "$files" | cut -d';' -f2`
		DRAFTS_NAMES=`echo "$files" | cut -d';' -f3`
		DRAFTS_LENGTH=`getLinesCount "$files"`

		echoSection 'Drafts'

		for i in $(seq $DRAFTS_LENGTH) ; do
			theDate=`getNthLine "$DRAFTS_DATES" "$i"`
			theName=`getNthLine "$DRAFTS_NAMES" "$i"`
			# echo "$theDate $theName"
			printf "${FG_MAGENTA}%2d) " "$i"
			echo -en "${RESET_FG}${FG_CYAN}$theDate${RESET_FG} $theName"

			if [ "$i" == "1" ]; then
				echo -e " ${FG_DARK_GRAY}[Newest]${RESET_FG}"
			else
				echo
			fi
		done
		return 0
	fi
}


listPosts() {	
	if [ `ls -1 "$POSTS_DIR" | wc -l` == "0" ]; then
		POSTS_DATES=""
		POSTS_NAMES=""
		POSTS_LENGTH=0
		showInfoMessage '[Info]' 'No post available.'
		return 1
	else
		cd "$POSTS_DIR";
		files=`stat -f '%m;%Sm;%N' * | sort -nr | head -30`		# only get the newest 30 items
		cd - > /dev/null 2>&1;
		
		POSTS_DATES=`echo "$files" | cut -d';' -f2`
		POSTS_NAMES=`echo "$files" | cut -d';' -f3`
		POSTS_LENGTH=`getLinesCount "$files"`

		echoSection 'Posts'

		for i in $(seq $POSTS_LENGTH) ; do
			theDate=`getNthLine "$POSTS_DATES" "$i"`
			theName=`getNthLine "$POSTS_NAMES" "$i"`
			# echo "$theDate $theName"
			printf "${FG_MAGENTA}%2d) " "$i"
			echo -en "${RESET_FG}${FG_CYAN}$theDate${RESET_FG} $theName"

			if [ "$i" == "1" ]; then
				echo -e " ${FG_DARK_GRAY}[Newest]${RESET_FG}"
			else
				echo
			fi
		done
		return 0
	fi
}


promptDraft() {
	text="$1"
	question="$2"

	guardDraftsAvailabe && {
		selected=`promptText "$text"`

		if [ "$selected" != "" ] && (( "$selected" >= 1 )) && (( "$selected" <= $DRAFTS_LENGTH )); then
			promptYesNo "$question"
			if [ "$?" == "0" ]; then
				getNthLine "$DRAFTS_NAMES" "$selected"
				return 0
			else
				>&2 showInfoMessage '[Info]' 'No action'
				return 1
			fi
		else
			>&2 showErrorMessage '[Error]' 'Incorrect selection'
			return 1
		fi
	}
}


promptPost() {
	text="$1"
	question="$2"

	guardPostsAvailabe && {
		selected=`promptText "$text"`

		if [ "$selected" != "" ] && (( "$selected" >= 1 )) && (( "$selected" <= $POSTS_LENGTH )); then
			promptYesNo "$question"
			if [ "$?" == "1" ]; then
				getNthLine "$POSTS_NAMES" "$selected"
				return 0
			else
				>&2 showInfoMessage '[Info]' 'No action'
				return 1
			fi
		else
			>&2 showErrorMessage '[Error]' 'Incorrect selection'
			return 1
		fi
	}
}


##########################################################################################


runJekyllCmd() {
	cd "$BASE_DIR";
	$CMD "$@";
	cd - > /dev/null;
}


runFeatureNew() {
	showInfoMessage '[Info]' "Making new draft..."
	name=`promptText "Name of the draft"`
	runJekyllCmd draft "$name"
}


runFeatureDelete() {
	promptDraft "Delete draft" "Are you sure want to delete?" | {
		answer=`cat`
		if [ "$answer" != "" ]; then
			rm -v "${DRAFTS_DIR}/${answer}"
		fi
	}
}


runFeaturePublish() {
	promptDraft "Publish draft" "Are you sure want to publish?" | {
		answer=`cat`
		if [ "$answer" != "" ]; then
			runJekyllCmd publish "${DRAFTS_DIR}/${answer}"
		fi
	}
}


runFeatureUnpublish() {
	listPosts

	promptPost "Unpublish post" "Are you sure want to unpublish?" | {
		answer=`cat`
		if [ "$answer" != "" ]; then
			runJekyllCmd unpublish "${POSTS_DIR}/${answer}"
		fi
	}
}


runFeatureCommit() {
	git status

	promptYesNo "Commit only staged files?"

	if [ "$?" == "0" ]; then
		git commit -m "Updated files"
	else
		>&2 showInfoMessage '[Info]' 'No action'
	fi
}


runFeatureServe() {
	showInfoMessage '[Info]' "Serving..."
	runJekyllCmd serve --drafts --config _config.yml,_config-dev.yml --trace
	# runJekyllCmd serve --drafts --config _config.yml,_config-dev.yml
}


runFeatureClean() {
	promptYesNo "Clean project?"

	if [ "$?" == "0" ]; then
		runJekyllCmd clean
	else
		>&2 showInfoMessage '[Info]' 'No action'
	fi
}


listDraftsIfNotInteractive() {
	isInteractive="$1"

	if [ "$isInteractive" == "" ]; then
		listDrafts
	fi
}


FEATURE_NEW_DRAFT="new"
FEATURE_DELETE_DRAFT="delete"
FEATURE_PUBLISH_DRAFT="publish"
FEATURE_UNPUBLISH_POSTS="unpublish"
FEATURE_COMMIT="commit"
FEATURE_SERVE_HTTP="serve"
FEATURE_CLEAN="clean"
DISPLAY_FEATURES="(${FEATURE_NEW_DRAFT}|${FEATURE_DELETE_DRAFT}|${FEATURE_PUBLISH_DRAFT}|${FEATURE_UNPUBLISH_POSTS}|${FEATURE_COMMIT}|${FEATURE_SERVE_HTTP}|${FEATURE_CLEAN})"


runFeature() {
	featureName="$1"
	isInteractive="$2"

	case "$featureName" in
		"$FEATURE_NEW_DRAFT")
			runFeatureNew ;;
		"$FEATURE_DELETE_DRAFT")
			listDraftsIfNotInteractive "$isInteractive"
			runFeatureDelete ;;
		"$FEATURE_PUBLISH_DRAFT")
			listDraftsIfNotInteractive "$isInteractive"
			runFeaturePublish ;;
		"$FEATURE_UNPUBLISH_POSTS")
			runFeatureUnpublish ;;
		"$FEATURE_COMMIT")
			runFeatureCommit ;;
		"$FEATURE_SERVE_HTTP")
			runFeatureServe ;;
		"$FEATURE_CLEAN")
			runFeatureClean ;;
		*)
			showErrorMessage "[Error]" "Incorrect feature: $featureName"
	esac
}


promptFeaturesInteractive() {
	listDrafts
	echo

	setupPS3 "Choices" "(1/2/...)";

	DISPLAY_NEW_DRAFT="New draft"
	DISPLAY_DELETE_DRAFT="Delete draft"
	DISPLAY_PUBLISH_DRAFT="Publish draft"
	DISPLAY_UNPUBLISH_POSTS="Unpublish posts"
	DISPLAY_COMMIT="Commit"
	DISPLAY_SERVE_HTTP="Serve (HTTP)"
	DISPLAY_CLEAN="Clean"

	echoSection "Select features"
	select choice in "$DISPLAY_NEW_DRAFT" "$DISPLAY_DELETE_DRAFT" "$DISPLAY_PUBLISH_DRAFT" "$DISPLAY_UNPUBLISH_POSTS" "$DISPLAY_COMMIT" "$DISPLAY_SERVE_HTTP" "$DISPLAY_CLEAN"; do
		echo -en "${RESET_ALL}";

		case "$choice" in
			"$DISPLAY_NEW_DRAFT")
				runFeature "$FEATURE_NEW_DRAFT" "Y"
				break ;;
			"$DISPLAY_DELETE_DRAFT")
				runFeature "$FEATURE_DELETE_DRAFT" "Y"
				break ;;
			"$DISPLAY_PUBLISH_DRAFT")
				runFeature "$FEATURE_PUBLISH_DRAFT" "Y"
				break ;;
			"$DISPLAY_UNPUBLISH_POSTS")
				runFeature "$FEATURE_UNPUBLISH_POSTS" "Y"
				break ;;
			"$DISPLAY_COMMIT")
				runFeature "$FEATURE_COMMIT" "Y"
				break ;;
			"$DISPLAY_SERVE_HTTP")
				runFeature "$FEATURE_SERVE_HTTP" "Y"
				break ;;
			"$DISPLAY_CLEAN")
				runFeature "$FEATURE_CLEAN" "Y"
				break ;;
		esac
	done
}


main() {
	cmd="$1"

	if [ "$cmd" == "-h" ]; then
		showInfoMessage "Usage:" "$0 ${DISPLAY_FEATURES}"

	elif [ "$cmd" != "" ]; then
		runFeature "$cmd"

	else
		promptFeaturesInteractive

	fi
}


main "$@"


##########################################################################################
