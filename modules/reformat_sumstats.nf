//Add rsids to the variant information file
process join_rsids_var_info {
    tag "${qtl_subset}"
    container = 'quay.io/eqtlcatalogue/qtlmap:v20.05.1'

    input:
    tuple val(qtl_subset), file(var_info)
    file(rsid_map)

    output:
    tuple val(qtl_subset), file(var_info), file("${var_info.simpleName}.var_info_rsid.tsv.gz")

    script:
    """
    join_variant_info.py \\
        -v $var_info \\
        -r $rsid_map \\
        -o ${var_info.simpleName}.var_info_rsid.tsv.gz
    """
}

process reformat_sumstats {
    tag "${qtl_subset}"
    container = 'quay.io/eqtlcatalogue/qtlmap:v20.05.1'

    input:
    tuple val(qtl_subset), file(summ_stats), file(var_info), file(rsid_map), file(phenotype_metadata), file(median_tpm)

    output:
    tuple val(qtl_subset), file("${qtl_subset}.nominal.sorted.tsv.gz")

    script:
    """
    join_variant_info.py \
        -s $summ_stats \
        -v $var_info \
        -r $rsid_map \
        -p $phenotype_metadata \
        -m $median_tpm \
        -o ${qtl_subset}.nominal.sorted.tsv.gz
    """
}

/*
 * Tabix-index summary statistics files
 */
process tabix_index {
    tag "${qtl_subset}"
    publishDir "${params.outdir}/sumstats", mode: 'copy'
    container = 'quay.io/eqtlcatalogue/qtlmap:v20.05.1'

    input:
    tuple val(qtl_subset), file(sumstats_file)

    output:
    tuple val(qtl_subset), file("${qtl_subset}.all.tsv.gz"), file("${qtl_subset}.all.tsv.gz.tbi")

    script:
    """
    zcat $sumstats_file | bgzip > ${qtl_subset}.nominal.sorted.bgzip.tsv.gz
    mv ${qtl_subset}.nominal.sorted.bgzip.tsv.gz ${qtl_subset}.all.tsv.gz
    tabix -s2 -b3 -e3 -S1 -f ${qtl_subset}.all.tsv.gz
    """
}