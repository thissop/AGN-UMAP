source ./bashrc
heainit 
xspec 
data /Users/yaroslav/Downloads/thaddaeus_delivery/0100320102/jspipe/js_ni0100320102_0mpu7_goddard_GTI0.jsgrp
/Users/yaroslav/Downloads/thaddaeus_delivery/0100320102/jspipe/js_ni0100320102_0mpu7_goddard_GTI0.bg
ignore **-0.5 10.0-** #(1-21), (255-336)
ignore 1.7-2.3
ignore bad
model tbabs*(diskbb+nthcomp)
3.2107
, , 0.2 0.2 3 3

, , 1.1 1.1 3.5 4.0
, , 4 4 250 250
=p2
1
0

freeze 1 7 8
query no
fit 400