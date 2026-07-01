/*------------------------------------------------------------
File:       surprise_within_influencer.do
Purpose:    DIAGNOSTIC — test whether the c1 "disclosure surprise" effect survives
            when surprise is measured with genuine WITHIN-influencer, tweet-level
            variation instead of the influencer-mean construct.
            Builds surprise = disclosed - E[disclosed | content features + influencer FE]
            (a regression residual), then re-runs the headline class x surprise spec
            and compares it to the original c1_disclose_surprise.
Inputs:     ${derived}/IM_Data_step5_zscored.dta
Outputs:    ${tables}/Surprise_WithinInfluencer.csv
Run order:  Standalone (diagnostic; not part of the main pipeline)
Note:       This answers "is the surprise story real once identified within influencer?"
            NOT a final spec. Paste-safe (no /// continuations).
------------------------------------------------------------*/

version 17
clear all
set more off

* ---- CONFIG: project root (same two-candidate pattern as validation_moderators.do)
global ROOT1 "C:/Users/ade2/Dropbox/Anwesha_2018/KELLEY/RESEARCH/Essay 2/Revised Version JM"
global ROOT2 "D:/Dropbox/Anwesha_2018/KELLEY/RESEARCH/Essay 2/Revised Version JM"
global root ""
capture confirm file "${ROOT1}/Derived/IM_Data_step5_zscored.dta"
if !_rc global root "${ROOT1}"
if "${root}" == "" {
    capture confirm file "${ROOT2}/Derived/IM_Data_step5_zscored.dta"
    if !_rc global root "${ROOT2}"
}
if "${root}" == "" {
    display as error "step5_zscored.dta not found under ROOT1 or ROOT2."
    exit 601
}
global derived "${root}/Derived"
global tables  "${root}/Tables"

use "${derived}/IM_Data_step5_zscored.dta", clear

global controls "z_posts z_wordcount z_followers z_following topic_probsbeauty4 topic_probshealthandwellness4 topic_probsnutrition4 topic_probsfashion4 multi_brand"
global fes_abs  "influencercode month hour"
global prior    "BM_handhash_NN1000valprior_cum"
global outcomes "ln_retweetcount ln_replycount"

* ---- Rebuild the ORIGINAL construct (for side-by-side comparison) ------------
capture drop c1_disclosed
capture drop c1_infl_disclose_rate
capture drop c1_disclose_surprise
gen byte c1_disclosed = (BM_handhash_NN1000val == 1)
bysort influencercode: egen c1_infl_disclose_rate = mean(c1_disclosed)
gen double c1_disclose_surprise = abs(c1_disclosed - c1_infl_disclose_rate)

* ---- Build content-feature list that predicts disclosure at the TWEET level --
* Content/context features only. EXCLUDE the BM class (would be mechanical) and outcomes.
local feat0 "z_wordcount z_posts z_followers z_following topic_probsbeauty4 topic_probshealthandwellness4 topic_probsnutrition4 topic_probsfashion4 multi_brand tone_stdM emotion_stdM hedonicity_75percentilemem_stdM"
local feats ""
foreach v of local feat0 {
    capture confirm variable `v'
    if !_rc local feats "`feats' `v'"
}
display as text "Prediction features used: `feats'"

* ---- Residual surprise: disclosed minus what content + influencer baseline predict
* absorb(influencercode) removes the influencer mean; features remove predictable tweet-level
* disclosure. The residual is genuine within-influencer, tweet-level surprise.
capture drop c1_surprise_signed
capture drop c1_surprise_abs
capture drop z_surp_signed
capture drop z_surp_abs
reghdfe c1_disclosed `feats', absorb(influencercode) residuals(c1_surprise_signed)
gen double c1_surprise_abs = abs(c1_surprise_signed)
egen double z_surp_signed = std(c1_surprise_signed)
egen double z_surp_abs    = std(c1_surprise_abs)
label variable z_surp_signed "Residual disclosure surprise (signed, per SD)"
label variable z_surp_abs    "Residual disclosure surprise (|.|, per SD)"

* ---- DIAGNOSTIC: within-influencer variation among NON-disclosed posts --------
* The original construct is (near) constant within influencer among class 2/3 (the bug).
* The residual should vary. Show mean within-influencer SD among non-disclosed rows.
preserve
    keep if BM_handhash_NN1000val != 1
    bysort influencercode: egen wsd_orig = sd(c1_disclose_surprise)
    bysort influencercode: egen wsd_new  = sd(c1_surprise_signed)
    quietly summarize wsd_orig
    local mo = r(mean)
    quietly summarize wsd_new
    local mn = r(mean)
    display as result "Mean within-influencer SD among non-disclosed posts:"
    display as result "   ORIGINAL c1_disclose_surprise = " %6.4f `mo' "   (near 0 = identification problem)"
    display as result "   RESIDUAL surprise             = " %6.4f `mn' "   (>0 = genuine tweet-level variation)"
restore

* ---- Re-run the headline spec with each measure; collect joint tests ----------
tempname S
postfile `S' str16 outcome str22 measure double jF double jp double b1 double b2 double b3 using "${tables}/Surprise_WithinInfluencer.dta", replace

foreach y of global outcomes {
    foreach m in c1_disclose_surprise z_surp_signed z_surp_abs {
        quietly reghdfe `y' ib0.BM_handhash_NN1000val##c.`m' $controls $prior, absorb($fes_abs) vce(cluster influencercode)
        scalar b1 = _b[1.BM_handhash_NN1000val#c.`m']
        scalar b2 = _b[2.BM_handhash_NN1000val#c.`m']
        scalar b3 = _b[3.BM_handhash_NN1000val#c.`m']
        capture test 1.BM_handhash_NN1000val#c.`m' 2.BM_handhash_NN1000val#c.`m' 3.BM_handhash_NN1000val#c.`m'
        if _rc post `S' ("`y'") ("`m'") (.) (.) (b1) (b2) (b3)
        else   post `S' ("`y'") ("`m'") (r(F)) (r(p)) (b1) (b2) (b3)
    }
}
postclose `S'

preserve
    use "${tables}/Surprise_WithinInfluencer.dta", clear
    display as result _newline "=== c1 SURVIVAL CHECK: original vs within-influencer residual ==="
    list outcome measure jF jp b1 b2 b3, sepby(outcome) noobs
    export delimited using "${tables}/Surprise_WithinInfluencer.csv", replace
restore

display _newline as result "Read: if z_surp_signed / z_surp_abs keep a significant joint p AND"
display as text "b1 is now non-missing (class 1 no longer collinear), the surprise story"
display as text "survives with genuine within-influencer identification. If the joint p"
display as text "collapses, the original effect was driven by influencer-level disclosure rate."
