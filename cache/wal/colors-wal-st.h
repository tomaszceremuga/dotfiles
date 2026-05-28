const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#090610", /* black   */
  [1] = "#452957", /* red     */
  [2] = "#53316C", /* green   */
  [3] = "#55306E", /* yellow  */
  [4] = "#5D4671", /* blue    */
  [5] = "#623B84", /* magenta */
  [6] = "#6F4A91", /* cyan    */
  [7] = "#c1c0c3", /* white   */

  /* 8 bright colors */
  [8]  = "#5c5669",  /* black   */
  [9]  = "#452957",  /* red     */
  [10] = "#53316C", /* green   */
  [11] = "#55306E", /* yellow  */
  [12] = "#5D4671", /* blue    */
  [13] = "#623B84", /* magenta */
  [14] = "#6F4A91", /* cyan    */
  [15] = "#c1c0c3", /* white   */

  /* special colors */
  [256] = "#090610", /* background */
  [257] = "#c1c0c3", /* foreground */
  [258] = "#c1c0c3",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
