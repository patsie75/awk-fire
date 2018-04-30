#!/usr/bin/gawk -f

function MyTime() {
  # /proc/uptime has more precision than strftime()
  getline < "/proc/uptime"
  close("/proc/uptime")
  return($1)
}

BEGIN {
  srand()

  graphic[0][1] = " "
  graphic[0][2] = "░"
  graphic[0][3] = "░"
  graphic[0][4] = "▒"
  graphic[0][5] = "▒"
  graphic[0][6] = "▓"
  graphic[0][7] = "▓"
  graphic[0][8] = "█"
  graphic[0][9] = "█"
  
  graphic[1][1] = "\033[0m "  # black
  graphic[1][2] = "\033[31m░" # red
  graphic[1][3] = "\033[91m░" # bright red
  graphic[1][4] = "\033[91m▒" # bright red
  graphic[1][5] = "\033[33m▒" # yellow
  graphic[1][6] = "\033[33m▓" # yellow
  graphic[1][7] = "\033[93m▓" # bright yellow
  graphic[1][8] = "\033[93m█" # bright yellow
  graphic[1][9] = "\033[93m█" # bright yellow

  graphlen = length(graphic[1])

  if ("COLUMNS" in ENVIRON) {
    w = ENVIRON["COLUMNS"]
    h = ENVIRON["LINES"] - 1
  } else {
    w = 80; h = 22
    #w = 170; h = 40
  }

  decay = 16/67
  nrframes = 200
  StatusBar = 1
  FrameCount = 0
  TimeStart = TimeThen = TimeNow = MyTime()

  # hide cursor
  printf("\033[?25l")

  for (frame=1; frame<nrframes; frame++) {
#  while ("awk" != "difficult") {
    printf("\033[H")

    # randomize bottom row
    for (x=1; x<=w; x++)
      ## testing
      #if (x < w/3) scr[x][h] = rand()%2*11+2
      #else if (x < w*2/3) scr[x][h] = rand()%2*9+4
      #else scr[x][h] = rand()%2*16
      scr[x][h] = rand()%2*9+4

    # clear screen buffer and process all rows
    screen = ""
    for (y=1; y<h; y++) {
      # clear line buffer and process all pixels on row
      line = ""; prev = 0
      for (x=1; x<=w; x++) {
        # calculate new value for pixel, store and add to line
        val = (scr[x-1][y+1] + scr[x][y+1] + scr[x+1][y+1] + scr[x][y+2]) * decay
        scr[x][y] = val
        ival = int(val) % graphlen + 1

        #line = line graphic[1][ival]
        line = line graphic[(prev != ival)][ival]
        prev = ival
      }
      # add line buffer to screen buffer
      screen = screen line "\033[0m\n"
    }

    # print statusbar
    if (StatusBar)
      printf("%s\033[K\n", status)

    # print screen buffer and delay a bit
    printf("%s", screen)

    if (StatusBar) {
      FrameCnt++
      TimeNow = MyTime()
      if ( (TimeNow - TimeThen) >= 0.5) {
        status = sprintf("frame %d/%d now:%.2ffps avg:%.2ffps", frame, nrframes, FrameCnt/(TimeNow-TimeThen), frame/(TimeNow-TimeStart))
        TimeThen = TimeNow
        FrameCnt = 0
      }
    }

    system("sleep 0.1")
  }

  # show cursor
  printf("\033[?25h")
}
