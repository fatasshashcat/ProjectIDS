breed [cops cop]
breed [citizens citizen]
breed [prisoners prisoner]

globals
[
  prison-region
  restaurant-region
  destination-region
  work-region
  university-region
  assemblyhall-region

  cinema-region
  townsquare-region
  workPlace-region
  policeStation-region
  espressoHouse-region
  factory-region

  year
  month
  day
  hour
  minute
  clock
]

citizens-own[
  state
  last_state
  socialHunger
  hunger
  atHome?
  inPrison?
  time-in-prison
  prison-duration
  troubleMaker?
  atWork?
  finishedWorking?
  time
]

cops-own [
  state
  time-out-of-restaurant
  hunger
  go-to-restaurant
]

patches-own [region]

;================================================================================================================================
to setup
  clear-all

  ask patches[set pcolor white - 2 set region "else"]

  set townsquare-region patches with [pxcor > -10 and pxcor < 10 and pycor > -10 and pycor < 10]
  ask townsquare-region [set pcolor gray set region "town square"]
  ask patches with[pxcor = 1 and pycor = 9] [set plabel "TOWN SQUARE"]

  set prison-region patches with [pxcor > 15 and pxcor < 30 and pycor > -7 and pycor < 7]
  ask prison-region [ set pcolor red set region "prison"]
  ask patches with[pxcor = 23 and pycor = 6] [set plabel "PRISON"]

  set workPlace-region patches with [pxcor < -15 and pxcor > -30 and pycor > -7 and pycor < 7]
  ask workPlace-region [ set pcolor brown set region "workPlace"]
  ask patches with[pxcor = -21 and pycor = 6] [set plabel "WORK PLACE"]

  set university-region patches with [pxcor < -18 and pxcor > -28 and pycor > 10 and pycor < 20]
  ask university-region [ set pcolor brown - 2 set region "university"]
  ask patches with[pxcor = -21 and pycor = 19] [set plabel "POLICE STATION"]

  set cinema-region patches with [pxcor > -6 and pxcor < 6 and pycor > 14 and pycor < 20]
  ask cinema-region [ set pcolor green set region "cinema"]
  ask patches with[pxcor = 0 and pycor = 19] [set plabel "CINEMA"]

  set policeStation-region patches with [pxcor > 18 and pxcor < 28 and pycor > 10 and pycor < 20]
  ask policeStation-region[ set pcolor red - 2 set region "policeStation"]
  ask patches with[pxcor = 25 and pycor = 19] [set plabel "POLICE STATION"]

  set espressoHouse-region patches with [pxcor > -6 and pxcor < 6 and pycor < -14 and pycor > -20]
  ask espressoHouse-region [ set pcolor green set region "espressoHouse"]
  ask patches with[pxcor = 2 and pycor = -15] [set plabel "ESPRESSO HOUSE"]

  set factory-region patches with [pxcor < -18 and pxcor > -28 and pycor < -10 and pycor > -18]
  ask factory-region [ set pcolor pink set region "factory"]
  ask patches with[pxcor = -22 and pycor = -11] [set plabel "FACTORY"]

  set restaurant-region patches with [pxcor > 18 and pxcor < 28 and pycor < -10 and pycor > -18]
  ask restaurant-region [ set pcolor blue set region "restaurant"]
  ask patches with[pxcor = 24 and pycor = -11] [set plabel "RESTAURANT"]

  ask patches with [pxcor = 12 and pycor = -12] [set pcolor black set region "home"]

  create-cops num-cops [
    setxy random-xcor random-ycor
    set shape "car"
    set color blue
    set label who
    set label-color white
  ]

  create-citizens num-citizens [
    setxy random-xcor random-ycor
    set shape "person"
    set color white
    set size 2
    ;set label who
    ;set label-color pink

    move-to one-of patches with[region = "home"]
    set atHome? true
    set atWork? false
    set finishedWorking? false
    set inPrison? false
    set troubleMaker? false
    set socialHunger 0
    set hunger 0
    set time 0

    set state [-> walk-around]
    set last_state [-> walk-around]

  ]

  ;set time 0
  set year 2024
  set month 1
  set day 1
  set hour 6
  set minute 0

  set clock 0

  reset-ticks
end

;================================================================================================================================
to go

  ask turtles
  [
    if breed = cops [cop-behaviour]
    if breed = citizens [citizen-behaviour]
  ]

  calender

  ;if clock = 960 [set clock 0]
  if clock = 1440 [set clock 0] ;minutes in a day
  set clock (clock + 1)
  print clock

  tick
end

