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

## Key moderator: disclosure surprise (important caveat)

`c1_disclose_surprise` is defined as
$$
S_{it} = \big|\,\mathbb{1}[\text{disclosed}_{it}] - \bar d_{j}\,\big|,
\qquad \bar d_j = \text{influencer } j\text{'s mean disclosure rate (constant within influencer)},
$$
so a post's "surprise" is how far its disclosure status departs from the creator's baseline
disclosure propensity. Empirically it is bounded in $[0,1]$ and highly right-skewed
(mean 0.003, SD 0.037).

**Identification caveat (from the pipeline's own note, and consistent with the dropped
coefficient in §3).** Because $\bar d_j$ is constant within influencer and $\mathbb{1}[\text{disclosed}]$
is binary, $S_{it}$ takes only two values within an influencer. As a result:
- `class 1 (disclosed) × surprise` is perfectly collinear with class 1 within influencer → **dropped** (this is why $\gamma_1$ is not identified in §3).
- The identifying variation in `class 2 × surprise` and `class 3 × surprise` is the
  **influencer-level baseline disclosure rate $\bar d_j$, not a tweet-level surprise signal.**

**This reframes the interpretation:** the headline moderation is effectively *between-influencer*
(undisclosed/organic content by creators with different disclosure propensities), not a
within-post "surprise." The pipeline reports both `c1_disclose_surprise` and the mechanical
decomposition `class k × c1_infl_disclose_rate` for transparency; they should agree. §3's
"surprising undisclosed content" language should be tempered accordingly — see the flag in §3.

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
  4. BIGGER: the disclosure-surprise identification caveat means §3's "surprise" interpretation
     is really an influencer-level disclosure-propensity moderation. Reconcile §3 language and
     decide whether c1_disclose_surprise or the c1_infl_disclose_rate decomposition is the
     headline presentation. -->
