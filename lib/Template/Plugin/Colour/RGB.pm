#============================================================= -*-Perl-*-
#
# Template::Plugin::Colour::RGB
#
# DESCRIPTION
#   Template Toolkit plugin for representing RGB colours.
#
# AUTHOR
#   Andy Wardley   <abw@cpan.org>
#
# COPYRIGHT
#   Copyright (C) 2006 Andy Wardley.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
# REVISION
#   $Revision: 6 $
#
#============================================================================

package Template::Plugin::Colour::RGB;

use strict;
use warnings;
use base 'Template::Plugin::Colour';

our $VERSION = sprintf("2.%03d", q$Revision: 6 $ =~ /(\d+)/);
our $THROW   = 'Colour.RGB';

use constant RED   => 0;
use constant GREEN => 1;
use constant BLUE  => 2;


sub new {
    my ($proto, $context, @args) = @_;
    my ($class, $self);

    if ($class = ref $proto) {
        $self = bless [@$proto], $class;
    }
    else {
        $self = bless [0, 0, 0], $proto;
    }
    $self->rgb(@args) if @args;
    return $self;
}


sub copy {
    my $self = shift;
    my $args = @_ && ref $_[0] eq 'HASH' ? shift : { @_ };
    $args->{ red   } = $self->[RED]   unless defined $args->{ red   };
    $args->{ green } = $self->[GREEN] unless defined $args->{ green };
    $args->{ blue  } = $self->[BLUE]  unless defined $args->{ blue  };
    $self->new('no context', $args);
}


sub rgb {
    my $self = shift;
    my $col;

    if (@_ == 1) {
        # single argument is a list or hash ref, or RGB value
        $col = shift;
    }
    elsif (@_ == 3) {
        # three arguments provide red, green, blue components
        $col = [ @_ ];
    }
    elsif (@_ == 6) {
        # list of six items is red => $r, green => $g, blue => $b
        $col = { @_ };
    }
    elsif (@_) {
        # any other number of arguments is an error 
        return $self->error("invalid rgb parameter(s): ", join(', ', @_));
    }
    else {
        # return $self when called with no arguments
        return $self;
    }
    
    # at this point $col is a reference to a list or hash, or a rgb value

    if (UNIVERSAL::isa($col, 'HASH')) {
        # convert hash ref to list
        $col = [  map {
            defined $col->{ $_ } 
            ? $col->{ $_ } 
            : return $self->error("missing $_ colour parameter");
        } qw( red green blue ) ];
    }
    elsif (UNIVERSAL::isa($col, 'ARRAY')) {
        # $col list is ok as it is
    }
    elsif (ref $col) {
        # anything other kind of reference is Not Allowed
        return $self->error("invalid rgb parameter: $col");
    }
    else {
        $self->hex($col);
        return $self;
    }

    # ensure all rgb component values are in range 0-255
    for (@$col) {
        $_ =   0 if $_ < 0;
        $_ = 255 if $_ > 255;
    }

    # update self with new colour, also deletes any cached HSV
    @$self = @$col;

    return $self;
}


sub hex {
    my $self = shift;

    if (@_) {
        my $hex = shift;

        if ($hex =~ / ^ 
           \#?            # short form of hex triplet: #abc
           ([0-9a-f])     # red 
           ([0-9a-f])     # green
           ([0-9a-f])     # blue
           $
           /ix) {
            @$self = map { hex } ("$1$1", "$2$2", "$3$3");
        }
        elsif ($hex =~ / ^ 
           \#?            # long form of hex triple: #aabbcc
           ([0-9a-f]{2})  # red 
           ([0-9a-f]{2})  # green
           ([0-9a-f]{2})  # blue
           $
           /ix) {
            @$self = map { hex } ($1, $2, $3);
        }
        else {
            return $self->error("invalid hex colour: $hex\n");
        }
    }
    return sprintf("%02x%02x%02x", @$self);
}

sub HEX {
    my $self = shift;
    return uc $self->hex(@_);
}

sub html {
    my $self = shift;
    return '#' . $self->hex(@_);
}

sub HTML {
    my $self = shift;
    return '#' . uc $self->hex(@_);
}


sub red { 
    my $self = shift;
    return @_ ? ($self->[RED] = shift) : $self->[RED];
}


sub green { 
    my $self = shift;
    return @_ ? ($self->[GREEN] = shift) : $self->[GREEN];
}


sub blue { 
    my $self = shift;
    return @_ ? ($self->[BLUE] = shift) : $self->[BLUE];
}


