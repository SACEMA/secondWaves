# SACEMA COVID-19 Second Waves Repository

## ZigZag

We will look into the [ZigZag](https://school.stockcharts.com/doku.php?id=technical_indicators:zigzag) approach for identifying waves and have identified 2 R packages that implement this approach:

- {TTR} package
    - https://www.rdocumentation.org/packages/TTR/versions/0.24.0/topics/ZigZag
    - `install.packages('TTR')`
- {btutils} packages
    - https://www.r-bloggers.com/a-better-zigzag/
    - `install.packages('btutils', repos="http://R-Forge.R-project.org")`
    
## Notes

### 2020-09-05

 - need resurge annotation; e.g. CZE
 - above annotation should persist through new peak; e.g. ISR
 - not quite right post labelling e.g. LVA, PAK
 - "peak" labelling wrong for PRT, (maybe SGE?)
 - second wave resurgence in SVE and ISR

- Errors
    - UGA (Error in roll_sum_impl(x, as.integer(n), as.numeric(weights), as.integer(by),: negative length vectors are not allowed)
- Methodology notes
    - Sometimes 'above' seems to be defined based on the second peak rather than the first (see BEL, NLD, SVN, DNK - second wave occurs too early, at 1/3 of the second peak?) - TODO 
    - We're not actually interested in valleys; on decline, we're interested in (1) point where first wave ends and (2) the trough (minimum value after the first peak but before the end of the second wave) - TODO PRIORITY
    - Define resurgence based on co-occurence of uptick and upswing prior to end of wave - TODO
    - Incorporate positivity trends into defiitions of upswing and uptick - DONE; Carl please check that you're happy with this (analyze.R lines 62-69) - TODO
    - Consolidation step - TODO
        - Classify dynamics for each country (typology) - second wave, resurgence, apparently controlled (MUS), other (how to describe LVA, PRT? simmering?)
        - For second waves: what proportion of the time is the peak of the second wave higher than the peak of the first wave? (will be a minimum as all others are indeterminate until end of second wave)
        - Time from first wave peak to end of first wave?
        - Time from from end of first wave to trough?
        - Time from first wave peak / end of first wave / trough to meeting second wave criterion?
        - Time from first post-trough uptick to meeting the second wave criterion?
        - How many upticks between end of first wave / trough and meeting the second wave criterion?
        - How good an indicator of upswings / resurgences / second waves are upticks defined based on case numbers? positivity?
        - What was the size of the first trough relative to the size of the first peak?
        - How many total cases / deaths per million population by the end of the first wave?
        - How many total tests per thousand population by the end of the first wave?
- Figure notes (parameters: change = 15, minVal = 1, m = 14, len = 5, window = 8, threshold = 6)
    - Visualization: second wave range should include 'above' and those below 1/3 of first peak but above 1/10 of second peak (until/unless resurgence) - TODO
    - BEL: look into above definition - seems to occur at < 1/3 the first peak
    - CZE: example of major and minor resurgences (if we want to define these)
    - DEU: characterization probably the same as LVA (?), FIN - 'post-wave' (vigilance warranted)
    - DNK: example of a second wave without a preceeding uptick (? - may change with uptick definition; second wave is preceded by an upswing)
    - ESP: new upswing defintion less clear
    - FIN: very jaggedy - seems to have a spurious upswing - is it also an uptick?; increase at the end would probably qualify as an 'uptick' in any non-technical assessment but doesn't meet our criteria (does mean upswing criteria at the moment; revisit this as definitions change)
    - ISR: example of a resurgence during the second wave
    - JPN: poor lead time from indicators
    - KOR: example with upswings much earlier than second wave; should these be considered examples of false positive indicators? is there also a false negative? may need to define time windows - TODO
    - LVA: very jaggedy - how would we characterize what's going on here? slow burn? post-wave?
    - NGA: might be an example where adding positivity indicator (upticks) important; jaggedy without resurgences (but multiple non-wave peaks); probably indicative of poor surveillance, but how would we classify it - just as still in first wave (seems appropriate, actually)
    - NLD: look into above definition - seems to occur at < 1/3 the first peak (1/3 of second peak?); example of a (very minor) resurgence after which first wave ends - is this some form of false positive?
    - PRT: jaggedy - has 3 peaks that aren't wave peaks and 2 short upswings and a resurgence
    - SGP: example of a minor resurgence (or 2); example of upticks and upswing in positivity while cases going down
    - SRB: when second wave drops below 1/3 of first wave 'above' definition no longer met but doesn't really have a meaning; change viz? (see also: AUS, others)
    - SVN: look into above definition - seems to occur at < 1/3 the first peak; example of major resurgence in second wave; example of a false negative (or is this just because of weirdness with 1/3 definition?)
    - SWE: nice example of upticks indicating a resurgence (with current upswing definition, minor resurgence is dependent of including positivity)
    - USA: nice example of upticks indicating a resurgence
