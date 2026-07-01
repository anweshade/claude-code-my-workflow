/*------------------------------------------------------------
File:       validation_moderators.do
Purpose:    Validate the moderator findings (headline: c1_disclose_surprise)
            via three exercises — (A) 70/30 out-of-sample split by influencer,
            (B) Holm family-wise correction over all moderators, and
            (C) 100x repeated 50/50 cross-validation for c1.
Inputs:     ${derived}/IM_Data_step5_zscored.dta
Outputs:    ${tables}/Validation_OOS.{dta,csv}
            ${tables}/Validation_Holm.{dta,csv}
            ${tables}/Validation_CV_c1.{dta,csv}, Validation_CV_c1_summary.csv
Run order:  Standalone (reads the step-5 z-scored panel)
Notes:      Reconstructed & cleaned from the run log. Specifications and seeds
            are UNCHANGED from the original, so results reproduce identically.
            Cleaning = fixed a `lobal`->`global` typo, removed a duplicated
            `global outcomes`, added the reproducibility header + section banners.
------------------------------------------------------------*/

version 17
clear all
set more off

* ---- CONFIG: set project root (edit ROOT1 if your path differs) -------------
* Two candidates checked explicitly (no fragile quoting). ROOT1 = your machine.
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
    display as error "Edit ROOT1 at the top of this do-file to your project folder."
    exit 601
}
global derived "${root}/Derived"
global tables  "${root}/Tables"
display as text "Using root:    ${root}"
display as text "Using derived: ${derived}"

cap log close _all
log using "${tables}/validation_moderators_log.smcl", replace

use "${derived}/IM_Data_step5_zscored.dta", clear

* ---- Specification globals ---------------------------------------------------
global controls "z_posts z_wordcount z_followers z_following topic_probsbeauty4 topic_probshealthandwellness4 topic_probsnutrition4 topic_probsfashion4 multi_brand"
global fes_abs  "influencercode month hour"
global prior    "BM_handhash_NN1000valprior_cum"
global mods     "c1_disclose_surprise c2_brand_momentum c3_topic_drift c4_voice_consistency c5_log_spacing c6_effort c7_brand_exclusivity c8_engagement_priming c9_first_pairing alt5_hed_change_baseline hedonicity_50percentilemem_stdM hedonicity_75percentilemem_stdM hedonicity_90percentilemem_stdM tone_stdM emotion_stdM"
global outcomes "ln_retweetcount ln_replycount"

set seed 12345
set sortseed 12345   // protective; split below is deterministic (unique influencercode) so results are unchanged

* Split INFLUENCERS (not posts) 70/30 so discovery and holdout share no
* influencer — a clean out-of-sample test at the unit the SEs cluster on.
preserve
    keep influencercode
    duplicates drop
    gen double _u = runiform()
    gen byte discovery = _u < 0.70
    tempfile split
    save `split'
restore
merge m:1 influencercode using `split', nogenerate

label define disc 1 "discovery(70%)" 0 "holdout(30%)"
label values discovery disc
tab discovery

* Treatment-class counts by split. The disclosed (class 1) / undisclosed
* (class 2) cells are rare, so the holdout is thin: read a holdout null as
* "underpowered," not "refuted," and lean on Part B (full-sample correction)
* and the causal-forest BLP for the better-powered evidence.
tab BM_handhash_NN1000val discovery

* =============================================================================
* PART A — Out-of-sample: screen on discovery (70%), test on holdout (30%)
* =============================================================================
tempname A
postfile `A' str40 moderator str16 outcome double F_disc double p_disc double F_hold double p_hold using "${tables}/Validation_OOS.dta", replace

foreach y of global outcomes {
    foreach m of global mods {
        capture confirm variable `m'
        if _rc {
            display as error "  [skip] moderator `m' not found"
            continue
        }
        * Discovery-sample screen (mimics the original selection)
        quietly reghdfe `y' ib0.BM_handhash_NN1000val##c.`m' $controls $prior if discovery==1, absorb($fes_abs) vce(cluster influencercode)
        capture test 1.BM_handhash_NN1000val#c.`m' 2.BM_handhash_NN1000val#c.`m' 3.BM_handhash_NN1000val#c.`m'
        if _rc {
            local Fd = .
            local pd = .
        }
        else {
            local Fd = r(F)
            local pd = r(p)
        }
        * Holdout-sample estimate (selection never saw these influencers)
        quietly reghdfe `y' ib0.BM_handhash_NN1000val##c.`m' $controls $prior if discovery==0, absorb($fes_abs) vce(cluster influencercode)
        capture test 1.BM_handhash_NN1000val#c.`m' 2.BM_handhash_NN1000val#c.`m' 3.BM_handhash_NN1000val#c.`m'
        if _rc {
            local Fh = .
            local ph = .
        }
        else {
            local Fh = r(F)
            local ph = r(p)
        }
        post `A' ("`m'") ("`y'") (`Fd') (`pd') (`Fh') (`ph')
    }
}
postclose `A'

preserve
    use "${tables}/Validation_OOS.dta", clear
    gsort outcome -F_disc
    list outcome moderator F_disc p_disc F_hold p_hold, sepby(outcome) noobs
    * The headline question: does c1 replicate on the holdout?
    display _newline as result "=== OUT-OF-SAMPLE CHECK: c1_disclose_surprise ==="
    list outcome F_disc p_disc F_hold p_hold if moderator=="c1_disclose_surprise", noobs
    export delimited using "${tables}/Validation_OOS.csv", replace
restore

* =============================================================================
* PART B — Full-sample estimates + Holm step-down family-wise correction
* =============================================================================
tempname B
postfile `B' str40 moderator str16 outcome double F_full double p_full using "${tables}/Validation_Holm.dta", replace