sub grey  { 
    my $self = shift;

    if (@_) {
        return ($self->[RED] = $self->[GREEN] = $self->[BLUE] = shift);
    }
    else {
        return int( $self->[RED]  * 0.222 
                  + $self->[GREEN]* 0.707 
                  + $self->[BLUE] * 0.071 );
    }
}


#------------------------------------------------------------------------
# hsv()
# hsv($h, $s, $v)
#
# Convert RGB to HSV, with optional $h, $s and/or $v arguments.
#------------------------------------------------------------------------

sub hsv {
    my ($self, @args) = @_;
    my $hsv;

    # generate HSV values from current RGB if no arguments provided
    unless (@args) {
        my ($r, $g, $b) = @$self;
        my ($h, $s, $v);
        my $min   = $self->min($r, $g, $b);
        my $max   = $self->max($r, $g, $b);
        my $delta = $max - $min;
        $v = $max;                              

        if($delta){
            $s = $delta / $max;
            if ($r == $max) {
                $h = 60 * ($g - $b) / $delta; 
            }
            elsif ($g == $max) {
                $h = 120 + (60 * ($b - $r) / $delta); 
            }
            else { # if $b == $max 
                $h = 240 + (60 * ($r - $g) / $delta);
            }
            
            $h += 360 if $h < 0;  # hue is in the range 0-360
            $h = int( $h + 0.5 ); # smooth out rounding errors
            $s = int($s * 255);   # expand saturation to 0-255
        }
        else {
            $h = $s = 0;
        }
        @args = ($h, $s, $v);
    }

    $self->HSV(@args);
}

sub error {
    my $self = shift;
    die Template::Exception->new($THROW, join('', @_));
}


1;

__END__

=head1 NAME

Template::Plugin::Colour - Template plugin for colour manipulation

=head1 SYNOPSIS

    # long or short hex triplets, with or without '#'
    [% USE col = Colour.RGB('abc')     %]    
    [% USE col = Colour.RGB('#abc')    %]   
    [% USE col = Colour.RGB('ff0000')  %] 
    [% USE col = Colour.RGB('#ff0000') %]

    # decimal r, g, b values
    [% USE col = Colour.RGB(255, 128, 0) %]

    # named parameters
    [% USE col = Colour.RGB(red = 255, green = 128, blue = 0) %]

=head1 DESCRIPTION

This Template Toolkit plugin module allows you to represent and
manipulate colours using the RGB (red, green, blue) colour space.

You can create an RGB colour object by accessing the plugin directly:

    [% USE col = Colour.RGB('#112233') %]

Or via the Template::Plugin::Colour plugin.  

    [% USE col = Colour('#112233') %]

The default colour space is RGB so there's no need to specify it, but
you can if you like:

    [% USE col = Colour( rgb = '#112233' ) %]

The final option is to load the Colour plugin and then call the 
RGB method whenever you need a new colour.

    [% USE Colour;
       red   = Colour.RGB('#c00');
       green = Colour.RGB('#0c0');
       blue  = Colour.RGB('#00c');
    %]

You can also access the plugin using the 'Color' name instead of
'Colour' (note the spelling difference).

    [% USE col = Color.RGB('#112233') %]
    [% USE col = Color('#112233') %]
    [% USE Color;
       red   = Color.RGB('#c00');
       green = Color.RGB('#0c0');
       blue  = Color.RGB('#00c');
    %]

=head1 METHODS

=head2 new(@args)

Create a new RGB colour.  This method is invoked when you C<USE> the 
plugin from within a template.

    [% USE col = Colour.RGB('#ffccdd') %]

The colour can be specified as a short (3 digit) or long (6 digit)
hexadecimal number, with or without the leading '#'.  A list or
reference to a list of decimal red, green and blue values can also be
provided:

    [% USE col = Colour.RGB(100, 200, 300) %]
    [% USE col = Colour.RGB([100, 200, 300]) %]

Alternately, you can use a list or reference to a hash array of named
parameters:

    [% USE col = Colour.RGB( red=100, green=200, blue=250 ) %]
    [% USE col = Colour.RGB({ red=100, green=200, blue=250 }) %]

You can also create a Colour by calling the RGB method of the 
Colour plugin.  It looks very similar to the above, but you only
need the one USE directive.

    [% USE Colour;
       red   = Colour.RGB('#ff0000');
       green = Colour.RGB('#00ff00');
       blue  = Colour.RGB('#0000ff');
    %]

=head2 copy(@args)

Copy an existing colour.  

    [% orange = Colour.RGB('#ff7f00');
       redder = orange.copy.green(32);
    %]

You can specify one or more of the 'red', 'green' or 'blue' 
parameters to modify the new colour created.

    [% orange = Colour.RGB('#ff7f00');
       redder = orange.copy(green=32);
    %]

