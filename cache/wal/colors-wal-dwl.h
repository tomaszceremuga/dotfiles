/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const float rootcolor[]             = COLOR(0x090610ff);
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xc1c0c3ff, 0x090610ff, 0x5c5669ff },
	[SchemeSel]  = { 0xc1c0c3ff, 0x53316Cff, 0x452957ff },
	[SchemeUrg]  = { 0xc1c0c3ff, 0x452957ff, 0x53316Cff },
};
