# xplyr

`xplyr` is a small experiment around a simple question:

**after I transform a data frame, what actually changed?**

Inspired by ideas from Bret Victor and Seymour Papert, `xplyr` explores whether computation can make the consequences of a transformation easier to see and reason about, instead of asking the user to reconstruct them mentally. This can be useful while exploring or debugging data, and also in teaching contexts.

```r
library(dplyr)
library(xplyr)

starwars |>
  filter(mass > 50) |>
  mutate(bmi = mass / (height / 100)^2)
```

`xplyr` keeps ordinary `dplyr` syntax and adds a small amount of contextual feedback. It does not try to judge whether code is right or wrong.

This experiment sits alongside projects such as [`tidylog`](https://github.com/elbersb/tidylog), [`skimr`](https://docs.ropensci.org/skimr/), and [`pointblank`](https://rstudio.github.io/pointblank/), which make data operations, profiles, or validation visible in different ways. `xplyr` is not intended to compete with them; it simply explores whether showing a few consequences at the moment a transformation happens can make data pipelines easier to understand.

For now the experiment is intentionally small: local data frames, `filter()` and `mutate()`, and textual console output.

By default only a few notable changes are shown. To see everything detected:

```r
options(xplyr.max_changes = Inf)
```
