---
paths:
  - "report/**/*.md"
  - "scripts/**/*.do"
  - "scripts/**/*.R"
  - "scripts/**/*.py"
---

# Project Knowledge Base: Influencer Marketing (Essay 2)

<!-- Claude reads this before drafting/analysis. Keep it current: when a metric
     is defined, a variable is constructed, or a modeling decision is locked,
     record it here so every session uses the same definitions. -->

## Marketing Metrics Registry

| Term | Definition | Notes / how measured here |
|------|-----------|---------------------------|
| Reach | Unique users who saw a post | *(confirm source)* |
| Impressions | Total views (non-unique) | |
| Engagement | Interaction count (likes + replies + retweets) | Outcomes here: retweets, replies |
| Engagement rate | Engagement ÷ followers (or ÷ reach) | State denominator explicitly |
| CPM | Cost per 1,000 impressions | |
| CPE | Cost per engagement | |
| CPA | Cost per acquisition/action | |
| ROAS | Revenue ÷ ad spend | |
| Followers / audience | Account's follower count at post time | `z_followers` = z-scored |

## Outcome & Treatment Variables (this project)

| Variable | Meaning | Construction / notes |
|----------|---------|----------------------|
| `ln_retweetcount` | Log retweets | `ln(retweetcount + 1)` (zeros retained) — primary outcome |
| `ln_replycount` | Log replies | `ln(replycount + 1)` (zeros retained) — secondary outcome (weaker in validation) |
| `BM_handhash_NN1000val` | Brand-match / disclosure class (0/1/2/3) | 0 = no match (base); 1 = disclosed; 2 = undisclosed; 3 = organic. Treated cells rare (390 / 1,976 / 4,771) |
| `BM_handhash_NN1000valprior_cum` | Cumulative prior on the match | control (`$prior`) |
| `influencercode` | Influencer id | clustering + FE unit (~150 unique) |

## Constructed Moderators (c1–c9 + hedonicity/tone/emotion)

| Moderator | Construct | Predicted sign / role |
|-----------|-----------|-----------------------|
| `c1_disclose_surprise` | Disclosure surprise | **Headline moderator** — survives Holm + CV. Unstandardized; mean .003, SD .037, range 0–1 (report per-SD) |
| `c2_brand_momentum` | Brand momentum | |
| `c3_topic_drift` | Topic drift | |
| `c4_voice_consistency` | Voice consistency | |
| `c5_log_spacing` | Log post spacing | *(dropped in validation — collinear/omitted, F missing)* |
| `c6_effort` | Post effort | |
| `c7_brand_exclusivity` | Brand exclusivity | |
| `c8_engagement_priming` | Engagement priming | |
| `c9_first_pairing` | First brand pairing | |
| `hedonicity_{50,75,90}percentilemem_stdM` | Hedonicity thresholds | standardized |
| `tone_stdM`, `emotion_stdM` | Tone / emotion | standardized |

## Controls & Fixed Effects (locked)

| Group | Members |
|-------|---------|
| `$controls` | `z_posts z_wordcount z_followers z_following topic_probs{beauty,healthandwellness,nutrition,fashion}4 multi_brand` |
| `$fes_abs` (absorbed) | `influencercode month hour` |
| `$prior` | `BM_handhash_NN1000valprior_cum` |
| SEs | `vce(cluster influencercode)` via `reghdfe` |

## Decisions & Assumptions Registry

<!-- The "remember our decisions" backbone. Add a row whenever a choice is made. -->

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-06-30 | Report in Word/Docs; repo holds data + analysis + Markdown drafts | Prose lives outside repo; repo is source of truth for numbers |
| 2026-07-01 | Stata primary; R/Python secondary | Essay 2 analysis is Stata (`reghdfe`, `postfile`) |
| 2026-07-01 | Retweets = primary outcome; replies = corroborating | Replies weaker: 57% CV replication / 74% sign-consistency vs 83% / 95% |
| 2026-07-01 | Validation = Holm family correction + repeated 50/50 CV; single 70/30 holdout is underpowered | Thin treated cells in holdout; cite CV, not single split |
| 2026-07-01 | Main c1 effect on undisclosed (class 2): retweets +4.94*** , replies −4.76** (`tab_main_c1`); organic (class 3) replies −3.52*** | Full-sample `reghdfe`; γ₁ (disclosed, 390 posts) drops as collinear — not identified |
| 2026-07-01 | Per-SD (std): undisclosed +0.181*** retweets / −0.174** replies; organic −0.129*** replies (`tab_main_c1_std`) | Report per-SD (≈ +20% / −16% / −12%); raw coeffs misleading since surprise SD ≈ .037 |

## Tolerance Thresholds

| Check | Tolerance |
|-------|-----------|
| Headline estimates reproduce | *(set when building replication package — `[confirm]`)* |
| p-values | Report to precision claimed in text; flag near-misses |

## Analysis Pitfalls (log them as found)

| Pitfall | Impact | Fix |
|---------|--------|-----|
| `lobal mods …` typo (dropped `g`) in do-file | Loop runs empty if the redefining line is deleted | Fix to `global`; remove duplicate `global outcomes` |
| ln of a count with zeros | Undefined / dropped obs | State `ln(1+x)` vs drop; keep consistent |
| Few clusters (~150) + rare treatment | Cluster-robust SEs may be anti-conservative | Consider wild-cluster bootstrap for headline |
