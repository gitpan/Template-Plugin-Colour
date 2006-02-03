#============================================================= -*-Perl-*-
#
# Template::Plugin::Color::HSV
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

package Template::Plugin::Color::HSV;

use strict;
use warnings;
use base 'Template::Plugin::Colour::HSV';

our $VERSION = sprintf("2.%03d", q$Revision: 6 $ =~ /(\d+)/);
our $THROW   = 'Color.HSV';

sub error {
    my $self = shift;
    die Template::Exception->new($THROW, join('', @_));
}


1;

__END__

=head1 NAME

Template::Plugin::Color - Template plugin for colour manipulation

=head1 SYNOPSIS

    [% USE col = Colour.HSV(50, 255, 128) %]

    [% col.hue %]                          # 50
    [% col.sat %] / [% col.saturation %]   # 255
    [% col.val %] / [% col.value %]        # 128

=head1 DESCRIPTION

The Template::Plugin::Color::HSV plugin module creates an object that
represents a colour in the HSV (hue, saturation, value) colour space.

It is implemented as a subclass of Template::Plugin::Colour::HSV (note
the spelling difference) and is provided as a convenience for
Americans and other international users who spell 'Colour' as 'Color'.

Please see the documentation for L<Template::Plugin::Colour::HSV> for
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

L<Template::Plugin::Colour::HSV>


