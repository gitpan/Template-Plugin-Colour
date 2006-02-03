#============================================================= -*-perl-*-
#
# t/hsv.t
#
# Test the Template::Plugin::Colour::HSV module.
#
# Copyright (C) 2006 Andy Wardley.  All Rights Reserved.
#
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: hsv.t 6 2006-02-03 11:59:29Z abw $
#
#========================================================================

use strict;
use warnings;
use lib qw( ./lib ../lib );
use Template::Test;

test_expect(\*DATA, undef, { ttv => $Template::VERSION });

__DATA__

-- test --
[% USE Colour;
   hsv = Colour.HSV(210, 170, 48) -%]
col: [% hsv.rgb.hex %]
-- expect --
col: 102030

-- test --
[% USE hsv = Colour( hsv = [210, 170, 48] ) -%]
col: [% hsv.rgb.hex %]
-- expect --
col: 102030

-- test --
[% USE hsv = Colour.HSV(210, 170, 48) -%]
col: [% hsv.rgb.hex %]
-- expect --
col: 102030

-- test --
[% USE hsv = Colour.HSV(hue=210, saturation=170, value=48) -%]
col: [% hsv.rgb.hex %]
-- expect --
col: 102030

-- test --
[% USE Colour -%]
  red: [% Colour.RGB('#c00').hsv.join('/') %]
green: [% Colour.RGB('#0c0').hsv.join('/') %]
 blue: [% Colour.RGB('#00c').hsv.join('/') %]
-- expect --
  red: 0/255/204
green: 120/255/204
 blue: 240/255/204


-- test --
-- name Colour.HSV exception --
[% TRY;
     USE Colour.HSV('I should not', 'be allowed to', 'operate a', 'computer');
   CATCH;
     error;
   END
%]
-- expect --
Colour.HSV error - invalid hsv parameter(s): I should not, be allowed to, operate a, computer



#------------------------------------------------------------------------
# Check 'Color' works as 'Colour' for y'all out there in the US of A.
#------------------------------------------------------------------------
-- test --

[% USE Color;
   hsv = Color.HSV(210, 170, 48) -%]
col: [% hsv.rgb.hex %]
-- expect --
col: 102030


-- test --
-- name Color.HSV exception --
[% TRY;
     USE Color.HSV('I should not', 'be allowed to', 'operate a', 'computer');
   CATCH;
     error;
   END
%]
-- expect --
Color.HSV error - invalid hsv parameter(s): I should not, be allowed to, operate a, computer

