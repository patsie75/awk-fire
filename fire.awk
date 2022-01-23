#!/usr/bin/awk -f

function clip(val, a, b) { return (val<a) ? a : (val>b) ? b : val }

function timex() {
  getline < "/proc/uptime"
  close("/proc/uptime")
  return $1
}

BEGIN {
  srand()

  colors   = 0
  decay    = 16/67
  nrframes = 400

  # get terminal width and height
  "tput cols"  | getline w
  "tput lines" | getline h
  if (!w || !h) {
    w = 80; h = 24
  }
  h *= 2

  # generate colours
  for (i=0; i<256; i+=4)
    color[colors++] = sprintf("%d;0;0", i)
  for (i=0; i<256; i+=4)
    color[colors++] = sprintf("255;%d;%d", i, i/4)

  # hide cursor
  printf("\033[?25l")

#  while ("awk" != "difficult") {
  for (frame=1; frame<nrframes; frame++) {
    printf("\033[H")

    # randomize bottom row
    for (x=1; x<=w; x++)
      scr[x,h] = rand() * (colors*0.75) + (colors*0.25)

    # clear screen buffer and process all rows
    screen = ""
    for (y=0; y<h; y+=2) {
      # set cursor position
      line = sprintf("\033[%0d;%0dH", y/2+1, 1)

      for (x=1; x<=w; x++) {
        # calculate new value for pixel, store and add to line
        scr[x,y+0] = (scr[x-1,y+1] + scr[x,y+1] + scr[x+1,y+1] + scr[x,y+2]) * decay 
        scr[x,y+1] = (scr[x-1,y+2] + scr[x,y+2] + scr[x+1,y+2] + scr[x,y+3]) * decay

        up = clip(int(scr[x,y+0]*2), 0, colors-1)
        dn = clip(int(scr[x,y+1]*2), 0, colors-1)

        line = line "\033[38;2;" color[up] ";48;2;" color[dn] "m▀"
      }

      # add line buffer to screen buffer
      screen = screen line "\033[0m"
    }

    printf("%s", screen)
    system("sleep 0.03")
  }

  # show cursor
  printf("\033[?25h")
}
