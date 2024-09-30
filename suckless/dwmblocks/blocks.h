static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"\x08  \x01", "date '+%I:%M %p'",					1,		0},
	{"\x09  \x01", "checkupdates | wc -l",				1,		0},
	{"\x010  \x01", "pamixer --get-volume-human",		1,		0},
};

static char delim[] = "  ";
static unsigned int delimLen = 5;