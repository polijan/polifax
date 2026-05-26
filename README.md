```
 --  -___ - --  ___ ___
   - / _ \___- / (_) _/__ ___ __
- - / ___/ _ \/ / / _/ _ `/\ \ /
 - /_/   \___/_/_/_/ \_,_//_\_\ 
  - -
- Polifax: a simple bitmap font
  -  - -- - - - based on Fairfax
```

## Polifax

Polifax is a simple bitmap font based off [Fairfax](https://www.kreativekorp.com/software/fonts/fairfax/) (a mostly-"monospaced (with a 6x12 cell)" bitmap font which supports a large number of Unicode blocks and many private use characters, including [constructed](https://www.kreativekorp.com/ucsur/) scripts).

It comes in several versions:

1. **Polifax**: Focuses mostly on the Latin alphabet and text [pseudo](https://en.wikipedia.org/wiki/Semigraphics)-graphics, as well as basic support for [Sitelen Pona](https://en.wikipedia.org/wiki/Sitelen_Pona), Greek, Cyrillic. It tries to remain lightweight (so that it can be used on the web) and thus unapologetically chooses to focus on text effects and **visuals** instead of proper semantics.
2. **Polifax-full**: Characters which were originally present in Fairfax are added back in this version. This makes the font very similar to Fairfax but with the few modified glyphs and additions from Polifax. This version is much heavier to serve on the web, but is primarily meant to be used in terminal emulators, text editors, word processors, or IDEs.
3. **Polifax-ascii**: Only contains the printable ASCII glyphs. Very lightweight.


## Tools required to build the fonts

* Posix environment tools
* Python interpreter
* The [Bits'n'Picas](https://github.com/kreativekorp/bitsnpicas) bitmap font editor

## Tips & Tricks

* When using Polifax as vector fonts, use a size which is a multiple of 12px (=9pt) to ensure proper sharpness.
* This repo include interesting scripts

## Credits and Appreciations

*Fairfax* and *Bits'n'Picas* are creations from *Rebecca Bettencourt*. I am a big fan of her work with typography, character encoding, conlangs, and software. Furthermore, she is a fellow [tokiponist](https://en.wikipedia.org/wiki/Toki_Pona). So, make sure to check and follow her amazing work at [KreativeKorp](https://kreativekorp.com/).

## Licensing, etc.

TODO
