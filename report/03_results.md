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
| Disclosed × propensity ($\gamma_1$) | 2.87 (9.30) | −3.91** (1.52) |
| Undisclosed × propensity ($\gamma_2$) | 4.943*** (1.278) | −4.763** (1.855) |
| Organic × propensity ($\gamma_3$) | 2.514 (3.745) | −3.524*** (0.970) |
| Controls / prior, FE (influencer, month, hour) | Yes | Yes |
| *N* | 281,837 | 281,837 |

*Notes.* All SEs **influencer-clustered** (`reghdfe`, `Table1_propensity_clustered.csv`); $N=281{,}837$,
150 clusters. * .10, ** .05, *** .01. In the equivalent $|\cdot|$ (surprise) parameterization
$\gamma_1$ is collinear and drops; the **disclosure-rate parameterization identifies all three
classes** and is the Table 1 we report. $\gamma_1$ (disclosed × propensity) on replies is
$-3.91$ ($p<.05$) under clustering — the reply penalty holds for disclosed posts too.

## Interpretation

Among **undisclosed** brand posts, those by **higher-disclosure-propensity** influencers earn
**more retweets** ($+4.94$, $p<.01$) but **fewer replies** ($-4.76$, $p<.05$); **organic** posts
show the same reply penalty ($-3.52$, $p<.01$) with no retweet effect. With all three classes
identified, a **broad reply pattern** emerges: higher disclosure propensity lowers replies on
*every* brand-post type (disclosed $-3.9$, undisclosed $-4.8$, organic $-3.5$), while the
**retweet gain is specific to undisclosed content** ($+4.9$). The joint tests are significant
under influencer-clustered inference (retweets $F(3,149)=5.71$, $p=.0010$; replies
$F(3,149)=5.51$, $p=.0013$).

Scaling to a one-standard-deviation increase in disclosure propensity (clustered,
`Table1_propensity_clustered.csv`): undisclosed **+0.030 ≈ +3.0% retweets** ($p<.01$) and
**−0.029 ≈ −2.9% replies** ($p<.05$); organic **−0.021 ≈ −2.1% replies** ($p<.01$); disclosed
**−0.024 ≈ −2.4% replies** ($p<.05$). **These per-SD effects are modest**, and honestly so:
disclosure propensity varies little across influencers (SD ≈ 0.006 on the 0–1 rate scale, since
disclosure is rare — 390 of 281,837 posts), so the moderation is **statistically robust but
economically small**, reflecting a minority of higher-disclosing creators. *(The earlier
"+20%/−16%" figures were per SD of the wider $|\cdot|$ surprise measure and overstated the
effect; the rate-standardized numbers here are the correct ones.)*

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
  - DONE: Table 1 clustered (all 3 classes), gamma_1 reply penalty holds (-3.91**), per-SD
    standardized on the disclosure rate (Table1_propensity_clustered.csv). Joint p .001/.0013.
  - Honest caveat now in text: per-SD effect is small (~3%) because disclosure propensity has
    little cross-influencer variation (SD ~0.006; disclosure rare). Consider whether the
    economic magnitude is enough to headline, or lead with the qualitative pattern.
  - Mechanism (PKM) still needs the mediation populated (Mediation_c1_indirect_effects.csv empty).
  - §4 validation numbers are for the surprise form; equivalent for classes 2/3 but relabel. -->
