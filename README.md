# xplyr

`xplyr` is a small experiment around a simple question:

**after I transform a data frame, what actually changed?**

Inspired by ideas from Bret Victor and Seymour Papert, `xplyr` is meant to be used in teaching and learning contexts, where making the consequences of a transformation visible can help students understand how data changes through a pipeline.

```r
library(dplyr)
library(xplyr)

starwars |>
  filter(mass > 50) |>
  mutate(bmi = mass / (height / 100)^2)
```

`xplyr` keeps ordinary `dplyr` syntax and adds a small amount of contextual feedback. It does not try to judge whether code is right or wrong.

This experiment sits alongside projects such as [`tidylog`](https://github.com/elbersb/tidylog), [`skimr`](https://docs.ropensci.org/skimr/), and [`pointblank`](https://rstudio.github.io/pointblank/), which make data operations, profiles, or validation visible in different ways. `xplyr` is not intended to compete with them; it simply explores whether showing a few consequences at the moment a transformation happens can be useful for teaching and learning `dplyr`.

For now the experiment is intentionally small: local data frames, `filter()` and `mutate()`, and textual console output.

By default only a few notable changes are shown. To see everything detected:

```r
options(xplyr.max_changes = Inf)
```
