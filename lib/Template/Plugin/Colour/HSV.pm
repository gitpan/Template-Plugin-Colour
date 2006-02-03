#============================================================= -*-Perl-*-
#
# Template::Plugin::Colour::HSV
#
# DESCRIPTION
#   Template Toolkit plugin for representing colours using the HSV
#   (Hue, Saturation, Value) colour space.
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

package Template::Plugin::Colour::HSV;

use strict;
use warnings;
use base 'Template::Plugin::Colour';

our $VERSION = sprintf("2.%03d", q$Revision: 6 $ =~ /(\d+)/);
our $THROW   = 'Colour.HSV';

use constant HUE => 0;
use constant SAT => 1;
use constant VAL => 2;

*sat  = \&saturation;
*val  = \&value;


sub new {
    my ($proto, $context, @args) = @_;
    my ($class, $self);

    if ($class = ref $proto) {
        $self = bless [@$proto], $class;
    }
    else {
        $self = bless [0, 0, 0], $proto;
    }
    $self->hsv(@args) if @args;
    return $self;
}


sub copy {
    my $self = shift;
    my $args = @_ && ref $_[0] eq 'HASH' ? shift : { @_ };

    # default HSV to $self values.  Note that we use the longer
    # form of 'saturation' and 'value', allowing the user to 
    # specify the shorter form of 'sat' or 'val' which gets 
    # detected before the longer 'saturation' and 'value' in 
    # the hsv() method below
    $args->{ hue } = $self->[HUE] 
        unless defined $args->{ hue };
    $args->{ saturation } = $self->[SAT] 
        unless defined $args->{ saturation };
    $args->{ value } = $self->[VAL] 
        unless defined $args->{ value };

    $self->new('no context', $args);
}

sub hsv {
    my $self = shift;
    my $hsv;

    if (@_ == 1) {
        # single argument is a list or hash ref
        $hsv = shift;
    }
    elsif (@_ == 3) {
        # three arguments provide hue, saturation, and value components
        $hsv = [ @_ ];
    }
    elsif (@_ == 6) {
        # list of six items is hue => $h, saturation => $s, value => $v
        $hsv = { @_ };
    }
    elsif (@_) {
        # any other number of arguments is an error 
        return $self->error("invalid hsv parameter(s): ", join(', ', @_));
    }
    else {
        # return $self when called with no arguments
        return $self;
    }

    # at this point $hsv is a reference to a list or hash, or hsv value

    if (UNIVERSAL::isa($hsv, 'HASH')) {
        # convert hash ref to list
        $hsv->{ sat } = $hsv->{ saturation } unless exists $hsv->{ sat };
        $hsv->{ val } = $hsv->{ value      } unless exists $hsv->{ val };
        $hsv = [  map {
            defined $hsv->{ $_ } 
            ? $hsv->{ $_ } 
            : return $self->error("missing $_ parameter");
        } qw( hue sat val ) ];
    }
    elsif (UNIVERSAL::isa($hsv, 'ARRAY')) {
        # $hsv list is ok as it is
    }
    else {
        # anything else is Not Allowed
        return $self->error("invalid hsv parameter: $hsv");
    }

    # sanity checks: hue is in range 0-359 (circular), saturation 
    # and value in the range 0-255 (clipped)
    $hsv->[HUE] %= 360;
    $hsv->[HUE] += 360 if $hsv->[HUE] < 0;
    $hsv->[SAT]  =   0 if $hsv->[SAT] < 0;
    $hsv->[SAT]  = 255 if $hsv->[SAT] > 255;
    $hsv->[VAL]  =   0 if $hsv->[VAL] < 0;
    $hsv->[VAL]  = 255 if $hsv->[VAL] > 255;

    # update self with new colour
    @$self = @$hsv;

    return $self;
}


sub hue { 
    my $self = shift;
    if (@_) {
        my $hue = shift;
        $self->[HUE] = $hue % 360;
    }
    return $self->[HUE];
}


sub saturation { 
    my $self = shift;
    if (@_) {
        my $sat = shift;
        $sat = 0   if $sat < 0;
        $sat = 255 if $sat > 255;
        $self->[SAT] = $sat;
    }
    return $self->[SAT];
}


sub value { 
    my $self = shift;
    if (@_) {
        my $val = shift;
        $val = 0   if $val < 0;
        $val = 255 if $val > 255;
        $self->[VAL] = $val;
    }
    return $self->[VAL];
}



#------------------------------------------------------------------------
# rgb()
# rgb($r, $g, $b)
#
# Convert HSV to RGB, with optional $r, $g, $b arguments.
#------------------------------------------------------------------------

sub rgb {
    my ($self, @args) = @_;
    my $rgb;

    # generate RGB values from current HSV if no arguments provided
    unless (@args) {
        my ($h, $s, $v) = @$self;
        my ($r, $g, $b);

        if ($s == 0) {
            # TODO: make this truly achromatic
            @args = ($v) x 3;
        }
        else {
            # normalise saturation from range 0-255 to 0-1
            $s /= 255;

            $h /= 60;                          ## sector 0 to 5
            my $i = POSIX::floor( $h );
            my $f = $h - $i;                   ## factorial part of h
            my $p = $v * ( 1 - $s );
            my $q = $v * ( 1 - $s * $f );
            my $t = $v * ( 1 - $s * ( 1 - $f ) );

            if    ($i == 0) { $r = $v; $g = $t; $b = $p }
            elsif ($i == 1) { $r = $q; $g = $v; $b = $p }
            elsif ($i == 2) { $r = $p; $g = $v; $b = $t }
            elsif ($i == 3) { $r = $p; $g = $q; $b = $v }
            elsif ($i == 4) { $r = $t; $g = $p; $b = $v }
            else            { $r = $v; $g = $p; $b = $q }

            @args = map { int } ($r, $g, $b);
        }
    }

    return $self->RGB(@args);
}