;================================================================================================================================
to citizen-behaviour
  ifelse inPrison? = true
  [
    set state [-> prison]
    set last_state 0
  ]
  [
    ifelse any? cops in-radius citizen-vision and troubleMaker? = true
    [
      set state [-> flee]
      set last_state 0
    ]
    [
      ifelse hunger > 70
      [
        set state [-> go-to-restaurant]
      ]
      [
        ifelse atHome? = true
        [
          ;ifelse time > 7 and time < 8
          ifelse clock >= 60 and clock <= 120
          [
            set state [-> working]
            set last_state [-> working]
          ]
          [
            ;ifelse time = 10
            ifelse clock = 240
            [
              set state [-> studying]
              set last_state [-> studying]
            ]
            [
              ;ifelse time > 19 and time < 23
              ifelse clock >=  780 and clock <= 1020
              [
                set state [-> relaxing-at-home]
              ]
              [
                set state [-> walk-around]
                set last_state [-> walk-around]
              ]
            ]
          ]
        ]
        [
          ifelse atWork? = true
          [

          ]
          [
            ifelse last_state = 0
            [
              set state[-> proactive]
            ]
            [
              set state last_state
            ]
          ]
        ]
      ]
    ]
  ]

  run state
  ;run last_state
  ;print state
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to move-to-destination
  let destination one-of destination-region
  face destination
  forward citizen-speed
  if (patch-here = destination) [
  set state "free"
  ]
  let nearby-cops cops in-radius citizen-vision
  if any? nearby-cops [
    ;run-away
  ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to move-to-work
  let workarea one-of work-region
  face workarea
  forward citizen-speed
  if (patch-here = workarea) [
  set state "working"
  ]
  let nearby-cops cops in-radius citizen-vision
  if any? nearby-cops [
    ;run-away
  ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to flee
  let nearby-cops cops in-radius citizen-vision
  if any? nearby-cops[
    let target one-of nearby-cops
    face target
    fd (-1 * citizen-speed)
  ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to being-arrested
  move-to one-of prison-region
  set color red
  set state "in-prison"
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to prison
  set time-in-prison time-in-prison + 1
  if time-in-prison >= prison-duration[
    set color green
    set time-in-prison 0
    set state "moving-home"
  ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to working
  ;print "working"

  ifelse [region] of patch-here = "workPlace"
  [
    set atWork? true
    set finishedWorking? false
  ]
  [
    set heading towards one-of patches with[region = "workPlace"]
    fd 1
  ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to studying
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to relaxing-at-home
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to walk-around
  ifelse time > 0
  [
    set atHome? false
    set heading random 361
    fd 1

    set time (time - 1)
    ;print time
  ]
  [
    move-to one-of patches with[region = "home"]
    set atHome? true
    ;set time random 91 + 30
    set time 61
    ;print time
  ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to proactive
;  ifelse any? friends in-radius citizen-vision and socialHunger > 50 [set state [-> meeting-friends]]
;  [
;    ifelse time > 14 and time < 20 [set state [-> participate-in-social-event]]
;    [
;      ifelse time > 14 and time < 23 [set state [-> go-to-cinema]]
;      [
;        ;speaking up / demonstrating
;      ]
;    ]
;  ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to meeting-friends
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to end-to-cinema
end

;================================================================================================================================
to cop-behaviour
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to move-cops
  ask cops [
    if state = "not-hungry" [chase]
  ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------
to chase
  set heading random 360
  forward cop-speed
  let nearby-citizens citizens in-radius cop-vision
  if any? nearby-citizens[
    let target one-of nearby-citizens
    if [state] of target != "in-prison" [
      if [state] of target != "free" [
        if [state] of target != "working" [
          face target
          fd cop-speed
          if distance target <= 1 [
            ask target[
              if color != red[
                set state "being-arrested"
              ]
            ]
          ]
        ]
      ]
    ]
  ]
  set time-out-of-restaurant time-out-of-restaurant + 1
  if time-out-of-restaurant >= hunger [
    set state "hungry"
  ]
end
;================================================================================================================================
to calender
  set minute (minute + 1)

  if minute = 60
  [
    set minute 0
    set hour (hour + 1)
  ]

  ;if hour = 22
  if hour = 24
  [
    set hour 0
    set day (day + 1)
  ]

  if day = 31
  [
    set day 1
    set month (month + 1)
  ]

  if month = 13
  [
    set month 1
    set year (year + 1)
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
203
10
1132
638
-1
-1
15.1
1
10
1
1
1
0
1
1
1
-30
30
-20
20
0
0
1
ticks
30.0

BUTTON
1240
12
1325
84
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1150
12
1235
84
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1151
165
1323
198
citizen-vision
citizen-vision
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
1151
279
1323
312
cop-vision
cop-vision
0
10
7.0
1
1
NIL
HORIZONTAL

SLIDER
1151
213
1323
246
num-cops
num-cops
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
1151
99
1323
132
num-citizens
num-citizens
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
1151
132
1323
165
citizen-speed
citizen-speed
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
1151
246
1323
279
cop-speed
cop-speed
0
10
2.0
1
1
NIL
HORIZONTAL

SWITCH
26
13
184
46
show-intentions
show-intentions
0
1
-1000

MONITOR
18
58
75
103
Year
year
17
1
11

MONITOR
76
58
133
103
Month
month
17
1
11

MONITOR
134
58
191
103
Day
day
17
1
11

MONITOR
49
108
106
153
Hour
hour
17
1
11

MONITOR
106
108
163
153
Minute
minute
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
