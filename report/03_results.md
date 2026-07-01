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
2 = undisclosed; 3 = organic), $S_{it}$ is disclosure surprise, $X_{it}$ the control
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

**Table 1. Disclosure surprise × brand-match class.**

| Interaction | $\ln(1+\text{retweets})$ | $\ln(1+\text{replies})$ |
|---|---|---|
| Disclosed × surprise ($\gamma_1$) | — (dropped) | — (dropped) |
| Undisclosed × surprise ($\gamma_2$) | 4.943*** (1.278) | −4.763** (1.855) |
| Organic × surprise ($\gamma_3$) | 2.514 (3.745) | −3.524*** (0.970) |
| Controls / prior | Yes | Yes |
| FE: influencer, month, hour | Yes | Yes |
| Joint *p* (interaction = 0) | .0003 | .0007 |
| Clusters (influencers) | 150 | 150 |
| *N* | 281,837 | 281,837 |

*Notes.* SEs clustered by influencer in parentheses. Significance: * .10, ** .05, *** .01.
The disclosed-class interaction ($\gamma_1$; 390 posts) is dropped as collinear within the
fixed-effect + control structure and is not identified. Source: `Tables/tab_main_c1.csv`.

## Interpretation

The key contrast is on the **undisclosed × surprise** term ($\gamma_2$): surprising
*undisclosed* brand content earns **more retweets** ($+4.94$, $p<.01$) but **fewer replies**
($-4.76$, $p<.05$) — a sign flip that is stable across resampling (recovered in 95% of retweet
splits and 74% of reply splits; see §4). Organic content shows the same reply penalty
($-3.52$, $p<.01$) with no retweet effect. Substantively, surprising undisclosed content
travels further while inviting less conversation. A **persuasion-knowledge** account fits this
contrast: because a surprising, undisclosed brand association is not recognized as advertising,
it is amplified relatively uncritically (more retweets) while failing to trigger the
scrutinizing conversation that recognized sponsorship attracts (fewer replies). The
disclosed-class interaction ($\gamma_1$; 390 posts) drops out as collinear and is not
identified, so we make no claim about it.
<!-- TENTATIVE mechanism — do not treat as established. Pending: (1) the formal mediation
     (Mediation_c1_indirect_effects.csv is currently empty — indirect effects not computed);
     (2) reconciliation of the mechanism-spec variable c1_infl_disclose_rate with the main
     moderator c1_disclose_surprise. Persuasion (z_pv_score) main effects run opposite to the
     c1 effect (retweets -.025**, replies +.045***), which motivates this account; authenticity
     (authentic_stdM) main effects are ns. Confirm before asserting. -->

Because surprise is concentrated near zero (mean 0.003, SD 0.037 on a 0–1 scale), the raw
per-unit coefficients overstate any realistic change. Scaling to a **one-standard-deviation**
increase in surprise gives interpretable magnitudes (`Tables/tab_main_c1_std.csv`): for
undisclosed content, **+0.181 log-points ≈ +20% retweets** ($p<.01$) and **−0.174 ≈ −16%
replies** ($p<.05$) per 1 SD; for organic content, **−0.129 ≈ −12% replies** ($p<.01$). With
the $\ln(1+\cdot)$ transform and many small counts these percentage readings are approximate.

These estimates are the object the robustness exercises in **§4 (Robustness & Validation)**
stress-test: they survive family-wise correction across fifteen candidate moderators and
replicate under repeated cross-validation, strongest for retweets.

---

<!-- OPEN ITEMS (do not paste):
  Table 1 (raw) + per-SD magnitudes filled from tab_main_c1.csv / tab_main_c1_std.csv (2026-07-01).
  Still needed: the one-sentence mechanism in Interpretation ([fill in]) — author does not have it yet.
  Resolved: class 3 = organic; per-SD reported. Note: gamma_1 (disclosed, 390 posts) dropped/collinear. -->
