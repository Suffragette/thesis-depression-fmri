# Statistical interpretation: the locked rules

These rules govern how every result in this project is read and worded. They are
fixed, because the difference between a careful and a careless claim here is the whole
point of the work.

## The six locked rules

1. **Non-significant is not "no effect".** A p-value above threshold means the data
   did not detect an effect, not that the effect is zero.
2. **A passed equivalence test (TOST) is not "exactly zero".** It means an effect *as
   large as the specified bound* can be rejected; smaller effects remain possible.
3. **A failed equivalence test is not support for the original effect.** It means the
   data can neither confirm nor exclude an effect of that size (unresolved).
4. **Direction agreement is not replication.** Matching sign, without significance at
   the reported magnitude, does not count as a reproduced finding.
5. **An NBS null is not "every edge is zero".** It means no connected subnetwork
   survived family-wise-error control, not that each individual edge is null.
6. **A sensitivity branch is not an independent replication.** It re-tests the same
   data under a different choice; agreement across branches is not independent evidence.

## What counts as "reproduced" (dual criterion)

A reported finding is treated as reproduced only if it agrees on **both** direction and
statistical significance at the reported magnitude. Sign agreement alone is never
sufficient; a nominal result that does not survive correction is not counted.

## Excluded vs unresolved

When a finding does not reproduce, the two cases are kept distinct:
- **Excluded:** equivalence testing rejects an effect of the reported size.
- **Unresolved:** the data can neither confirm nor exclude it (usually small samples).

The project never writes "there is no effect"; it writes that a finding "does not
reproduce at the reported magnitude or stability", then labels each case.

## Multiplicity and dependence

Nominal counts are read against an explicit chance baseline. The binomial audit
assumes independence; the empirical permutation null shows inter-edge dependence
inflates the true variability (about 1.3x), so binomial figures are contextual
multiplicity analysis, not a formal model of the original's dependency structure.

## Dependence across analyses

Repeated tests over the same subjects, networks, or scans are not independent. The
project reports a small, dependence-aware direction-agreement count with caveats and
refuses to compute an "overall replication rate" from a pooled list of dependent
comparisons (see `docs/07_study_overlap.md`).

## Vocabulary

- **reanalysis**, not *replication* (same data).
- **prespecified**, not *preregistered* (no public timestamp).
- **standardised** pipeline (not described as newer or superior).
- **confirmatory NBS** = standard Network-Based Statistic (Zalesky 2010); not constrained NBS.
