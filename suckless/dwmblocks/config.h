static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"\x07  \x01", "date '+%I:%M %p'",					60,		0},
	{"\x08  \x01", "checkupdates | wc -l",				60,		0},
	{"\x09  \x01", "pamixer --get-volume-human",		60,		0},
};

static char delim[] = "  ";
static unsigned int delimLen = 5;