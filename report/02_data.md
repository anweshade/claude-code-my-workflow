# Data & Measurement

<!-- Working draft (Markdown). Paste polished text into Word/Docs.
     Facts sourced from Data_Description.docx + Essay_2_Pipeline.do (2026-07-01 read).
     Remaining [CONFIRM] items are genuinely unresolved; everything else is real. -->

## Setting and sample

The data are influencer posts (tweets) on **X (formerly Twitter)** for the **2019** calendar
year, across four industries (Beauty, Health & Wellness, Fashion, Nutrition). The raw corpus
(`IM Data 11262025.xlsx`) contains **294,557 tweets from 205 influencers**, each with tweet
text, influencer id and industry, timestamp, and engagement (retweets, replies, potential
impressions). After dropping non-English/unscoreable tweets (12,720; 4.3%), the **analysis
sample is 281,837 tweets** (95.7%). Estimation clusters standard errors at the influencer
level (**150 influencers** in the estimation file). [CONFIRM the 205→150 influencer reduction
between the raw corpus and the estimation file — document the filter.]

*Note — the sample was substantially rebuilt after the earlier submission: the prior version
used 73 influencers / ~129,519 posts (2019); this version uses 205 (raw) / 150 (estimation)
influencers and 281,837 posts.*

## Treatment: brand-match and disclosure class

Brand mentions are identified by an **LLM-built gazetteer of 943 confirmed product brands**,
matched to tweets on **@-handle and #-hashtag only** (text-name matching excluded to avoid
false positives on short names like *Gap*, *Dove*, *Cos*). A tweet is a single-brand mention
if exactly one gazetteer brand matches (7,435 tweets); multi-brand tweets (548) are retained
but flagged with a `multi_brand` control rather than dropped.

Following **Ershov, He & Seiler (2025)**, a supervised text classifier (selected among Naive
Bayes / logit / random forest / gradient boosting, with a misclassification-error correction)
sorts brand tweets into a four-level treatment, `BM_handhash_NN1000val`:

| Class | Label | Posts |
|---|---|---|
| 0 | No single-brand match (baseline; incl. 533 multi-brand, flagged) | 274,700 |
| 1 | Disclosed sponsored (contains #ad / #sponsored-type disclosure) | 390 |
| 2 | Undisclosed sponsored (maybe-organic, classified sponsored) | 1,976 |
| 3 | Organic brand mention (maybe-organic, classified organic) | 4,771 |

Treated cells are small — the disclosed cell (390) especially — which limits precision on
class-specific estimates.

## Outcomes

Engagement is measured by two post-level counts, entered as $\ln(1+\text{count})$ so zero-
engagement posts are retained:

- **Retweets** — `ln_retweetcount` $=\ln(1+\text{retweets})$. Amplification / public word-of-mouth.
- **Replies** — `ln_replycount` $=\ln(1+\text{replies})$. Conversation / more private response.

Potential impressions are available in the raw data but not used in the current specification.

## Key moderator: influencer disclosure propensity

The moderator is the influencer's **disclosure propensity** — their baseline rate of disclosing
sponsorships,
$$
\bar d_j = \text{mean of } \mathbb{1}[\text{disclosed}_{it}] \text{ within influencer } j \text{ (constant within influencer)},
$$
implemented as `c1_infl_disclose_rate`. (The pipeline also stores the equivalent magnitude form
`c1_disclose_surprise` $=|\mathbb{1}[\text{disclosed}]-\bar d_j|$, which for the identified
non-disclosed classes equals $\bar d_j$; it is bounded in $[0,1]$, mean 0.003, SD 0.037.)

**This is a between-influencer moderator by design.** Because $\bar d_j$ is constant within
influencer, the interaction is identified from *cross-influencer* differences in disclosure
habits: `class 1 (disclosed) × propensity` is collinear within influencer and drops (hence
$\gamma_1$ is unidentified in §3), while `class 2/3 × propensity` compares undisclosed/organic
content across creators of differing disclosure propensity. Inference is standard (influencer
aggregate, not a generated regressor). A stricter *within-post* surprise measure (a first-stage
residual) was also built; it is only suggestive under correct two-step inference (§3 robustness),
which is why the between-influencer propensity result is the headline.

## Controls and fixed effects

All models include **influencer, month, and hour** fixed effects and (z-scored where
continuous):

- **Post:** word count (`z_wordcount`, LIWC-22), posting volume (`z_posts` — [CONFIRM: cumulative
  posts by the influencer up to the focal post]), seeded-LDA topic shares
  (`topic_probs{beauty, healthandwellness, nutrition, fashion}4`; K = 4 seeded LDA on cleaned
  English text), and `multi_brand`.
- **Account:** followers (`z_followers`), following (`z_following`).
- **Prior:** cumulative brand-match prior, `BM_handhash_NN1000valprior_cum`.

Additional constructed measure families (used as alternative moderators in §4 and as mechanism
variables): **hedonicity** (Dodds et al. 2011 labMIT sum at seven percentile cutoffs),
**LIWC-22 tone/emotion**, a feature-based **personal-voice authenticity** index, and a
**persuasion** measure (8-category dictionary + supervised classifier; 3.4% of tweets coded
persuasive). The last two are the candidate mechanism mediators (§3).

---

<!-- OPEN ITEMS (do not paste):
  1. 205 -> 150 influencer reduction between raw corpus and estimation file — document the filter.
  2. z_posts exact definition (cumulative posts? confirm).
  3. Hour FE time zone.
  4. RESOLVED: headline reframed to influencer disclosure PROPENSITY (between-influencer),
     with within-post surprise as suggestive robustness. Still to do: report the
     class × c1_infl_disclose_rate spec directly as Table 1, and re-standardize per-SD on the
     rate. -->
