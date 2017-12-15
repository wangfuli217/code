#!/usr/local/bin/perl -w

# Demonstrate how to use Dialog to create and manipulate dialog objects.
# lusol@Lehigh.EDU  95/06/14


require 5.002;
use Tk;
require Tk::Dialog;
use strict;

my $MW = MainWindow->new;
my $but = $MW->Button(-text => 'Quit', -command => \&exit);
$but->pack;
my $bitmaps = Tk->findINC("demos/images");

my $D1 = $MW->Dialog(
    -title          => 'Dialog Example 1',
    -text           => '',
    -bitmap         => "\@${bitmaps}/noletters",
    -default_button => '3',
    -buttons        => ['OK', '2', '3'],
);
my $D2 = $MW->Dialog(
    -title          => 'Dialog Example 2',
    -text           => 'Frogs lacking lipophores are blue!',
    -bitmap         => 'warning'
);

$D1->configure(
    -wraplength => '6i',
    -justify    => 'right',
    -text       => 'Crest has been shown to be an effective ' .
                   'decay-preventive dentifrice that can be of significant ' .
                   'value when used in a conscientiously applied program ' .
                   'of oral hygiene and regular professional care.',
);
$D1->configure(-bg => 'yellow', -fg => 'blue');
print "Selected button = ", $D1->Show, ".\n";

$D2->Show('-global');

$D2->configure(-text => 'Change message text.');
$D2->Show;
$D2->configure(-text => 'New font.', -font => '-*-helvetica-bold-r-*-*-*-240-*-*-*-*-*-*');
$D2->Show;
$D2->configure(-text => 'New color.', -foreground => 'cyan');
$D2->Show;

$D2->configure(-text => 'New bitmap and background color.');
$D2->configure(-bitmap => "\@$bitmaps/flagup", -background => 'red');
Show $D2;

$D2->configure(-bitmap => undef, -bg => ($D2->configure(-bg))[3]);
$D2->Subwidget('message')->configure(
    -text       => 'Now remove the bitmap ...',
    -wraplength => '3i',
);
$D2->Show;

$D2->configure(-bitmap => "\@$bitmaps/flagdown");
$D2->Subwidget('message')->configure(
    -text    => 'and restore Flagdown!',
    -justify => 'center',
);
$D2->Show;

MainLoop;
