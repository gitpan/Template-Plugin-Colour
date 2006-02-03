#============================================================= -*-Perl-*-
#
# Template::Plugin::Color
#
# DESCRIPTION
#   Wrapper around the Template::Plugin::Colour module for those who
#   spell 'Colour' the American way, 'Color'.
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

package Template::Plugin::Color;

use strict;
use warnings;
use base 'Template::Plugin::Colour';
use Template::Plugin::Color::RGB;
use Template::Plugin::Color::HSV;

our $VERSION = sprintf("2.%03d", q$Revision: 6 $ =~ /(\d+)/);
our $PLUGINS = {
    RGB => 'Template::Plugin::Color::RGB',
    HSV => 'Template::Plugin::Color::HSV',
};


sub RGB {
    my $self = shift;
    $PLUGINS->{RGB}->new('no context', @_);
}


sub HSV {
    my $self = shift;
    $PLUGINS->{HSV}->new('no context', @_);
}


1;

__END__

=head1 NAME

Template::Plugin::Color - Template plugin for color manipulation

=head1 SYNOPSIS

    # long or short hex triplets, with or without '#'
    [% USE Color('abc')     %]    
    [% USE Color('#abc')    %]   
    [% USE Color('ff0000')  %] 
    [% USE Color('#ff0000') %]

    # decimal r, g, b values
    [% USE Color(255, 128, 0) %]

    # named parameters
    [% USE Color( red=255, green=128, blue=0 ) %]
    [% USE Color( hue=30, saturation=255, value=255 ) %]

    # explicit colour space
    [% USE Color( rgb = [255, 128, 00] ) %] 
    [% USE Color( hsv = [30, 255, 255] ) %] 

    # alternately, call Color methods
    [% USE Color;

       # create RGB colours
       red    = Color.RGB('#c00');
       green  = Color.RGB('#0c0');
       blue   = Color.RGB('#00c');

       # create HSV colours
       orange = Color.HSV(30, 255, 255);
    %]

=head1 DESCRIPTION

The Template::Plugin::Color module allows you to define and manipulate
colours using the RGB (red, green, blue) and HSV (hue, saturation,
value) colour spaces.

It is implemented as a subclass of Template::Plugin::Colour (note the 
spelling difference) and is provided as a convenience for Americans
and other international users who spell 'Colour' as 'Color'.

Please see the documentation for L<Template::Plugin::Colour> for 
further details.  Wherever you see 'Colour', you can safely write
it as 'Color'.

=head1 AUTHOR

Andy Wardley E<lt>abw@cpan.orgE<gt>

=head1 VERSION

$Revision: 6 $

=head1 COPYRIGHT

Copyright (C) 2006 Andy Wardley.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Template::Plugin::Colour>


