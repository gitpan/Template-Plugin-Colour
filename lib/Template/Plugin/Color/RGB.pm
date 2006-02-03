#============================================================= -*-Perl-*-
#
# Template::Plugin::Color::RGB
#
# DESCRIPTION
#   Subclass of Template::Plugin::Colour for those who spell it 'Color'.
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

package Template::Plugin::Color::RGB;

use strict;
use warnings;
use base 'Template::Plugin::Colour::RGB';

our $VERSION = sprintf("2.%03d", q$Revision: 6 $ =~ /(\d+)/);
our $THROW   = 'Color.RGB';

sub error {
    my $self = shift;
    die Template::Exception->new($THROW, join('', @_));
}


1;

__END__

=head1 NAME

Template::Plugin::Color - Template plugin for colour manipulation

=head1 SYNOPSIS

    # long or short hex triplets, with or without '#'
    [% USE col = Color.RGB('abc')     %]    
    [% USE col = Color.RGB('#abc')    %]   
    [% USE col = Color.RGB('ff0000')  %] 
    [% USE col = Color.RGB('#ff0000') %]

    # decimal r, g, b values
    [% USE col = Color.RGB(255, 128, 0) %]

    # named parameters
    [% USE col = Color.RGB(red = 255, green = 128, blue = 0) %]

=head1 DESCRIPTION

The Template::Plugin::Color::RGB module allows you to represent and
manipulate colours using the RGB (red, green, blue) colour space.

It is implemented as a subclass of Template::Plugin::Colour::RGB (note
the spelling difference) and is provided as a convenience for
Americans and other international users who spell 'Colour' as 'Color'.

Please see the documentation for L<Template::Plugin::Colour::RGB> for
further details.  Wherever you see 'Colour', you can safely write it
as 'Color'.

=head1 AUTHOR

Andy Wardley E<lt>abw@cpan.orgE<gt>

=head1 VERSION

$Revision: 6 $

=head1 COPYRIGHT

Copyright (C) 2006 Andy Wardley.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Template::Plugin::Colour::RGB>