foreach y of global outcomes {
    foreach m of global mods {
        capture confirm variable `m'
        if _rc continue
        quietly reghdfe `y' ib0.BM_handhash_NN1000val##c.`m' $controls $prior, absorb($fes_abs) vce(cluster influencercode)
        capture test 1.BM_handhash_NN1000val#c.`m' 2.BM_handhash_NN1000val#c.`m' 3.BM_handhash_NN1000val#c.`m'
        if _rc {
            post `B' ("`m'") ("`y'") (.) (.)
        }
        else {
            post `B' ("`m'") ("`y'") (r(F)) (r(p))
        }
    }
}
postclose `B'

preserve
    use "${tables}/Validation_Holm.dta", clear
    drop if missing(p_full)
    bysort outcome (p_full): gen rank = _n
    by outcome: gen nfam = _N
    * Holm step-down adjusted p: running max of (n - rank + 1)*p, capped at 1.
    by outcome: gen double p_holm = (nfam - rank + 1)*p_full
    by outcome: replace p_holm = max(p_holm, p_holm[_n-1]) if _n>1
    replace p_holm = min(p_holm, 1)
    gsort outcome p_full
    list outcome moderator F_full p_full p_holm, sepby(outcome) noobs
    display _newline as result "=== HOLM-ADJUSTED p FOR c1_disclose_surprise ==="
    list outcome p_full p_holm if moderator=="c1_disclose_surprise", noobs
    export delimited using "${tables}/Validation_Holm.csv", replace
restore

* =============================================================================
* PART C — Repeated 50/50 cross-validation for c1 (R splits)
* =============================================================================
local R    = 100
local base = 20260630

tempname D
postfile `D' int rep str16 outcome double jF double jp double b2 double b3 using "${tables}/Validation_CV_c1.dta", replace

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

    foreach y of global outcomes {
        capture reghdfe `y' ib0.BM_handhash_NN1000val##c.c1_disclose_surprise $controls $prior if _cvhold==1, absorb($fes_abs) vce(cluster influencercode)
        if _rc {
            post `D' (`r') ("`y'") (.) (.) (.) (.)
        }
        else {
            scalar _b2 = _b[2.BM_handhash_NN1000val#c.c1_disclose_surprise]
            scalar _b3 = _b[3.BM_handhash_NN1000val#c.c1_disclose_surprise]
            capture test 1.BM_handhash_NN1000val#c.c1_disclose_surprise 2.BM_handhash_NN1000val#c.c1_disclose_surprise 3.BM_handhash_NN1000val#c.c1_disclose_surprise
            if _rc post `D' (`r') ("`y'") (.) (.) (_b2) (_b3)
            else   post `D' (`r') ("`y'") (r(F)) (r(p)) (_b2) (_b3)
        }
    }
}
postclose `D'

preserve
    use "${tables}/Validation_CV_c1.dta", clear
    gen byte sig05 = jp < .05 if !missing(jp)
    gen byte b2_expected = .
    replace b2_expected = (b2>0) if outcome=="ln_retweetcount" & !missing(b2)
    replace b2_expected = (b2<0) if outcome=="ln_replycount"   & !missing(b2)
    export delimited using "${tables}/Validation_CV_c1.csv", replace
    collapse (count) n_splits=jF (mean) repl_rate=sig05 mean_jF=jF mean_b2=b2 mean_b3=b3 signcons_b2=b2_expected (p50) med_jp=jp, by(outcome)
    display as result _newline "=== REPEATED 50/50 CV FOR c1 (per-outcome summary, R splits) ==="
    list outcome n_splits repl_rate med_jp mean_jF mean_b2 signcons_b2, noobs
    export delimited using "${tables}/Validation_CV_c1_summary.csv", replace
    display as text "repl_rate   = fraction of holdout splits with joint p<.05"
    display as text "signcons_b2 = fraction with theory-predicted sign on undisclosed x surprise (b2)"
restore

* ---- Summary ----------------------------------------------------------------
display _newline as result "Validation complete."
display as text "  Out-of-sample : ${tables}/Validation_OOS.csv"
display as text "  Holm-adjusted : ${tables}/Validation_Holm.csv"
display as text "Read these two together: c1 is credible if it (a) replicates on the"
display as text "holdout (Part A: p_hold small) AND (b) survives family correction"
display as text "(Part B: p_holm < .05)."

log close
