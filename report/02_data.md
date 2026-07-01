# Data & Measurement

<!-- Working draft (Markdown). Paste polished text into Word/Docs.
     Facts drawn from the analysis (IM_Data_step5_zscored.dta) and the metrics
     registry. [CONFIRM] marks data-collection details not inferable from the
     analysis — fill before submission; do not ship the brackets. -->

## Setting and sample

The data are post-level observations from [CONFIRM platform — retweets/replies imply
Twitter/X] covering [CONFIRM time window]. The analysis sample is
**281,837 posts** by **[≈150] influencers** ([CONFIRM exact influencer count and how the
influencer roster was drawn — e.g., accounts in category X above a follower threshold]).
Because each influencer contributes many posts, all inference is clustered at the influencer
level (see §3). [CONFIRM the collection method — API pull / scrape / vendor panel — and any
inclusion/exclusion filters, deletions, or deduplication applied to reach the analysis sample.]

The estimation file (`IM_Data_step5_zscored.dta`) is the fifth step of a documented build
pipeline; continuous controls enter as z-scores (prefix `z_`). [CONFIRM: point to the build
scripts / a data-appendix describing steps 1–5.]

## Treatment: brand-match and disclosure class

The treatment variable `BM_handhash_NN1000val` classifies each post into one of four
mutually exclusive brand-match categories:

| Class | Label | Posts |
|---|---|---|
| 0 | No brand match (baseline) | 274,700 |
| 1 | Disclosed sponsorship | 390 |
| 2 | Undisclosed sponsorship | 1,976 |
| 3 | Organic brand mention | 4,771 |

[CONFIRM the classifier: how a brand match is detected (handle / hashtag matching), how the
"NN1000val" step assigns/validates a class, and — critically — how **disclosed vs. undisclosed**
is coded (e.g., presence of `#ad`/`#sponsored` or an FTC-style disclosure token). This coding
is load-bearing for the paper's contribution, so it needs a precise, replicable description.]
Treated cells are small — the disclosed cell in particular (390 posts) — which limits the
precision of class-specific estimates and, in the disclosed×surprise interaction, leaves that
term unidentified (§3).

## Outcomes

Engagement is measured by two post-level counts, entered as $\ln(1+\text{count})$ so that
posts with zero engagement are retained:

- **Retweets** — `ln_retweetcount` $= \ln(1+\text{retweets})$. Amplification / sharing.
- **Replies** — `ln_replycount` $= \ln(1+\text{replies})$. Conversation / direct response.

[CONFIRM whether likes / quote-tweets / impressions are available and why they are or aren't
used.] The retweet–reply distinction is substantively important: the two capture different
engagement modes and, in our results, move in opposite directions.

## Key moderator: disclosure surprise

`c1_disclose_surprise` measures how **surprising** a post's disclosure status is given the
influencer's history / context — [CONFIRM the exact construction: what "surprise" is computed
against (e.g., deviation of this post's disclosure behavior from the influencer's baseline
rate, or a model-predicted disclosure probability)]. It is bounded in $[0,1]$ and highly
right-skewed (mean 0.003, SD 0.037), i.e., most posts carry little surprise with a thin tail
of highly surprising posts. Because a one-unit change is far outside the observed range, we
report effects **per one standard deviation** of surprise (§3). Fourteen additional candidate
moderators (`c2`–`c9`, and hedonicity/tone/emotion measures) are defined in [CONFIRM appendix];
they enter only the multiple-testing family in §4.

## Controls and fixed effects

All specifications include influencer, calendar-month, and hour-of-day fixed effects, and the
following post/account controls (z-scored where continuous):

- **Post:** length (`z_wordcount`), [CONFIRM `z_posts` — posting volume?], topic shares
  (`topic_probs{beauty, healthandwellness, nutrition, fashion}4` from a [CONFIRM: k-topic model]),
  and a multi-brand indicator (`multi_brand`).
- **Account:** followers (`z_followers`), following (`z_following`).
- **Prior:** a cumulative brand-match prior, `BM_handhash_NN1000valprior_cum`.

Standard errors are clustered at the influencer level (≈150 clusters); with few clusters and
rare treatment, §4 discusses a wild-cluster-bootstrap robustness line.

---

<!-- OPEN ITEMS (do not paste). Fill the [CONFIRM] tags:
  platform; time window; exact influencer count + roster construction; collection method +
  filters; the BM_handhash_NN1000val classifier and disclosed/undisclosed coding; the
  disclosure-surprise construction; topic-model spec; z_posts definition; which engagement
  metrics exist. These are facts only the author has — I have not invented any. -->
