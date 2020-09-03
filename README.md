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

# 2020-09-03

- Errors
    - DEU, CHL (Error: missing value where TRUE/FALSE needed)
    - ITA
- Methodology notes
    - We're not actually interested in valleys; on decline, we're interested in (1) point where first wave ends and (2) the trough (minimum value after the first peak but before the end of the second wave)
    - We should look at sensitivity and specificity of upticks as indicators for second waves; currently they are used to define resurgence but maybe this should change??
    - May want to try increasing `m` to 14; `minVal` should probably be 0; look at different values for `change`?
- Figure notes (parameters: change = 15, minVal = 2, m = 10, len = 5)
    - FIN: very jaggedy - gives 2 peaks that shouldn't be; neither is big enough to meet the second wave criterion; increase at the end would probably qualify as an 'uptick' in any non-technical assessment but doesn't meet our criteria
    - FRA: jaggedy - gives 2 peaks that shouldn't be; neither is big enough to meet the second wave criterion, so maybe this is ok but we need to add a check for this; example of a second wave without a preceeding uptick
    - KOR: example with upticks much earlier than second wave (and one as it takes off); should these be considered examples of false positive indicators; NB: one of the **upticks** disappeared when `m` set to 14... this should not happen
    - ISR: example of a resurgence during the second wave
    - DNK: example of a second wave without a preceeding uptick
    - LVA: very jaggedy - gives 4 peaks that shouldn't be but none meet second wave criterion (add check); one of these peaks removed when `m` set to 14
    - PER: has an intermediate peak as part of resurgence that shouldn't be there; maybe try increasing `change`? increasing `m` (eg to 14) could also help and might get rid of some of the other spurious peaks as well (NB: there is an uptick that preceeds the spurious peak so maybe it's just a minor resurgence?); intermediate peak removed when `m` set to 14
    - PRT: jaggedy - has 3 peaks that aren't wave peaks; 2 follow upticks so could be considered resurgence peaks; third could be 
    - SGP: extra intermediate peak - could be example of a resurgence that was missed by the uptick indicator, but doesn't work with current definition (intermediate peak remvoed when `m` set to 14)
    - SVN: jaggedy and complicated; uptick followed by messy 3-peaked second wave (one of these peaks removed when `m` set to 14)
    - SWE: nice example of upticks indicating resurgences (and has both major and minor resurgences)
    - DEU: uptick seems to be going back down; is there a valley that's also an uptick?
    