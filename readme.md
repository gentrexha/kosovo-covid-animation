# Kosovo COVID-19 Data

## Getting Started

## Usage

```.bash
facebook-scraper --filename data/IKSHPK_page_posts.csv --pages 100 IKSHPK
```

## Notes

`2601685773292744` first case.

### Regex notes

* Get the paragraph with the number of cases: ``Rastet pozitive janë nga:(.*)\.``
* Get header with new cases and healed: ``\d+ TË SHËRUAR DHE \d+ RASTE ME COVID-19!``