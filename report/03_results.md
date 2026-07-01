# Results: Influencer Disclosure Propensity and Engagement

<!-- Working draft (Markdown). Paste polished text into Word/Docs.
     REFRAMED (2026-07-01): the identified, defensible moderator is the influencer's
     DISCLOSURE PROPENSITY (baseline disclosure rate, c1_infl_disclose_rate), a
     between-influencer construct with standard inference — NOT a tweet-level
     "surprise" (which is only suggestive; see the robustness note). Numbers are
     from tab_main_c1.csv / tab_main_c1_std.csv (run 2026-07-01). -->

## Specification

We estimate how an influencer's **disclosure propensity** — their baseline rate of disclosing
sponsorships, $\bar d_j$ (the mean of the disclosed indicator, constant within influencer) —
moderates the engagement effect of a post's brand-match class. For each outcome $y_{it}$,
$\ln(1+\text{retweets})$ and $\ln(1+\text{replies})$,

$$
y_{it} = \sum_{k\in\{1,2,3\}} \big(\beta_k\,\mathbb{1}[T_{it}=k] + \gamma_k\,\mathbb{1}[T_{it}=k]\times \bar d_{j}\big)
       + X_{it}'\delta + \text{prior}_{it}\phi + \alpha_i + \tau_m + \eta_h + \varepsilon_{it},
$$

where $T_{it}$ is the brand-match class (0 = no match, base; 1 = disclosed; 2 = undisclosed;
3 = organic), $X_{it}$ the controls, and $\alpha_i,\tau_m,\eta_h$ are influencer, month, and
hour fixed effects. SEs are clustered by influencer (≈150). Because $\bar d_j$ is an influencer
aggregate (not a first-stage estimate), the interaction inference is standard.

*(Equivalent form used in the pipeline: `c1_disclose_surprise` $=|\mathbb{1}[\text{disclosed}]-\bar d_j|$,
which for the identified non-disclosed classes equals $\bar d_j$ — so the estimates below are
identical for classes 2 and 3.)*

## Main estimates

The brand-class × disclosure-propensity interaction is **jointly significant** for both outcomes:

| Outcome | Joint *F* | Joint *p* |
|---|---|---|
| $\ln(1+\text{retweets})$ | 8.53 | .0003 |
| $\ln(1+\text{replies})$ | 7.65 | .0007 |

**Table 1. Brand-match class × influencer disclosure propensity.**

| Interaction | $\ln(1+\text{retweets})$ | $\ln(1+\text{replies})$ |
|---|---|---|
| Disclosed × propensity ($\gamma_1$) | — (dropped) | — (dropped) |
| Undisclosed × propensity ($\gamma_2$) | 4.943*** (1.278) | −4.763** (1.855) |
| Organic × propensity ($\gamma_3$) | 2.514 (3.745) | −3.524*** (0.970) |
| Controls / prior, FE (influencer, month, hour) | Yes | Yes |
| Joint *p* | .0003 | .0007 |
| Clusters / *N* | 150 / 281,837 | 150 / 281,837 |

*Notes.* SEs clustered by influencer in parentheses. * .10, ** .05, *** .01. The disclosed-class
interaction ($\gamma_1$; 390 posts) is collinear within influencer and not identified. Source:
`Tables/tab_main_c1.csv`.

## Interpretation

Among **undisclosed** brand posts, those by **higher-disclosure-propensity** influencers earn
**more retweets** ($+4.94$, $p<.01$) but **fewer replies** ($-4.76$, $p<.05$); **organic** posts
show the same reply penalty ($-3.52$, $p<.01$) with no retweet effect. Scaling to a
one-standard-deviation increase in disclosure propensity: undisclosed **+0.18 log-pts ≈ +20%
retweets** and **−0.17 ≈ −16% replies**; organic **−0.13 ≈ −12% replies** (`tab_main_c1_std.csv`;
per-SD computed on the surprise measure — a rate-standardized version is a minor re-run).

Substantively, an undisclosed brand post from a creator who *usually* discloses is atypical for
that creator, and audiences appear to amplify it more while engaging in less conversation. A
**persuasion-knowledge** reading fits: relative to a habitual discloser's norm, an unflagged
brand post is not read as advertising, so it is shared relatively uncritically (retweets) while
prompting less of the scrutinizing conversation that recognized sponsorship attracts (replies).
Because $\bar d_j$ is influencer-level, this is a **between-influencer** result — a difference
across creators of differing disclosure habits, not a within-post effect.

## Robustness: is there a within-post "surprise" effect?

A stricter, tweet-level version — surprise as the residual $|\text{disclosed}-E[\text{disclosed}\mid\text{content}+\text{influencer}]|$,
which identifies all three classes — was tested (`validation_residual_surprise.do`). It preserves
the sign pattern and is the sole survivor of family-wise correction under naive clustered SEs, but
under a **two-step cluster bootstrap** (correct for the generated regressor) the effect is only
**marginal (joint $p\approx.08$ replies, $.14$ retweets)**. We therefore report the between-influencer
disclosure-propensity result as the finding and treat within-post surprise as **suggestive**.

These estimates are the object the robustness exercises in **§4** stress-test (family-wise
correction; repeated cross-validation).

---

<!-- OPEN ITEMS (do not paste):
  - Re-standardize per-SD on c1_infl_disclose_rate for the final Table 1 magnitudes.
  - Consider reporting the class × c1_infl_disclose_rate spec directly (Main_NN_c1surprise_SUR)
    as the headline table rather than the |.| surprise form.
  - Mechanism (PKM) still needs the mediation populated (Mediation_c1_indirect_effects.csv empty).
  - §4 validation numbers are for the surprise form; equivalent for classes 2/3 but relabel. -->
