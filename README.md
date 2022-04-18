# scroll4d

Atari driver for A4Tech's WWT-13 trackball on serial port

![A4Tech WWT-13 trackball](https://raw.githubusercontent.com/Kochise/atari-scroll4d/master/IMGS/PDyCi7p.jpg)

* Hardware and software needed

You need the following to get this program working :

\- Atari with a DB-9 serial port and a PS-2 adapter<br>
\- A4Tech's WWT-13 trackball on serial port

[A4Tech WOP-35 optical mouse](https://a4tech.net/product/product&cid=1&scid=8&id=22)

[A4Tech WWT-13 trackball](https://a4tech.net/product&cid=1&scid=11&id=79)<br>
[A4Tech WWT-13 trackball](http://xahlee.info/kbd/a4tech_wwt-13_scrolltrack_4d_mouse.html)

* List of programs

\- MINIST4D.ACC : driver as an accessory to forward wheels' movement to the AES<br>
\- SCROLL4D.SS : Motorola 68030 assembler source code for the accessoryk<br>
\- SCROLL4D.TXT : Oh my, that looks so old and childish now :) I was in my 20s<br>
\- WWT13DRV.SS : lame attempt to clean the mess and turn it into a TSR driver<br>

* How to use it

Copy the 'MINIST4D.ACC' file at the root of your boot drive (A:, C:, whatever) or in the /ACCS/ folder set by the right utility program, reboot, and voilà. The driver is loaded as an accessory with no effect but display a entry in the Atari menu.

You can use the trackball like a normal mouse, the two wheels work like expected and scroll the vertical and horizontal bar of the window under the mouse cursor.

If you use it in conjonction with GEMRAM and WINX, you can move windows in real time, not just having a dotted lines ghost of the window's frame.

* Known limitations

Crash the OS after a while when using the trackball, maybe some memory leaks here and there, mostly due to the fact I poke directly into the line-A to move the mouse cursor. Needs some stability rework. But beside this completely usable.

* Some infos

The code is dirty and hackish, I was not yet a professional with standards. The accessory build date is 000508, yes, 2000. Almost 17 years back. Sure time flies.
