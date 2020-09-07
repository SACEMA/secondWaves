
# enables overriding all of the `?=` defined variables
# not required to be present
-include local.Makefile

# where is the input / output results?
# these definitions for local testing
# typically want a shared folder, e.g. dropbox
DATADIR ?= data
OUTDIR ?= results
FIGDIR ?= fig

default: ${OUTDIR}/consolidated.rds

# convenience definitions
R = Rscript $^ $@
Rstar = Rscript $^ $* $@

# make the data directory if not already present
${DATADIR} ${OUTDIR} ${FIGDIR}:
	mkdir -p $@

${DATADIR}/owid.rds: get_owid.R | ${DATADIR}
	${R}

${DATADIR}/isos.csv: get_isos.R ${DATADIR}/owid.rds
	${R}

isosetup: ${DATADIR}/isos.csv ${OUTDIR}
	while read line; do mkdir -p "${OUTDIR}/$${line}"; done < $<

${OUTDIR}/%/result.rds: analyze.R ${DATADIR}/owid.rds featureFunctions.R thresholds.json | isosetup
	${Rstar}

${OUTDIR}/%/stats.rds: extract.R ${OUTDIR}/%/result.rds
	${R}

#${FIGDIR}/%.png: visualize.R ${OUTDIR}/%/result.rds | ${FIGDIR}
#	${R}

${FIGDIR}/%.png: alt_visualize.R ${OUTDIR}/%/result.rds | ${FIGDIR}
	${R}


setup: isosetup

DEMOISOS ?= GBR AUS KEN JPN ZAF PAK USA ESP SWE SVN PRT CZE PER ISR FIN BEL DNK FRA NLD NGA BRA IND SRB SGP KOR MUS LVA DEU
ALLISOS ?= $(shell cat ${DATADIR}/isos.csv)

demo: $(patsubst %,${OUTDIR}/%/result.rds,${ALLISOS})

demofigs: $(patsubst %,${FIGDIR}/%.png,${ALLISOS})

demostats: $(patsubst %,${OUTDIR}/%/stats.rds,${ALLISOS})

.PRECIOUS: ${OUTDIR}/%/stats.rds ${OUTDIR}/%/result.rds

${OUTDIR}/consolidated.rds: consolidate.R $(wildcard results/*/stats.rds)
	Rscript $< ${OUTDIR} $@

cleanisosetup:
	rm -rf ${OUTDIR}