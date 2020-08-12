# Kosovo COVID-19 Data

## Getting Started

## Usage

```.bash
facebook-scraper --filename data/IKSHPK_page_posts.csv --pages 50 IKSHPK --encoding utf-8
```

`2601685773292744` first case.

`2601685773292744` first case.

### Regex notes

* Get the paragraph with the number of cases: ``Rastet pozitive janë nga: (.*)\.``
	* Match cities with more than 1 case: `komuna (\w+|\w+\s+\w+) \d+ raste`
	* 1 case cities: `dhe me nga një rast komunat (.*)\.`
		* Names: `\w+\b(?<!\bdhe)`
* Get header with new cases and healed: ``\d+ TË SHËRUAR DHE \d+ RASTE ME COVID-19!``
	* Recovered: `\d+ TË SHËRUAR`
	* New cases: `\d+ RASTE`
* Get new tests paragraph `Gjatë 24 orëve të fundit, (.*) raste pozitive.`
	* Tests: `\d+ mostra`