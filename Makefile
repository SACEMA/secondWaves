
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

${OUTDIR}/%/result.rds: analyze.R ${DATADIR}/owid.rds featureFunctions.R | isosetup
	${Rstar}

${FIGDIR}/%.png: visualize.R ${OUTDIR}/%/result.rds | ${FIGDIR}
	${R}

setup: isosetup

demo: $(patsubst %,${OUTDIR}/%/result.rds,KEN JPN ZAF PAK USA ESP)

demofigs: $(patsubst %,${FIGDIR}/%.png,KEN JPN ZAF PAK USA ESP SWE SVN PRT) \
	$(patsubst %,${FIGDIR}/%.png,CZE PER ISR FIN AUS BEL DNK FRA NLD SGP KOR MUS LVA)

${OUTDIR}/consolidated.rds: consolidate.R $(wildcard results/*/result.rds)
	Rscript $< ${OUTDIR} $@
	