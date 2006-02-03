#============================================================= -*-perl-*-
#
# t/rgb.t
#
# Test the Template::Plugin::Colour::RGB module.
#
# Copyright (C) 2006 Andy Wardley.  All Rights Reserved.
#
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id: rgb.t 8 2006-02-03 12:07:34Z abw $
#
#========================================================================

use strict;
use warnings;
use lib qw( ./lib ../lib );
use Template;
use Template::Test;


test_expect(\*DATA, undef, { ttv => $Template::VERSION });

__DATA__

-- test --
[% USE Colour;
   c = Colour.RGB('#123456' ) -%]
col: [% c.hex %]
-- expect --
col: 123456

-- test --
[% USE c = Colour.RGB('#123456' ) -%]
col: [% c.hex %]
-- expect --
col: 123456

-- test --
[% USE rgb = Colour.RGB('#0066b3') -%]
  red: [% rgb.red %]
green: [% rgb.green %]
 blue: [% rgb.blue %]
 grey: [% rgb.grey %]
  red: [% rgb.red(100) %]
  hex: [% rgb.hex %]
 html: [% rgb.html %]
  HEX: [% rgb.HEX %]
 HTML: [% rgb.HTML %]
-- expect --
  red: 0
green: 102
 blue: 179
 grey: 84
  red: 100
  hex: 6466b3
 html: #6466b3
  HEX: 6466B3
 HTML: #6466B3

-- test --
[% USE rgb = Colour.RGB('#102030');
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
[% USE col = Colour.RGB(17, 34, 51); "col: $col.hex" %]
-- expect --
col: 112233

-- test -- 
[% USE col = Colour.RGB('112233'); "col: $col.hex" %]
-- expect --
col: 112233

-- test -- 
[% USE col = Colour.RGB(17, 34, 51) -%]
[% col.0 %]/[% col.1 %]/[% col.2 %]
-- expect --
-- process --
[% IF ttv.match('^2\.14\w') or ttv > 2.14 -%]
17/34/51
[% ELSE -%]
//
[% END %]


-- test --
-- name Colour.RGB exception --
[% TRY;
     USE Colour.RGB(10, 20, 30, 40, 50, "I don't know", "what I am doing");
   CATCH;
     error;
   END
%]
-- expect --
Colour.RGB error - invalid rgb parameter(s): 10, 20, 30, 40, 50, I don't know, what I am doing



#------------------------------------------------------------------------
# Check 'Color' works as 'Colour' for y'all out there in the US of A.
#------------------------------------------------------------------------
-- test --

[% USE c = Color.RGB('#123456' ) -%]
col: [% c.hex %]
-- expect --
col: 123456


-- test --
-- name Color.RGB exception --
[% TRY;
     USE Color.RGB(10, 20, 30, 40, 50, "I don't know", "what I am doing");
   CATCH;
     error;
   END
%]
-- expect --
Color.RGB error - invalid rgb parameter(s): 10, 20, 30, 40, 50, I don't know, what I am doing


