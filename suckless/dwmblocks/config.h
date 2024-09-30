static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"\x07  \x01", "date '+%I:%M %p'",					60,		0},
	{"\x08  \x01", "checkupdates | wc -l",				60,		0},
	{"\x09  \x01", "pamixer --get-volume-human",		60,		0},
	{"\x07  \x01", "free -h | awk '/^Mem/ { print $3\"/\"$2 }' | sed s/i//g",	30,		0},
};

static char delim[] = "  ";
static unsigned int delimLen = 5;