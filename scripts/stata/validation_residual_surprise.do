/*------------------------------------------------------------
File:       validation_residual_surprise.do
Purpose:    Re-validate the headline moderator using a WITHIN-influencer,
            tweet-level residual-MAGNITUDE surprise measure (the defensible
            construct), replacing the influencer-mean c1_disclose_surprise.
              z_sres = std( |disclosed - E[disclosed | content feats + infl FE]| )
            Runs: (B') Holm family correction; (C') repeated 50/50 CV;
            (BOOT) two-step cluster bootstrap for generated-regressor SEs;
            (ROBUST) first-stage feature-set sensitivity.
Inputs:     ${derived}/IM_Data_step5_zscored.dta
Outputs:    ${tables}/ResSurprise_Holm.csv, ResSurprise_CV.csv, ResSurprise_Boot.dta
Run order:  Standalone (paste-safe; no /// continuations)
------------------------------------------------------------*/

version 17
clear all
set more off

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
global timefe   "month hour"
global prior    "BM_handhash_NN1000valprior_cum"
global outcomes "ln_retweetcount ln_replycount"
global feats_bs "z_wordcount z_posts z_followers z_following topic_probsbeauty4 topic_probshealthandwellness4 topic_probsnutrition4 topic_probsfashion4 multi_brand tone_stdM emotion_stdM hedonicity_75percentilemem_stdM"

* ---- Build residual-magnitude surprise on the full sample -------------------
capture drop c1_disclosed
capture drop _restmp
capture drop c1_sres
capture drop z_sres
gen byte c1_disclosed = (BM_handhash_NN1000val == 1)
reghdfe c1_disclosed $feats_bs, absorb(influencercode) residuals(_restmp)
gen double c1_sres = abs(_restmp)
egen double z_sres = std(c1_sres)
drop _restmp

* Moderator family: residual c1 (z_sres) replaces c1_disclose_surprise; other 14 unchanged
global mods "z_sres c2_brand_momentum c3_topic_drift c4_voice_consistency c5_log_spacing c6_effort c7_brand_exclusivity c8_engagement_priming c9_first_pairing alt5_hed_change_baseline hedonicity_50percentilemem_stdM hedonicity_75percentilemem_stdM hedonicity_90percentilemem_stdM tone_stdM emotion_stdM"

