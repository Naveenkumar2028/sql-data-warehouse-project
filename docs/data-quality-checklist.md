# Data Quality Checklist

Use this checklist when moving data from the Bronze layer into Silver and Gold.

## 1. Completeness

- [ ] Confirm every expected source file was loaded.
- [ ] Compare source row counts with Bronze row counts.
- [ ] Identify required columns that contain `NULL` values.
- [ ] Check that key business fields are populated before modeling.

## 2. Validity

- [ ] Validate dates and reject impossible values.
- [ ] Confirm numeric columns contain numeric values and expected ranges.
- [ ] Check categorical values against the approved business vocabulary.
- [ ] Verify foreign-key values exist in the related dimension or source table.

## 3. Consistency

- [ ] Standardize casing, whitespace, and text formatting.
- [ ] Apply one date and currency convention across all source systems.
- [ ] Normalize product, customer, and category identifiers.
- [ ] Confirm the same business rule is used across Silver transformations.

## 4. Uniqueness

- [ ] Check for duplicate source records.
- [ ] Confirm dimension keys are unique.
- [ ] Verify the grain of each fact table before aggregating.
- [ ] Investigate duplicate business events instead of silently dropping them.

## 5. Reconciliation

- [ ] Compare Silver totals with Bronze totals after documented exclusions.
- [ ] Reconcile Gold revenue and quantity metrics with trusted source totals.
- [ ] Record row-count and amount differences for each pipeline run.
- [ ] Document any accepted variance and its reason.

## 6. Release Gate

Before publishing a Gold model or report:

- [ ] All critical checks pass.
- [ ] Failed checks have an owner and documented resolution.
- [ ] Transformation assumptions are recorded in the data catalog.
- [ ] A sample business query returns expected results.

A repeatable checklist makes data quality visible and helps prevent silent errors from reaching analytics users.
