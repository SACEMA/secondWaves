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

### 2020-09-04

- Errors
    - AUS (Error: Insufficient values in manual scale. 4 needed but only 3 provided.)
- Methodology notes
    - We're not actually interested in valleys; on decline, we're interested in (1) point where first wave ends and (2) the trough (minimum value after the first peak but before the end of the second wave) - TODO PRIORITY
    - We should look at sensitivity and specificity of upticks as indicators for second waves and upswings / resurgences - TODO
    - We should adjust `window` and `threshold` of `find_upswing()` so that an upswing is definitionally always preceeded by an uptick - TODO
    - Redefine uptick to be `find_upswing(x, 5, 5)` - TODO
    - Incorporate positivity trends into defiitions of upswing and uptick - TODO
    - Consolidation step - TODO
        - Classify dynamics for each country (typology) - second wave, resurgence, contrulled (MUS), other (how to describe LVA, PRT? simmering?)
        - For second waves: what proportion of the time is the peak of the second wave higher than the peak of the first wave? (will be a minimum as all others are indeterminate until end of second wave)
        - Time from first wave peak to end of first wave?
        - Time from from end of first wave to trough?
        - Time from first wave peak / end of first wave / trough to meeting second wave criterion?
        - Time from first post-trough uptick to meeting the second wave criterion?
        - How many upticks between end of first wave / trough and meeting the second wave criterion?
        - How good an indicator of upswings / resurgences / second waves are upticks defined based on case numbers? positivity?
        - What was the size of the first trough relative to the size of the first peak?
        - How many total cases per million population by the end of the first wave?
        - How many total tests per thousand populaiton by the end of the first wave?
- Figure notes (parameters: change = 15, minVal = 1, m = 14, len = 5, window = 7, threshold = 5)
    - Visualization: try putting a bar to indicate 'this period of time you are in an upswing / above / etc' - TODO
    - Visualization: add indicator for end of wave/s - TODO
    - BEL: look into above definition - seems to occur at < 1/3 the first peak
    - CZE: example of major and minor resurgences (if we want to define these)
    - DNK: example of a second wave without a preceeding uptick (? - may change with uptick definition; second wave is preceded by an upswing)
    - FIN: very jaggedy - seems to have a spurious upswing - is it also an uptick?; increase at the end would probably qualify as an 'uptick' in any non-technical assessment but doesn't meet our criteria (does mean upswing criteria at the moment; revisit this as definitions change)
    - ISR: example of a resurgence during the second wave
    - KOR: example with upswings much earlier than second wave (uptick as it takes off? revisit with definition changes); should these be considered examples of false positive indicators? is there also a false negative? may need to define time windows - TODO
    - LVA: very jaggedy - a couple of short upswings (may disappear with definition adjustments); do they meet uptick definition?
    - NLD: look into above definition - seems to occur at < 1/3 the first peak
    - PAK: has ZZ_NA in legend but no marker - TODO
    - PER: possible spurious upswing; does it disappear with different criteria? is it also an uptick?
    - PRT: jaggedy - has 3 peaks that aren't wave peaks and various short upswings
    - SGP: example of a minor resurgence (I think)
    - SRB: when second wave drops below 1/3 of first wave 'above' definition no longer met but doesn't really have a meaning; change viz?
    - SVN: look into above definition - seems to occur at < 1/3 the first peak; complicated second wave
    - SWE: nice example of upticks indicating resurgences (and has both major and minor resurgences); should the minor resurgence come up as a peak? It doesn't but why? is it because upswing dominates peak (if they occur at the same point)? - TODO
