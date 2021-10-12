# maat

PowerShell module for working with Code Maat

## Reports

### Summary

Produces a summary analysis report.

Columns: statistic, value

### Authors

Produces a report on the number of authors contributing to entities.

Columns: entity, n-authors, n-revs

### Abs-churn

Produces a report on the absolute code churn per date.

Columns: date, added, deleted, commits

### Age

Produces a report on the age of entities.

Columns: entity, age-months

### Author-churn

Produces a report with an analysis of the over all contributions by each individual.

Columns: author, added, deleted, commits

### Communication

Produces a report showing code that people have worked on the same entities.

Communication: author, peer, shared, average, strength

### Coupling

Produces a report on entities that tend to change together.

Columns: entity, coupled, degree, average-revs

### Entity-churn

Produces a report on the churn associated with an entity.

Columns: entity, added, deleted, commits

### Entity-effort

Produces a report on the effort per entity of individual authors.

Columns: entity, author, author-revs, total-revs

### Entity-ownership

Produces a report that helps identify "owners" of entities.

Columns: entity, author, added, deleted

### Fragmentation

Produces a report on the "fragmentation" of work on an entity between multiple developers.

Columns: entity, fractal-value, total-revs

### Identity

Produces a report that indicates the primary developers on an entity.

Columns: author, rev, date, entity, message, loc-added, loc-deleted

### Main-dev

Produces a report that indicates the primary developer on an entity.

Columns: entity, main-dev, added, total-added, ownership

### Main-dev-by-revs

Produces a report that indicates the primary developer on an entity based on revisions.

Columns: entity, main-dev, added, total-added, ownership

### Refactoring-main-dev

Produces a report that indicates the primary developer that's done refactoring on an entity.

Columns: entity, main-dev, removed, total-removed, ownership

### Revisions

Produces a report of the number of revisions on an entity.

Columns: entity, n-revs

### Soc

Produces a "sum of couplings" report.

Columns: entity, soc
