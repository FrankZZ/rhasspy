#!/usr/bin/env bash
set -e

if [[ -z "$1" ]]; then
    echo "Directory required as first argument"
    exit 1
fi

DIR="$1"
download_dir="${DIR}/download"

if [[ "$2" = "--delete" ]]; then
    rm -rf "${download_dir}"
fi

mkdir -p "${download_dir}"

echo "Downloading Spanish (es) profile (sphinx)"

#------------------------------------------------------------------------------
# Acoustic Model
#------------------------------------------------------------------------------

acoustic_url='https://github.com/synesthesiam/rhasspy-profiles/releases/download/v1.0-es/cmusphinx-es-5.2.tar.gz'
acoustic_file="${download_dir}/cmusphinx-es-5.2.tar.gz"
acoustic_output="${DIR}/acoustic_model"

if [[ ! -s "${acoustic_file}" ]]; then
    echo "Downloading acoustic model (${acoustic_url})"
    curl -sSfL -o "${acoustic_file}" "${acoustic_url}"
fi

echo "Extracting acoustic model (${acoustic_file})"
rm -rf "${acoustic_output}"
tar -C "${DIR}" -xf "${acoustic_file}" "cmusphinx-es-5.2/model_parameters/voxforge_es_sphinx.cd_ptm_4000/" && mv "${DIR}/cmusphinx-es-5.2/model_parameters/voxforge_es_sphinx.cd_ptm_4000/" "${acoustic_output}" && rm -rf "${DIR}/cmusphinx-es-5.2"

#------------------------------------------------------------------------------
# G2P
#------------------------------------------------------------------------------

g2p_url='https://github.com/synesthesiam/rhasspy-profiles/releases/download/v1.0-es/es-g2p.tar.gz'
g2p_file="${download_dir}/es-g2p.tar.gz"
g2p_output="${DIR}/g2p.fst"

if [[ ! -s "${g2p_file}" ]]; then
    echo "Downloading g2p model (${g2p_url})"
    curl -sSfL -o "${g2p_file}" "${g2p_url}"
fi

echo "Extracting g2p model (${g2p_file})"
tar --to-stdout -xzf "${g2p_file}" 'g2p.fst' > "${g2p_output}"

#------------------------------------------------------------------------------
# Dictionary
#------------------------------------------------------------------------------

dict_output="${DIR}/base_dictionary.txt"
echo "Extracting dictionary (${acoustic_file})"
tar --to-stdout -xf "${acoustic_file}" "cmusphinx-es-5.2/etc/voxforge_es_sphinx.dic" > "${dict_output}"

#------------------------------------------------------------------------------
# Language Model
#------------------------------------------------------------------------------

lm_output="${DIR}/base_language_model.txt"
echo "Extracting language model (${acoustic_file})"
tar --to-stdout -xf "${acoustic_file}" "cmusphinx-es-5.2/etc/es-20k.lm.gz" | zcat > "${lm_output}"

#------------------------------------------------------------------------------
# Snowboy
#------------------------------------------------------------------------------

snowboy_models=("snowboy.umdl" "computer.umdl")
for model_name in "${snowboy_models[@]}"; do
    model_output="${DIR}/${model_name}"
    if [[ ! -s "${model_output}" ]]; then
        model_url="https://github.com/Kitt-AI/snowboy/raw/master/resources/models/${model_name}"
        echo "Downloading ${model_output} (${model_url})"
        curl -sSfL -o "${model_output}" "${model_url}"
    fi
done
