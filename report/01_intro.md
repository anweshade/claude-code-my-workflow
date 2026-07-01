# Introduction

<!-- SKETCH (Markdown). A skeleton to react to, not final prose. [CITE] marks
     where the literature goes — I don't have your reference set, so I've named
     the *type* of cite needed rather than inventing sources. -->

## 1. Motivation

Influencer marketing has become a primary channel for brand communication [CITE market-size /
industry stat], and with it has come regulatory attention to **disclosure**: when creators are
paid to promote a brand, they are expected to say so [CITE FTC endorsement guides / platform
policy]. A large literature studies whether disclosure helps or hurts sponsored-content
performance [CITE disclosure-effects literature], generally framing disclosure as a binary
"disclosed vs. not." Much less is known about how the **surprise** of a disclosure — how far a
post's disclosure behavior departs from what the audience has come to expect from that
creator — shapes engagement.

## 2. Tension / gap

Two gaps motivate this paper. First, "engagement" is usually treated as a single quantity, but
audiences can respond in distinct modes: they can **amplify** content (retweet/share) or
**converse** with it (reply). These modes need not move together, and a disclosure effect that
raises one while lowering the other would be invisible to a pooled engagement measure. Second,
the *expectedness* of disclosure — not just its presence — plausibly drives reactions:
[CITE expectancy-violation / persuasion-knowledge theory]. A surprising, unflagged brand
association may be processed very differently from a routine one.

## 3. This paper

We study how **disclosure surprise** moderates the relationship between a post's brand-match
class (no match, disclosed, undisclosed, organic) and engagement, estimated separately for
**retweets** and **replies**. Using **281,837 posts** by **[≈150]** influencers, we fit
high-dimensional fixed-effects models (influencer, month, hour) with influencer-clustered
standard errors, and interact each brand-match class with disclosure surprise.

## 4. What we find

Surprise moves the two engagement modes in **opposite directions**. For **undisclosed** brand
content, a one-standard-deviation increase in disclosure surprise is associated with about
**+20% more retweets** but **−16% fewer replies**; **organic** content shows a comparable
reply penalty (**−12%**). The pattern is not an artifact of specification search: disclosure
surprise is the only one of fifteen candidate moderators to survive family-wise correction on
both outcomes, and it replicates in the large majority of repeated cross-validation splits
(§4). A **persuasion-knowledge** mechanism is consistent with the contrast — surprising
undisclosed content evades recognition as advertising, earning uncritical amplification but
little scrutinizing conversation (tentative; see §3).

## 5. Contribution

We contribute [CITE positioning] by (i) separating **amplification from conversation** and
showing a disclosure moderator that pushes them apart; (ii) introducing **disclosure surprise**
— expectedness, not just presence — as the operative construct; and (iii) subjecting the
finding to an unusually demanding validation protocol (family-wise correction, repeated
cross-validation, out-of-sample holdout).

---

<!-- OPEN ITEMS (do not paste):
  - All [CITE] tags need your reference set (market size, FTC guides, disclosure-effects lit,
    expectancy-violation / persuasion-knowledge theory, positioning).
  - Confirm exact influencer N.
  - The one-sentence finding in §4 and the contribution framing should be revisited once the
    mechanism (below) is settled and once you decide whether retweets or the retweet/reply
    *contrast* is the headline. -->