* =============================================================================
* (B') HOLM family correction with residual c1
* =============================================================================
tempname B
postfile `B' str40 moderator str16 outcome double F_full double p_full using "${tables}/ResSurprise_Holm.dta", replace
foreach y of global outcomes {
    foreach m of global mods {
        capture confirm variable `m'
        if _rc continue
        quietly reghdfe `y' ib0.BM_handhash_NN1000val##c.`m' $controls $prior, absorb($fes_abs) vce(cluster influencercode)
        capture test 1.BM_handhash_NN1000val#c.`m' 2.BM_handhash_NN1000val#c.`m' 3.BM_handhash_NN1000val#c.`m'
        if _rc post `B' ("`m'") ("`y'") (.) (.)
        else   post `B' ("`m'") ("`y'") (r(F)) (r(p))
    }
}
postclose `B'
preserve
    use "${tables}/ResSurprise_Holm.dta", clear
    drop if missing(p_full)
    bysort outcome (p_full): gen rank = _n
    by outcome: gen nfam = _N
    by outcome: gen double p_holm = (nfam - rank + 1)*p_full
    by outcome: replace p_holm = max(p_holm, p_holm[_n-1]) if _n>1
    replace p_holm = min(p_holm, 1)
    gsort outcome p_full
    display as result _newline "=== (B') HOLM with residual c1 (z_sres) ==="
    list outcome moderator F_full p_full p_holm, sepby(outcome) noobs
    display as result "Does z_sres survive? look for moderator==z_sres with p_holm<.05"
    export delimited using "${tables}/ResSurprise_Holm.csv", replace
restore

* =============================================================================
* (C') Repeated 50/50 CV for residual c1 (residual rebuilt within each split)
* =============================================================================
local R    = 100
local base = 20260701
tempname D
postfile `D' int rep str16 outcome double jF double jp using "${tables}/ResSurprise_CV.dta", replace
quietly forvalues r = 1/`R' {
    capture drop _cvhold
    preserve
        keep influencercode
        duplicates drop
        set seed `=`base'+`r''
        gen double _u2 = runiform()
        gen byte _cvhold = _u2 < 0.50
        drop _u2
        tempfile s2
        save `s2'
    restore
    merge m:1 influencercode using `s2', nogenerate
    * rebuild residual surprise WITHIN the estimation subsample (no leakage)
    capture drop _rtmp _sr _zsr c1d
    gen byte c1d = (BM_handhash_NN1000val==1)
    reghdfe c1d $feats_bs if _cvhold==1, absorb(influencercode) residuals(_rtmp)
    gen double _sr = abs(_rtmp)
    egen double _zsr = std(_sr)
    foreach y of global outcomes {
        capture reghdfe `y' ib0.BM_handhash_NN1000val##c._zsr $controls $prior if _cvhold==1, absorb($fes_abs) vce(cluster influencercode)
        if _rc post `D' (`r') ("`y'") (.) (.)
        else {
            capture test 1.BM_handhash_NN1000val#c._zsr 2.BM_handhash_NN1000val#c._zsr 3.BM_handhash_NN1000val#c._zsr
            if _rc post `D' (`r') ("`y'") (.) (.)
            else   post `D' (`r') ("`y'") (r(F)) (r(p))
        }
    }
    drop _rtmp _sr _zsr c1d
}
postclose `D'
preserve
    use "${tables}/ResSurprise_CV.dta", clear
    gen byte sig05 = jp < .05 if !missing(jp)
    collapse (count) n_splits=jF (mean) repl_rate=sig05 (p50) med_jp=jp, by(outcome)
    display as result _newline "=== (C') Repeated 50/50 CV for residual c1 ==="
    list outcome n_splits repl_rate med_jp, noobs
    export delimited using "${tables}/ResSurprise_CV.csv", replace
restore

* =============================================================================
* (BOOT) Two-step cluster bootstrap: rebuild first-stage residual each replicate
* absorb the RESAMPLED cluster id (_bsid) so duplicated influencers are distinct FE
* =============================================================================
capture program drop _bs_surp
program define _bs_surp, rclass
    capture drop c1d _rt _sr _zs
    gen byte c1d = (BM_handhash_NN1000val==1)
    reghdfe c1d $feats_bs, absorb(_bsid) residuals(_rt)
    gen double _sr = abs(_rt)
    egen double _zs = std(_sr)
    quietly reghdfe ln_retweetcount ib0.BM_handhash_NN1000val##c._zs $controls $prior, absorb(_bsid $timefe)
    return scalar b2rt = _b[2.BM_handhash_NN1000val#c._zs]
    return scalar b3rt = _b[3.BM_handhash_NN1000val#c._zs]
    quietly reghdfe ln_replycount ib0.BM_handhash_NN1000val##c._zs $controls $prior, absorb(_bsid $timefe)
    return scalar b2rp = _b[2.BM_handhash_NN1000val#c._zs]
    return scalar b3rp = _b[3.BM_handhash_NN1000val#c._zs]
    drop c1d _rt _sr _zs
end
display as result _newline "=== (BOOT) two-step cluster bootstrap (200 reps; be patient) ==="
bootstrap b2rt=r(b2rt) b3rt=r(b3rt) b2rp=r(b2rp) b3rp=r(b3rp), reps(200) cluster(influencercode) idcluster(_bsid) seed(12345) saving("${tables}/ResSurprise_Boot.dta", replace): _bs_surp
estat bootstrap, percentile
* Bootstrap SEs + normal/percentile CIs print above; per-replicate draws saved to ResSurprise_Boot.dta.

* =============================================================================
* (ROBUST) First-stage feature-set sensitivity for the headline joint test
* =============================================================================
display as result _newline "=== (ROBUST) headline joint p under alternative first-stage feature sets ==="
local set1 "z_wordcount z_posts z_followers z_following topic_probsbeauty4 topic_probshealthandwellness4 topic_probsnutrition4 topic_probsfashion4 multi_brand tone_stdM emotion_stdM hedonicity_75percentilemem_stdM"
local set2 "z_wordcount z_followers z_following multi_brand"
local set3 "z_wordcount z_posts z_followers z_following topic_probsbeauty4 topic_probshealthandwellness4 topic_probsnutrition4 topic_probsfashion4 multi_brand tone_stdM emotion_stdM hedonicity_50percentilemem_stdM hedonicity_75percentilemem_stdM hedonicity_90percentilemem_stdM"
local k = 0
foreach S in set1 set2 set3 {
    local ++k
    capture drop c1d _rt _sr _zs`k'
    gen byte c1d = (BM_handhash_NN1000val==1)
    reghdfe c1d ``S'', absorb(influencercode) residuals(_rt)
    gen double _sr = abs(_rt)
    egen double _zs`k' = std(_sr)
    drop c1d _rt _sr
    foreach y of global outcomes {
        quietly reghdfe `y' ib0.BM_handhash_NN1000val##c._zs`k' $controls $prior, absorb($fes_abs) vce(cluster influencercode)
        quietly test 1.BM_handhash_NN1000val#c._zs`k' 2.BM_handhash_NN1000val#c._zs`k' 3.BM_handhash_NN1000val#c._zs`k'
        display as text "  feature set `k'  `y'  joint p = " %7.5f r(p)
    }
}

display _newline as result "Residual-surprise validation complete."
display as text "  Holm : ${tables}/ResSurprise_Holm.csv   (z_sres survives if p_holm<.05)"
display as text "  CV   : ${tables}/ResSurprise_CV.csv"
display as text "  Boot : ${tables}/ResSurprise_Boot.dta    (two-step cluster-robust CIs; SEs also printed)"
