#!/usr/bin/env bash
#
# Updates ./sweden-zipcode.csv based on changes from the Swedish tax office.
# https://www.skatteverket.se/offentligaaktorer/informationsutbyte/navethamtauppgifteromfolkbokforing/nyheter/2023/nyheter/postnummerandringarden6mars2023.5.48cfd212185efbb440b1852.html
#
# ./update-from-tax-office.sh

file="./sweden-zipcode.csv"
changes="./sweden-zipcode-changes.csv"

cp $file "${file}.bak"

# For each line in CHANGES
while IFS=',' read -ra line
do
    # Remove if the line containers "STÄNGS".
    if [[ " ${line[*]} " =~ ' STÄNGS ' ]]; then
        echo "removing ${line[0]}"
        sed -i'.orig' "/^${line[0]}/d" "${file}"
    fi

    # Add if the line containers "NYTT".
    if [[ " ${line[*]} " =~ ' NYTT ' ]] && ! grep -q "${line[3]},${line[5]}" "${file}"; then
        echo "adding ${line[0]}"
        echo "${line[3]},${line[5]}" >> "${file}"
    fi
done < "$changes"

sort -o $file $file

echo "Duplicates:"
uniq -d $file

echo "Diff:"
diff $file "${file}.bak"

rm -f "${file}.bak"
