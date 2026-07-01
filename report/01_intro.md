# Introduction

<!-- SKETCH (Markdown). A skeleton to react to, not final prose. [CITE] marks
     where the literature goes — I don't have your reference set, so I've named
     the *type* of cite needed rather than inventing sources. -->

## 1. Motivation

Influencer marketing has become a primary channel for brand communication — the industry
reached roughly \$24 billion in 2024, more than tripling since 2019 (Statista) — and with it
has come regulatory attention to **disclosure**: when creators are paid to promote a brand,
they are expected to say so (the Federal Trade Commission's Endorsement Guides). A large
literature studies whether disclosure helps or hurts sponsored-content performance
(e.g., Boerman, Willemsen, and Van Der Aa 2017; Evans et al. 2017; Eisend et al. 2020;
Cao and Belo 2023), generally framing disclosure as a binary "disclosed vs. not." Much less is known about how the **surprise** of a disclosure — how far a
post's disclosure behavior departs from what the audience has come to expect from that
creator — shapes engagement.

## 2. Tension / gap

Two gaps motivate this paper. First, "engagement" is usually treated as a single quantity, but
audiences can respond in distinct modes: they can **amplify** content (retweet/share, a public
word-of-mouth act) or **converse** with it (reply, a more private one) (Zhang, Moe, and
Schweidel 2017). These modes need not move together, and a disclosure effect that raises one
while lowering the other would be invisible to a pooled engagement measure. Second,
the *expectedness* of disclosure — not just its presence — plausibly drives reactions: an
unexpected brand behavior violates audience expectations (Expectancy Violations Theory,
Burgoon 1993) and can activate persuasion knowledge (Friestad and Wright 1994). A surprising,
unflagged brand association may be processed very differently from a routine one.

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

We contribute to the influencer-marketing literature (e.g., Hughes, Swaminathan, and Brooks
2019; Lou and Yuan 2019; Leung et al. 2022) by (i) separating **amplification from conversation** and
showing a disclosure moderator that pushes them apart; (ii) introducing **disclosure surprise**
— expectedness, not just presence — as the operative construct; and (iii) subjecting the
finding to an unusually demanding validation protocol (family-wise correction, repeated
cross-validation, out-of-sample holdout).

---

<!-- OPEN ITEMS (do not paste):
  - Citations wired in from lit_review_essay2.md (framing locked: disclosure surprise, not
    positivity). Verify the Statista figure and FTC-Guides phrasing against your preferred source.
  - Confirm exact influencer N (~150 in the current analysis; the JMR draft used 73).
  - Mechanism still tentative (persuasion knowledge; EVT added) — pending the mediation fix. -->
