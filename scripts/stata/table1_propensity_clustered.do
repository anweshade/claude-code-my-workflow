/*------------------------------------------------------------
File:       table1_propensity_clustered.do
Purpose:    Finalize Table 1 — brand-class x influencer disclosure propensity,
            estimated with reghdfe + influencer-CLUSTERED SEs (so gamma_1 gets a
            proper clustered SE, not the SUR-robust one). Identifies all 3 classes.
Inputs:     ${derived}/IM_Data_step5_zscored.dta
Outputs:    ${tables}/Table1_propensity_clustered.{tex,csv}
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
global prior    "BM_handhash_NN1000valprior_cum"

* Rebuild the disclosure-propensity moderator (influencer mean disclosure rate)
capture drop c1_disclosed
capture drop c1_infl_disclose_rate
gen byte c1_disclosed = (BM_handhash_NN1000val == 1)
bysort influencercode: egen double c1_infl_disclose_rate = mean(c1_disclosed)
label variable c1_infl_disclose_rate "Influencer disclosure propensity"

* Also a per-SD (standardized) version for interpretable magnitudes
capture drop z_prop
egen double z_prop = std(c1_infl_disclose_rate)
label variable z_prop "Disclosure propensity (per SD)"

eststo clear
quietly reghdfe ln_retweetcount ib0.BM_handhash_NN1000val##c.c1_infl_disclose_rate $controls $prior, absorb($fes_abs) vce(cluster influencercode)
eststo m_rt
display as result "Retweets — joint test of class x propensity:"
test 1.BM_handhash_NN1000val#c.c1_infl_disclose_rate 2.BM_handhash_NN1000val#c.c1_infl_disclose_rate 3.BM_handhash_NN1000val#c.c1_infl_disclose_rate

quietly reghdfe ln_replycount ib0.BM_handhash_NN1000val##c.c1_infl_disclose_rate $controls $prior, absorb($fes_abs) vce(cluster influencercode)
eststo m_rp
display as result "Replies — joint test of class x propensity:"
test 1.BM_handhash_NN1000val#c.c1_infl_disclose_rate 2.BM_handhash_NN1000val#c.c1_infl_disclose_rate 3.BM_handhash_NN1000val#c.c1_infl_disclose_rate

* Per-SD versions (interpretable magnitudes), clustered.
* NOTE: do NOT `eststo clear` here — it would wipe m_rt/m_rp needed by esttab below.
quietly reghdfe ln_retweetcount ib0.BM_handhash_NN1000val##c.z_prop $controls $prior, absorb($fes_abs) vce(cluster influencercode)
eststo z_rt
quietly reghdfe ln_replycount ib0.BM_handhash_NN1000val##c.z_prop $controls $prior, absorb($fes_abs) vce(cluster influencercode)
eststo z_rp

local kraw 1.BM_handhash_NN1000val#c.c1_infl_disclose_rate 2.BM_handhash_NN1000val#c.c1_infl_disclose_rate 3.BM_handhash_NN1000val#c.c1_infl_disclose_rate
local kstd 1.BM_handhash_NN1000val#c.z_prop 2.BM_handhash_NN1000val#c.z_prop 3.BM_handhash_NN1000val#c.z_prop

esttab m_rt m_rp using "${tables}/Table1_propensity_clustered.tex", replace booktabs label keep(`kraw') b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N N_clust, fmt(%9.0fc %9.0fc) labels("Observations" "Clusters")) mtitles("ln(1+retweets)" "ln(1+replies)") nonotes addnote("Influencer-clustered SEs. Controls, prior, influencer/month/hour FE. Raw disclosure-rate scale.")
esttab m_rt m_rp z_rt z_rp using "${tables}/Table1_propensity_clustered.csv", replace keep(`kraw' `kstd') b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N N_clust, fmt(%9.0fc %9.0fc)) mtitles("RT_raw" "RP_raw" "RT_perSD" "RP_perSD")

display _newline as result "Wrote Table1_propensity_clustered.{tex,csv}."
display as text "Compare gamma_1 (disclosed x propensity) clustered SE to the SUR value (-3.91 replies)."
display as text "Per-SD columns give interpretable magnitudes on the disclosure-rate scale."
