# Results: Disclosure Surprise and Engagement

<!-- Working draft (Markdown). Paste polished text into Word/Docs.
     Joint-test p-values are from the run log (2026-07-01). The coefficient TABLE
     is a placeholder: the log ran estimations `quietly` and did not save individual
     coefficients/SEs. Generate the real table by running the esttab block now added
     to scripts/stata/validation_moderators.do (see "## Generating Table 1" note),
     then replace the [ ] cells. Construct name "disclosure surprise" kept for now. -->

## Specification

We estimate how **disclosure surprise** moderates the effect of a brand-match on
post-level engagement. For each engagement outcome $y_{it}$ — $\ln(1+\text{retweets})$
and $\ln(1+\text{replies})$ — we fit

$$
y_{it} = \sum_{k\in\{1,2,3\}} \big(\beta_k \, \mathbb{1}[T_{it}=k] + \gamma_k\, \mathbb{1}[T_{it}=k]\times S_{it}\big)
       + X_{it}'\delta + \text{prior}_{it}\,\phi + \alpha_i + \tau_m + \eta_h + \varepsilon_{it},
$$

where $T_{it}$ is the brand-match class (0 = no match, the omitted base; 1 = disclosed;
2 = undisclosed; 3 = [confirm label]), $S_{it}$ is disclosure surprise, $X_{it}$ the control
set (post/account characteristics and topic shares), $\text{prior}_{it}$ the cumulative
match prior, and $\alpha_i,\tau_m,\eta_h$ are influencer, month, and hour fixed effects.
Standard errors are clustered at the influencer level (≈150 clusters). The coefficients of
interest are the interactions $\gamma_1,\gamma_2,\gamma_3$ — how surprise shifts engagement
within each disclosure class. Estimated with `reghdfe` in
`scripts/stata/validation_moderators.do`.

## Main estimates

The interaction between disclosure class and surprise is **jointly significant** for both
outcomes on the full sample (joint test of $\gamma_1=\gamma_2=\gamma_3=0$):

| Outcome | Joint *F* | Joint *p* |
|---|---|---|
| $\ln(1+\text{retweets})$ | 8.53 | **.0003** |
| $\ln(1+\text{replies})$ | 7.65 | **.0007** |

**Table 1. Disclosure surprise × brand-match class.** *(coefficients to fill from `esttab`)*

| Interaction | $\ln(1+\text{retweets})$ | $\ln(1+\text{replies})$ |
|---|---|---|
| Disclosed × surprise ($\gamma_1$) | [ b (se) ] | [ b (se) ] |
| Undisclosed × surprise ($\gamma_2$) | [ b (se) ] | [ b (se) ] |
| Class 3 × surprise ($\gamma_3$) | [ b (se) ] | [ b (se) ] |
| Controls / prior | Yes | Yes |
| FE: influencer, month, hour | Yes | Yes |
| Joint *p* ($\gamma_1=\gamma_2=\gamma_3=0$) | .0003 | .0007 |
| Clusters (influencers) | ≈150 | ≈150 |
| *N* | 281,837 | 281,837 |

*Notes.* SEs clustered by influencer in parentheses. Significance: * .10, ** .05, *** .01.

## Interpretation

The key contrast is on the **undisclosed × surprise** term ($\gamma_2$): its sign is
**positive for retweets and negative for replies** — a pattern that is stable across
resampling (recovered in 95% of retweet splits and 74% of reply splits; see §4). Substantively,
surprising *undisclosed* brand content travels further (more retweets) while drawing fewer
replies, consistent with [one-sentence theoretical mechanism — fill in]. The disclosed-class
interaction ($\gamma_1$) is estimated on a thin cell (390 posts) and is correspondingly
imprecise; we read it cautiously.

Magnitudes and per-unit interpretation depend on the scale of the surprise measure and the
$\ln(1+\cdot)$ transform (with many small counts, $\gamma$ is only *approximately* a
semi-elasticity). We report standardized magnitudes once Table 1 is populated.

These estimates are the object the robustness exercises in **§4 (Robustness & Validation)**
stress-test: they survive family-wise correction across fifteen candidate moderators and
replicate under repeated cross-validation, strongest for retweets.

---

<!-- ## Generating Table 1 (do not paste)
  The current do-file only postfiles joint F/p. To emit the coefficient table, run the
  esttab block appended to scripts/stata/validation_moderators.do (Part D), which estimates
  the two full-sample c1 models and writes:
    ${tables}/tab_main_c1.tex   (LaTeX booktabs)
    ${tables}/tab_main_c1.csv   (for pasting here)
  Then replace the [ b (se) ] cells above and delete this note.
  Also confirm: the class-3 label, and the one-sentence mechanism in Interpretation. -->
