CC65=	cc65
CL65=	cl65

COPTS=	-Os -Icc65/include -I./inc

TILDACCFILES=	src/jude.c\
		src/karljr.c

TILDAASMFILES=	src/_jude_widgets.s\
		src/_jude.s\
		src/_karljr.s\
		src/_karljr_zp.s

TILDAINCFILES=	Makefile\
		src/_jude_types.inc\
		src/_karljr_types.inc

TILDAHEADERFILES=	inc/jude_widgets.h\
		inc/jude.h\
		inc/karljr.h

.PHONY:		clean

lib/libtilda.a:	$(TILDACCFILES:.c=.o) $(TILDAASMFILES:.s=.o) 
		$(warning ======== Making: $@)
		ar65 r $@ $(TILDACCFILES:.c=.o) $(TILDAASMFILES:.s=.o) 

$(TILDACCFILES:.c=.o):	$(TILDACCFILES:.c=.s)

%.o:	%.s
		$(warning ======== Making: $@)
		ca65 -o $@ $<

$(TILDACCFILES:.c=.s):	$(TILDACCFILES)

%.s:	%.c
		$(warning ======== Making: $@)
		$(CC65) $(COPTS) -o $@ $<

$(TILDAASMFILES:.s=.o):	$(TILDAASMFILES)

$(TILDACCFILES):	$(TILDAHEADERFILES)

$(TILDAASMFILES):	$(TILDAINCFILES)

ifeq ($(OS),Windows_NT)     # is Windows_NT on XP, 2000, 7, Vista, 10...
clean:
		for %%f in (.\\src\\*.o .\\src\\jude.s .\\src\\karljr.s .\\lib\\libtilda.a) do del %%f
else

endif