sub error {
    my $self = shift;
    die Template::Exception->new($THROW, join('', @_));
}


1;

__END__

=head1 NAME

Template::Plugin::Colour::HSV - Template plugin for HSV colours

=head1 SYNOPSIS

    [% USE col = Colour.HSV(50, 255, 128) %]

    [% col.hue %]                          # 50
    [% col.sat %] / [% col.saturation %]   # 255
    [% col.val %] / [% col.value %]        # 128

=head1 DESCRIPTION

This Template Toolkit plugin module creates an object that represents
a colour in the HSV (hue, saturation, value) colour space.

You can create an HSV colour object by accessing the plugin directly:

    [% USE col = Colour.HSV(50, 255, 128) %]

Or via the Template::Plugin::Colour plugin, specifying the 'HSV' 
colour space in either upper or lower case.

    [% USE col = Colour( hsv = [50, 255, 128] ) %]
    [% USE col = Colour( HSV = [50, 255, 128] ) %]

The final option is to load the Colour plugin and then call the 
HSV method whenever you need a new colour.

    [% USE Colour;
       red   = Colour.HSV(0, 255, 204);
       green = Colour.HSV(120, 255, 204);
       blue  = Colour.HSV(240, 255, 204);
    %]

You can also access the plugin using the 'Color' name instead of
'Colour' (note the spelling difference).

    [% USE col = Color.HSV(50, 255, 128) %]
    [% USE col = Color( hsv = [50, 255, 128] ) %]
    [% USE Color;
       red   = Color.HSV(0, 255, 204);
       green = Color.HSV(120, 255, 204);
       blue  = Color.HSV(240, 255, 204);
    %]

=head1 METHODS

=head2 new(@args)

Create a new HSV colour.  This method is invoked when you C<USE> the 
plugin from within a template.

    [% USE Colour.HSV(50, 255, 128) %]

The colour is specified as three decimal values (or a reference to a
list of three values) representing the hue (0-359 degrees), saturation
(0-255) and value (0-255) components.

    [% USE Colour.HSV(50, 255, 128) %]
    [% USE Colour.HSV([50, 255, 128]) %]

Alternately you can use named parameters

    [% USE Colour.HSV( hue=50, saturation=255, value=128) %]
    [% USE Colour.HSV({ hue=50, saturation=255, value=128 }) %]

You can also create a Colour by calling the HSV method of the 
Colour plugin.  It looks very similar to the above, but you only
need the one USE directive.

    [% USE Colour;
       orange  = Colour.HSV(30, 255, 255);
       lighter = Colour.HSV(30, 127, 255);
       darker  = Colour.HSV(20, 255, 127);
    %]

=head2 copy(@args)

Copy an existing colour.  

    [% orange  = Colour.HSV(30, 255, 255);
       lighter = orange.copy.saturation(127);
    %]

You can specify one or more of the 'hue', 'saturation' (or 'sat') or
'value' (or 'val') parameters to modify the new colour created.

    [% orange  = Colour.HSV('#ff7f00');
       lighter = orange.copy( saturation = 127 );
       darker  = orange.copy( value = 127 );
    %]

=head2 hue($h)

Get or set the hue of the colour.  The value is decimal and
clipped to the range 0-359.

    [% col.hue(300) %]
    [% col.hue %]           # 300

=head2 saturation($s)

Get or set the saturation of the colour.  The value is decimal and
clipped to the range 0..255

    [% col.saturation(255) %]
    [% col.saturation %]         # 255

Lazy people and bad typists will be pleased to know that sat() is
provided as an alias for saturation().

=head2 value($v)

Get or set the value component of the colour.  The value is decimal
and clipped to the range 0..255

    [% col.value(255) %]
    [% col.value %]          # 255

Lazy people and bad typists will be pleased to know that val() is
provided as an alias for value().  But to be honest, if you find it
difficult typing those extra two characters for the greater good of
increased clarity then you should be ashamed of yourself!

=head2 rgb($r,$g,$b)

Convert the HSV colour to one in the RGB (red, green, blue) colour
space, by creating a new Template::Plugin::Colour::RGB object.  If
arguments are provided then these are passed to the RGB constructor
for red, green, and blue parameters.  Otherwise they are computed from
the current HSV colour.

    [% USE hsv = Colour.HSV(210, 170, 48) %]

    [% rgb = hsv.rgb %]
    [% rgb.red       %]    # 16
    [% rgb.green     %]    # 32
    [% rgb.blue      %]    # 48

See Template::Plugin::Colour::RGB for further information.

=head1 AUTHOR

Andy Wardley E<lt>abw@cpan.orgE<gt>

=head1 VERSION

$Revision: 6 $

=head1 COPYRIGHT

Copyright (C) 2006 Andy Wardley.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Template::Plugin::Colour>, L<Template::Plugin::Colour::RGB>,
L<Template::Plugin>


