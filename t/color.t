#============================================================= -*-perl-*-
#
# t/color.t
#
# Test the Template::Plugin::Color modules.  These are just wrappers
# around the T::P::Colour modules, provided for our American friends
# and other international users who spell 'Colour' as 'Color'.  We 
# aim to please here at TT Command  :-)
#
# Copyright (C) 2006 Andy Wardley.  All Rights Reserved.
#
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: color.t 8 2006-02-03 12:07:34Z abw $
#
#========================================================================

use strict;
use warnings;
use lib qw( ./lib ../lib );
use Template::Test;

test_expect(\*DATA, undef, { ttv => $Template::VERSION });

__DATA__

-- test --
[% USE Color( rgb => '#123456' ) -%]
col: [% Color.hex %]
-- expect --
col: 123456

-- test --
[% USE rgb = Color( rgb => '#0066b3' ) -%]
  red: [% rgb.red %]
green: [% rgb.green %]
 blue: [% rgb.blue %]
 grey: [% rgb.grey %]
  red: [% rgb.red(100) %]
  hex: [% rgb.hex %]
 html: [% rgb.html %]
-- expect --
  red: 0
green: 102
 blue: 179
 grey: 84
  red: 100
  hex: 6466b3
 html: #6466b3

-- test --
[% USE hsv = Color( hsv => [50, 100, 150] ) -%]
  hue: [% hsv.hue %]
  sat: [% hsv.sat %] / [% hsv.saturation %]
  val: [% hsv.val %] / [% hsv.value %]
-- expect --
  hue: 50
  sat: 100 / 100
  val: 150 / 150

-- test --
[% USE rgb = Color('#102030');
   hsv = rgb.hsv; rgb = hsv.rgb
-%]
 rgb: [% rgb.red %] / [% rgb.green %] / [% rgb.blue %]
 hsv: [% hsv.hue %] / [% hsv.sat %] / [% hsv.val %]
 rgb.join: [% rgb.join(', ') %]
 hsv.join: [% hsv.join(', ') %]
-- expect --
 rgb: 16 / 32 / 48
 hsv: 210 / 170 / 48
 rgb.join: 16, 32, 48
 hsv.join: 210, 170, 48

-- test -- 
[% USE col = Color(17, 34, 51); "col: $col.hex" %]
-- expect --
col: 112233

-- test -- 
[% USE col = Color('112233'); "col: $col.hex" %]
-- expect --
col: 112233

-- test -- 
[% USE col = Color(17, 34, 51) -%]
[% col.0 %]/[% col.1 %]/[% col.2 %]
-- expect --
-- process --
[% IF ttv.match('^2\.14\w') or ttv > 2.14 -%]
17/34/51
[% ELSE -%]
//
[% END %]


-- test --
-- name Color exception --
[% TRY;
     USE Color(10, 20, 30, 40, 50, "I don't know", "what I am doing");
   CATCH;
     error;
   END
%]
-- expect --
Color.RGB error - invalid rgb parameter(s): 10, 20, 30, 40, 50, I don't know, what I am doing