=head2 rgb($r,$g,$b)

Method to set all of the red, green and blue components in one go.
Any of the supported argument formats can be used.

    [% col.rgb('#ff1020') %]
    [% col.rgb(255, 16, 32) %]
    [% col.rgb(red=255, green=16, blue=32) %]

When called without any arguments it simply returns itself, a blessed
reference to a list of red, green and blue components.  This is
effectively a no-op, but can be useful to ensure that you have a colour
defined in a particular colour space.

For example, say we have two colours, one of which is defined in the
RGB colour space, the other in HSV (Hue, Saturation, Value - see
L<Template::Plugin::Colour::HSV>).

    [% red    = Colour.RGB('#C00');
       orange = Colour.HSV(30, 255, 255);
    %]

If we iterate over these colours in a FOREACH loop then we can't be 
sure if the colour we're looking at is defined in the RGB or HSV colour
space.  By calling the 'rgb' method against it we can convert any
HSV colours to RGB, and leave those that are already RGB as they are.

    [% FOREACH col IN [red, orange] %]
       <span style="background-color: [% col.rgb.html %]">
        Sample Colour: [% col.rgb.html %]
       </span>
    [% END %]

=head2 red($r)

Get or set the red component of the colour.  The value is decimal and
clipped to the range 0..255

    [% col.red(255) %]
    [% col.red %]           # 255

=head2 green($g)

Get or set the green component of the colour.  The value is decimal and
clipped to the range 0..255

    [% col.green(255) %]
    [% col.green %]         # 255

=head2 blue($b)

Get or set the blue component of the colour.  The value is decimal and
clipped to the range 0..255

    [% col.blue(255) %]
    [% col.blue %]          # 255

=head2 grey($g)

Get or set the greyscale value of the colour.  When called with an
argument, it sets each of the red, green and blue components to that
value.

    [% col.grey(128) %]
    [% col.red   %]         # 128
    [% col.green %]         # 128
    [% col.blue  %]         # 128

When called without an argument, it returns the greyscale value for
the current RGB colour.  Because our eyes do not perceive the
different red, green and blue components with equal intensity (green
is the dominant colour in defining the perception of brightness,
whereas blue contributes very little), the value returned is one 
based on the following formula which is widely accepted to give
the most accurate value:

    (red * 0.222) + (green * 0.707) + (blue * 0.071)

=head2 hex($x)

Get or set the value using hexadecimal notation.  When called with an 
argument, it sets the red, green and blue components according to the 
value.  This can be specified in short (3 digit) or long (6 digit) form,
with or without a leading '#'.

    [% col.hex('369')     %]
    [% col.hex('#369')    %]
    [% col.hex('336699')  %]
    [% col.hex('#336699') %]

When called without any arguments, it returns the current value as
a 6 digit hexadecimal string without the leading '#'.

    [% col.hex %]               # 336699

Any alphabetical characters ('a'-'f') are output in lower case.

    [% col.hex('#AABBCC') %]
    [% col.hex %]               # aabbcc

Use the HEX() method if you want them output in upper case.

=head2 HEX($x)

Wrapper around the hex() method which returns the hex string
converted to upper case.

    [% col.hex('#aabbcc') %]
    [% col.hex %]               # AABBCC

=head2 html($h)

Wrapper around the hex() method which prefixes the returned value
with a '#', suitable for using directly as an HTML or CSS colour.

    [% col.hex('#aabbcc') %]
    [% col.html %]              # #aabbcc

=head2 HTML($h)

Same as the html() method, but returning the colour in upper case,
as per HEX().

    [% col.hex('#aabbcc') %]
    [% col.html %]              # #AABBCC

=head2 hsv($h,$s,$v)

Convert the RGB colour to one in the HSV (hue, saturation, value)
colour space, by creating a new Template::Plugin::Colour::HSV object.
If arguments are provided then these are passed to the HSV constructor
for hue, saturation and value parameters.  Otherwise they are computed
from the current RGB colour.

    [% USE rgb = Colour('#102030') %]

    [% hsv = rgb.hsv  %]
    [% hsv.hue        %]    # 210  
    [% hsv.saturation %]    # 170
    [% hsv.value      %]    #  48

See Template::Plugin::Colour::HSV for further information.

=head1 AUTHOR

Andy Wardley E<lt>abw@cpan.orgE<gt>

=head1 VERSION

$Revision: 6 $

=head1 COPYRIGHT

Copyright (C) 2006 Andy Wardley.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Template::Plugin::Colour>, L<Template::Plugin::Colour::HSV>,
L<Template::Plugin>


