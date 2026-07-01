# Robustness & Validation

<!-- Working draft (Markdown). Paste polished text into Word/Docs.
     Numbers are from scripts/stata/validation_moderators.do → ${tables}/Validation_*.csv
     (run log 2026-07-01). Construct reframed to influencer disclosure propensity; validation
     numbers are identical for the identified classes (see §3 robustness for the two-step
     bootstrap that separates this from a within-post surprise effect). -->

Because the moderating role of **influencer disclosure propensity** (`c1`) was identified from a
set of fifteen candidate moderators, we subject it to three validation exercises designed to
separate a genuine effect from a multiple-comparisons artifact or an overfit to our
particular sample. The engagement outcomes are log-transformed counts,
$\ln(1 + \text{retweets})$ and $\ln(1 + \text{replies})$ — the $+1$ retains posts with zero
engagement. All specifications retain the full control set, influencer / month / hour fixed
effects, and standard errors clustered at the influencer level (≈150 clusters). The exercises
are implemented in `scripts/stata/validation_moderators.do`.

## A. Family-wise correction (full sample)

Estimating each of the fifteen moderators on the full sample and applying a **Holm
step-down correction** (separately by outcome), influencer disclosure propensity is the **only**
moderator that remains significant for *either* outcome — and it survives for **both** (under
naive clustered SEs; see §3 for the two-step bootstrap caveat):

| Outcome | Raw joint *p* | Holm-adjusted *p* |
|---|---|---|
| Retweets (`ln_retweetcount`) | .0003 | **.004** |
| Replies (`ln_replycount`) | .0007 | **.010** |

The next-strongest candidate (post effort, `c6`, on retweets) does not survive correction
(adjusted *p* = .19). The effect is therefore not the incidental "winner" of a wide search
but the sole moderator robust to family-wise correction.

## B. Repeated cross-validation (stability)

Across **100 random 50/50 splits** of influencers, the joint interaction is significant at
the 5% level in a large majority of splits, with the theory-predicted sign recovered nearly
always for retweets:

| Outcome | Splits significant (*p* < .05) | Sign-consistent (b₂) | Median split *p* |
|---|---|---|---|
| Retweets | **83%** | **95%** | .002 |
| Replies | **57%** | **74%** | .011 |

Replication rates of this magnitude are far above the 5% rate expected under the null,
indicating a stable feature of the data rather than an artifact of any single sample. This
also rules out a pure winner's-curse explanation: an overfit effect would replicate near
the 5% null rate, not 57–83%.

## C. Single out-of-sample holdout (reported for completeness)

As a stricter check we partition influencers 70/30, identify the effect in the 70% discovery
sample, and re-estimate on the held-out 30%. The interaction is strongly significant in
discovery (*p* = .0003 for replies, .001 for retweets) but does not reach significance in the
holdout (*p* = .29 and .75). We interpret this cautiously: the held-out sample contains very
few treated posts (83, 396, and 412 across the three treatment classes), so the single-split
holdout is **underpowered rather than disconfirming**. The repeated-split cross-validation in
Part B — the same out-of-sample logic averaged over many draws — is the better-powered version
of this test and supports the effect.

## Summary

Taken together, the evidence is strongest and most consistent for **retweets** (survives
family correction; 83% CV replication; 95% sign-consistent) and **corroborating but more
modest for replies** (survives family correction; 57% / 74% in CV). We therefore treat the
retweet result as the primary finding and the reply result as supporting.

---

<!-- Referee-anticipation notes (do not paste; address before submission):
  * ≈150 clusters + rare treatment cells → consider a wild-cluster bootstrap for the
    headline joint test as a further robustness line.
  * Outcomes are ln(1+count) (zeros retained). Note that with many small counts the
    coefficient is only approximately a semi-elasticity; state this if reviewers press.
  * Keep the language calibrated: replies are "suggestive," not "robust." -->
