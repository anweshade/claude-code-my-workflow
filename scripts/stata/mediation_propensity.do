/*------------------------------------------------------------
File:       mediation_propensity.do
Purpose:    Mechanism test for the disclosure-propensity result. Indirect effect
            a*b of (class k × c1_infl_disclose_rate) on engagement via candidate
            mediators, cluster-bootstrapped. Adapts the pipeline's §9.6-9.7 design
            to the CURRENT construct (c1_infl_disclose_rate, not c1_disclose_surprise)
            and reghdfe FE + influencer clustering, at 200 reps (fast).
            Predictions (dual-process): authenticity mediates RETWEETS (Mech 1);
            persuasion suppresses REPLIES (Mech 2); cross-paths ~ 0.
Inputs:     ${derived}/IM_Data_step5_zscored.dta
Outputs:    ${tables}/Mediation_propensity.csv
Run order:  Standalone (paste-safe; no /// continuations). ~10-20 min.
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
    display as error "step5_zscored.dta not found."
    exit 601
}
global derived "${root}/Derived"
global tables  "${root}/Tables"
use "${derived}/IM_Data_step5_zscored.dta", clear

global controls "z_posts z_wordcount z_followers z_following topic_probsbeauty4 topic_probshealthandwellness4 topic_probsnutrition4 topic_probsfashion4 multi_brand"
global fes_abs  "influencercode month hour"
global prior    "BM_handhash_NN1000valprior_cum"

capture drop c1_disclosed
capture drop c1_infl_disclose_rate
gen byte c1_disclosed = (BM_handhash_NN1000val == 1)
bysort influencercode: egen double c1_infl_disclose_rate = mean(c1_disclosed)

* Program returns the indirect effect ab for globals MED (mediator), OUT (outcome), K (class)
capture program drop _med
program define _med, rclass
    quietly reghdfe ${MED} ib0.BM_handhash_NN1000val##c.c1_infl_disclose_rate $controls, absorb($fes_abs)
    scalar a = _b[${K}.BM_handhash_NN1000val#c.c1_infl_disclose_rate]
    quietly reghdfe ${OUT} ib0.BM_handhash_NN1000val##c.c1_infl_disclose_rate ${MED} $controls $prior, absorb($fes_abs)
    scalar b = _b[${MED}]
    return scalar ab = a * b
    return scalar a  = a
    return scalar b  = b
end

tempname M
postfile `M' str22 mediator str16 outcome int class double a double b double ab double se_ab double z using "${tables}/Mediation_propensity.dta", replace

* Mechanism 1 (authenticity -> retweets); Mechanism 2 (persuasion -> replies); + cross tests.
* Each row: "mediatorvar outcomevar class". Skips gracefully if a mediator var is absent.
foreach spec in "authentic_stdM ln_retweetcount 2" "authentic_stdM ln_retweetcount 3" "z_FirstPerson_Ratio ln_retweetcount 2" "authentic_stdM ln_replycount 2" "z_pv_score ln_replycount 2" "z_pv_score ln_replycount 3" "persuasion ln_replycount 2" "z_pv_score ln_retweetcount 2" {
    tokenize "`spec'"
    global MED "`1'"
    global OUT "`2'"
    global K   "`3'"
    capture confirm variable ${MED}
    if _rc {
        display as error "  [skip] mediator ${MED} not found"
        continue
    }
    quietly _med
    scalar pa = r(a)
    scalar pb = r(b)
    scalar pab = r(ab)
    capture bootstrap ab=r(ab), reps(200) cluster(influencercode) seed(20260701) nodots: _med
    if _rc {
        post `M' ("${MED}") ("${OUT}") (${K}) (pa) (pb) (pab) (.) (.)
    }
    else {
        scalar seab = _se[ab]
        scalar zab  = pab/seab
        post `M' ("${MED}") ("${OUT}") (${K}) (pa) (pb) (pab) (seab) (zab)
        display as result "  ${MED} -> ${OUT} (class ${K}): ab=" %7.4f pab "  se=" %7.4f seab "  z=" %5.2f zab
    }
}
postclose `M'

preserve
    use "${tables}/Mediation_propensity.dta", clear
    gen str3 sig = ""
    replace sig = "*"   if abs(z)>1.645 & !missing(z)
    replace sig = "**"  if abs(z)>1.96
    replace sig = "***" if abs(z)>2.576
    display as result _newline "=== INDIRECT EFFECTS (a*b), cluster-bootstrapped ==="
    list mediator outcome class a b ab se_ab z sig, noobs sepby(outcome)
    export delimited using "${tables}/Mediation_propensity.csv", replace
restore

display _newline as result "Mediation complete → ${tables}/Mediation_propensity.csv"
display as text "Predictions: authenticity mediates RETWEETS (class 2 ab>0); persuasion"
display as text "suppresses REPLIES (class 2 ab<0); cross-paths ~ 0 (discriminant)."
