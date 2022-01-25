#!/usr/bin/awk -f

function clip(val, a, b) { return (val<a) ? a : (val>b) ? b : val }

function timex() {
  getline < "/proc/uptime"
  close("/proc/uptime")
  return $1
}

BEGIN {
  srand()

  flameheight    = 3.7	; # between 2.0 and 5.0
  flameintensity = 0.9	; # between 0.5 and 1.0

  decay          = 16/67; # this is pretty much the ideal
  nrframes       = 400	; # how long do you want it to go on

  # get terminal width and height
  "tput cols"  | getline w
  "tput lines" | getline h
  if (!w || !h) {
    w = 80; h = 24
  }
  h *= 2

  # generate colors (black to red to yellow to white)
  colors = 0
  for (i=0; i<256; i+=1)
    color[colors++] = sprintf("%d;0;0", i)
  for (i=0; i<256; i+=4)
    color[colors++] = sprintf("255;%d;%d", i, int(i/4))
  for (i=64; i<256; i+=16)
    color[colors++] = sprintf("255;255;%d", i)

  # hide cursor
  printf("\033[?25l")

#  while ("awk" != "difficult") {
  for (frame=1; frame<nrframes; frame++) {
    printf("\033[H")

    # randomize bottom row
    for (x=1; x<=w; x++)
      scr[x,h+4] = rand() * (colors*flameintensity) + (colors*(1-flameintensity))

    # clear screen buffer and process all rows
    screen = ""
    for (y=0; y<h+4; y+=2) {
      # set cursor position
      if (y<h) line = sprintf("\033[%0d;%0dH", y/2+1, 1)

      for (x=1; x<=w; x++) {
        # calculate new value for pixel, store and add to line
        scr[x,y+0] = (scr[x-1,y+1] + scr[x,y+1] + scr[x+1,y+1] + scr[x,y+2]) * decay
        scr[x,y+1] = (scr[x-1,y+2] + scr[x,y+2] + scr[x+1,y+2] + scr[x,y+3]) * decay

        up = clip(int(scr[x,y+0] * flameheight), 0, colors-1)
        dn = clip(int(scr[x,y+1] * flameheight), 0, colors-1)

        if (y<h) line = line "\033[38;2;" color[up] ";48;2;" color[dn] "m▀"
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
