#!/bin/bash

set -xe

if [ -d gentoo/.git ]; then
    git -C gentoo pull
else
    git clone https://github.com/gentoo/gentoo.git
fi

GENTOO_GIT_REPO="$(realpath ./gentoo)"

#RE_MASK='(acct-user|acct-group|dev-java|dev-haskell|dev-ros|dev-ml|ros-meta)'

eix -# --in-overlay gentoo > pkgs.txt

rm -rf 0_riscv.txt 1_arm64.txt 1_arm64_ver.txt 2_none.txt README.md
./keyworded pkgs.txt

for pkg in $(cat 1_arm64.txt 2_none.txt | sort | uniq); do
    dep_pkgs=$(zbt ls -p default/linux/riscv/20.0/rv64gc/lp64d/desktop/plasma/systemd $pkg)
    dep_pkgs_cnt=$(echo "$dep_pkgs" | wc -l)
    dep_pkgs_oneline=$(echo "$dep_pkgs" | tr '\n' ' ')
    eix_info=$(eix -cp $pkg 2>/dev/null)
    echo -e "$pkg\t$dep_pkgs_cnt\t$eix_info\t$dep_pkgs_oneline" >> README.md
done

sort -rnk2 -o README.md README.md

git add 0_riscv.txt 1_arm64.txt 1_arm64_ver.txt 2_none.txt pkgs.txt README.md
git commit -m "update $(date '+%F %H:%M')"
git push
