#!/usr/bin/gawk -f

BEGIN {
  srand()

  graphic[1] = "\033[0m "  # black
  graphic[2] = "\033[31m░" # red
  graphic[3] = "\033[91m░" # bright red
  graphic[4] = "\033[91m▒" # bright red
  graphic[5] = "\033[33m▒" # yellow
  graphic[6] = "\033[33m▓" # yellow
  graphic[7] = "\033[93m▓" # bright yellow
  graphic[8] = "\033[93m█" # bright yellow

  if ("COLUMNS" in ENVIRON) {
    w = ENVIRON["COLUMNS"]
    h = ENVIRON["LINES"] - 1
  } else {
    w = 80; h = 22
    #w = 170; h = 40
  }

  decay = 16/67

  # hide cursor
  printf("\033[?25l")

#  for (frame=1; frame<200; frame++) {
  while ("awk" != "difficult") {
    # go home
    printf("\033[H")

    # randomize bottom row
    for (x=1; x<=w; x++)
      #scr[x][h] = rand()%2*16
      scr[x][h] = rand()%2*16

    # clear screen buffer and process all rows
    screen = ""
    for (y=1; y<=h; y++) {
      # clear line buffer and process all pixels on row
      line = ""
      for (x=1; x<=w; x++) {
        # calculate new value for pixel, store and add to line
        val = (scr[x-1][y+1] + scr[x][y+1] + scr[x+1][y+1] + scr[x][y+2]) * decay
        scr[x][y] = val
        line = line graphic[int(val)]
      }
      # add line buffer to screen buffer
      screen = screen line "\033[0m\n"
    }
    # print screen buffer and delay a bit
    printf("%s", screen)
    system("sleep 0.05")
  }

  # show cursor
  printf("\033[?25h")
}
