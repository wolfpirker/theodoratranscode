README

This program uses the command ffmpeg2theora to transcode videos. 
ffmpeg2theora can transcode any videofiles ffmpeg can too. 

Where this program tries to be better than (some) alternatives:
* most free GUI programms where conversion to theora-transcoded ogv files  is 
supported, lack some options ffmpeg2theora provides; 
* many do not have a proper preview feature 
* in some the quality of the video seems to be less optimized for Theora videos 
than with ffmpeg2theora
* some do not offer the possiblity to transcode several files at the same time
* some do not offer a color correction adjustment feature

...this program tries to be better with that

About the name:

The name "Theodora Transcode" was partly inspired by the transcoder "Arista Transcode".
The video codec ffmpeg2theora uses is called Theora, so I thought Theodora is a great name.  

The name "Theodora" has its origin in the Greek language (theos = god, doron = gift).
A Russian form of this name is Fedora.

Plans:
* currently I have not big plans with more features, but sure the application will get
more polished in the next months
* midterm TODO's:
	- better integrate in GNOME 3 (instead of giving the easy possibility to destroy
the app during conversion, make use of the notification bar)
	- possibly give better Feedback, in the GUI when there is an ongoing conversion
	- perhaps: make the program compatible with some Windows releases
* possiblities in the longer term:  
	- instead of only being a GUI for ffmpeg2theora, it might be possible to implement
	other commandline transcoders as alternative (e.g. ffmpeg, h264enc, or commandline 
	tools for upcoming codecs such as Daala, VP9)

Note for anyone playing with the C or Vala files: this program was developed with Vala. 
But to avoid the Vala dependency: the Make-, configure- and scriptfiles are configured to 
use the C files instead! 

If you have any suggestions, feedback or if you want to contribute somehow,
feel free to send me a message to w_pirker@gmx.de 
