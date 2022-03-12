#!/bin/bash

set -xe

GENTOO_GIT_REPO="${GENTOO_GIT_REPO:-/var/db/repos/gentoo}"
GENTOO_GIT_REPO="$(realpath $GENTOO_GIT_REPO)"

#eix -# | grep -Ev '(acct-user|acct-group)' > pkgs.txt

#./keyworded pkgs.txt

rm -rf README.md

mkdir -p tmp
pushd tmp

set +e
for pkg in $(cat ../1_arm64.txt ../2_none.txt | sort | uniq); do
    mkdir -p $(dirname $pkg);
    nattka --repo "$GENTOO_GIT_REPO" make-package-list --arch riscv "$pkg" > $pkg
done
set -e

for pkg in $(ls -S */*); do
    echo "================================================================================" >> ../README.md

    echo "$pkg need keyword $(wc --lines $pkg | cut -d' ' -f1) packages" >> ../README.md
    cat "$pkg" >> ../README.md

    echo "$(eix $pkg 2>/dev/null)" >> ../README.md
done
popd

git add 0_riscv.txt 1_arm64.txt 1_arm64_ver.txt 2_none.txt pkgs.txt README.md
git commit -m "update $(date '+%F %H:%M')"
git push
